return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc", "html", "css",
  		},
  	},
  },

  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
    opts = {
      window = {
        width = 82, -- 80 + a bit for signs/numbers
        options = {
          wrap = true,
          linebreak = true,
          breakindent = true,
        },
      },
    },
  },

  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("orgmode").setup({
        -- NOTE: Comment out the agenda setup to speed up the startup time.
        -- org_agenda_files = "~/Documents/OrgMode/**/*",
        -- org_default_notes_file = "~/Documents/OrgMode/Inbox.org",
        org_startup_folded = "showeverything",
      })
      Org.indent_mode()
    end,
  },

}

