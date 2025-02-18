from xonsh.built_ins import XSH
from xonsh.shells.ptk_shell.key_bindings import tab_insert_indent

from prompt_toolkit.keys import Keys
from prompt_toolkit.filters import Condition, EmacsInsertMode, ViInsertMode
from prompt_toolkit.application.current import get_app

def dedent(line):
    """ Dedents a line. """
    # line.removeprefix(indent) alone does not deal with partial indents.
    indent = XSH.env.get('INDENT')

    longest_prefix = ''
    for prefix in [indent[:i] for i in range(len(indent) + 1)]:
        if line.startswith(prefix) and len(prefix) > len(longest_prefix):
            longest_prefix = prefix

    return line.removeprefix(longest_prefix)

@Condition
def should_tab():
    """ Different tabbing logic. """
    # cf. xonsh.ptk_shell.key_bindings.tab_insert_indent
    # and https://github.com/xonsh/xonsh/blob/75f351821a210cbae3e4c642cdb90a84fb642f94/xonsh/ptk_shell/key_bindings.py#L103
    before_cursor = get_app().current_buffer.document.current_line_before_cursor

    return before_cursor.isspace() or not before_cursor

@events.on_ptk_create
def custom_keybindings(bindings, **kw):
    insert_mode = ViInsertMode() | EmacsInsertMode()

    @bindings.add(Keys.BackTab, filter=insert_mode)
    def shift_tab_dedents(event):
        """ In insert mode we want to dedent with Shift-Tab instead of inserting a literal tab. """
        # cf. https://github.com/xonsh/xonsh/blob/75f351821a210cbae3e4c642cdb90a84fb642f94/xonsh/ptk_shell/key_bindings.py#L275
        b = event.current_buffer
        if b.complete_state:
            b.complete_previous()
        else:
            env = XSH.env
            event.cli.current_buffer.transform_current_line(dedent)

#    @bindings.add(Keys.Tab, filter=insert_mode & should_tab)
#    def tab_indents(event):
#        env = XSH.env
#        event.cli.current_buffer.insert_text(env.get("INDENT"))

# @bindings.add(Keys.ShiftEnter, filter=insert_mode)
# def shift_enter_inserts_literal(event):
#     env = XSH.env
#     event.cli.current_buffer.insert_text('\n')


