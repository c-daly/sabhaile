# Backlog

Forward-looking work that's been considered, designed enough to act on,
but deferred. Pull from here when the basics are stable and you want
the next nice thing.

---

## Claude Code ↔ Neovim integration

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

2. **Add a `:checktime` autocmd** to `dot_config/nvim/lua/config/autocmds.lua`
   so files Claude edits on disk reload immediately when the buffer
   regains focus:

   ```lua
   autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
       group = augroup("AutoCheckTime", { clear = true }),
       command = "checktime",
   })
   ```

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
