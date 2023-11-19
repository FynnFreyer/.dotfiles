# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# Source user specific environment and startup programs
if [ -d ~/.bash_profile.d ]; then
    for profile in ~/.bash_profile.d/*; do
        if [ -f "$profile" ]; then
            . "$profile"
        fi
    done
fi

unset profile
