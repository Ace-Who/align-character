# vim-AlignCharacter

Make occurrences of the specified character on different lines align visually.

## Usage

```viml
<leader>ali    " align a character 
<leader>unali   " unalign, or remove extra spaces before, a character
```

User will be prompted to input the target character.

Works in both normal mode and visual mode.

In normal mode, it affects lines from cursor position to the end of file.
In visual mode, it affects selected lines.
