# .bash_profile

# Source user specific environment and startup programs
if [ -d ~/.bash_profile.d ]; then
    for profile in ~/.bash_profile.d/*; do
        if [ -f "$profile" ]; then
            . "$profile"
        fi
    done
fi

unset profile

# If running interactively and bashrc exists
if [[ $- == *i* && -f ~/.bashrc ]]; then
    # Get the aliases and functions
	source ~/.bashrc
fi
