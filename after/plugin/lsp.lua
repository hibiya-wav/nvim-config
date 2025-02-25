-- Required for basedpyright configuration
local nvim_lsp = require("lspconfig")
local util = nvim_lsp.util
local path = util.path

-- Initialize lsp-zero
local lsp_zero = require('lsp-zero')

-- Function to get Python path
local function get_python_path()
    if vim.env.VIRTUAL_ENV then
        return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
    end
    return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

-- Configure lua language server
lsp_zero.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = {"vim"}
            }
        }
    }
})

-- Configure lua language server for neovim
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    require('cmp_nvim_lsp').default_capabilities()
)

-- LSP Attach autocmd
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = {buffer = event.buf}
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    end
})

-- Setup Mason
require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        'basedpyright',
        'sqlls',
        'terraformls',
        'yamlls',
        'jdtls',
        'bashls',
        'clangd',
        'eslint',
        'lua_ls',
    },
    handlers = {
        lsp_zero.default_setup,
    },
})

-- Configure basedpyright
nvim_lsp.basedpyright.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.document_formatting = false
        client.server_capabilities.semanticTokensProvider = nil
    end,
    capabilities = lspconfig_defaults.capabilities,
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "standard",
                diagnosticSeverityOverrides = {
                    reportAny = false,
                    reportMissingTypeArgument = false,
                    reportMissingTypeStubs = false,
                    reportUnknownArgumentType = false,
                    reportUnknownMemberType = false,
                    reportUnknownParameterType = false,
                    reportUnknownVariableType = false,
                    reportUnusedCallResult = false,
                },
                inlayHints = {
                    variableTypes = true,
                    functionReturnTypes = true,
                    callArgumentNames = true,
                    genericTypes = true,
                }
            },
        },
        python = {},
    },
    before_init = function(_, config)
        local python_path = get_python_path()
        config.settings.python.pythonPath = python_path
        vim.notify(python_path)
    end,
})

-- Configure completion
local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = {
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
}

cmp.setup({
    sources = {
        {name = "nvim_lsp"},
        {name = "buffer"},
    },
    mapping = cmp_mappings,
    -- You can add more configuration options here if needed
})

-- Final setup
lsp_zero.setup()

