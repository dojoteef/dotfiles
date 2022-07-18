function fish_mode_prompt
  switch $fish_bind_mode
    case default
      set_color 87afaf --bold
      echo 'N '
    case insert
      set_color dcdccc --bold
      echo 'I '
    case replace
      set_color 87af87 --bold
      echo 'C '
    case replace_one
      set_color 87af87 --bold
      echo 'R '
    case visual
      set_color ffd7af --bold
      echo 'V '
    case '*'
      set_color --bold red
      echo '? '
  end
  set_color normal
end
