# Variables that define colors and styles
# See for details: https://en.wikipedia.org/wiki/ANSI_escape_code

_RESET=$(__sgr 0)
_RESET_COL_FG=$(__sgr 39)
_RESET_COL_BG=$(__sgr 49)
_RESET_COL_UL=$(__sgr 59)
_RESET_COL="\[$(__sgr 39)$(__sgr 49)\]"

_BOLD=$(__sgr 1)
_BOLD_RESET=$(__sgr 22)
_DIM=$(__sgr 2)
_DIM_RESET=$(__sgr 22)

_ITALIC=$(__sgr 3)
_ITALIC_RESET=$(__sgr 23)
_STRIKE=$(__sgr 9)
_STRIKE_RESET=$(__sgr 29)
_BLINK=$(__sgr 5)
_BLINK_RESET=$(__sgr 25)
_BLINK_FAST=$(__sgr 6)
_BLINK_FAST_RESET=$(__sgr 25)

_UNDERLINE=$(__sgr 4)
_DOUBLE_UNDERLINE=$(__sgr 4)
_UNDERLINE_RESET=$(__sgr 24)
_DOUBLE_UNDERLINE_RESET=$(__sgr 24)
_OVERLINE=$(__sgr 53)
_OVERLINE_RESET=$(__sgr 55)

_SUPERSCRIPT=$(__sgr 73)
_SUBSCRIPT=$(__sgr 74)
_SUPERSCRIPT_RESET=$(__sgr 75)
_SUBSCRIPT_RESET=$(__sgr 75)

__BLUE_HEX="0077b6"
__GREEN_HEX="38b000"
__RED_HEX="f26419"
__CYAN_HEX="00b4d8"
__YELLOW_HEX="f6ae2d"
__MAGENTA_HEX="f72585"
__WHITE_HEX="d3d3d3"

# Color codes
_BLACK_FG=$(__col_base "black" "fg")
_RED_FG=$(__col_base "red" "fg")
_GREEN_FG=$(__col_base "green" "fg")
_YELLOW_FG=$(__col_base "yellow" "fg")
_BLUE_FG=$(__col_base "blue" "fg")
_MAGENTA_FG=$(__col_base "magenta" "fg")
_CYAN_FG=$(__col_base "cyan" "fg")
_WHITE_FG=$(__col_base "white" "fg")

_BLACK_BG=$(__col_base "black" "bg")
_RED_BG=$(__col_base "red" "bg")
_GREEN_BG=$(__col_base "green" "bg")
_YELLOW_BG=$(__col_base "yellow" "bg")
_BLUE_BG=$(__col_base "blue" "bg")
_MAGENTA_BG=$(__col_base "magenta" "bg")
_CYAN_BG=$(__col_base "cyan" "bg")
_WHITE_BG=$(__col_base "white" "bg")

_BLACK_FG_BR=$(__col_base "black" "fg" "bright")
_RED_FG_BR=$(__col_base "red" "fg" "bright")
_GREEN_FG_BR=$(__col_base "green" "fg" "bright")
_YELLOW_FG_BR=$(__col_base "yellow" "fg" "bright")
_BLUE_FG_BR=$(__col_base "blue" "fg" "bright")
_MAGENTA_FG_BR=$(__col_base "magenta" "fg" "bright")
_CYAN_FG_BR=$(__col_base "cyan" "fg" "bright")
_WHITE_FG_BR=$(__col_base "white" "fg" "bright")

_BLACK_BG_BR=$(__col_base "black" "bg" "bright")
_RED_BG_BR=$(__col_base "red" "bg" "bright")
_GREEN_BG_BR=$(__col_base "green" "bg" "bright")
_YELLOW_BG_BR=$(__col_base "yellow" "bg" "bright")
_BLUE_BG_BR=$(__col_base "blue" "bg" "bright")
_MAGENTA_BG_BR=$(__col_base "magenta" "bg" "bright")
_CYAN_BG_BR=$(__col_base "cyan" "bg" "bright")
_WHITE_BG_BR=$(__col_base "white" "bg" "bright")
