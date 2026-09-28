# Backlog

Forward-looking work that's been considered, designed enough to act on,
but deferred. Pull from here when the basics are stable and you want
the next nice thing.

---

## Claude Code ↔ Neovim integration

**Status (2026-09-23):** deferred, not worth it yet. A `claudecode.nvim`
branch was tried and never merged, because it amounted to a terminal
panel inside nvim rather than real integration. What's actually wanted:
seeing the files Claude creates or modifies, opening file links from
Claude's output in nvim, and Claude knowing what's open in nvim.
Already done outside this plan: files changed on disk auto-reload (step 2
below), and `C-h/j/k/l` hops between nvim and the Claude pane
(vim-tmux-navigator).

**What:** wire Claude Code (running in a tmux pane) to the Neovim pane
so the two cooperate as an IDE — file mentions in the chat pane jump
to the right buffer in nvim, selections in nvim get sent to Claude
with one keybinding, and Claude's edits land instantly in the open
buffer.

**Why:** the current pattern is "agent in side pane, editor in another
pane, copy-paste between them." Tighter integration removes the
copy-paste tax, lets Claude see the live editor context, and turns the
agent into a real IDE peer rather than a separate program you happen
to be running nearby.

**Approach:** install `coder/claudecode.nvim`. It implements Claude
Code's IDE socket protocol on the nvim side — same protocol the
official VS Code extension uses. No API key needed; works against
the `claude` CLI you already use via the Max-sub OAuth.

### Steps

1. **Add the plugin spec.** New file or appended to
   `dot_config/nvim/lua/plugins/agents.lua`:

   ```lua
   {
       "coder/claudecode.nvim",
       dependencies = { "folke/snacks.nvim" },  -- for the diff UI
       config = true,
       keys = {
           { "<leader>cc", "<cmd>ClaudeCode<cr>",          desc = "Toggle Claude Code" },
           { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>",     desc = "Focus Claude Code" },
           { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude Code" },
           { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last session" },
           { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>",     desc = "Add current buffer to context" },
           { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
           { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
           { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
       },
   }
   ```

2. ~~**Add a `:checktime` autocmd**~~ **Done 2026-09-23** in
   `dot_config/nvim/lua/config/autocmds.lua`: checks on
   `FocusGained` / `BufEnter` / `TermLeave` plus a 1-second timer in
   Normal mode. The `CursorHold` version first planned here didn't
   reload while you sat watching, because `CursorHold` fires only once
   per idle period.

3. **Update KEYS.md** Agents section with the new bindings (`<leader>c*`)
   and remove the "no nvim binding" caveat from the Claude Code paragraph.

4. **Apply + sync:**
   ```sh
   chezmoi apply
   nvim --headless "+Lazy! sync" +qa
   ```

5. **Verification:** open nvim, hit `<leader>cc` to launch Claude Code
   in a managed terminal, ask it to "edit this file" with the current
   buffer in context, accept the proposed diff with `<leader>ca`,
   confirm the change shows up live in the buffer.

### Effort & risk

- ~30 min including push, sync, smoke test
- Plugin is ~v0.x as of late 2025; semver bumps may shift command
  names — re-verify the `:ClaudeCode*` command list before adopting
- snacks.nvim is the only new dep (already used by some other plugins;
  small)
- Claude Code's IDE socket only opens when invoked from the integrated
  terminal, not when you run `claude` in an unrelated tmux pane —
  expect to switch from "tmux split + claude" to "`<leader>cc` inside nvim"

---

## (Future entries go below — keep newest at top, oldest at bottom)

## nvim-treesitter: move from `master` to `main`

**What:** switch nvim-treesitter (and nvim-treesitter-textobjects) from
the `master` branch to `main`, then delete the compatibility shim in the
`init` function of `dot_config/nvim/lua/plugins/treesitter.lua`.

**Why:** `master` is locked and its README says "Neovim 0.12 is **not
supported**". On 0.12, markdown files with a language-tagged code fence
errored on open (`attempt to call method 'range'`), because 0.12 dropped
the `all = false` option that master's query handlers rely on. The shim
(added 2026-09-24) restores that behaviour. It works, but master gets no
fixes, so the next Nvim change it trips over stays broken.

**Prerequisites** (from `main`'s README):
- Neovim 0.12.0+. Its support policy is the *latest* stable release, so
  update the tarball install first (0.12.2 → 0.12.5 as of 2026-09-24).
- `tar`, `curl` and a C compiler.
- `tree-sitter-cli` **0.26.1 or later**, from a package manager or a
  release binary, **not npm**. It isn't installed now. Check whether
  Ubuntu's apt version is new enough; otherwise add a release-binary
  download to `run_once_before_02-tools.sh.tmpl`.

### Steps

1. **Rewrite `plugins/treesitter.lua` for `main`:** `lazy = false` (main
   doesn't support lazy-loading), `branch = "main"`, parsers via
   `require('nvim-treesitter').install({...})`, and a `FileType`
   autocmd that calls `vim.treesitter.start()` and sets
   `indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"`.
   Folding already uses Nvim's own `vim.treesitter.foldexpr()` and is
   unaffected.
2. **Text objects:** move nvim-treesitter-textobjects to its `main`
   branch too. It has no `textobjects = {...}` setup table there, so the
   `af`/`if`/`ac`/`ic`/`aa`/`ia` and `]m`/`[m`/`]]`/`[[` keys become
   explicit keymaps. Check its README for the current API.
3. **Delete the shim** (the `init` function) and remove the old
   parsers (`:TSUninstall all` on master first, or clear the parser
   directory), then reinstall on `main`.
4. **Verify:** open `README.md` (has a `sh` code fence): no error, and the
   fence is highlighted as bash. Check the text objects in a Python and a
   C# file, and run `:checkhealth nvim-treesitter` with `/mnt` stripped
   from PATH (see the cheatsheet's Config health).
5. **Update docs:** KEYS.md (text-objects section), the README stack
   row, and the cheatsheet.
