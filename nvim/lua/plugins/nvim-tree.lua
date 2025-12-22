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


    -- Auto-close NvimTree when quitting the last real buffer
    vim.api.nvim_create_autocmd("QuitPre", {
      group = vim.api.nvim_create_augroup("AutoCloseNvimTree", { clear = true }),
      callback = function()
        local wins = vim.api.nvim_list_wins()
        local tree_wins = {}
        local floating_wins = {}

        for _, w in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(w)
          local ft = vim.bo[buf].filetype
          if ft == "NvimTree" then
            table.insert(tree_wins, w)
          end
          if vim.api.nvim_win_get_config(w).relative ~= "" then
            table.insert(floating_wins, w)
          end
        end

        -- If this is the last real window, close nvim-tree first
        if #wins - #floating_wins - #tree_wins == 1 then
          for _, w in ipairs(tree_wins) do
            vim.api.nvim_win_close(w, true)
          end
        end
      end,
    })
  end,
}

