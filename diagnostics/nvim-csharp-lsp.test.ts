/**
 * nvim C# LSP (csharp_ls) tests
 * Run: bun test nvim-csharp-lsp.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { $ } from "bun";
import {
  NvimRunner, NeovimClient, fileExists,
  assertLspAttached, assertHoverWorks, assertMappingExists,
  assertCompletionAvailable, assertInlayHintsEnabled, assertDiagnosticsWork,
} from "./lib";

const TEST_DIR = "/tmp/nvim-csharp-test";
const TEST_FILE = `${TEST_DIR}/Program.cs`;
const SOCKET_PATH = "/tmp/nvim-csharp-diag.sock";
const LSP_NAME = "csharp_ls";

const TEST_CONTENT = `using System;

namespace TestApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello, World!");
            var message = "test";
            Console.WriteLine(message);
        }

        static int Add(int a, int b)
        {
            return a + b;
        }
    }
}
`;

const CSPROJ = `<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
</Project>
`;

const SLN = `Microsoft Visual Studio Solution File, Format Version 12.00
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "TestApp", "TestApp.csproj", "{00000000-0000-0000-0000-000000000001}"
EndProject
`;

const nvim = new NvimRunner();
let client: NeovimClient;

beforeAll(async () => {
  // Pre-flight checks
  const masonPath = `${process.env.HOME}/.local/share/nvim/mason/bin/csharp-ls`;
  if (!await fileExists(masonPath)) {
    throw new Error("csharp-ls not installed. Run :Mason and install csharp-language-server");
  }

  const dotnet = await $`dotnet --version`.nothrow().quiet();
  if (dotnet.exitCode !== 0) {
    throw new Error(".NET SDK not installed. Run: brew install dotnet");
  }

  // Setup project
  await $`rm -rf ${TEST_DIR} && mkdir -p ${TEST_DIR}`.nothrow();
  await Bun.write(TEST_FILE, TEST_CONTENT);
  await Bun.write(`${TEST_DIR}/TestApp.csproj`, CSPROJ);
  await Bun.write(`${TEST_DIR}/TestApp.sln`, SLN);

  client = await nvim.start(SOCKET_PATH, TEST_FILE, TEST_DIR);
  await nvim.setFiletype("cs");
}, 20000);

afterAll(async () => {
  await nvim.cleanup(TEST_DIR);
});

describe("csharp_ls LSP", () => {
  it("attaches to buffer", async () => {
    await assertLspAttached(nvim, LSP_NAME);
  }, 35000);

  it("hover shows documentation", async () => {
    await client.command("9");
    await client.command("normal! ^w");
    await assertHoverWorks(client);
  }, 10000);

  it("gd mapped to definition", async () => {
    await assertMappingExists(client, "gd", /lsp|trouble|definition/i);
  });

  it("<leader>ca mapped to code action", async () => {
    await assertMappingExists(client, "<leader>ca", /code_action|lsp/);
  });

  it("completion provider available", async () => {
    await assertCompletionAvailable(client);
  });

  it("inlay hints enabled", async () => {
    await assertInlayHintsEnabled(client);
  });

  it("diagnostics reported for invalid code", async () => {
    await assertDiagnosticsWork(client, "invalid code here;");
  }, 10000);
});
