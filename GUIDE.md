# Sabhaile — user guide

The README tells you how to install this environment and KEYS.md lists
every key it binds. This is the piece in between: what the environment
is, how the parts fit together, how to work in it day to day, and how to
look after it. It assumes you are comfortable in a Linux shell and want
the setup to make you faster — not a Unix tutorial.

Read §1 once. Live in §3–§6. Come back to §7 when you change something
and §8 when something breaks. §9 is the short list of habits that pay
for the whole thing.

---

## 1. The shape of it

Three programs, one vocabulary.

| Layer | Program | What it gives you |
| --- | --- | --- |
| Shell | zsh + powerlevel10k, plugins via antidote | instant prompt, git state in the prompt, fuzzy everything |
| Multiplexer | tmux + tpm | one session per project, panes that survive reboots, a pane for Claude Code |
| Editor | Neovim 0.12, plugins via lazy.nvim, servers via Mason | LSP, treesitter, fuzzy finding, git hunks, format-on-save |

Underneath: git with SSH-signed commits and the delta pager; ripgrep,
fd, fzf, bat, eza, zoxide, jq, btop; uv for Python, clang for C/C++,
.NET 10 for C#.

The vocabulary that ties them together:

- **vi keys everywhere.** The shell's line editor is in vi mode (zsh
  chooses it because `$EDITOR` is nvim), tmux copy mode is vi, and the
  editor is vim. `Esc` means the same thing in all three.
- **`C-h/j/k/l` moves you around** — between nvim splits *and* tmux
  panes, no prefix. After a day you stop noticing which program owns the
  pane you are in.
- **fzf is the picker** wherever there is a list: tab completion,
  `Ctrl-R` history, `Ctrl-T` files, Telescope inside nvim.
- **One clipboard.** Yank in nvim or tmux and it lands in the Windows
  clipboard (win32yank on WSL); `Ctrl-V` in any Windows app pastes it.
- **Catppuccin Mocha** in the prompt, tmux, nvim and (once its theme is
  installed, see §8) delta, so colours mean the same thing in every pane.
- **`$HOME` is generated.** Every config file comes from the chezmoi
  source repo. You edit the source and apply; per-machine deviations go
  in files the tracked ones source: `~/.zshrc.local`,
  `~/.gitconfig.local`, `~/.config/secrets/*.env`.

The layout is deliberately flat: one shell config, one tmux config, a
dozen small nvim Lua files (one per concern), six numbered bootstrap
scripts. When you want to know why something behaves as it does, the
answer is in a file you can read in a minute — KEYS.md links the file at
the end of each section.

---

## 2. First hour on a new machine

1. Run the bootstrap one-liner from the README. It installs the
   prerequisites, authenticates `gh`, installs chezmoi, clones this repo,
   runs the `run_once_*` scripts (apt packages, tools, nvim, tmux plugins,
   toolchains — 10–15 minutes), generates a per-machine SSH key, uploads
   it to GitHub for auth and signing, and adds it to `allowed_signers`.
2. `exec zsh`. If `~/.p10k.zsh` did not come down for some reason the
   p10k wizard starts; otherwise you get the prompt straight away.
3. `chezmoi status` should print nothing. If it lists every file with a
   mode-only diff, see the umask note in §8.
4. `tmux`. Plugins are already installed; the status bar should be
   Catppuccin. If it is not, `prefix I` installs them.
5. `nvim`, then `:checkhealth`. Expect green for lazy, mason, treesitter
   and the LSP servers. `:Mason` shows what is installed; `:Lazy` shows
   plugins.
6. If you have secrets tracked with age, put the private key at
   `~/.config/chezmoi/key.txt` (mode 0600) and `chezmoi apply` again.
7. Anything this machine needs that the others do not — a `safe.directory`
   for a Windows path, an alias for a local tool — goes in
   `~/.gitconfig.local` or `~/.zshrc.local`, not in the tracked files.

---

## 3. The shell

### The prompt

Two lines. The first shows the OS icon, the directory, and git state; the
second is just the prompt character, so long paths never push your
cursor to the right edge.

- **Directory** is shortened to the shortest unique prefix of each
  parent (something like `~/p/sabhaile` for `~/projects/sabhaile`). Anchors — a repo
  root, a directory with `.python-version` and so on — stay bold and
  unshortened. You can always paste what you see into `cd`.
- **Git** shows branch, ahead/behind, and counts of staged, unstaged and
  untracked files. It is computed asynchronously (gitstatusd), so big
  repos do not slow the prompt.
- **Right side**, only when relevant: the exit code of the last command
  if non-zero, how long it took if more than a couple of seconds,
  background jobs, and context segments such as a Python venv, a
  Kubernetes context, or an AWS profile.
- **Prompt character** doubles as the vi-mode indicator: `❯` in insert
  mode, `❮` in normal mode. It turns red when the last command failed.
- **Transient prompt:** once you run a command, the previous prompt
  collapses to a single line, so scrollback is mostly output.
- **Instant prompt:** the prompt is painted before plugins load. The cost
  is that nothing in `.zshrc` may print to the terminal before the
  instant-prompt block; if you add something that does, p10k warns you.

`p10k configure` re-runs the wizard. The result lands in `~/.p10k.zsh`,
which is tracked — `chezmoi re-add ~/.p10k.zsh` afterwards.

### Vi mode on the command line

Because `$EDITOR` is nvim, zsh starts the line editor in vi insert mode.
Type as normal. `Esc` drops into normal mode: `h`/`l`, `w`/`b`, `0`/`$`,
`x`, `dw`, `cw`, `r`, `~` all work on the command line; `i`/`a`/`A` go
back to insert. Arrow keys, `Ctrl-R`, `Ctrl-T` and `Alt-C` work in both
modes. If a command has gone wrong halfway through typing it, `Esc` `0`
`cw` is often faster than holding backspace.

### Finding commands again

Four ways, from cheapest to most powerful:

| Want | Do |
| --- | --- |
| The command I just ran | `↑` |
| A recent command that started with `docker` | type `docker`, then `↑` / `↓` (substring search) |
| Something I ran last week containing `--prune` | `Ctrl-R`, type fragments in any order, `Enter` |
| Re-run the last command | `!!` (also `sudo !!`) |

History is shared across every open shell, 50 000 entries, duplicates
collapsed, timestamps recorded (`history -i` shows them). **A command
typed with a leading space is not saved** — use that for anything with
a token in it.

### Finding files and directories

- `Ctrl-T` — fuzzy-pick a file under the current directory and insert
  its path at the cursor. Works mid-command: `nvim ` then `Ctrl-T`.
- `Alt-C` — fuzzy-pick a directory and `cd` into it.
- `z <fragment>` — jump to the directory you visit most that matches
  (`z sab` → `~/projects/sabhaile`). zoxide learns from every `cd`.
  `zi` opens an interactive picker.
- `AUTO_CD` is on: typing a directory name alone is a `cd`. `..` works.
- `AUTO_PUSHD` is on: `cd -` goes back, `dirs -v` lists the stack,
  `cd -2` jumps to entry 2.
- `fd <pattern>` — find by name, ignoring `.git` and `.gitignore`d files.
  `rg <pattern>` — grep by content, same ignore rules, `-t py` to
  restrict by language, `-l` for file names only, `--files` to list.

### Completion and suggestions

- `Tab` opens an fzf menu instead of a static list. Type to filter,
  `Enter` to pick, `,` / `.` to move between groups (files vs options,
  for example). Completing a `cd` shows a preview of the directory.
- Ghost text after the cursor is a suggestion from history; `→` or `End`
  accepts it, or keep typing to ignore it.
- Commands turn red as you type when they do not exist, and green when
  they do — cheaper than running them to find out.
- Completion definitions are cached (`~/.zcompdump`) and rebuilt at most
  once a day, which is most of why the shell starts fast.

### The aliases, and how to get around them

| You type | You get | Why |
| --- | --- | --- |
| `ls`, `ll`, `la` | eza with icons, directories first, a git-status column | see at a glance what is modified |
| `tree` | `eza --tree` | `tree -L 2` still works |
| `cat` | `bat -p` (plain, no line numbers) | syntax colour; pages automatically when the output is taller than the screen |
| `less` | `bat` | same, with line numbers and a header |
| `top` | `btop` | |
| `fd` | `fdfind` | Ubuntu renames the binary |
| `g` | `git` | |

When you need the real program — `cat` into a pipe where you do not want
paging, say — prefix with a backslash (`\cat file`) or use `command cat`.
`cat -A` (bat's `--show-all`) shows tabs, trailing spaces and non-printing
characters, which is the fastest way to answer "why does this diff look
identical".

### Environment

`~/.local/bin` and the .NET tool dirs are on `PATH` (set in `.zshenv`, so
scripts and cron see them too). `EDITOR` and `VISUAL` are nvim, which is
what `git commit`, `crontab -e` and `visudo` open. `LESS=-R` so colour
survives paging.

Secrets: any `~/.config/secrets/*.env` file is sourced at the end of
`.zshrc`. Put `export TOKEN=...` lines there, mode 0600, and they never
enter the repo. Machine-local aliases and functions go in
`~/.zshrc.local`, sourced last so they win.

---

## 4. tmux

### Mental model

A **session** per project (or per long-running task). Inside it,
**windows** are tabs and **panes** are splits. The server keeps running
when you detach; the plugins below keep it running across reboots.

The prefix is `C-a`. `C-a C-a` sends a literal `C-a` through to the
program. `prefix a` toggles back to the previous window (tmux-sensible
adds this when the prefix is `C-a`).

### Daily moves

```sh
tmux new -s sabhaile          # start a session named for the project
tmux a -t sabhaile            # reattach from another terminal
tmux ls                       # what is running
```

| Do | Keys |
| --- | --- |
| Switch session (with preview) | `prefix s` |
| Detach, leave everything running | `prefix d` |
| New window in the current directory | `prefix c` |
| Next / previous window | `prefix n` / `prefix p` |
| Split right / below, in the current directory | `prefix \|` / `prefix -` |
| Move between panes | `C-h/j/k/l`, no prefix |
| Zoom a pane to full size, and back | `prefix z` |
| Scratch shell in a floating popup, in the current directory | `prefix P` (exit closes it) |
| Reload the config | `prefix r` |

Windows and panes are numbered from 1 (so `prefix 1` is the first) and
renumber when one closes. The mouse works: click to focus, drag borders
to resize, wheel to scroll (which enters copy mode). Closing the last
shell in a session drops you into another session rather than out of
tmux.

### Copy mode

`prefix [` (or scroll up). Vi keys to move, `/` and `?` to search, `v`
to start a selection (`V` lines, `C-v` block), `y` to copy — straight
to the Windows clipboard — and `q` to leave. Dragging with the mouse
copies too.

For grabbing a path, a commit hash, a URL or an IP that is already on
screen, `prefix F` (tmux-fingers) labels every such token with a letter;
press it to copy, `Shift`+letter to paste it into the pane as well. This
replaces most reasons to reach for the mouse.

### What survives

tmux-resurrect saves the layout, the working directory of every pane,
and pane contents; tmux-continuum saves every 15 minutes and restores on
the next server start. `prefix C-s` saves now, `prefix C-r` restores.
Editors come back open (nvim, less, man and friends are on the default
restore list) and Claude Code panes come back as `claude --continue`,
which resumes the latest conversation in that directory.

### The Claude Code pane

The intended layout: nvim on the left, `claude` in a pane on the right,
the terminal you need for tests below one of them.

- `prefix |`, then `claude` in the new pane.
- `C-h` / `C-l` hop between editor and agent as if they were splits.
- Files Claude edits reload in nvim by themselves within a second (§5).
- When Claude finishes or needs permission while you are elsewhere, it
  rings the bell; the window gets a bell icon in the status bar, and
  `prefix M-n` jumps to the next window with an alert.
- The pane border shows the pane's title; Claude Code sets it to the
  current task.
- `Shift+Enter` inserts a newline in Claude's input (extended keys are
  on for this).

### Status bar

Session name on the left. Directory and clock on the right. Window
list in the middle with the current one highlighted, plus a flag icon
for windows with activity or a bell.

---

## 5. Neovim

### How to find out what a key does

Leader is `Space`. Press it and wait ~400 ms: which-key lists every
continuation. `<leader>fk` fuzzy-searches all keymaps by description.
`:help <thing>` opens the manual in a split you can close with `q`.
`:checkhealth` tells you what is broken.

### Getting to a file

| Want | Do |
| --- | --- |
| A file by name | `<leader>ff` |
| A line by content, across the project | `<leader>fg` (live grep) |
| The word under the cursor, across the project | `<leader>fw` |
| A file I had open recently | `<leader>fr` |
| Another open buffer | `<leader>fb`, or `S-h` / `S-l` to cycle |
| A symbol in this file | `<leader>fs` |
| The directory this file is in | `-` (oil) |
| The picker I just closed, same query | `<leader>fR` |

Telescope pickers: type to filter, `C-n`/`C-p` or arrows to move,
`Enter` opens, `C-v`/`C-x` open in a split, `Esc` closes.

**oil** treats a directory as a text buffer. `-` opens the parent
directory of the current file; `Enter` opens an entry; `-` again goes up.
To rename, delete or create, *edit the buffer* — change a name, `dd` a
line, add a line — and `:w` applies it (with a confirmation). `g.`
toggles dotfiles.

`<leader>x` closes a buffer without closing the window. `<leader>w`
saves, `<leader>q` quits.

### Editing faster than you type

Treesitter parses the file, so text objects follow the code's structure
instead of whitespace:

| Object | Meaning |
| --- | --- |
| `af` / `if` | a function / its body |
| `ac` / `ic` | a class / its body |
| `aa` / `ia` | an argument / just its value |
| `ih` | a git hunk |

Combine with any operator: `daf` deletes a function, `cia` replaces an
argument, `yif` yanks a body, `vac` selects a class. `]m` / `[m` jump
to the next / previous function, `]]` / `[[` to the next / previous
class. In Visual mode `an` / `in` grow / shrink the selection by syntax
node.

- **Surround:** `ysiw"` wraps the word in quotes, `cs"'` changes them
  to single quotes, `ds(` removes the parentheses.
- **Comment:** `gcc` toggles the line, `gc` + motion or selection.
- **Pairs:** brackets and quotes auto-close; typing the closer skips
  over it.
- **Move lines:** in Visual mode `J` / `K` move the selection down / up
  and re-indent; `<` / `>` re-indent and keep the selection.
- **Folds** follow the syntax tree and start open: `za` toggles, `zM`
  closes all, `zR` opens all. Handy for a long file: `zM`, then open the
  one function you care about.
- **Undo is persistent** across sessions. `<leader>uu` opens the undo
  tree when linear undo is not enough.
- `Y` yanks to end of line; `n` / `N` and `C-d` / `C-u` keep the cursor
  centred.

### Language servers

Installed and enabled: basedpyright + ruff (Python), clangd (C/C++,
with clang-tidy and include-what-you-use header insertion), roslyn (C#),
ts_ls (TypeScript), lua_ls, and servers for JSON, YAML, bash and
Markdown. They attach automatically when you open a matching file.

| Do | Keys |
| --- | --- |
| Definition / declaration / implementation | `gd` / `gD` / `gi` |
| References | `grr` (quickfix) or `<leader>fu` (Telescope) |
| Hover docs | `K` |
| Rename across the project | `<leader>rn` |
| Code action (fix, import, refactor) | `<leader>ca` |
| Next / previous diagnostic, with its message | `]d` / `[d` |
| All diagnostics, searchable | `<leader>fd` |
| Inlay hints (types, parameter names) | `<leader>uh` |
| Signature help while typing | `C-k`, or automatic |
| Document symbols | `gO` |

Completion is blink.cmp with the default keys: the menu opens as you
type, `C-n` / `C-p` move, `C-y` accepts, `C-e` dismisses, `C-space`
toggles documentation, `Tab` / `S-Tab` jump between snippet fields.
Sources are LSP, file paths, snippets (friendly-snippets) and words in
the buffer.

**Format on save** is on: stylua for Lua, ruff for Python, clang-format
for C/C++, prettierd for JSON/YAML/Markdown, shfmt for shell, falling
back to the language server. `:FormatToggle` turns it off for the
session; `<leader>F` formats on demand. `:ConformInfo` shows which
formatter will run.

### Git without leaving

Gitsigns marks added, changed and deleted lines in the gutter.

| Do | Keys |
| --- | --- |
| Next / previous hunk | `]h` / `[h` |
| Preview the hunk's diff inline | `<leader>hp` |
| Stage / reset this hunk | `<leader>hs` / `<leader>hr` (in Visual mode: just the selected lines) |
| Stage / reset the whole file | `<leader>hS` / `<leader>hR` |
| Diff the buffer against the index | `<leader>hd` |
| Blame this line | `<leader>hb`; `<leader>ub` toggles inline blame |
| Changed files, as a picker | `<leader>gs` |
| Full porcelain (stage, commit, push, log) | `:Git` (fugitive) |
| Side-by-side diff of the buffer | `:Gvdiffsplit` |

Staging hunks and lines from the editor is how you keep commits small
without the `git add -p` dance.

### Working with Claude Code

Nvim checks for on-disk changes on focus, on buffer switch, and every
second while idle in Normal mode, so Claude's edits appear in the buffer
you are looking at with a `Reloaded <file>` notice. The review loop is:
read the change with `]h` and `<leader>hp`, keep it or `<leader>hr` it,
and stage what you accept with `<leader>hs`. `C-l` and `C-h` hop between
nvim and the Claude pane.

### Housekeeping commands

`:Lazy` (plugins: `U` updates, `X` cleans), `:Mason` (servers and tools:
`U` updates all), `:TSUpdate` (parsers), `:checkhealth`, `:restart`
(reloads the config in place after you change it).

---

## 6. Git, as configured

Things that happen without you asking:

- **Every commit and tag is signed** with the machine's SSH key.
  Verification uses `~/.ssh/allowed_signers`, which the bootstrap
  appends each machine's key to, so `git log --show-signature` shows
  "Good signature" for commits from any of your machines.
- **`git pull` rebases** instead of merging. **`git push`** on a new
  branch sets the upstream itself. **Fetch prunes** branches deleted on
  the remote.
- **Conflicts use zdiff3:** the conflict block shows your side, the
  common ancestor, and their side, which is usually enough to see who
  changed what. **rerere** remembers how you resolved a conflict and
  replays it if the same one comes back (rebases, cherry-picks).
- **Diffs use the histogram algorithm** and mark moved code in a
  different colour from changed code.
- **Mistyped subcommands** prompt to run the corrected one.
- **GitHub auth** goes through `gh`, so HTTPS remotes need no stored
  token.

The pager is **delta**: side by side, line numbers, syntax colour. `n`
and `N` jump between files inside a long diff; `q` quits. When the
terminal is narrow, `git -c delta.side-by-side=false diff` or just
`git --no-pager diff`. (delta's Catppuccin theme is not installed yet —
see §8 — so colours are currently bat's default.)

Aliases: `g st` (short status with branch), `g lg` (graph log, one line
per commit), `g last` (the last commit with its files), `g co`, `g br`,
`g ci`, `g amend` (amend without editing the message), `g unstage
<file>`.

---

## 7. Changing things

Every change follows the same loop: edit the **source** (never the
copy in `$HOME`), apply, and when it is right, commit and push.

```sh
chezmoi cd                    # the source repo
chezmoi edit ~/.zshrc         # opens the source file for a target path
chezmoi diff                  # what apply would change
chezmoi apply                 # write it
chezmoi status                # anything still different?
```

If you edited the copy in `$HOME` instead (it happens), `chezmoi re-add
<path>` copies it back into the source. `re-add` skips templates; for
`~/.gitconfig` use `chezmoi merge ~/.gitconfig`. A brand-new file needs
`chezmoi add <path>` — **re-add does not pick up new files**, which is
the easiest way to lose a new nvim plugin file when moving between
machines. Other machines pick everything up with `chezmoi update`. The
README's "Syncing between machines" section has the full loop.

### Where things go

| I want to… | Edit | Then |
| --- | --- | --- |
| add a shell alias or function | `dot_zshrc` | `chezmoi apply`, `exec zsh` |
| add a zsh plugin | `dot_zsh_plugins.txt` (antidote `user/repo` line) | apply; the static bundle rebuilds on the next shell |
| change the prompt | `p10k configure`, then `chezmoi re-add ~/.p10k.zsh` | |
| add a tmux binding or option | `dot_tmux.conf` | apply, `prefix r` |
| add a tmux plugin | `dot_tmux.conf` (`@plugin` line) | apply, `prefix I` |
| add an nvim plugin | new spec in `dot_config/nvim/lua/plugins/<concern>.lua` | `chezmoi add` if the file is new; `:Lazy sync` |
| add a language server | `ensure_installed` and `servers` in `plugins/lsp.lua`, plus the package list in `run_once_after_04-nvim.sh.tmpl` | `:Mason` installs it, or restart nvim |
| add a formatter | `formatters_by_ft` in `plugins/formatting.lua`, plus the Mason list | |
| add an nvim keymap | `lua/config/keymaps.lua` (general) or the plugin's spec (`keys = {}`) | `:restart`; then KEYS.md |
| add an apt package for all machines | `run_once_before_01-system-packages.sh.tmpl` | install it by hand here (the script already ran; see below) |
| add a git alias or setting | `dot_gitconfig.tmpl` | apply |
| keep a secret | `~/.config/secrets/<name>.env`, or `chezmoi add --encrypt` to track it | |
| something only this machine wants | `~/.zshrc.local`, `~/.gitconfig.local` | nothing to apply |

Document a new key in KEYS.md in the same commit; future you will look
there first.

### run_once scripts

They run once per machine — precisely, once per *content*: change a
script and it runs again on the next apply, which is how new Mason
packages and tmux plugins arrive. They are written to be idempotent
(each step checks before acting). To re-run them all on purpose:

```sh
chezmoi state delete-bucket --bucket=scriptState && chezmoi apply
```

### Keeping tools current

| Tool | Update with |
| --- | --- |
| dotfiles | `chezmoi update` |
| nvim plugins | `:Lazy update` (no automatic checks; `lazy-lock.json` is not tracked, so each machine floats) |
| language servers, formatters | `:Mason`, then `U` |
| treesitter parsers | `:TSUpdate` |
| tmux plugins | `prefix U` |
| zsh plugins | `source ~/.antidote/antidote.zsh && antidote update`, then open a new shell (the static bundle sources the updated clones) |
| apt packages | `sudo apt update && sudo apt upgrade` |
| uv, Python | `uv self update`, `uv python install 3.13` |
| Neovim itself | it is a tarball in `~/.local/nvim-linux-x86_64`; delete that directory and re-run the tools script (see re-running above) to fetch the latest release |

---

## 8. When something is off

**`chezmoi status` lists every file with a mode-only diff.** The shell
umask is `0002` (Ubuntu's private-group default) and chezmoi wants to
write group-writable files. Pin `umask = 0o022` at the top of
`~/.config/chezmoi/chezmoi.toml`, above the `[age]` table. `chezmoi
doctor` reports the umask it sees.

**`chezmoi apply` stops with "has changed since chezmoi last wrote it".**
You edited the `$HOME` copy. Either `chezmoi re-add` it to keep the edit,
or `chezmoi apply --force` to discard it. `chezmoi diff <path>` shows
which lines are at stake.

**Every managed file shows `R` for a script.** A `run_once_*` script's
content changed and it will run on the next apply. That is expected
after pulling.

**tmux exits immediately after a crash or power loss.** continuum can
leave a zero-byte save file that resurrect then restores. In
`~/.local/share/tmux/resurrect/`, point the `last` symlink at the newest
non-empty `tmux_resurrect_*.txt` and start tmux again.

**Shell startup warns "no such file: …vendor-completions/_docker".**
Docker Desktop's WSL integration installs a completion symlink into
`/mnt/wsl`, which only exists while Docker Desktop is running. Harmless;
start Docker or ignore.

**`checkhealth` or `command -v` is slow on WSL.** Windows' `PATH` is
appended to the Linux one (dozens of `/mnt/c/...` entries on a network
filesystem). Setting `appendWindowsPath=false` under `[interop]` in
`/etc/wsl.conf` fixes it; `win32yank.exe` still works because it lives
in `~/.local/bin`, but `explorer.exe`, `code` and similar then need full
paths.

**delta says "Unknown theme 'Catppuccin-mocha'".** The git config names
a bat theme that is not installed. Fix: put the Catppuccin `.tmTheme`
files in `~/.config/bat/themes/`, run `batcat cache --build`, and change
`syntax-theme` in `dot_gitconfig.tmpl` to the name bat reports
(`Catppuccin Mocha`, with a space). Until then delta uses bat's default
theme.

**An nvim plugin misbehaves after an update.** `:Lazy` shows the commit
each plugin is on; `:Lazy restore` goes back to the lock file, `:Lazy
log` shows what changed. For the LSP, `:checkhealth vim.lsp` and
`:LspLog`.

**The prompt shows a warning about instant prompt.** Something in
`.zshrc` printed before the instant-prompt block. Move it below, or
silence its output.

**A program in a pane never receives `C-h` / `C-l`.** vim-tmux-navigator
binds those keys in tmux and forwards them only to panes running vim;
everywhere else tmux uses them to change pane. That is why the shell's
clear-screen is `prefix C-l`, which sends a literal `C-l` to the pane —
use the same trick for a REPL that wants one.

**Need the vault or the plan?** Project notes live in the vault under
`10-projects/Sabhaile` (landing page, narrative, plans); the repo keeps
BACKLOG.md for deferred work and KEYS.md for keys.

---

## 9. Habits that pay for all this

1. **Stop typing paths.** `z name`, `Alt-C`, `Ctrl-T`, and `Tab` with
   fzf. If you typed a path with more than one slash by hand, there was
   a faster way.
2. **Search history, don't scroll it.** `Ctrl-R` with two or three
   fragments beats twenty `↑`s. Prefix plus `↑` for the recent case.
3. **A leading space keeps it out of history.** Tokens, passwords,
   one-off experiments.
4. **One tmux session per project, named.** Detach instead of closing;
   continuum brings it all back tomorrow, including the Claude
   conversation.
5. **Move with `C-h/j/k/l`, everywhere.** Never reach for the mouse to
   change pane.
6. **Copy from the screen with `prefix F`.** Hashes, paths, URLs.
7. **Learn five text objects and one operator each week.** `daf`,
   `cia`, `vih`, `ysiw"`, `gcc` cover most edits you currently do with
   Visual mode and the arrow keys.
8. **Let the LSP navigate.** `gd`, `grr`, `<leader>fs`, `<leader>ca`
   before grep and before scrolling.
9. **Stage hunks, not files.** `<leader>hs` in the editor, and your
   commits stop mixing concerns.
10. **Read diffs in delta.** `g lg` to find the commit, `g show` to read
    it, `n`/`N` to move between files.
11. **When you forget a key, ask the tool:** `Space` and wait, or
    `<leader>fk`, or `prefix ?` in tmux, before opening KEYS.md.
12. **Change the source, not `$HOME`.** If you catch yourself editing
    `~/.zshrc`, stop and `chezmoi edit ~/.zshrc` instead. Commit the
    change and its KEYS.md line together.
