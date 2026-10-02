# colored prompt, if the terminal has the capability
case "$TERM" in
    xterm*|*-256color) __use_color_prompt=yes;;
esac

# TODO: get the git prompt to work...
_gp_cmd() {
  local git_prompt=__git_ps1
  if [[ -n "$__use_color_prompt" ]]; then
    local modified_files=$(git status --porcelain | grep "^ M ")
    local state="clean"
    if [[ -n "$modified_files" ]]; then
      state="dirty"
    fi
    local color
    case $state in
      clean) color="$_GREEN_FG";;
      dirty) color="$_RED_FG";;
    esac
    echo "${color}${git_prompt}${_RESET_COL_FG}"
  else
    echo $git_prompt
  fi
}

# build up prompt parts
_host='\u@\h'
_cwd='\w'
_suffix=' \$> '
_time='\D{%H:%M}'
_git='$(_gp_cmd)'

# mark host name red for root
case $(id -u) in
  0) host_color="$_RED_FG";;
  *) host_color="$_GREEN_FG";;
esac

# add color, if we "want" that
if [ "$__use_color_prompt" = yes ]; then
  _host="${host_color}${_host}${_RESET_COL_FG}"
  _cwd="${_BLUE_FG_BR}${_cwd}${_RESET_COL_FG}"
  _time="${_RED_FG}${_time}${_RESET_COL_FG}"
  _suffix="${_CYAN_FG}${_suffix}${_RESET_COL_FG}"
fi

unset host_color

# set prompt vars
PS0="$_RESET"  # emited right before command output
PS1="${_host} : ${_cwd} ${_time}\n${_suffix}" # the prompt
PS2='    '  # line continuation

unset _host _cwd _time _suffix

# # If this is an xterm set the title to user@host:dir
# case "$TERM" in
#   xterm*|rxvt*)
#     PS1="\[\e]0;\u@\h: \w\a\]$PS1"
#     ;;
#   *)
#     ;;
# esac
