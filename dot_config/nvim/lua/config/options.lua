local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitright = true
opt.splitbelow = true

opt.termguicolors = true
opt.background = "dark"

opt.mouse = "a"
opt.clipboard = "unnamedplus"

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"

opt.updatetime = 200
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }

opt.list = true
opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

opt.wildmode = "longest:full,full"
opt.shortmess:append("sI")

opt.fillchars = { eob = " " }

if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
        name = "win32yank",
        copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
        },
        cache_enabled = 0,
    }
end
