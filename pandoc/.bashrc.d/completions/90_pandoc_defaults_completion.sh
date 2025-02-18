#!/bin/bash

# This is a bash completion script for pandoc's -d flag. It suggests the names of files
# in the "$XDG_DATA_HOME/pandoc/defaults" directory, stripping the extensions.

# Register the completion function for the `pandoc` command
_pandoc() {
    # This is the function that handles the completion for the pandoc command
    # It checks for the '-d' flag and then suggests files from the directory

    # Check if the first argument is the `-d` flag
    if [[ ${COMP_WORDS[1]} == "-d" ]]; then
        # Set the directory from the XDG_DATA_HOME environment variable
        local dir="$XDG_DATA_HOME/pandoc/defaults"

        # Check if the directory exists
        if [[ -d "$dir" ]]; then
            # Find files in the directory, strip the extensions and sort them
            # We use `basename` to remove the file suffixes, `sort` to sort them alphabetically
            local files=$(find "$dir" -type f \( -name "*.yaml" -o -name "*.yml" \) -exec basename {} \; | sed -E 's/\.(yaml|yml)$//g' | sort)

            # Provide the list of suggestions
            COMPREPLY=( $(compgen -W "$files" -- ${COMP_WORDS[2]}) )
        fi
    fi
}

echo loaded pandoc completion

# Register the completion function to be used with the `pandoc` command
complete -F _pandoc pandoc
