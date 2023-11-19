xontributions = [
    'argcomplete',
    'coreutils',
    'direnv',
    'init_ssh_agent',
    'kitty',
    'makefile_complete',
    'vox'
]

fail = False
for xontribution in xontributions:
    try:
        xontrib load @(xontribution)
    except:
        fail = True

if fail:
    print("Failed to load some xontribs.")
