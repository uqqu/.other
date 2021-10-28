'''Neovim file open caller.

This file (in .exe form) associated with majority of the text formats
    and with custom file context menu command 'Edit with Nvim'.
If Neovim has existing process, check isn't file already open in any tab.
    If file is new, open new tab with this file;
    Else: switch to tab with calling file.
Аt the end is called LWin+q hotkey,
    which on the third-party 'qphyx.exe' script responsible for activate Nvim window.
To be able to get the existing Nvim process, init.vim config must have the following lines:
> autocmd VimEnter * silent execute '!echo ' . v:servername . ' > "' . $VIM . '\\servername.txt"'
> autocmd VimLeave * silent execute '!del "' . $VIM . '\\servername.txt"'
'''

import sys
import neovim
from os import path
from subprocess import call  # nosec
from psutil import process_iter
from pynput.keyboard import Key, Controller


if __name__ == '__main__' and len(sys.argv) > 1:
    servername_path = 'C:\\Program Files\\Neovim\\share\\nvim\\servername.txt'
    if not path.isfile(servername_path):
        call(['C:\\Program Files\\Neovim\\bin\\nvim-qt.exe', sys.argv[1]])
        sys.exit()

    with open(servername_path, mode='rt') as f:
        line = f.readline()
        servername = line.strip('\r\n ')

    try:
        nvim = neovim.attach('socket', path=servername)
    except OSError:
        sys.exit()
    test = nvim.command_output(':tabdo echo bufwinnr("' + '/'.join(sys.argv[1].split('\\')) + '")')
    if not test:
        nvim.feedkeys('\x1b')
        test = nvim.command_output(
            ':tabdo echo bufwinnr("' + '/'.join(sys.argv[1].split('\\')) + '")'
        )
    if '1' in test.split('\n'):
        nvim.feedkeys('\x1b')
        nvim.feedkeys(str(test.split('\n').index('1') + 1) + 'gt')
        pyw_bug_test = nvim.command_output(':echo @%')
        if sys.argv[1] != pyw_bug_test != '/'.join(sys.argv[1].split('\\')):
            nvim.command(':tabnew %s | tabmove' % sys.argv[1])
    else:
        nvim.command(':tabnew %s | tabmove' % sys.argv[1])

    nvim.close()

    if 'qphyx.exe' in (proc.name() for proc in process_iter()):
        keyboard = Controller()
        keyboard.press(Key.cmd_l)
        keyboard.press('q')
        keyboard.release(Key.cmd_l)
        keyboard.release('q')
