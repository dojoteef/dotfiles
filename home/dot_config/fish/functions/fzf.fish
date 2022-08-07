function fzf --wraps fzf
    if type -q fd
        FZF_DEFAULT_COMMAND="fd --type f --hidden" command fzf $argv
    else
        FZF_DEFAULT_COMMAND="find . --type f ! -path '*/.git*'" command fzf $argv
    end
end
