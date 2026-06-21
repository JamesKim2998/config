-- https://github.com/mrcjkb/rustaceanvim
-- Rust LSP. Owns rust-analyzer — do NOT add it to mason-lspconfig.
return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false, -- self-manages ft-based lazy loading
	init = function()
		vim.g.rustaceanvim = {
			server = {
				-- Pin to `stable`'s rust-analyzer: our rust-toolchain.toml pins lack
				-- the component, so the bare rustup proxy errors "Unknown binary".
				cmd = { "rustup", "run", "stable", "rust-analyzer" },
				default_settings = {
					-- clippy instead of `cargo check` for richer on-save diagnostics
					["rust-analyzer"] = { check = { command = "clippy" } },
				},
			},
		}
	end,
}
