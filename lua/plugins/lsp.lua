return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-buffer",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lua",
        -- Snippets
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local autoformat_filetypes = {
            "lua",
            "dart",
        }
        -- Create a keymap for vim.lsp.buf.implementation
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client then
                    return
                end
                if vim.tbl_contains(autoformat_filetypes, vim.bo.filetype) then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = args.buf,
                        callback = function()
                            vim.lsp.buf.format({
                                formatting_options = { tabSize = 4, insertSpaces = true },
                                bufnr = args.buf,
                                id = client.id,
                            })
                        end,
                    })
                end
            end,
        })

        -- Add borders to floating windows
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.lsp.handlers["textDocument/signatureHelp"] =
            vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

        -- Configure error/warnings interface
        vim.diagnostic.config({
            virtual_text = true,
            severity_sort = true,
            float = {
                style = "minimal",
                border = "rounded",
                header = "",
                prefix = "",
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "✘",
                    [vim.diagnostic.severity.WARN] = "▲",
                    [vim.diagnostic.severity.HINT] = "⚑",
                    [vim.diagnostic.severity.INFO] = "»",
                },
            },
        })

        local lspconfig_defaults = require("lspconfig").util.default_config
        lspconfig_defaults.capabilities = vim.tbl_deep_extend(
            "force",
            lspconfig_defaults.capabilities,
            require("cmp_nvim_lsp").default_capabilities()
        )

        -- This is where you enable features that only work
        -- if there is a language server active in the file
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event)
                local opts = { buffer = event.buf }

                vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
                vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
                vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
                vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
                vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
                vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
                vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
                vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
                vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
                vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
                vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
                vim.keymap.set("n", "<leader>co", function()
                    vim.lsp.buf.code_action({
                        apply = true,
                        context = {
                            only = { "source.organizeImports" },
                        },
                    })
                end, { buffer = event.buf, desc = "Organize Imports" })
            end,
        })

        require("mason").setup({})
        require("mason-lspconfig").setup({

            ensure_installed = {
                "lua_ls",
                "intelephense",
                "ts_ls",
                "eslint",
                "pyright",
                "jdtls",
            },
            handlers = {
                function(server_name)
                    if server_name == "lua_ls" then
                        return
                    end -- avoid starting with {}
                    if server_name == "jdtls" then
                        return
                    end -- avoid starting with {}
                    vim.lsp.config[server_name].setup({})
                end,

                lua_ls = function()
                    vim.lsp.config.lua_ls.setup({
                        settings = {
                            Lua = {
                                runtime = {
                                    version = "LuaJIT",
                                },
                                diagnostics = {
                                    globals = { "vim" },
                                },
                                workspace = {
                                    library = { vim.env.VIMRUNTIME },
                                },
                            },
                        },
                    })
                end,
            },
        })

        -- Setup dartls separately (not managed by Mason)
        vim.lsp.config.dartls = {
            cmd = { "/home/kratosfury/develop/flutter/bin/dart", "language-server", "--protocol=lsp" },
            filetypes = { "dart" },
            root_markers = { "pubspec.yaml" },
            capabilities = lspconfig_defaults.capabilities,
            init_options = {
                onlyAnalyzeProjectsWithOpenFiles = false,
                suggestFromUnimportedLibraries = true,
                closingLabels = true,
                outline = true,
                flutterOutline = true,
            },
            settings = {
                dart = {
                    completeFunctionCalls = true,
                    showTodos = true,
                    enableSnippets = true,
                    lineLength = 80,
                },
            },
        }
        vim.lsp.enable("dartls")

        local cmp = require("cmp")

        require("luasnip.loaders.from_vscode").lazy_load()

        vim.opt.completeopt = { "menu", "menuone", "noselect" }

        cmp.setup({
            preselect = "item",
            completion = {
                completeopt = "menu,menuone,noinsert",
            },
            window = {
                documentation = cmp.config.window.bordered(),
            },
            sources = {
                { name = "path" },
                { name = "nvim_lsp" },
                { name = "buffer",  keyword_length = 3 },
                { name = "luasnip", keyword_length = 2 },
            },
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            formatting = {
                fields = { "abbr", "menu", "kind" },
                format = function(entry, item)
                    local n = entry.source.name
                    if n == "nvim_lsp" then
                        item.menu = "[LSP]"
                    else
                        item.menu = string.format("[%s]", n)
                    end
                    return item
                end,
            },
            mapping = cmp.mapping.preset.insert({
                -- confirm completion item
                ["<CR>"] = cmp.mapping.confirm({ select = false }),

                -- scroll documentation window
                ["<C-f>"] = cmp.mapping.scroll_docs(5),
                ["<C-u>"] = cmp.mapping.scroll_docs(-5),

                -- toggle completion menu
                ["<C-Space>"] = cmp.mapping.complete(),

                -- navigate completion menu with arrow keys
                ["<Down>"] = cmp.mapping.select_next_item({ behavior = "select" }),
                ["<Up>"] = cmp.mapping.select_prev_item({ behavior = "select" }),

                -- navigate to next snippet placeholder
                ["<C-d>"] = cmp.mapping(function(fallback)
                    local luasnip = require("luasnip")

                    if luasnip.jumpable(1) then
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                -- navigate to the previous snippet placeholder
                ["<C-b>"] = cmp.mapping(function(fallback)
                    local luasnip = require("luasnip")

                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
        })
    end,
}
