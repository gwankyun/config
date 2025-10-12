-- 引入wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- 創建配置
local config = wezterm.config_builder()

-- 默認程序
config.default_prog = { 'pwsh' }

-- 窗口設置
config.initial_cols = 120
config.initial_rows = 25
config.font_size = 14

-- 顏色方案
local color_scheme = ''
color_scheme = 'Catppuccin Mocha'
-- color_scheme = 'Solarized Light'
config.color_scheme = color_scheme

-- 光標樣式
local default_cursor_style = 'BlinkingBlock'
default_cursor_style = 'BlinkingBar'
config.default_cursor_style = default_cursor_style

-- 窗口背景透明度，0至1，越小越透明
config.window_background_opacity = 0.9

-- 類似終端的行為
-- https://github.com/wezterm/wezterm/discussions/3541#discussioncomment-5633570
config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "NONE",
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ""
            if has_selection then
                window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
            end
        end),
    },
}

return config
