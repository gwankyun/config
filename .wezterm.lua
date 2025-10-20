-- 引入wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

-- 保存会话状态到文件
local function save_session()
    local state = mux.serialize_state()
    local session_file = wezterm.home_dir .. '/.wezterm_session'

    local file = io.open(session_file, 'w')
    if file then
        file:write(state)
        file:close()
        wezterm.log_info('Session saved to ' .. session_file)
    else
        wezterm.log_error('Failed to save session')
    end
end

-- 从文件恢复会话
local function restore_session()
    local session_file = wezterm.home_dir .. '/.wezterm_session'
    local file = io.open(session_file, 'r')

    if file then
        local state = file:read('*all')
        file:close()

        local success, err = pcall(function()
            mux.unserialize_state(state)
        end)

        if success then
            wezterm.log_info('Session restored from ' .. session_file)
        else
            wezterm.log_error('Failed to restore session: ' .. err)
        end
    else
        wezterm.log_info('No session file found at ' .. session_file)
    end
end

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

-- 在配置中添加键绑定
config.keys = {
    -- 保存会话（Ctrl+Shift+S）
    {
        key = 's',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function()
            save_session()
        end)
    },

    -- 恢复会话（Ctrl+Shift+R）
    {
        key = 'r',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function()
            restore_session()
        end)
    },
}

-- 在WezTerm启动时自动恢复会话
wezterm.on('gui-startup', function()
    -- 检查是否有保存的会话文件
    local session_file = wezterm.home_dir .. '/.wezterm_session'
    if io.open(session_file, 'r') then
        restore_session()
    end
end)

return config
