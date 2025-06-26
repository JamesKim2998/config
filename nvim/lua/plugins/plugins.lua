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

  -- git
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { "lewis6991/gitsigns.nvim" },

  -- autocomplete
  { "github/copilot.vim", lazy = false },
}

