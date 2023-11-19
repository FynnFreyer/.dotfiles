# add python_user dir to PYTHON_PATH
BIN_DIR="$HOME/.local/lib/custom_python_site-packages/"
if ! [[ "$PYTHONPATH" =~ $BIN_DIR ]]; then
    export PYTHONPATH="$BIN_DIR:$PYTHONPATH"
fi

