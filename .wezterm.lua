local wezterm = require 'wezterm'
local act = wezterm.action

return {
  -- 見た目
  color_scheme = "Catppuccin Mocha",
  font = wezterm.font("JetBrains Mono"),
  font_size = 13.0,

  -- カーソル
  default_cursor_style = "BlinkingBlock",

  -- タブバー
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,

  -- ウィンドウ透明度
  window_background_opacity = 0.9,

  -- 起動シェル（PowerShell）
  default_prog = { "pwsh.exe" },

  -- キーバインド
  keys = {
    -- 分割
    { key = "Enter", mods = "ALT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "-", mods = "ALT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },

    -- タブ操作
    { key = "t", mods = "ALT", action = act.SpawnTab "CurrentPaneDomain" },
    { key = "d", mods = "ALT", action = act.CloseCurrentTab { confirm = false } },

    -- ペイン移動
    { key = 'h', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Right' },

    -- タブ移動
    { key = "1", mods = "ALT", action = act.ActivateTab(0) },
    { key = "2", mods = "ALT", action = act.ActivateTab(1) },
    { key = "3", mods = "ALT", action = act.ActivateTab(2) },

    -- フォントサイズ
    { key = "+", mods = "ALT|SHIFT", action = act.IncreaseFontSize },
    { key = "-", mods = "ALT|SHIFT", action = act.DecreaseFontSize },

    -- コピペ
    { key = "c", mods = "CTRL", action = act.CopyTo "Clipboard" },
    { key = "v", mods = "CTRL", action = act.PasteFrom "Clipboard" },
  },
}
