# wezterm.kak
# Provides basic WezTerm integration for Kakoune
# Inspired by Kakoune's included windowing modules

provide-module wezterm %{

# ensure that we're running on WezTerm
evaluate-commands %sh{
    [ -z "${kak_opt_windowing_modules}" ] || [ "$TERM_PROGRAM" = "WezTerm" ] || echo 'fail WezTerm not detected'
}

define-command wezterm-terminal-vertical -params 1.. -shell-completion -docstring '
    wezterm-terminal-vertical <program> [<arguments>]: create a new terminal as a WezTerm pane
    The current pane is split into two, top and bottom
    The program passed as argument will be executed in the new terminal' \
%{
    wezterm-cli-impl split-pane --cwd %val{client_env_PWD} -- %arg{@}
}

define-command wezterm-terminal-horizontal -params 1.. -shell-completion -docstring '
    wezterm-terminal-horizontal <program> [<arguments>]: create a new terminal as a WezTerm pane
    The current pane is split into two, left and right
    The program passed as argument will be executed in the new terminal' \
%{
    wezterm-cli-impl split-pane --horizontal --cwd %val{client_env_PWD} -- %arg{@}
}

define-command wezterm-terminal-window -params 1.. -shell-completion -docstring '
    wezterm-terminal-window <program> [<arguments>]: create a new terminal as a WezTerm window
    The program passed as argument will be executed in the new terminal' \
%{
    wezterm-cli-impl spawn --new-window --cwd %val{client_env_PWD} -- %arg{@}
}

define-command wezterm-terminal-tab -params 1.. -shell-completion -docstring '
    wezterm-terminal-tab <program> [<arguments>]: create a new terminal as a WezTerm tab
    The program passed as argument will be executed in the new terminal' \
%{
    wezterm-cli-impl spawn --cwd %val{client_env_PWD} -- %arg{@}
}

# TODO
# define-command wezterm-focus -params ..1 -client-completion -docstring '
#   wezterm-focus [<client>]: focus the given client
#   If no client is passed then the current one is used' \
# %{}

define-command -hidden wezterm-cli-impl -params .. -docstring '
    wezterm [<flags>] [<options>] [<subcommand>]: run WezTerm' \
%{
    nop %sh{
        wezterm cli "$@" < /dev/null > /dev/null 2>&1
    }
}

alias global terminal wezterm-terminal-horizontal
}

set-option -add current windowing_modules 'wezterm'
