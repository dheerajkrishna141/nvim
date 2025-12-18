return {

    "mfussenegger/nvim-jdtls",
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function(args)
                require("plugins.jdtls.jdtls_setup").setup()
            end,
        })
    end,
}
