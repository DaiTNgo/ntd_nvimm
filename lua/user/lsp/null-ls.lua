local null_ls_status_ok, null_ls = pcall(require, "null-ls")

-- local linters = require("lvim.lsp.null-ls.linters")
-- linters.setup({
-- 	{ command = "flake8", filetypes = { "python" } },
-- 	{
-- 		-- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
-- 		command = "shellcheck",
-- 		---@usage arguments to pass to the formatter
-- 		-- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
-- 		extra_args = { "--severity", "warning" },
-- 	},
-- 	{
-- 		command = "codespell",
-- 		---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
-- 		filetypes = { "javascript", "python" },
-- 	},
-- })

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
if not null_ls_status_ok then
	return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

-- https://github.com/prettier-solidity/prettier-plugin-solidity
null_ls.setup({
	debug = false,
	sources = {
		formatting.prettier.with({
			extra_filetypes = { "toml" },
			extra_args = { "--single-quote", "--jsx-single-quote" },
		}),
		formatting.stylua,
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
					vim.lsp.buf.format({ buffer = bufnr })
				end,
			})
		end
	end,
})
