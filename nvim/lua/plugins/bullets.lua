-- bullets.vim: list continuation (CR, o, O) and renumbering (gN)
-- Handles: - bullet, 1. numbered, - [ ] checkbox continuation
return {
	"bullets-vim/bullets.vim",
	ft = "markdown",
	init = function()
		vim.g.bullets_enable_in_empty_buffers = 0
		-- Enable checkbox markers
		vim.g.bullets_checkbox_markers = " x"
		vim.g.bullets_nested_checkboxes = 1
		-- Let bullets.vim handle all mappings
		vim.g.bullets_set_mappings = 1
	end,
}
