# exec xonsh

# if [ -f "$HOME/xonsh" ]; then
#     xonsh="$HOME/xonsh"
# elif [ -f "$PREFIX/xonsh" ]; then
#     xonsh="$PREFIX/xonsh"
# fi

if type xonsh; then
    # if we find xonsh in the PATH, we note were
    xonsh=$(command -v xonsh)
else
    # else we issue a warning
    echo "WARNING: no xonsh found"
fi

# if we found xonsh, we run it
if [ -n "$xonsh" ]; then
    export SHELL="$xonsh"
    unset xonsh
    exec "$SHELL"
fi
