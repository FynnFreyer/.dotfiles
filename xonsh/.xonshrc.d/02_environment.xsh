# completions
$COMPLETIONS_CONFIRM = True
$COMPLETION_MODE = 'menu-complete'
$XONSH_AUTOPAIR = True

$CASE_SENSITIVE_COMPLETIONS = False
$AUTO_SUGGEST_IN_COMPLETIONS = True
$ALIAS_COMPLETIONS_OPTIONS_BY_DEFAULT = True

$UPDATE_COMPLETIONS_ON_KEYPRESS = False
$COMPLETION_IN_THREAD = True

# navigation
$AUTO_CD = True
$AUTO_PUSHD = True
$DIRSTACK_SIZE = 50
$PUSHD_MINUS = True
$PUSHD_SILENT = True

$CDPATH = ['/', '~/']

# shell behaviour
$DOTGLOB = True
$UPDATE_OS_ENVIRON = True

# using -w switch will wait for gedit before resuming execution, for git etc
$EDITOR = '/usr/bin/gnome-text-editor -s' if is_graphical_environment() else '/usr/bin/nano'


# history
$XONSH_HISTORY_BACKEND = 'sqlite'
$XONSH_HISTORY_FILE = $XDG_DATA_HOME + '/xonsh/history.sqlite'
$HISTCONTROL = 'ignoredups'

