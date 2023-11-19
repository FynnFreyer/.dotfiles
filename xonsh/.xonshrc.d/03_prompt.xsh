from datetime import datetime

# We need this to refresh the prompt 
$UPDATE_PROMPT_ON_KEYPRESS = True
$PROMPT_REFRESH_INTERVAL = 1

def prompt():
    time = datetime.now().strftime("%X")
    
    prompt = (
        '{env_name}{BOLD_CYAN}{user}@{hostname}{BOLD_BLUE} :{BOLD_YELLOW} '
        '{cwd}{branch_color}{curr_branch: {}}{BOLD_RED} ' + time + '\n'
        '{BOLD_BLUE} {prompt_end}>{RESET} '
    )

    return prompt


$TITLE = lambda: '{env_name}{user}@{hostname}'
$PROMPT = prompt

$PROMPT_FIELDS['date_time'] = lambda: now()

$DYNAMIC_CWD_WIDTH = '75%'
$DYNAMIC_CWD_ELISION_CHAR = '…'

$MULTILINE_PROMPT = '    '
$INDENT = '    '

# prompt input
#$XONSH_CTRL_BKSP_DELETION = True
# TODO [issue](https://github.com/xonsh/xonsh/issues/4591)
#  no scrolling possible when MOUSE_SUPPORT is set
#$MOUSE_SUPPORT = True

def status_line():
    time = datetime.now().strftime("%X")
    # return time
    return ''

$BOTTOM_TOOLBAR = ''

