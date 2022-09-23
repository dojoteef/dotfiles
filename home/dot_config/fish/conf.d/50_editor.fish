if type -q kak
    set -gx EDITOR kak
    abbr -a kak-ide kak -e ide
    # Requires Skim.app to have the following
    # Command: sh
    # Arguments: -c "echo 'evaluate-commands -verbatim -client %opt{jumpclient} -- edit -- %file %line' | kak -p synctex"
    abbr -a kak-tex kak -e "'ide synctex'"
else if type -q vim
    set -gx EDITOR vim
end

set -gx VISUAL $EDITOR
