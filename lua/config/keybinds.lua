vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)
vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({
        lsp_format = "fallback",
    })
end, { desc = "Format current file" })

vim.keymap.set("n", "<leader>cp", function()
    if vim.g.copilot_enabled == 1 then
        vim.g.copilot_enabled = 0
        print("Copilot disabled")
    else
        vim.g.copilot_enabled = 1
        print("Copilot enabled")
    end
end, { desc = "Toggle Copilot" })
