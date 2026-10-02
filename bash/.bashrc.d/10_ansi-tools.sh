# Functions to generate escape sequences
# See these links for details:
#   https://en.wikipedia.org/wiki/ANSI_escape_code
#   https://www.xfree86.org/current/ctlseqs.html

_CSI='\e['  # control sequence introducer
_OSC='\e]'  # operating system command
_ST='\e\'   # string terminator

__sgr() {
  # returns CSI<n>m
  # <n> is a number in [0, 107]
  local n=$1
  echo "\[${_CSI}${n}m\]"
}

__osc() {
  # returns OSC <cmd>;<arg> ST
  # <cmd> is the command (e.g. 0 for setting the title)
  # <arg> is the argument (e.g. "My Terminal" for setting the title)
  local cmd=$1
  local arg=$2
  echo "\[${_OSC}${cmd};${arg}${_ST}\]"
}

__col_base() {
  # returns CSI <col_code>m -- Select base color
  # <color> is a word in ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
  # <target> is "fg" or "bg" and defaults to "fg"
  # if <bright> is passed the color will intensity will be set accordingly
  local color=$1
  local target=${2:-"fg"}
  local bright=${3:-""}

  # set base color code (normal intensity and foreground)
  declare -i col_code
  case $color in
    black)   col_code=30;;
    red)     col_code=31;;
    green)   col_code=32;;
    yellow)  col_code=33;;
    blue)    col_code=34;;
    magenta) col_code=35;;
    cyan)    col_code=36;;
    white)   col_code=37;;
  esac

  if [[ "$target" == bg ]]; then
    col_code+=10
  fi
  if [[ -n "$bright" ]]; then
    col_code+=60
  fi

  echo "\[${_CSI}${col_code}m\]"
}

__col_table() {
  # <n> is a number in [0, 255]
  # <target> is a string in ["fg", "bg", "ul"]
  local n=$1
  local target=${2:-"fg"}
  # sgr code is set via target
  local sgr  # fg -> 38, bg -> 48, ul -> 58
  case "$target" in
    fg) sgr=38;;
    bg) sgr=48;;
    ul) sgr=58;;
  esac
  echo "\[${_CSI}${sgr}:5:${n}m\]"
}

__col_fg_table() {
  # returns CSI 38:5:<n>m -- Select foreground color
  # <n> is a number in [0, 255]
  local n=$1
  echo $(__col_table $n 'fg')
}

__col_bg_table() {
  # returns CSI 48:5:<n>m -- Select background color
  # <n> is a number in [0, 255]
  local n=$1
  echo $(__col_table $n 'bg')
}

__col_ul_table() {
  # returns CSI 58:5:<n>m -- Select underline color
  # <n> is a number in [0, 255]
  local n=$1
  echo $(__col_table $n 'ul')
}

# helpers to convert colors to/from hex/rgb
__hex_to_rgb() {
  local hex="${1#'#'}"  # strip leading '#'

  # validate format
  if [[ ! $hex =~ ^[0-9A-Fa-f]{6}$ ]]; then
    echo "Invalid color hex code" >&2
    return 1
  fi

  local r g b  # calculate nums
  r=$((16#${hex:0:2}))
  g=$((16#${hex:2:2}))
  b=$((16#${hex:4:2}))

  # format as string
  printf "%d %d %d\n" "$r" "$g" "$b"
}

__rgb_to_hex() {
  local r="$1" g="$2" b="$3"

  # validate range
  for v in "$r" "$g" "$b"; do
    if (( v <0 || v > 255 )); then
      echo "RGB values must be in [0, 255]" >&2
      return 1
    fi
  done

  # format as hex
  printf "#%02x%02x%02x\n" "$r" "$g" "$b"
}

# functions to generate escape codes
__col_rgb() {
  # <r>, <g>, <b> are numbers in [0, 255]
  # <target> is a string in ["fg", "bg"] and defaults to "fg"
  local r="$1" g="$2" b="$3"
  local target=${4:-"fg"}
  # sgr code is set via target
  local sgr  # fg -> 38, bg -> 48, ul -> 58
  case "$target" in
    fg) sgr=38;;
    bg) sgr=48;;
  esac
  echo "\[${_CSI}${sgr};2;${r};${g};${b}m\]"
}

__col_hex() {
  local r g b
  read r g b <<< "$(__hex_to_rgb $1)"
  local target=${4:-"fg"}
  echo "$(__col_rgb $r $g $b $target)"
}
