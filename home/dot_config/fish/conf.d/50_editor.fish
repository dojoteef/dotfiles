if type -q kak
    set -gx EDITOR kak
    abbr -a kak-ide kak -e ide
else if type -q vim
    set -gx EDITOR vim
end

set -gx VISUAL $EDITOR
