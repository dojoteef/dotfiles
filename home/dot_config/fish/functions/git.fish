if type -q hub
    function git --wraps hub
        hub $argv
    end
end
