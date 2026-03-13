# define the aliases
alias ga='git add'
alias gc='git commit'
alias gst='git status'
alias gpl='git pull'
alias gps='git push'
alias gd='git diff'
alias gl='git log'
alias gb='git branch'
alias lgit='lazygit'

# Link the aliases to the normal git completion logic
_completion_loader git  # need to load git completions before use
__git_complete ga _git_add
__git_complete gc _git_commit
__git_complete gst _git_status
__git_complete gpl _git_pull
__git_complete gps _git_push
__git_complete gd _git_diff
__git_complete gl _git_log
__git_complete gb _git_branch

