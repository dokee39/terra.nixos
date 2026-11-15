{ lib, ... }:

let
  mkRaw = lib.nixvim.mkRaw;
in {
  plugins.fzf-lua = {
    enable = true;
    profile = "telescope";
    luaConfig.post = "require('fzf-lua').register_ui_select()";

    settings = {
      fzf_opts."--layout" = "reverse";
      keymap.fzf = {
        tab = "down";
        "shift-tab" = "up";
      };
      winopts = {
        row = 0.5;
        backdrop = 100;
        preview = {
          horizontal = "right:62%";
          vertical = "down:62%";
        };
      };
      defaults.file_icons = false;
      git.files.cmd = "git -c core.quotepath=false ls-files --exclude-standard";
      grep = {
        rg_glob = false;
        no_esc = true;
      };
    };

    keymaps = {
      "<leader>fr" = {
        action = "oldfiles";
        settings.cwd_only = true;
        options.desc = "FzfLua [r]ecent files in cwd";
      };
      "<leader><space>" = {
        action = "blines";
        options.desc = "FzfLua current buffer lines";
      };
      "<leader>fb" = {
        action = "buffers";
        options.desc = "FzfLua [b]uffers";
      };
      "<leader>fk" = {
        action = "keymaps";
        options.desc = "FzfLua [k]eymaps";
      };
      "<leader>fh" = {
        action = "helptags";
        options.desc = "FzfLua [h]elp tags";
      };
      "<leader>fm" = {
        action = "marks";
        options.desc = "FzfLua all [m]arks";
      };
      "<leader>fM" = {
        action = "marks";
        settings.marks = "[^A-Z0-9]";
        options.desc = "FzfLua local [M]arks";
      };
    };
  };

  keymaps =
    let
      mkFind =
        { key, scopeExpr, trackedOnly, desc }:
        {
          mode = "n";
          inherit key;
          action = mkRaw ''
            function()
              local fzf = require("fzf-lua")
              local cwd = ${scopeExpr}

              ${lib.optionalString trackedOnly ''
                vim.fn.system({ "git", "-C", cwd, "rev-parse", "--is-inside-work-tree" })
                if vim.v.shell_error == 0 then
                  fzf.git_files({ cwd = cwd })
                  return
                end
              ''}

              fzf.files({ cwd = cwd, hidden = true })
            end
          '';
          options.desc = desc;
        };

      mkGrep =
        { key, scopeExpr, trackedOnly, fixedStrings, desc }:
        {
          mode = [ "n" "x" ];
          inherit key;
          action = mkRaw ''
            function()
              local cwd = ${scopeExpr}
              local opts = {
                cwd = cwd,
                rg_opts = "--column --line-number --no-heading --color=always --smart-case --multiline${lib.optionalString fixedStrings " --fixed-strings"} -e",
              }

              local mode = vim.fn.mode()
              if mode:match("[vV\22]") then
                local lines = vim.fn.getregion(
                  vim.fn.getpos("v"),
                  vim.fn.getpos("."),
                  { type = mode }
                )
                opts.search = table.concat(lines, "\n")
                vim.cmd.normal({ "\27", bang = true })
              end

              ${lib.optionalString trackedOnly ''
                local result = vim.system({ "git", "-C", cwd, "ls-files", "-z" }):wait()
                if result.code == 0 then
                  opts.search_paths = vim.split(result.stdout, "\0", { trimempty = true })
                end
              ''}

              require("fzf-lua").live_grep(opts)
            end
          '';
          options.desc = desc;
        };
    in
      [
        (mkFind {
          key = "<leader>ff";
          scopeExpr = "vim.uv.cwd()";
          trackedOnly = true;
          desc = "FzfLua git files";
        })
        (mkFind {
          key = "<leader>fF";
          scopeExpr = "vim.fn.expand('%:p:h')";
          trackedOnly = true;
          desc = "FzfLua dir git files";
        })
        (mkFind {
          key = "<leader>Ff";
          scopeExpr = "vim.uv.cwd()";
          trackedOnly = false;
          desc = "FzfLua files";
        })
        (mkFind {
          key = "<leader>FF";
          scopeExpr = "vim.fn.expand('%:p:h')";
          trackedOnly = false;
          desc = "FzfLua dir files";
        })
        (mkGrep {
          key = "<leader>fg";
          scopeExpr = "vim.uv.cwd()";
          trackedOnly = true;
          fixedStrings = true;
          desc = "FzfLua git grep";
        })
        (mkGrep {
          key = "<leader>fG";
          scopeExpr = "vim.fn.expand('%:p:h')";
          trackedOnly = true;
          fixedStrings = true;
          desc = "FzfLua dir git grep";
        })
        (mkGrep {
          key = "<leader>Fg";
          scopeExpr = "vim.uv.cwd()";
          trackedOnly = false;
          fixedStrings = false;
          desc = "FzfLua grep";
        })
        (mkGrep {
          key = "<leader>FG";
          scopeExpr = "vim.fn.expand('%:p:h')";
          trackedOnly = false;
          fixedStrings = false;
          desc = "FzfLua dir grep";
        })
      ];
}
