# Keybinding cheatsheet

Concise reference for the keys this config binds. Source-of-truth files
are linked at the end of each section — go there to add/change.

---

## tmux

**Prefix is `C-a`** (rebound from default `C-b`). All bindings below
assume "prefix" means `C-a`. `C-a C-a` sends a literal `C-a` to the
program (start of line in the shell); `prefix a` jumps to the last window.

| Action | Keys |
| --- | --- |
| Vertical split | `prefix \|` |
| Horizontal split | `prefix -` |
| New window in same dir | `prefix c` |
| Move between panes (vim-style) | `prefix h / j / k / l` |
| Move between panes **and nvim splits**, no prefix | `C-h / j / k / l` *(vim-tmux-navigator; works in copy mode too)* |
| Jump back to the previous pane | `C-\` or `prefix ;` |
| Clear the shell screen (`C-l` is taken by the navigator) | `prefix C-l` |
| Zoom the pane to full window (again to unzoom) | `prefix z` |
| Floating scratch shell in the current dir (`exit` closes it) | `prefix P` |
| Next / previous window **with an alert** (e.g. Claude rang the bell) | `prefix M-n` / `prefix M-p` |
| Mouse: drag to resize, click to focus, right-click for menus | `set -g mouse on` is on |
| Reload config | `prefix r` |
| Detach session | `prefix d` (default) |
| Pick a session / window, with preview | `prefix s` / `prefix w` (default) |

**What you see:** each pane's border shows its title (Claude Code and
Codex set it to the current task). The status bar shows the session on
the left and the directory and time on the right. A window where a
program rang the bell gets a bell icon. Exiting the last shell in a
session switches to another session instead of dropping out of tmux.

**Copy mode (vi-style):**
- Enter copy mode: `prefix [` (or scroll up with the mouse wheel)
- Search: `/` down, `?` up, then `n` / `N`
- Start selection: `v` (`V` whole lines, `C-v` rectangle)
- Yank to Windows clipboard: `y` *(tmux-yank, piped through `win32yank.exe -i --crlf`; exits copy mode)*
- Mouse-drag selection also copies to the Windows clipboard.
- Exit: `q`

**Plugin keybindings:**
- `prefix F` / `prefix J`: tmux-fingers hint mode / jump mode. Paths,
  SHAs, URLs, IPs and numbers on screen get a letter; type it to copy
  (`Shift`+letter also pastes it into the pane).
- `prefix y` / `prefix Y`: copy the shell command line / the pane's
  working directory (tmux-yank)
- `prefix I` / `prefix U`: install / update plugins (tpm)
- `prefix C-s` / `prefix C-r`: save / restore sessions now (tmux-resurrect)

**Sessions auto-save every 15 minutes and restore when tmux starts**
(tmux-continuum). nvim comes back open; Claude Code panes come back as
`claude --continue`, which resumes the latest conversation *in that
directory* (two Claude panes in one directory both resume the same one).

**Claude Code in tmux:** Shift+Enter inserts a newline (extended keys
are on), and Claude rings the terminal bell when it finishes or waits for
permission while you're away (`preferredNotifChannel: "terminal_bell"` in `~/.claude/settings.json`,
which is not managed by this repo).

Source: [`dot_tmux.conf`](dot_tmux.conf),
[`run_once_after_05-tmux.sh.tmpl`](run_once_after_05-tmux.sh.tmpl) (plugins + the tmux-fingers binary)

---

## zsh

**Plugin features active:**
- `fzf-tab` — tab-completion uses fzf interactive UI
- `zsh-autosuggestions` — ghost-text suggestion as you type, accept with `→` or `End`
- `zsh-syntax-highlighting` — invalid commands turn red live
- `zsh-completions` — extra completion definitions
- `zsh-history-substring-search` — type a prefix, then `↑` / `↓` step through history entries containing it (both cursor-key modes are bound, so it works under tmux and ssh)

**fzf keybindings (default):**
- `Ctrl-R` — fuzzy search shell history
- `Ctrl-T` — fuzzy file picker, inserts selection at cursor
- `Alt-C` — `cd` into a fuzzy-picked directory

**zoxide:**
- `z <partial-name>` — jump to most-frecent directory matching
- `zi` — interactive picker via fzf

**Aliases:**
| Command | Runs |
| --- | --- |
| `ls`, `ll`, `la`, `tree` | eza variants with git/icons |
| `cat`, `less` | `batcat -p` / `batcat` on Ubuntu, `bat -p` / `bat` where the binary is named `bat` (paged on long files via `LESS=-R`) |
| `top` | `btop` |
| `fd` | `fdfind` (Ubuntu names the binary `fdfind`) |
| `g` | `git` |
| `z`, `zi` | zoxide jump / interactive pick (plain `cd` is untouched) |

**Local override:** `~/.zshrc.local` is sourced if present (untracked, per-machine).

Source: [`dot_zshrc`](dot_zshrc), [`dot_zsh_plugins.txt`](dot_zsh_plugins.txt)

---

## Neovim

**Leader is `<space>`. Local leader is `\`.**

### Core

| Keys | Action |
| --- | --- |
| `<leader>w` | save buffer |
| `<leader>q` | quit |
| `<leader>Q` | quit-all force |
| `<leader>h` | clear search highlight |
| `<leader>x` | close buffer |
| `<leader>e` | open diagnostic float for current line |
| `Y` | yank to end of line (not `yy`'s whole-line behaviour) |
| `n` / `N` | next/prev search match, **centered** |
| `<C-d>` / `<C-u>` | half-page scroll, **centered** |
| `<S-h>` / `<S-l>` | previous/next buffer |
| `<C-h/j/k/l>` | window navigation; at the edge of nvim it moves into the neighbouring tmux pane |
| `<leader>uh` | toggle LSP inlay hints (inline types / parameter names) |
| `<leader>uu` | undo tree (`:Undotree`), browse and jump to any earlier state |
| `ZR` / `:restart` | restart nvim in place (e.g. after a config change) |

`:DiffTool {left} {right}` compares two files or directories (built in, loaded at startup).

Files changed on disk (e.g. by Claude Code in another pane) **reload automatically**: on focus or
buffer switch, and every second while in Normal mode. A `Reloaded <file>` notice shows each time.

### Folding (treesitter)

Folds follow the syntax tree (functions, classes, blocks). Files open with everything unfolded.

| Keys | Action |
| --- | --- |
| `za` | toggle the fold under the cursor |
| `zM` / `zR` | close all / open all folds |

### Visual mode

| Keys | Action |
| --- | --- |
| `<` / `>` | re-indent and keep selection |
| `J` / `K` | move selected lines down/up |
| `an` / `in` | grow / shrink the selection by syntax node (built in, 0.12) |

### LSP (active when an LSP attaches to the buffer)

| Keys | Action |
| --- | --- |
| `gd` | goto definition |
| `gD` | goto declaration |
| `gi` | goto implementation |
| `K` | hover docs |
| `<leader>rn` | rename symbol |
| `<leader>ca` | code action menu |
| `<leader>F` | format buffer |
| `[d` / `]d` | prev/next diagnostic, opening its float |

**Nvim 0.12 built-in LSP keys** (no config needed):

| Keys | Action |
| --- | --- |
| `grr` | references |
| `gri` | goto implementation |
| `grn` | rename |
| `gra` | code action (Normal and Visual) |
| `grt` | goto type definition |
| `grx` | run code lens |
| `gO` | document symbols |
| `<C-s>` (Insert) | signature help |

Format-on-save is on by default. Toggle per-session with `:FormatToggle`.
Formatters (stylua, prettierd, shfmt) are installed by Mason via `run_once_after_04-nvim.sh.tmpl`.

### Telescope (fuzzy finder)

| Keys | Action |
| --- | --- |
| `<leader>ff` | find files |
| `<leader>fg` | live grep |
| `<leader>fb` | switch buffer |
| `<leader>fh` | help tags |
| `<leader>fr` | recent files |
| `<leader>fs` | LSP document symbols |
| `<leader>/` | fuzzy search current buffer |
| `<leader>fR` | reopen the last picker, with its query |
| `<leader>fd` | diagnostics |
| `<leader>fw` | grep the word under the cursor |
| `<leader>fu` | LSP references (usages) |
| `<leader>fk` | search keymaps |
| `<leader>gs` | git status (changed files) |

### File system (oil.nvim)

| Keys | Action |
| --- | --- |
| `-` | open parent directory as a buffer |
| `<CR>` | open file/directory under cursor |
| `<C-v>` / `<C-x>` | open in vertical/horizontal split |
| `<C-p>` | preview file |
| `g.` | toggle hidden files |
| `<C-h>` / `<C-l>` | window/pane navigation, same as everywhere else (oil's own split/refresh on these keys is turned off) |
| Edit the buffer to rename/delete/create | save with `:w` to apply |

### Git

| Keys | Action |
| --- | --- |
| `]h` / `[h` | next/prev hunk |
| `<leader>hs` | stage hunk (in Visual mode: stage just the selected lines) |
| `<leader>hr` | reset hunk (in Visual mode: reset just the selected lines) |
| `<leader>hS` / `<leader>hR` | stage / reset the whole buffer |
| `<leader>hp` | preview hunk |
| `<leader>hd` | diff the buffer against the index |
| `<leader>hb` | full blame for current line |
| `<leader>ub` | toggle inline blame on the current line |
| `ih` | hunk text object: `vih` selects a hunk, `dih` deletes it |
| `<leader>gs` | telescope git status |
| `:Git` | open fugitive status (full git porcelain) |
| `:Gvdiffsplit` / `:Gdiffsplit` | vertical / horizontal diff against index |

### Code text objects (treesitter)

Use after an operator (`d`, `c`, `y`) or in Visual mode, e.g. `daf` deletes a function, `vic` selects a class body.

| Keys | Action |
| --- | --- |
| `af` / `if` | around / inside function |
| `ac` / `ic` | around / inside class |
| `aa` / `ia` | around / inside argument |
| `]m` / `[m` | next / prev function start (`]M` / `[M` for the end) |
| `]]` / `[[` | next / prev class start (`][` / `[]` for the end) |

### Debugging (nvim-dap)

Python (debugpy, uses the project's `.venv` / `venv` / `$VIRTUAL_ENV`) and C# (netcoredbg: run
`dotnet build` first, then pick the dll). The debug UI opens when a session starts and closes when
it ends. There are no F-key bindings, because Windows Terminal takes F11.

| Keys | Action |
| --- | --- |
| `<leader>dc` | start / continue |
| `<leader>db` | toggle breakpoint |
| `<leader>dB` | conditional breakpoint |
| `<leader>do` / `<leader>di` / `<leader>dO` | step over / into / out |
| `<leader>dC` | run to cursor |
| `<leader>dl` | run last configuration again |
| `<leader>dt` | terminate |
| `<leader>dr` | toggle REPL |
| `<leader>du` | toggle debug UI |
| `<leader>de` | evaluate expression (word under cursor, or selection) |

### Agents

**Claude Code** is the only active agent. Runs in a tmux pane (uses
Max-sub OAuth — no API key required). No in-buffer plugin binding;
the workflow is split-pane, not inline.

| Step | Keys |
| --- | --- |
| Split pane vertically | `prefix \|` (tmux) |
| Launch agent in new pane | `claude` |
| Hop back to editor | `C-h` (or `prefix h`) |
| Hop back to agent | `C-l` (or `prefix l`) |

Claude's edits to open files reload in nvim on their own, within about a second (see Core).

**avante.nvim** is committed but disabled (`enabled = false`) because
it requires an Anthropic API key. Flip the flag in
`dot_config/nvim/lua/plugins/agents.lua` if a key ever comes into play.

### which-key

Hold any leader key (`<space>`) for ~400ms and `which-key` shows a
popup of available continuations. Useful when you forget a binding.

Source: [`dot_config/nvim/lua/config/keymaps.lua`](dot_config/nvim/lua/config/keymaps.lua),
[`dot_config/nvim/lua/config/options.lua`](dot_config/nvim/lua/config/options.lua),
[`dot_config/nvim/lua/config/autocmds.lua`](dot_config/nvim/lua/config/autocmds.lua),
[`dot_config/nvim/lua/plugins/editor.lua`](dot_config/nvim/lua/plugins/editor.lua),
[`dot_config/nvim/lua/plugins/treesitter.lua`](dot_config/nvim/lua/plugins/treesitter.lua),
[`dot_config/nvim/lua/plugins/debug.lua`](dot_config/nvim/lua/plugins/debug.lua),
[`dot_config/nvim/lua/plugins/lsp.lua`](dot_config/nvim/lua/plugins/lsp.lua),
[`dot_config/nvim/lua/plugins/telescope.lua`](dot_config/nvim/lua/plugins/telescope.lua),
[`dot_config/nvim/lua/plugins/oil.lua`](dot_config/nvim/lua/plugins/oil.lua),
[`dot_config/nvim/lua/plugins/git.lua`](dot_config/nvim/lua/plugins/git.lua),
[`dot_config/nvim/lua/plugins/agents.lua`](dot_config/nvim/lua/plugins/agents.lua)

---

## Cross-tool: clipboard

Anything yanked in nvim (visual mode `y`, normal `Y`, etc.) lands in
the Windows clipboard via `win32yank.exe`. Same for tmux copy mode.
This means `Ctrl-V` in any Windows app pastes what you yanked in WSL.

The bridge is configured automatically when `/proc/version` reports
`microsoft` (i.e., WSL detection). On native Linux it falls back to
the standard X11/Wayland clipboard.

---

## Common workflows

**Refactor with Claude Code:**
1. `tmux new -s <project>` (or attach to existing)
2. `prefix |` to split, `claude` in the new pane, point at the repo
3. Edit / review / accept Claude's changes in nvim with `:Gvdiffsplit` / gitsigns (`]h`, `<leader>hp`, `<leader>hd`)

**Fast file jumping in nvim:**
1. `<leader>ff` (telescope find) — fuzzy by filename
2. `<leader>fg` (telescope live-grep) — fuzzy by content
3. Or in oil: `-` to view parent dir as buffer, edit-to-navigate

**Ask Claude to fix the function under cursor:**
1. Put the cursor in it and note the file and function name (`<leader>fs` lists symbols)
2. `C-l` into the Claude pane, ask for the change by file and function
3. Back in nvim (`C-h`) the buffer reloads on its own; review with `]h` / `<leader>hp`, undo with `u` or `<leader>hr`

**Search across project (zsh):**
1. `rg <pattern>` — ripgrep (no aliased `grep`; muscle memory keeps `grep` for system grep)
2. Or in nvim: `<leader>fg` for live-grep with preview
