{ lib, ... }:

{
  plugins.telescope = {
    enable = true;
    extensions.fzf-native.enable = true;

    settings = {
      defaults = {
        path_display = [ "truncate" ];
        sorting_strategy = "ascending";

        layout_strategy = "flex";
        layout_config = {
          prompt_position = "top";

          flex = {
            flip_columns = 120;
            flip_lines = 50;
          };

          horizontal = {
            preview_cutoff = 120;
            preview_width = 0.618;
          };

          vertical = {
            preview_cutoff = 50;
            preview_height = 0.618;
            mirror = true;
          };
        };
      };
    };
  };

  keymaps =
    let
      luaBool = b: if b then "true" else "false";

      mkFind =
        { key, scopeExpr, trackedOnly, desc }:
        {
          mode = "n";
          inherit key;
          action.__raw = ''
            function()
              local builtin = require("telescope.builtin")
              local cwd = ${scopeExpr}

              if ${luaBool trackedOnly} then
                vim.fn.system({ "git", "-C", cwd, "rev-parse", "--is-inside-work-tree" })
                if vim.v.shell_error == 0 then
                  builtin.git_files({
                    cwd = cwd,
                    use_git_root = false,
                  })
                  return
                end
              end

              builtin.find_files({
                cwd = cwd,
                hidden = true,
              })
            end
          '';
          options.desc = desc;
        };

      mkGrep =
        { key, scopeExpr, trackedOnly, fixedStrings, desc }:
        {
          mode = [ "n" "v" ];
          inherit key;
          action.__raw = ''
            function()
              local builtin = require("telescope.builtin")
              local cwd = ${scopeExpr}
              local opts = {
                cwd = cwd,
              }

              local mode = vim.fn.mode()
              if mode:match("[vV\22]") then
                local reg = vim.fn.getreg("z")
                local regtype = vim.fn.getregtype("z")
                vim.cmd([[noautocmd normal! "zy]])
                opts.default_text = vim.fn.getreg("z")
                vim.fn.setreg("z", reg, regtype)
              end

              ${lib.optionalString fixedStrings ''
                opts.additional_args = { "--fixed-strings" }
              ''}

              if ${luaBool trackedOnly} then
                local files = vim.fn.systemlist({
                  "git",
                  "-C",
                  cwd,
                  "ls-files",
                  "--exclude-standard",
                  "--cached",
                })
                if vim.v.shell_error == 0 then
                  opts.search_dirs = files
                end
              end

              builtin.live_grep(opts)
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
          desc = "Telescope git files";
        })

        (mkFind {
          key = "<leader>fF";
          scopeExpr = "vim.fn.expand('%:p:h')";
          trackedOnly = true;
          desc = "Telescope dir git files";
        })

        (mkFind {
          key = "<leader>Ff";
          scopeExpr = "vim.uv.cwd()";
          trackedOnly = false;
          desc = "Telescope files";
        })

        (mkFind {
          key = "<leader>FF";
          scopeExpr = "vim.fn.expand('%:p:h')";
          trackedOnly = false;
          desc = "Telescope dir files";
        })

        (mkGrep {
          key = "<leader>fg";
          scopeExpr = "vim.uv.cwd()";
          trackedOnly = true;
          fixedStrings = true;
          desc = "Telescope git grep";
        })

        (mkGrep {
          key = "<leader>fG";
          scopeExpr = "vim.fn.expand('%:p:h')";
          trackedOnly = true;
          fixedStrings = true;
          desc = "Telescope dir git grep";
        })

        (mkGrep {
          key = "<leader>Fg";
          scopeExpr = "vim.uv.cwd()";
          trackedOnly = false;
          fixedStrings = false;
          desc = "Telescope grep";
        })

        (mkGrep {
          key = "<leader>FG";
          scopeExpr = "vim.fn.expand('%:p:h')";
          trackedOnly = false;
          fixedStrings = false;
          desc = "Telescope dir grep";
        })
        {
          mode = "n";
          key = "<leader>fr";
          action.__raw = ''
            function()
              require("telescope.builtin").oldfiles({ cwd_only = true })
            end
          '';
          options.desc = "Telescope [r]ecent files in cwd";
        }
        {
          mode = "n";
          key = "<leader><space>";
          action.__raw = ''
            function()
              require("telescope.builtin").current_buffer_fuzzy_find()
            end
          '';
          options.desc = "Telescope current_buffer_fuzzy_find";
        }
        {
          mode = "n";
          key = "<leader>fb";
          action.__raw = ''
            function()
              require("telescope.builtin").buffers({
                sort_mru = true,
              })
            end
          '';
          options.desc = "Telescope [b]uffers";
        }
        {
          mode = "n";
          key = "<leader>fk";
          action.__raw = ''
            function()
              require("telescope.builtin").keymaps()
            end
          '';
          options.desc = "Telescope [k]eymaps";
        }
        {
          mode = "n";
          key = "<leader>fh";
          action.__raw = ''
            function()
              require("telescope.builtin").help_tags()
            end
          '';
          options.desc = "Telescope [h]elp tags";
        }
        {
          mode = "n";
          key = "<leader>fm";
          action.__raw = ''
            function()
              require("telescope.builtin").marks()
            end
          '';
          options.desc = "Telescope all [m]arks";
        }
        {
          mode = "n";
          key = "<leader>fM";
          action.__raw = ''
            function()
              require("telescope.builtin").marks({ mark_type = "local" })
            end
          '';
          options.desc = "Telescope local [M]arks";
        }
      ];
}
