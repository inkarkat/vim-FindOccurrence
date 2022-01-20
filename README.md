FIND OCCURRENCE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin adds the following features to the default Vim mappings for
:isearch, :ilist and :ijump:
- ]I et al. not only list the occurrences, but ask for the occurrence number
  to jump to.
- ]I et al. also work in visual mode, searching for the selection instead of
  the word under cursor.
- New ]n ]N ]&lt;C-N&gt; &lt;C-W&gt;n &lt;C-W&gt;&lt;C-N&gt; mappings that operate on the
  last search pattern.
- New ]/ &lt;C-W&gt;/ mappings that query and then operate on a pattern.

### SOURCE

- [Based on the Vim Tip "Search visually":](http://vim.wikia.com/wiki/Search_visually)

### RELATED WORKS

- qlist (https://github.com/romainl/vim-qlist) makes [I, [D, and related
  commands persist to the quickfix list

USAGE
------------------------------------------------------------------------------

    List occurrences of \<word\> under cursor / word under cursor (g[I) / visual
    selection:
    With any [count], also includes 'comment'ed lines.
    [count][I               List all occurrences in the file. (Like :ilist)
    [count]]I               List occurrences from the cursor position to end of
                            file.
    [count][CTRL-I          Jump to the [count]'th occurrence in the file. (Like
                            :ijump)
    [count]]CTRL-I          Jump to the [count]'th occurrence starting from the
                            cursor position.

    List occurrences of last search pattern quote/:
    With any [count], also includes 'comment'ed lines.
    [count][n               List [count]'th occurrence in the file. (Like
                            :isearch)
    [count]]n               List [count]'th occurrence from the cursor position.
    [count][N               List all occurrences in the file. (Like :ilist)
    [count]]N               List occurrences from the cursor position to end of
                            file.
    [count][CTRL-N          Jump to the [count]'th occurrence in the file. (Like
                            :ijump)
    [count]]CTRL-N          Jump to the [count]'th occurrence starting from the
                            cursor position.

    List occurrences of queried pattern:
    With any [count], also includes 'comment'ed lines.
    [count][/               Without [count]: Query, then list all occurrences in
                            the file (like :ilist).
                            With [count]: Query, then jump to [count]'th
                            occurrence; if it doesn't exist, list all occurrences.
    [count]]/               Without [count]: Query, then list occurrences from the
                            cursor position to end of file.
                            With [count]: Query, then jump to [count]'th
                            occurrence from the cursor position; if it doesn't
                            exist, list occurrences from the cursor position to
                            end of file.
                            These eclipse [/ and ]/ motions, but you can still use
                            [* and ]*.
    [count]CTRL-W_/         Query, then jump to the [count]'th occurrence in a
                            split window.

    [count][?               Without [count]: List all occurrences of the
                            previously queried pattern in the file (like
                            :ilist).
                            With [count]: Jump to [count]'th previously queried
                            occurrence; if it doesn't exist, list all occurrences.
    [count]]?               Without [count]: List occurrences of the previously
                            queried pattern from the cursor position to end of
                            file.
                            With [count]: Jump to [count]'th previously queried
                            occurrence from the cursor position; if it doesn't
                            exist, list occurrences from the cursor position to
                            end of file.
    [count]CTRL-W_?         Jump to the [count]'th previously queried occurrence
                            in a split window.

### NOTES

    - The [ and <C-W> mappings start at the beginning of the file, the ] mappings
      at the line after the cursor. Both are directed forward, so it's easy to
      jump to the next match, but to go to a previous match, you have to find out
      about the match number and use that.
    - Without a [count], commented lines are ignored. If you want to show the list
      that includes commented lines, use a high count (e.g. 999) that is unlikely
      to produce a direct match.
    - x just echoes the occurrence, X prints a list of the occurrences and asks
      for the occurrence number to jump to, <C-X> directly jumps to the
      occurrence, <C-W>x and <C-W><C-X> split the window and jump to the
      occurrence.
    - i I <Tab> <C-W>i <C-W><Tab> for word under cursor.
    - d D <C-D> <C-W>d <C-W><C-D> for macro definition under cursor.
    - n N <C-N> <C-W>n <C-W><C-N> for last search pattern.
    - / <C-W>/                    for queried pattern.

### USE CASES

    - List all occurrences excluding / including comments:
      [X / 999[X
    - Move through all matches excluding / including comments:
      [CTRL-X, ]CTRL-X, ]CTRL-X, ... / 1[CTRL-X, 1]CTRL-X, 1]CTRL-X, ...
    - Move through every n'th match excluding / including comments:
      [CTRL-X, ]Xn, ]Xn, ... / 1[CTRL-X, n]CTRL-X, n]CTRL-X, ...

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-FindOccurrence
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim FindOccurrence*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.007 or
  higher.

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-FindOccurrence/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 1.02    RELEASEME

##### 1.01    23-May-2014
- ENH: Add g[I and g[&lt;Tab&gt; mappings that search for the word (not the
  \\&lt;word\\&gt;) under the cursor, like \* and g\*.

##### 1.00    10-Apr-2014
- First published version.

##### 0.01    08-Jul-2008
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2008-2022 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
