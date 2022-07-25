local wezterm = require 'wezterm'

return {
    color_scheme = "Zenburn",
    hide_tab_bar_if_only_one_tab = true,
    swallow_mouse_click_on_pane_focus = true,
    swallow_mouse_click_on_window_focus = true,
    keys = {
        {
            key="d", mods="CMD",
            action=wezterm.action.SplitHorizontal{domain="CurrentPaneDomain"},
        },
        {
            key="d", mods="CMD|SHIFT",
            action=wezterm.action.SplitVertical{domain="CurrentPaneDomain"},
        },
        {
            key="Enter", mods="CMD|SHIFT",
            action=wezterm.action.TogglePaneZoomState,
        },
        {
            key="LeftArrow", mods="CMD|SHIFT",
            action=wezterm.action.ActivatePaneDirection("Left"),
        },
        {
            key="RightArrow", mods="CMD|SHIFT",
            action=wezterm.action.ActivatePaneDirection("Right"),
        },
        {
            key="UpArrow", mods="CMD|SHIFT",
            action=wezterm.action.ActivatePaneDirection("Up"),
        },
        {
            key="DownArrow", mods="CMD|SHIFT",
            action=wezterm.action.ActivatePaneDirection("Down"),
        },
        {
            key="]", mods="CMD",
            action=wezterm.action.ActivatePaneDirection("Next"),
        },
        {
            key="[", mods="CMD",
            action=wezterm.action.ActivatePaneDirection("Prev"),
        },
        {
            key="w", mods="CMD",
            action=wezterm.action.CloseCurrentPane{confirm=true},
        },
        {
            key = '_', mods = 'CMD|SHIFT',
            action = wezterm.action.PaneSelect
        },
        {
            key = '+', mods = 'CMD|SHIFT',
            action = wezterm.action.PaneSelect{mode='SwapWithActive'},
        },
    }
}
