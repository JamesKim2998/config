-- bullets.vim: numbered lists and basic bullet continuation
return {
	"bullets-vim/bullets.vim",
	ft = "markdown",
	init = function()
		vim.g.bullets_checkbox_markers = " x"
		vim.g.bullets_nested_checkboxes = 1
		vim.g.bullets_set_mappings = 0
		vim.g.bullets_custom_mappings = {
			{ "nmap", "gN", "<Plug>(bullets-renumber)" },
			{ "vmap", "gN", "<Plug>(bullets-renumber)" },
		}
	end,
}
