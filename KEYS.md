# Keybinding cheatsheet

Concise reference for the keys this config binds. Source-of-truth files
are linked at the end of each section — go there to add/change.

---

## tmux

**Prefix is `C-a`** (rebound from default `C-b`). All bindings below
assume "prefix" means `C-a`.

| Action | Keys |
| --- | --- |
| Vertical split | `prefix \|` |
| Horizontal split | `prefix -` |
| New window in same dir | `prefix c` |
| Move between panes (vim-style) | `prefix h / j / k / l` |
| Mouse: drag to resize, click to focus | `set -g mouse on` is on |
| Reload config | `prefix r` |
| Detach session | `prefix d` (default) |
| List sessions | `prefix s` (default) |

**Copy mode (vi-style):**
- Enter copy mode: `prefix [`
- Start selection: `v`
- Yank to Windows clipboard: `y` *(piped through `win32yank.exe -i --crlf`)*
- Mouse-drag selection also copies to Windows clipboard automatically.
- Exit: `q`

**Plugin keybindings (via tpm):**
- `prefix I` — install new plugins listed in `~/.tmux.conf`
- `prefix U` — update plugins
- `prefix C-s` — save session (tmux-resurrect)
- `prefix C-r` — restore session

**Sessions auto-restore on tmux start** (tmux-continuum).

Source: [`dot_tmux.conf`](dot_tmux.conf)

---

## zsh

**Plugin features active:**
- `fzf-tab` — tab-completion uses fzf interactive UI
- `zsh-autosuggestions` — ghost-text suggestion as you type, accept with `→` or `End`
- `zsh-syntax-highlighting` — invalid commands turn red live
- `zsh-completions` — extra completion definitions

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
| `cat` | `bat -p` (paged on long files via `LESS=-R`) |
| `top` | `btop` |
| `fd` | `fdfind` (Ubuntu names the binary `fdfind`) |
| `g` | `git` |
| `cd` | rewired to zoxide's `__zoxide_z` (still accepts plain paths) |

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
| `<C-h/j/k/l>` | window navigation |

### Visual mode

| Keys | Action |
| --- | --- |
| `<` / `>` | re-indent and keep selection |
| `J` / `K` | move selected lines down/up |

### LSP (active when an LSP attaches to the buffer)

| Keys | Action |
| --- | --- |
| `gd` | goto definition |
| `gD` | goto declaration |
| `gr` | references |
| `gi` | goto implementation |
| `K` | hover docs |
| `<leader>rn` | rename symbol |
| `<leader>ca` | code action menu |
| `<leader>F` | format buffer |
| `[d` / `]d` | prev/next diagnostic |

Format-on-save is on by default. Toggle per-session with `:FormatToggle`.

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

### File system (oil.nvim)

| Keys | Action |
| --- | --- |
| `-` | open parent directory as a buffer |
| `<CR>` | open file/directory under cursor |
| `<C-v>` / `<C-x>` | open in vertical/horizontal split |
| `<C-p>` | preview file |
| `g.` | toggle hidden files |
| Edit the buffer to rename/delete/create | save with `:w` to apply |

### Git

| Keys | Action |
| --- | --- |
| `]h` / `[h` | next/prev hunk |
| `<leader>hs` | stage hunk |
| `<leader>hr` | reset hunk |
| `<leader>hp` | preview hunk |
| `<leader>hb` | full blame for current line |
| `:Git` | open fugitive status (full git porcelain) |
| `:Gvdiff` | vertical diff against index |

### Agents

**Claude Code** is the only active agent. Runs in a tmux pane (uses
Max-sub OAuth — no API key required). No in-buffer plugin binding;
the workflow is split-pane, not inline.

| Step | Keys |
| --- | --- |
| Split pane vertically | `prefix \|` (tmux) |
| Launch agent in new pane | `claude` |
| Hop back to editor | `prefix h` |
| Hop back to agent | `prefix l` |

**avante.nvim** is committed but disabled (`enabled = false`) because
it requires an Anthropic API key. Flip the flag in
`dot_config/nvim/lua/plugins/agents.lua` if a key ever comes into play.

### which-key

Hold any leader key (`<space>`) for ~400ms and `which-key` shows a
popup of available continuations. Useful when you forget a binding.

Source: [`dot_config/nvim/lua/config/keymaps.lua`](dot_config/nvim/lua/config/keymaps.lua),
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
3. Edit / review / accept Claude's changes in nvim with `:Gvdiff` / gitsigns

**Fast file jumping in nvim:**
1. `<leader>ff` (telescope find) — fuzzy by filename
2. `<leader>fg` (telescope live-grep) — fuzzy by content
3. Or in oil: `-` to view parent dir as buffer, edit-to-navigate

**Ask AI to fix the function under cursor:**
1. Visual-select the function (`vap` for paragraph, or `Vif` for inner-function via treesitter text-objects)
2. `<leader>ae` — Avante prompts for an edit instruction, applies as inline diff
3. Accept the diff or hit `u` to undo

**Search across project (zsh):**
1. `rg <pattern>` — ripgrep (no aliased `grep`; muscle memory keeps `grep` for system grep)
2. Or in nvim: `<leader>fg` for live-grep with preview
