"""
from colorama import Fore, Back, Style
from my_term_colors import RichFore as RF, RichBack as RB, RichStyle as RS

# styling
$XONSH_COLOR_STYLE = 'native'

$LS_COLORS = ':'.join([
    'rs=0', 'di=01;36', 'ln=01;36', 'mh=00', 'pi=40;33', 'so=01;35', 
    'do=01;35', 'bd=40;33;01', 'cd=40;33;01', 'or=40;31;01', 'su=37;41', 
    'sg=30;43', 'ca=30;41', 'tw=30;42', 'ow=34;42', 'st=37;44', 'ex=01;32'
])

TERMCAPS = {}

# Coloured man pages

solarized = {
    'base03': '#002b36',
    'base02': '#073642',
    'base00': '#657b83',
    'base01': '#586e75',
    'base0': '#839496',
    'base1': '#93a1a1',
    'base2': '#eee8d5',
    'base3': '#fdf6e3',
    'yellow': '#b58900',
    'orange': '#cb4b16',
    'red': '#dc322f',
    'magenta': '#d33682',
    'violet': '#6c71c4',
    'blue': '#268bd2',
    'cyan': '#2aa198',
    'green': '#859900'
}

red_fg = RF.from_hex(solarized['red'])
red_bg = RB.from_hex(solarized['red'])

green_fg = RF.from_hex(solarized['green'])

light_fg = RF.from_hex(solarized['base2'])
light_bg = RB.from_hex(solarized['base2'])

dark_fg = RF.from_hex(solarized['base02'])
dark_bg = RB.from_hex(solarized['base02'])

$LESS_TERMCAP_mb = RS.BOLD + green_fg  # start bold
$LESS_TERMCAP_md = RS.BOLD + green_fg  # start blink
$LESS_TERMCAP_me = RS.RESET_ALL  # stop bold/blink

$LESS_TERMCAP_so = RS.ITALICS + RS.UNDERLINE + dark_bg + light_fg  # start standout
$LESS_TERMCAP_se = RS.RESET_ITALICS + RS.RESET_UNDERLINE + RB.RESET + RF.RESET  # stop standout

$LESS_TERMCAP_us = RS.BOLD + RS.UNDERLINE + green_fg  # start underline
$LESS_TERMCAP_ue = RS.NORMAL + RS.RESET_UNDERLINE + RF.RESET  # stop underline

$LESS_TERMCAP_mr = RS.INVERT  # start invert fg/bg
$LESS_TERMCAP_mh = RS.DIM  # start dim

$LESS_TERMCAP_ZH = RS.ITALICS  # start italics
$LESS_TERMCAP_ZR = RS.RESET_ITALICS  # stop italics

$LESS_TERMCAP_ZN = $(tput ssubm)  # start subscript
$LESS_TERMCAP_ZV = $(tput rsubm)  # stop subscript

$LESS_TERMCAP_ZO = $(tput ssupm)  # start superscript
$LESS_TERMCAP_ZW = $(tput rsupm)  # stop superscript

$GROFF_NO_SGR = 1  # Gnome-terminal needs this

# $LESS_TERMCAP_DEBUG = 1  # show used term caps in less output
$MANPAGER='less -s -M +Gg -aij .1 -wz-5'  # --use-color
"""
