-- Lazy.nvim plugin spec for lewis6991/gitsigns.nvim with a vim.keymap.set-based on_attach.
-- Put this file in your lazy plugins folder (e.g. lua/plugins/) or paste into your lazy setup list.

return {
    {
        "lewis6991/gitsigns.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("gitsigns").setup({
                -- (defaults from the README; keep or customize as you like)
                signs = {
                    add = { text = "│" },
                    change = { text = "│" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                    untracked = { text = "┆" },
                },
                signcolumn = true,
                numhl = false,
                linehl = false,
                word_diff = false,

                watch_gitdir = { follow_files = true },
                attach_to_untracked = true,

                current_line_blame = false,
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = "eol",
                    delay = 1000,
                    ignore_whitespace = false,
                },
                current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",

                sign_priority = 6,
                update_debounce = 100,
                status_formatter = nil,
                max_file_length = 40000,

                preview_config = {
                    border = "single",
                    style = "minimal",
                    relative = "cursor",
                    row = 0,
                    col = 1,
                },

                yadm = { enable = false },

                -- on_attach with explicit vim.keymap.set mappings (buffer-local)
                on_attach = function(bufnr)
                    local gs = require("gitsigns")
                    local function bufmap(mode, lhs, rhs, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        -- sensible defaults; override by passing opts
                        if opts.noremap == nil then
                            opts.noremap = true
                        end
                        if opts.silent == nil then
                            opts.silent = true
                        end
                        vim.keymap.set(mode, lhs, rhs, opts)
                    end

                    -- Navigation: ]c / [c behave with diff windows (:Gvdiff) and with gitsigns otherwise.
                    bufmap("n", "]c", function()
                        if vim.wo.diff then
                            return "]c"
                        end
                        vim.schedule(function()
                            gs.next_hunk()
                        end)
                        return "<Ignore>"
                    end, { expr = true })

                    bufmap("n", "[c", function()
                        if vim.wo.diff then
                            return "[c"
                        end
                        vim.schedule(function()
                            gs.prev_hunk()
                        end)
                        return "<Ignore>"
                    end, { expr = true })

                    -- Actions
                    bufmap("n", "<leader>hs", gs.stage_hunk)
                    bufmap("n", "<leader>hS", gs.stage_buffer)
                    bufmap("n", "<leader>hr", gs.reset_hunk)
                    bufmap("n", "<leader>hR", gs.reset_buffer_index)
                    bufmap("n", "<leader>hb", gs.blame_line)
                    bufmap("n", "<leader>hB", function()
                        gs.blame_line({ full = true })
                    end)
                    bufmap("n", "<leader>ht", gs.toggle_current_line_blame)
                    bufmap("n", "<leader>hd", gs.diffthis)
                    bufmap("n", "<leader>hD", function()
                        gs.diffthis("~")
                    end)

                    -- Visual mappings for staging/resetting ranges
                    bufmap("v", "<leader>hs", function()
                        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end)
                    bufmap("v", "<leader>hr", function()
                        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end)

                    -- Preview, toggle deleted, etc.
                    bufmap("n", "<leader>hp", gs.preview_hunk)
                    bufmap("n", "<leader>tb", gs.toggle_deleted)
                    bufmap("n", "<leader>hP", gs.toggle_current_line_blame) -- example extra binding

                    -- Text object for hunk
                    bufmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")

                    -- Optional: expose some commands as buffer-local functions if you like
                    -- e.g. bufmap('n', '<leader>hu', gs.undo_stage_hunk)
                end,
            })
        end,
    },
}
