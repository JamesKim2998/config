-- vim-markdown: indentexpr for proper == behavior on nested lists
-- Other features disabled (bullets.vim handles list continuation)
return {
	"preservim/vim-markdown",
	ft = "markdown",
	init = function()
		-- Disable all keymaps (bullets.vim + markdown-lists.lua handle these)
		vim.g.vim_markdown_no_default_key_mappings = 1
		-- Disable features handled by bullets.vim
		vim.g.vim_markdown_auto_insert_bullets = 0
		vim.g.vim_markdown_new_list_item_indent = 0
		-- Disable folding (use treesitter or native)
		vim.g.vim_markdown_folding_disabled = 1
		-- Disable conceal (render-markdown.nvim handles this)
		vim.g.vim_markdown_conceal = 0
		vim.g.vim_markdown_conceal_code_blocks = 0
		-- Useful extras
		vim.g.vim_markdown_frontmatter = 1 -- YAML frontmatter
		vim.g.vim_markdown_strikethrough = 1 -- ~~strikethrough~~
	end,
}
