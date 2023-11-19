#!/usr/bin/env bash
set -euo pipefail
trap "set +euo pipefail" EXIT ERR SIGHUP SIGKILL

# debug with
# set -x
# trap "set +x" EXIT ERR SIGHUP SIGKILL

usage() {
    cat << EOF
$(basename "${0}")

Description...
EOF
}

if [[ "${#}" -ge 1 && "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

# ... code ...

# only run this if executed as a script, not if sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ran as script"
    # execute functions here
fi

