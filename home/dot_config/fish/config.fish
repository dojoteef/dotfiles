if status is-interactive
    # Commands to run in interactive sessions can go here
    if type -q wezterm
        wezterm shell-completion --shell fish | source
    end
end
