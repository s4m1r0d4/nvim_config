return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- disable rtp plugin, as we only need its queries for mini.ai
          -- In case other textobject modules are enabled, we will load them
          -- once nvim-treesitter is loaded
          require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
          load_textobjects = true
        end,
      },
      {
         'JoosepAlviste/nvim-ts-context-commentstring',
      }
    },
    cmd = { "TSUpdateSync" },
    opts = {
        ensure_installed = { "vimdoc", "javascript", "typescript", "c", "lua", "go", "gomod", "gosum"},

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        highlight = {
            -- `false` will disable the whole extension
            enable = true,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        }
    },

    config = function(_, opts)
         if type(opts.ensure_installed) == "table" then
           ---@type table<string, boolean>
           local added = {}
           opts.ensure_installed = vim.tbl_filter(function(lang)
             if added[lang] then
               return false
             end
             added[lang] = true
             return true
           end, opts.ensure_installed)
         end
         require("nvim-treesitter.configs").setup(opts)
     end
}
