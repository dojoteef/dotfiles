function git --wraps git
    if type -q hub
        hub $argv
    else
        command git $argv
    end
end