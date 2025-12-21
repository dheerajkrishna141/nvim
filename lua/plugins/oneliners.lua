return {
	{
		"tpope/vim-fugitive",
	},
	{ -- Git plugin
		"tpope/vim-fugitive",
	},
	{ -- Show historical versions of the file locally
		"mbbill/undotree",
	},
	{
		"github/copilot.vim",
	},
	{ -- Show CSS Colors
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({})
		end,
	},
	{ "akinsho/git-conflict.nvim", version = "*", config = true },
}
