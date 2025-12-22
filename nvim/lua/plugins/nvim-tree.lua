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
  -- runs **before** the plugin is loaded
  init = function()
    -- disable netrw early
    vim.g.loaded_netrw       = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  opts = {},
  config = function(_, opts)
    -- Responsive width: 20% of editor, min 8, max 20
    local function get_width()
      local width = math.floor(vim.o.columns * 0.2)
      return math.max(8, math.min(width, 20))
    end

    opts.view = { width = get_width() }
    require("nvim-tree").setup(opts)

    -- Update width on window resize
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        local view = require("nvim-tree.view")
        if view.is_visible() then
          view.View.width = get_width()
          view.resize()
        end
      end,
    })

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

