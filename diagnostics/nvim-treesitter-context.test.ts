/**
 * nvim-treesitter-context plugin E2E tests
 * Run: bun test nvim-treesitter-context.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { NvimRunner, NeovimClient } from "./lib";

const TS_FILE = "/tmp/nvim-ctx-test.ts";
const SOCKET_PATH = "/tmp/nvim-ts-context.sock";

const nvim = new NvimRunner();
let client: NeovimClient;

// TypeScript file with nested structure for context testing
const TS_CONTENT = `class UserService {
  private users: Map<string, User> = new Map();

  async createUser(name: string, email: string): Promise<User> {
    // comment line 5
    // comment line 6
    // comment line 7
    // comment line 8
    // comment line 9
    // comment line 10
    // comment line 11
    // comment line 12
    // comment line 13
    // comment line 14
    // comment line 15
    // comment line 16
    // comment line 17
    // comment line 18
    // comment line 19
    // comment line 20 - cursor here should show context
    const user = { id: crypto.randomUUID(), name, email };
    this.users.set(user.id, user);
    return user;
  }
}

interface User {
  id: string;
  name: string;
  email: string;
}
`;

beforeAll(async () => {
  await Bun.write(TS_FILE, TS_CONTENT);
  client = await nvim.start(SOCKET_PATH, TS_FILE);
  await Bun.sleep(3000); // Wait for lazy plugins to fully load
}, 20000);

afterAll(async () => {
  await nvim.cleanup(TS_FILE);
});

describe("treesitter parser for typescript", () => {
  it("parser is available", async () => {
    const hasParser = await client.call("luaeval", [
      "pcall(vim.treesitter.get_parser, 0, 'typescript')"
    ]) as boolean;
    expect(hasParser).toBe(true);
  });

  it("treesitter highlighting is active", async () => {
    const active = await client.call("luaeval", [
      "vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil"
    ]) as boolean;
    expect(active).toBe(true);
  });
});

describe("treesitter-context sticky header", () => {
  it("plugin is loaded", async () => {
    const loaded = await client.call("luaeval", [
      "package.loaded['treesitter-context'] ~= nil"
    ]) as boolean;
    expect(loaded).toBe(true);
  });

  it("creates context window when cursor is deep in a function", async () => {
    // Move to line 20 (deep inside createUser method)
    await client.command("20");
    await client.command("normal! zt");
    await client.command("doautocmd CursorMoved"); // Trigger context update
    await Bun.sleep(500);

    // treesitter-context creates floating windows for context display
    // These windows have empty filetype but contain code context
    const contextWindowExists = await client.call("luaeval", [
      `(function()
        local main_buf = vim.api.nvim_get_current_buf()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          -- Context windows are different from main buffer and have nofile buftype
          if buf ~= main_buf and vim.bo[buf].buftype == 'nofile' then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
            if #lines > 0 and lines[1]:match('class') then
              return true
            end
          end
        end
        return false
      end)()`
    ]) as boolean;

    expect(contextWindowExists).toBe(true);
  });

  it("context window shows class/function signature", async () => {
    await client.command("20");
    await client.command("normal! zt");
    await client.command("doautocmd CursorMoved");
    await Bun.sleep(500);

    // Get the content of the context window
    const contextContent = await client.call("luaeval", [
      `(function()
        local main_buf = vim.api.nvim_get_current_buf()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if buf ~= main_buf and vim.bo[buf].buftype == 'nofile' then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            if #lines > 0 then
              return table.concat(lines, '\\n')
            end
          end
        end
        return ''
      end)()`
    ]) as string;

    // Should contain class or function name
    expect(contextContent).toMatch(/UserService|createUser/);
  });

  it("context window disappears at top of file", async () => {
    // Move to line 1 (top of file, no context needed)
    await client.command("1");
    await client.command("doautocmd CursorMoved");
    await Bun.sleep(500);

    // At top of file, context windows should be closed or empty
    const hasContextContent = await client.call("luaeval", [
      `(function()
        local main_buf = vim.api.nvim_get_current_buf()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if buf ~= main_buf and vim.bo[buf].buftype == 'nofile' then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            if #lines > 0 and lines[1] ~= '' then
              return true
            end
          end
        end
        return false
      end)()`
    ]) as boolean;

    expect(hasContextContent).toBe(false);
  });
});
