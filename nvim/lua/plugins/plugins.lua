return {
  -- appearance
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}, },
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = 'VeryLazy',
    keys = {
      -- go to N-th buffer
      { "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", desc = "Buffer 1" },
      { "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", desc = "Buffer 2" },
      { "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", desc = "Buffer 3" },
      { "<leader>0", "<Cmd>BufferLineGoToBuffer -1<CR>", desc = "Last buffer" },
      -- cycle
      { "<Tab>",     "<Cmd>BufferLineCycleNext<CR>",    desc = "Next buffer" },
      { "<S-Tab>",   "<Cmd>BufferLineCyclePrev<CR>",    desc = "Prev buffer" },
      -- move
      { "<leader><Right>", "<Cmd>BufferLineMoveNext<CR>", desc = "Move right" },
      { "<leader><Left>",  "<Cmd>BufferLineMovePrev<CR>", desc = "Move left" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        custom_filter = function(buf_number)
          local buf_name = vim.fn.bufname(buf_number)
          return not buf_name:match("NvimTree") -- hide NvimTree from tabline
        end,
      },
    },
  },

  -- git
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { "lewis6991/gitsigns.nvim" },

  -- navigation
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    end,
  },

  -- autocomplete
  { "github/copilot.vim", lazy = false },

  -- nvim-tree
  {
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
  },
}
