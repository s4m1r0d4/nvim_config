require('rc.set')
vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

require('rc.remap')

vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
end)

lsp.nvim_workspace()

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

require('lspconfig').clangd.setup({
    cmd = { "/usr/bin/clangd" },
    arguments = { "--query-driver=/usr/bin/g++" }
})

require 'lspconfig'.gopls.setup {
    settings = {
        gopls = {
            env = {
                GOFLAGS = "-tags=windows,linux,unittest"
            }
        },
    },
    on_attach = function(client, bufnr)
        print('go go go PROYECTO')
        -- Golang likes tabs...
        vim.opt.expandtab = false
    end
}

require('lspconfig').cmake.setup {}

-- Enable (broadcasting) snippet capability for completion
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
require('lspconfig').html.setup {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
    init_options = {
        configurationSection = { "html", "css", "javascript" },
        embeddedLanguages = {
            css = true,
            javascript = true
        },
        provideFormatter = true
    },
    single_file_support = true
}

require('lspconfig').omnisharp.setup {
    enable_roslyn_analyzers = true,
    organize_imports_on_format = false,
    enable_import_completion = false,
    analyze_open_documents_only = false,
    filetypes = { "cs", "vb", "razor" }
}

require('lspconfig').angularls.setup {}

require('lspconfig').cssls.setup {}

require('lspconfig').rust_analyzer.setup {}

vim.filetype.add({
    filename = {
        ['domesticaweb.online'] = 'nginx'
    },
})
require('lspconfig').nginx_language_server.setup {
    on_attach = function(client, bufnr)
        print('go go go PROYECTO')
        -- Golang likes tabs...
        vim.opt.expandtab = false
    end
}

-- require('Comment').setup()
require('ts_context_commentstring').setup {}
vim.gskip_ts_context_commentstring_module = true

require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'css', 'html', 'javascript',
        'lua', 'php', 'python', 'tsx',
        'typescript', 'vim', 'go'
    },

    context_commentstring = {
        enable = true,
    },
}

require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
})

-- Add additional capabilities supported by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'pyright', 'tsserver', 'lua_ls', 'angularls', 'cssls', 'rust_analyzer' }
for _, langsp in ipairs(servers) do
    lspconfig[langsp].setup {
        -- on_attach = my_custom_on_attach,
        capabilities = capabilities,
    }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require('cmp')

local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ['<C-f>'] = cmp.mapping(function(fallback)
        if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        else
            fallback()
        end
    end, { "i", "s" })
})

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp_mappings,
    sources = cmp.config.sources({
        { name = 'nvim_lsp', group_index = 2 },
        { name = 'luasnip',  group_index = 2 },
        { name = 'path',     group_index = 2 },
        { name = 'buffer',   keyword_length = 5, group_index = 2 },
        { name = "copilot",  group_index = 2 }
    }),
    experimental = {
        ghost_text = false
    }
})

require('luasnip.loaders.from_vscode').lazy_load()

-- load snippets from path/of/your/nvim/config/my-cool-snippets
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets/angular" } })

lsp.setup()
