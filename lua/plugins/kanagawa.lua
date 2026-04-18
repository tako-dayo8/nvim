return {
  "rebelot/kanagawa.nvim",
  name = "kanagawa",
  priority = 1000,
  -- enabled = false,
  config = function()
    -- Default options:
    require('kanagawa').setup({
        compile = false,             -- enable compiling the colorscheme
        undercurl = true,            -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true},
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,         -- do not set background color
        dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
        terminalColors = true,       -- define vim.g.terminal_color_{0,17}
        colors = {                   -- add/modify theme and palette colors
            palette = {
                fujiWhite = "#E6C384",  -- 文字を黄色っぽく
                dragonWhite = "#E6C384",
                autumnYellow = "#E6C384",
                myYellowBG = "#FFF4C1", -- 🌟 背景用の黄色 (少し淡い黄色)
            },
            theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        overrides = function(colors) -- add/modify highlights
            return {
                -- 🌟 背景を黄色に設定！
                -- Normal = { fg = colors.fujiWhite, bg = colors.palette.myYellowBG },
                -- NormalNC = { fg = colors.fujiWhite, bg = colors.palette.myYellowBG },
            }
        end,
        -- theme = "dragon",              -- Load "wave" theme
        background = {               -- map the value of 'background' option to a theme
            dark = "dragon",           -- try "dragon" !
            light = "lotus"
        },
    })

    -- setup must be called before loading
    vim.cmd("colorscheme kanagawa-dragon")
  end
}
