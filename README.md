# sabhaile

Personal universal configurator: dotfiles, scripts, and per-machine
state, rendered into `$HOME` by [chezmoi](https://chezmoi.io).
Tracked across WSL2 (Ubuntu), macOS, and Linux desktops.

The name is Irish *sa bhaile* ("at home"), echoing chezmoi's *chez moi*.

## Bootstrap a fresh machine

The single-script path (`bootstrap.sh` at the repo root) handles
everything: prereq tools, gh auth, chezmoi init+apply, SSH key
generation+upload, and `allowed_signers` update.

While the repo is **private**, manually clone first:

```sh
gh repo clone c-daly/sabhaile /tmp/sabhaile && bash /tmp/sabhaile/bootstrap.sh
```

When the repo is **public**:

```sh
curl -fsSL https://raw.githubusercontent.com/c-daly/sabhaile/main/bootstrap.sh | bash
```

The script is idempotent — re-run it if a step fails. Total time on
a fresh machine is ~10–15 minutes (apt installs, Mason LSPs, Python
interpreters via uv).

The only thing the script does **not** do is import the age private
key — that has to be human-supplied (don't put a private key fetch
in a script anyone can run). Drop it at `~/.config/chezmoi/key.txt`
and re-run `chezmoi apply` to decrypt any tracked secrets. See
[Secrets](#secrets) below.

## Stack

| Layer | Choice |
| --- | --- |
| Shell | zsh + [antidote](https://github.com/mattmc3/antidote) (static plugin cache) |
| Prompt | [powerlevel10k](https://github.com/romkatv/powerlevel10k) |
| Multiplexer | tmux + [tpm](https://github.com/tmux-plugins/tpm) — prefix `C-a` |
| Editor | Neovim, handwritten Lua config on [lazy.nvim](https://github.com/folke/lazy.nvim) |
| Completion | [blink.cmp](https://github.com/saghen/blink.cmp) + LuaSnip |
| LSP manager | nvim-lspconfig + [mason.nvim](https://github.com/williamboman/mason.nvim) |
| LSPs | basedpyright, ruff, clangd, [roslyn.nvim](https://github.com/seblyng/roslyn.nvim), lua_ls, jsonls, yamlls, bashls, marksman |
| AI agents | [avante.nvim](https://github.com/yetone/avante.nvim) (inline) + Claude Code (tmux pane) |
| Python | [uv](https://github.com/astral-sh/uv) |
| C / C++ | clang, clangd, cmake, ninja, ccache, gdb |
| .NET | dotnet-sdk-10.0 |
| Modern CLI | fzf, ripgrep, fd, bat, eza, zoxide, [git-delta](https://github.com/dandavison/delta), jq, btop |
| Clipboard bridge (WSL) | win32yank |
| Terminal font | any Nerd Font without the `Mono` suffix (JetBrainsMono Nerd Font, MesloLGS NF, Hack Nerd Font, …) |

## Layout

```
.
├── dot_zshrc, dot_zshenv, dot_zsh_plugins.txt   # zsh
├── dot_p10k.zsh                                  # prompt
├── dot_tmux.conf                                 # tmux
├── dot_config/nvim/                              # neovim (init.lua + lua/{config,plugins})
├── dot_gitconfig.tmpl                            # git: delta pager + SSH commit signing
├── private_dot_ssh/allowed_signers               # public keys for SSH commit verification
├── run_once_before_01-system-packages.sh.tmpl    # apt installs
├── run_once_before_02-tools.sh.tmpl              # antidote, win32yank, uv, gh
├── run_once_after_03-shell.sh.tmpl               # chsh to zsh
├── run_once_after_04-nvim.sh.tmpl                # Lazy sync + Mason install
├── run_once_after_05-tmux.sh.tmpl                # tpm + plugins
├── run_once_after_06-toolchains.sh.tmpl          # .NET, C/C++, uv-managed Python
├── .chezmoiignore                                # defensive ignores (private keys, secrets)
└── .chezmoidata.toml                             # public defaults (name, no-reply email)
```

## chezmoi naming convention (quick primer)

| Source pattern | Materialises as |
| --- | --- |
| `dot_zshrc` | `~/.zshrc` |
| `dot_config/nvim/init.lua` | `~/.config/nvim/init.lua` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` (Go-template rendered) |
| `private_dot_ssh/config` | `~/.ssh/config` (mode 0600) |
| `encrypted_dot_config/foo.env` | `~/.config/foo.env` (age-decrypted) |
| `run_once_before_NN-name.sh` | runs once before file apply, in name order |
| `run_once_after_NN-name.sh` | runs once after file apply, in name order |

Daily verbs: `chezmoi cd`, `chezmoi edit ~/.zshrc`, `chezmoi apply`,
`chezmoi diff`, `chezmoi status`, `chezmoi add [--encrypt] <path>`.

## Secrets

In-repo encryption via chezmoi's native [age](https://github.com/FiloSottile/age)
integration. Encrypted files have an `encrypted_` prefix in source
and decrypt at apply-time.

- Per-machine **age private key**: `~/.config/chezmoi/key.txt` —
  never tracked in this repo (see `.chezmoiignore`).
- Per-machine **chezmoi.toml**: `~/.config/chezmoi/chezmoi.toml` —
  also never tracked, holds the local age recipient.
- To track an encrypted secret:
  ```sh
  chezmoi add --encrypt ~/.config/secrets/anthropic.env
  ```

The age private key **cannot be regenerated**. Back it up to a
password manager / printout / external drive before encrypting
anything important; otherwise the encrypted file becomes permanently
unreadable on a new machine.

## tmux prefix

Prefix is `C-a`, not the default `C-b`. If sharing a machine, alias
or rebind locally rather than editing the tracked config.

## WSL2 specifics

- Install a Nerd Font on Windows (the variants *without* the `Mono`
  suffix render p10k icons correctly).
- Set the Windows Terminal WSL profile to use that font.
- The `run_once_before_02-tools.sh` script auto-installs `win32yank`
  for tmux/nvim ↔ Windows clipboard bridge when `/proc/version`
  reports a Microsoft kernel.

## macOS

Mac bootstrap is forthcoming — current `run_once_before_01-system-packages.sh`
returns an error on `darwin`. To unblock the Mac path, populate the
`{{ if eq .chezmoi.os "darwin" }}` branch with brew installs of the
same tools, then iterate.

## License

Personal config, no warranty. Fork freely if anything's useful;
attribution unnecessary.
