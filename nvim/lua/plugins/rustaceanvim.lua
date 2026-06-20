-- https://github.com/mrcjkb/rustaceanvim
-- Rust LSP (rust-analyzer + clippy). Owns rust-analyzer — do NOT add it to mason-lspconfig.
-- Configured via vim.g; rust-analyzer comes from rustup (~/.cargo/bin, on PATH).
return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false, -- self-manages ft-based lazy loading
	init = function()
		vim.g.rustaceanvim = {
			server = {
				default_settings = {
					-- clippy instead of `cargo check` for richer on-save diagnostics
					["rust-analyzer"] = { check = { command = "clippy" } },
				},
			},
		}
	end,
}
