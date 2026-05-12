#!/usr/bin/env bash
# bootstrap.sh — one-shot machine bootstrap for sabhaile.
#
# While the repo is private:
#   gh repo clone c-daly/sabhaile /tmp/sabhaile
#   bash /tmp/sabhaile/bootstrap.sh
#
# When the repo is public:
#   curl -fsSL https://raw.githubusercontent.com/c-daly/sabhaile/main/bootstrap.sh | bash
#
# Idempotent — safe to re-run if a step fails.

set -euo pipefail

REPO="c-daly/sabhaile"
SIGNING_EMAIL="83555576+c-daly@users.noreply.github.com"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
info() { printf '\033[34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m==>\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31m==> ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# 1. OS detection
case "$(uname -s)" in
    Linux)  os=linux ;;
    Darwin) os=darwin ;;
    *)      die "Unsupported OS: $(uname -s)" ;;
esac
info "Detected OS: ${os}"

# 2. Pre-req tools (git, curl, gh, ca-certs) — needed before chezmoi can clone
info "Installing pre-req tools (git, curl, gh)..."
if [[ ${os} == linux ]]; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git curl ca-certificates gnupg lsb-release
    if ! command -v gh >/dev/null; then
        info "Adding GitHub CLI apt feed..."
        sudo mkdir -p -m 755 /etc/apt/keyrings
        keyring=/etc/apt/keyrings/githubcli-archive-keyring.gpg
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            | sudo tee "${keyring}" > /dev/null
        sudo chmod go+r "${keyring}"
        arch=$(dpkg --print-architecture)
        echo "deb [arch=${arch} signed-by=${keyring}] https://cli.github.com/packages stable main" \
            | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gh
    fi
elif [[ ${os} == darwin ]]; then
    if ! command -v brew >/dev/null; then
        die "Homebrew not installed. Install from https://brew.sh first, then re-run."
    fi
    brew install --quiet git gh
fi

# 3. gh authentication (idempotent — skips if already authed)
if ! gh auth status >/dev/null 2>&1; then
    info "Authenticating gh (browser flow — paste device code when prompted)..."
    gh auth login --git-protocol ssh --hostname github.com
else
    info "gh already authenticated as $(gh api user --jq .login)"
fi

# 4. Install chezmoi into ~/.local/bin (no sudo)
mkdir -p "${HOME}/.local/bin"
if [[ ! -x "${HOME}/.local/bin/chezmoi" ]]; then
    info "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
fi
export PATH="${HOME}/.local/bin:${PATH}"

# 5. chezmoi init + apply (clones repo, runs run_once_*, materialises files)
if [[ ! -d "$(chezmoi source-path 2>/dev/null || echo /nonexistent)" ]]; then
    info "Cloning ${REPO} and applying (10–15 min for full bootstrap)..."
    chezmoi init --apply "${REPO}"
else
    info "chezmoi source already exists — running apply only..."
    chezmoi apply
fi

# 6. Per-machine SSH key
if [[ ! -f "${HOME}/.ssh/id_ed25519" ]]; then
    info "Generating per-machine SSH key..."
    mkdir -p "${HOME}/.ssh" && chmod 700 "${HOME}/.ssh"
    ssh-keygen -t ed25519 -N "" \
        -C "${SIGNING_EMAIL} — $(hostname)" \
        -f "${HOME}/.ssh/id_ed25519"
    info "Uploading SSH key to GitHub (auth + signing)..."
    gh ssh-key add "${HOME}/.ssh/id_ed25519.pub" \
        --title "$(hostname)"
    gh ssh-key add "${HOME}/.ssh/id_ed25519.pub" \
        --type signing --title "$(hostname) (signing)"
else
    info "SSH key already exists, skipping generation/upload"
fi

# 7. Append this machine's pubkey to allowed_signers (commit + push if new)
pubkey=$(awk '{print $1, $2}' "${HOME}/.ssh/id_ed25519.pub")
sigs="$(chezmoi source-path)/private_dot_ssh/allowed_signers"
if ! grep -qF "${pubkey}" "${sigs}" 2>/dev/null; then
    info "Adding $(hostname) pubkey to allowed_signers..."
    echo "${SIGNING_EMAIL} ${pubkey}" >> "${sigs}"
    (
        cd "$(chezmoi source-path)"
        git add private_dot_ssh/allowed_signers
        git commit -m "Add $(hostname) pubkey to allowed_signers"
        git push
    )
    chezmoi apply
else
    info "$(hostname) pubkey already in allowed_signers"
fi

# 8. Age key — must be human-supplied (security: never embed in a script)
if [[ ! -f "${HOME}/.config/chezmoi/key.txt" ]]; then
    bold ""
    bold "================================================================"
    bold "  ACTION REQUIRED: age private key not present on this machine"
    bold "================================================================"
    cat <<EOF

To decrypt encrypted secrets in sabhaile, place the age private key at:

    ~/.config/chezmoi/key.txt   (mode 0600)

Source it from your password manager / printout / a trusted machine.
After dropping it in, run:

    chezmoi apply

If this is a brand-new identity (no age key exists anywhere), generate one:

    age-keygen -o ~/.config/chezmoi/key.txt
    chmod 600 ~/.config/chezmoi/key.txt

…then add the public key to ~/.config/chezmoi/chezmoi.toml's [age]
recipient list (or as an additional recipient on every encrypted file).

EOF
fi

bold ""
bold "Bootstrap complete. Open a new terminal or run 'exec zsh' to enter the new shell."
bold "First-shell tasks:"
bold "  - p10k will auto-launch its configure wizard if ~/.p10k.zsh isn't tracked yet"
bold "  - chezmoi status   should report no drift"
