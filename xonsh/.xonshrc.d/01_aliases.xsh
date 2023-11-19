# resourcing rc file
aliases['resource_xonsh'] = lambda args: $[source ~/.xonshrc]

# fixes
aliases['lh'] = lambda args: $[ls --color=auto -dxX `\..*`]
aliases['busy'] = lambda args: $[cat /dev/urandom | hexdump -C | grep "ca fe"]

aliases['-'] = lambda args: $[popd]
aliases['--'] = lambda args: $[popd] or $[popd]  # $[cmd] always returns None

# tree
aliases['tp'] = lambda args: $[td -I '[_v]*']

# sync
aliases['sd'] = sync_dotfiles

# alarm
aliases['alarm'] = lambda: os.system('tput bel; sleep 1; tput bel; sleep 1; tput bel; sleep 1; tput bel; sleep 1; tput bel;')

# file management
