return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<C-n>", "<Cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
  },
  opts = function(_, opts)
    opts.on_attach = function(bufnr)
      local api = require("nvim-tree.api")
      api.config.mappings.default_on_attach(bufnr)
    end
  end,
  -- runs **before** the plugin is loaded
  init = function()
    -- disable netrw early
    vim.g.loaded_netrw       = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  config = function()
    require("nvim-tree").setup {}


    -- auto-open on startup
    local function open_nvim_tree(data)
      -- skip for claude-prompt temp files
      if data.file:match("claude%-prompt%-.-%.md$") then
        return
      end

      -- open for an empty buffer or a real file
      local real_file = vim.fn.filereadable(data.file) == 1
      local no_name   = data.file == "" and vim.bo[data.buf].buftype == ""

      if real_file or no_name then
        local api = require("nvim-tree.api")
        api.tree.toggle({ focus = false, find_file = true })
      end
    end

    vim.api.nvim_create_autocmd("VimEnter", { callback = open_nvim_tree })


    -- Auto-close Neovim if NvimTree is the last window
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("AutoCloseNvimTree", { clear = true }),
      callback = function()
        local api = require("nvim-tree.api")
        local view = require("nvim-tree.view")
        if #vim.api.nvim_list_tabpages() == 1 and #vim.api.nvim_list_wins() == 1 and view.is_visible() then
          vim.cmd("quit")
        end
      end,
    })
  end,
}

