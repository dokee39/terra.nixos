{ lib, ... }:

{
  keymaps = [
    # general
    {
      mode = "n";
      key = "<leader>w";
      action = "<cmd> w <cr>";
      options.desc = "write";
    }
    {
      mode = "n";
      key = "<leader>q";
      action = "<cmd> q <cr>";
      options.desc = "quit";
    }
    {
      mode = "n";
      key = "<C-CR>";
      action = "<cmd> setlocal wrap! <CR>";
      options.desc = "toggle word wrap";
    }

    # clear search highlights & stop active snippet
    {
      mode = "n";
      key = "<Esc>";
      action = lib.nixvim.mkRaw ''
        function()
          if vim.snippet.active() then
            vim.snippet.stop()
          end
          vim.cmd.nohlsearch()
          require("lualine").refresh()
        end
      '';
      options.desc = "general clear highlights";
    }

    # move line(s)
    {
      mode = "n";
      key = "<M-j>";
      action = "<cmd> move +1 <cr>";
      options.desc = "move the line down";
    }
    {
      mode = "n";
      key = "<M-k>";
      action = "<cmd> move -2 <cr>";
      options.desc = "move the line up";
    }
    {
      mode = "v";
      key = "<M-j>";
      action = ":m '>+1<CR>gv=gv";
      options = {
        desc = "move the lines down";
        silent = true;
      };
    }
    {
      mode = "v";
      key = "<M-k>";
      action = ":m '<-2<CR>gv=gv";
      options = {
        desc = "move the lines up";
        silent = true;
      };
    }

    # buffer
    {
      mode = "n";
      key = "<M-n>";
      action = "<cmd> tabnew <cr>";
      options.desc = "[n]ew tab";
    }

    # CTRL - <h j k l>
    {
      mode = "i";
      key = "<C-h>";
      action = "<Left>";
      options.desc = "move left";
    }
    {
      mode = "i";
      key = "<C-j>";
      action = "<Down>";
      options.desc = "move down";
    }
    {
      mode = "i";
      key = "<C-k>";
      action = "<Up>";
      options.desc = "move up";
    }
    {
      mode = "i";
      key = "<C-l>";
      action = "<Right>";
      options.desc = "move right";
    }
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "switch window left";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "switch window right";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.desc = "switch window down";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.desc = "switch window up";
    }

    # comment
    {
      mode = "n";
      key = "<leader>/";
      action = "gcc";
      options.remap = true;
    }
    {
      mode = "v";
      key = "<leader>/";
      action = "gc";
      options.remap = true;
    }
  ];

}
