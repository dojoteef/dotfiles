local wezterm = require 'wezterm'

return {
    color_scheme = "Zenburn",
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
            key="w", mods="CMD",
            action=wezterm.action.CloseCurrentPane{confirm=true},
        },
    }
}
