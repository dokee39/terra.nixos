{ lib, ... }:

{
  opts = {
    # Hint: use `:h <option>` to figure out the meaning if needed

    # ui
    number = true; # show absolute number
    relativenumber = true; # add numbers to each line on the left side
    cursorline = true; # highlight cursor line underneath the cursor horizontally
    splitbelow = true; # open new horizontal split below
    splitright = true; # open new vertical split right
    termguicolors = true; # enable 24-bit RGB color in the TUI
    showmode = false; # we are experienced, wo don't need the "-- INSERT --" mode hint
    wrap = false;
    scrolloff = 5;
    sidescrolloff = 10;

    # tab
    # tabstop = 4; # number of visual spaces per TAB
    # softtabstop = 4; # number of spacesin tab when editing
    # shiftwidth = 4; # insert 4 spaces on a tab
    # expandtab = true; # tabs are spaces, mainly because of python
    shiftround = true;
    autoindent = true;
    smartindent = true;

    # search
    ignorecase = true; # ignore case in searches by default
    smartcase = true; # but make it case sensitive if an uppercase is entered

    # other
    clipboard = "unnamedplus"; # use system clipboard
    completeopt = "menuone,noselect";
    mouse = "a"; # allow the mouse to be used in Nvim
    exrc = true; # .nvim.lua
    signcolumn = "yes";
    title = true;
    updatetime = 50;
    swapfile = false;
    undofile = true;
  };

  # global
  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  diagnostic.settings = {
    float.border = "rounded";
    update_in_insert = false;
    severity_sort = true;
    virtual_text.prefix = "";
    signs.text = lib.nixvim.mkRaw ''
     {
       [vim.diagnostic.severity.ERROR] = "󰅙",
       [vim.diagnostic.severity.WARN]  = "",
       [vim.diagnostic.severity.INFO]  = "󰋼",
       [vim.diagnostic.severity.HINT]  = "󰌵",
     }
    '';
    underline = true;
  };
}
