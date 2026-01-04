-- https://github.com/nvim-neo-tree/neo-tree.nvim
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<C-n>", "<Cmd>Neotree toggle<CR>", desc = "Toggle Neo-tree" },
    { "<leader>e", "<Cmd>Neotree focus<CR>", desc = "Focus Neo-tree" },
  },
  -- Disable netrw before plugins load
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  config = function()
    -- Responsive width: 20% of editor, min 8, max 20
    local function get_width()
      local width = math.floor(vim.o.columns * 0.2)
      return math.max(8, math.min(width, 20))
    end

    require("neo-tree").setup({
      -- Close when it's the last window
      close_if_last_window = true,
      -- Popup border style
      popup_border_style = "rounded",
      -- Enable git status icons
      enable_git_status = true,
      -- Enable diagnostics icons
      enable_diagnostics = true,

      -- Sources available: filesystem only
      sources = { "filesystem" },
      source_selector = {
        winbar = false,
        statusline = false,
      },

      -- Default component configs (shared across sources)
      default_component_configs = {
        indent = {
          indent_size = 1, -- Compact indentation
          with_markers = true,
          with_expanders = true,
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
        },
        modified = {
          symbol = "●",
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "➜",
            untracked = "★",
            ignored = "◌",
            unstaged = "✗",
            staged = "✓",
            conflict = "",
          },
        },
      },

      -- Window configuration
      window = {
        position = "left",
        width = get_width(),
        mappings = {
          -- Basic operations
          ["<space>"] = "toggle_node",
          ["<cr>"] = "open",
          ["<esc>"] = "cancel",
          ["P"] = { "toggle_preview", config = { use_float = true } },
          ["s"] = "open_split",
          ["v"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["a"] = { "add", config = { show_path = "relative" } },
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy",
          ["m"] = "move",
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
        },
      },

      -- Filesystem source configuration
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { ".git", "node_modules", ".DS_Store" },
        },
        follow_current_file = {
          enabled = true, -- Auto-reveal current file
          leave_dirs_open = false,
        },
        group_empty_dirs = true, -- Collapse empty directories
        hijack_netrw_behavior = "open_current",
        use_libuv_file_watcher = true, -- Auto-refresh on file changes
      },

      -- Event handlers for better UX
      event_handlers = {
        -- Equalize window sizes when opening/closing
        {
          event = "neo_tree_window_after_open",
          handler = function(args)
            if args.position == "left" or args.position == "right" then
              vim.cmd("wincmd =")
            end
          end,
        },
        {
          event = "neo_tree_window_after_close",
          handler = function(args)
            if args.position == "left" or args.position == "right" then
              vim.cmd("wincmd =")
            end
          end,
        },
      },
    })

    -- Auto-open on startup (skip claude-prompt temp files)
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        if data.file:match("claude%-prompt%-.-%.md$") then
          return
        end
        local real_file = vim.fn.filereadable(data.file) == 1
        local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
        if real_file or no_name then
          vim.cmd("Neotree show")
        end
      end,
    })

    -- Resize neo-tree on window resize
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        local state = require("neo-tree.sources.manager").get_state("filesystem")
        if state and state.win then
          vim.api.nvim_win_set_width(state.win, get_width())
        end
      end,
    })
  end,
}
