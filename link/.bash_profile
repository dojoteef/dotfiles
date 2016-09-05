if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

if is_ubuntu; then
  # Pulled from https://gist.github.com/dylon/5281572
  # This is for what I would consider a standard setup, where TTY's 1 -- 6 are
  # "linux" terminals and TTY's 7+ are reserved for X windows.  You should adjust
  # it to your setup, accordingly.
  #
  # ::: Important ::: You must have both fbterm and tmux installed and on your
  # path for this to work.
  virtual_terminal="$(tty | grep -oE ....$)"
  case "$virtual_terminal" in
    tty1|tty2|tty3|tty4|tty5|tty6)
      exec fbterm -- bash -c 'TERM=fbterm tmux'
      ;;
  esac

  # I had an issue invoking `TERM=fbterm screen` with `fbterm` directly -- it
  # seems to want the actual command to invoke as the first parameter (rather than
  # an environment variable).  I worked around it by using `bash -c`; you may use
  # whatever shell you want, or may even be able to figure out how to invoke
  # `TERM=fbterm screen` directly.
  #
  # To get the 256 color mode to work correctly, invoking `screen` with
  # `TERM=fbterm` is necessary.  It wouldn't work correctly simply exporting the
  # variable before or after invoking `screen`.
  #
  # This is what the official fbterm documentation says about 256 color mode:
  #
  # xterm has a 256 color mode extension, FbTerm also add it in this version. But
  # xterm's 256 color escape sequences conflict with the linux sequences
  # implemented by FbTerm, so private escape sequences were introduced to support
  # this feature:
  #
  # ESC [ 1 ; n }                   set foreground color to n (0 - 255)
  # ESC [ 2 ; n }                   set background color to n (0 - 255)
  # ESC [ 3 ; n ; r ; g ; b }       set color n to (r, g, b) ,  n, r, g, b all in (0 - 255)
  #
  # and a new terminfo database entry named "fbterm" was added to use these
  # private sequences, all program based on terminfo should work with it. By
  # default, FbTerm sets environment variable "TERM" to value "linux", you need
  # run "TERM=fbterm /path/to/program" to enable 256 color mode.
fi
