{ lib, pkgs, inputs, ... }:

let
  fidget = pkgs.vimUtils.buildVimPlugin {
    pname = "fidget.nvim";
    version = "unstable-${inputs.fidget.lastModifiedDate}";
    src = inputs.fidget;
  };
  mkRaw = lib.nixvim.mkRaw;
in
  lib.mkMerge [
    {
      extraPlugins = [ pkgs.vimPlugins.tiny-cmdline-nvim ];
      extraConfigLua = ''
        require('vim._core.ui2').enable({
          msg = {
            targets = 'msg',
            msg = { timeout = 5000, },
          },
        })
        require('tiny-cmdline').setup({
          position = { y = 3 },
          width = { value = "70%" },
          title = { enabled = true },
          on_reposition = require('tiny-cmdline').adapters.blink,
        })
      '';
    }
    {
      plugins.fidget = {
        enable = true;
        package = fidget;
        settings = {
          progress.poll_rate = false;
          notification = {
            override_vim_notify = true;
            view.reflow = "hyphenate";
            window = {
              max_width = 0.75;
              normal_hl = "PmenuSel";
              winblend = 0;
            };
          };
        };
      };
    }
    {
      plugins.blink-pairs = {
        enable = true;
        autoLoad = true;
        package = inputs.blink-pairs.packages.${pkgs.stdenv.hostPlatform.system}.blink-pairs;
        settings = {
          mappings.wrap = {
            "<C-b>" = false;
            "<C-S-b>" = false;
            "<A-w>" = "motion";
            "<A-S-w>" = "motion_reverse";
          };
          highlights.groups = [
            "Keyword"
            "DiagnosticError"
            "DiagnosticOk"
            "DiagnosticWarn"
            "DiagnosticHint"
          ];
        };
      };
    }
    {
      plugins.blink-indent = {
        enable = true;
        autoLoad = true;
        luaConfig.pre = ''
          local function set_my_hl()
            local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false, })
            if cursorline.bg then
              vim.api.nvim_set_hl(0, "HighlightIndent", { fg = cursorline.bg, })
            end
          end

          set_my_hl()
          vim.api.nvim_create_autocmd("ColorScheme", {
            callback = set_my_hl,
          })
        '';

        settings = {
          mappings = {
            object_scope = "";
            object_scope_with_border = "";
            goto_top = "";
            goto_bottom = "";
          };
          static = {
            enabled = true;
            char = "│";
            highlights = [
              "HighlightIndent"
            ];
          };
          scope = {
            enabled = true;
            char = "│";
            highlights = [
              "DiagnosticSignInfo"
            ];
            underline = {
              enabled = true;
              highlights = [
                "DiagnosticUnderlineInfo"
              ];
            };
          };
        };
      };
    }
    {
      plugins.gitsigns = {
        enable = true;
        autoLoad = true;
      };
    }
    {
      plugins.nui = {
        enable = true;
        autoLoad = true;
      };
    }
    {
      extraPlugins = [ pkgs.vimPlugins.colorful-winsep-nvim ];
      extraConfigLua = ''
        require("colorful-winsep").setup({
          animate = { enabled = false }
        })
        '';
    }
    {
      plugins.web-devicons = {
        enable = true;
        autoLoad = true;
      };
    }
    {
      plugins.lualine = {
        enable = true;
        settings = {
          options = {
            section_separators = {
              left = "";
              right = "";
            };
            component_separators = "";
            globalstatus = true;
          };

          sections = {
            lualine_a = mkRaw ''{
              { "mode", separator = { left = "" } },
            }'';

            lualine_b = mkRaw ''{
              {
                "filename",
                padding = { left = 1, right = 0 },
              },
              {
                "b:gitsigns_head",
                icon = "",
              },
            }'';

            lualine_c = mkRaw ''{
              {
                "diff",
                source = function()
                  local gitsigns = vim.b.gitsigns_status_dict
                  if gitsigns then
                    return {
                      added = gitsigns.added,
                      modified = gitsigns.changed,
                      removed = gitsigns.removed,
                    }
                  end
                end,
              },
              "diagnostics",
            }'';

            lualine_x = mkRaw ''{
              { "selectioncount", color = "DiagnosticHint"  },
              { "searchcount", color = "DiagnosticInfo"  },
              {
                function()
                  return vim.b.lualine_tw or ""
                end,
                color = "DiagnosticWarn",
              },
              {
                function()
                  return vim.b.lualine_mi or ""
                end,
                color = "DiagnosticError",
              },
            }'';

            lualine_y = mkRaw ''{
              {
                "encoding",
                cond = function()
                  local enc = vim.bo.fileencoding
                  if enc == "" then
                    enc = vim.o.encoding
                  end
                  return enc:lower() ~= 'utf-8'
                end
              },
              {
                "fileformat",
                cond = function() return vim.bo.fileformat ~= 'unix' end
              },
              {
                "filetype",
                padding = { left = 1, right = 0 },
              },
              {
                "lsp_status",
                padding = { left = 0, right = 1 },
                icon = "",
                symbols = { done = "󰁨" },
                show_name = false,
              },
              { "progress" },
            }'';

            lualine_z = mkRaw ''{
              { "location", separator = { right = "" } },
            }'';
          };
          inactive_sections = {};
        };
      };
      autoCmd = [
        {
          event = [ "BufEnter" "TextChanged" "InsertLeave" ];
          desc = "Cache trailing whitespace and mixed indent line for lualine";
          callback = mkRaw ''
            function(args)
              local buf = args.buf
              if vim.bo[buf].buftype ~= "" then
                return
              end

              local tw_line, space_line, tab_line, mi_line
              for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
                if not tw_line and line:find("[ \t]$") then
                  tw_line = i
                end
                if not mi_line then
                  if line:find("^\t+ ") or line:find("^ +\t") then
                    mi_line = space_line or tab_line or i
                  elseif not space_line and line:find("^ +") then
                    space_line = i
                    mi_line = tab_line
                  elseif not tab_line and line:find("^\t+") then
                    tab_line = i
                    mi_line = space_line
                  end
                end
                if tw_line and mi_line then
                  break
                end
              end

              vim.b[buf].lualine_tw = tw_line and ("TW:" .. tw_line) or nil
              vim.b[buf].lualine_mi = mi_line and ("MI:" .. mi_line) or nil
            end
          '';
        }
      ];
    }
    {
      plugins.barbar = {
        enable = true;
        settings = {
          animation = false;
          insert_at_end = true;
          icons.button = false;
        };
      };
      autoCmd = [
        {
          event = "User";
          pattern = "PersistenceSavePre";
          desc = "Prune deleted arguments and bridge persistence.nvim to barbar";
          callback = mkRaw ''
            function()
              local args = vim.fn.argv()
              for index = #args, 1, -1 do
                local bufnr = vim.fn.bufnr(args[index])
                if bufnr < 0 or vim.fn.buflisted(bufnr) == 0 then
                  vim.cmd.argdelete({ range = { index, index } })
                end
              end

              vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
            end
          '';
        }
      ];
      extraConfigLuaPre = ''
        vim.opt.sessionoptions:append("globals")
      '';
      keymaps = [
        {
          mode = "n";
          key = "<S-Tab>";
          action = "<cmd>BufferPrevious<CR>";
          options = {
            desc = "buffer previous";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<Tab>";
          action = "<cmd>BufferNext<CR>";
          options = {
            desc = "buffer next";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<A-[>";
          action = "<cmd>BufferMovePrevious<CR>";
          options = {
            desc = "buffer move previous";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<A-,>";
          action = "<cmd>BufferMovePrevious<CR>";
          options = {
            desc = "buffer move previous";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<A-;>";
          action = "<cmd>BufferMoveNext<CR>";
          options = {
            desc = "buffer move next";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<A-.>";
          action = "<cmd>BufferMoveNext<CR>";
          options = {
            desc = "buffer move next";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<A-]>";
          action = "<cmd>BufferMoveNext<CR>";
          options = {
            desc = "buffer move next";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>x";
          action = "<cmd>BufferClose<CR>";
          options = {
            desc = "close buffer";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>X";
          action = "<cmd>BufferRestore<CR>";
          options = {
            desc = "restore buffer";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>p";
          action = "<cmd>BufferPick<CR>";
          options = {
            desc = "[p]ick buffer";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>P";
          action = "<cmd>BufferPickDelete<CR>";
          options = {
            desc = "[P]ick and delete buffer";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<A-p>";
          action = "<cmd>BufferPin<CR>";
          options = {
            desc = "[p]in buffer";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>bb";
          action = "<cmd>BufferOrderByBufferNumber<CR>";
          options = {
            desc = "[b]uffer order by buffer [n]umber";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>bn";
          action = "<cmd>BufferOrderByName<CR>";
          options = {
            desc = "[b]uffer order by [n]ame";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>bd";
          action = "<cmd>BufferOrderByDirectory<CR>";
          options = {
            desc = "[b]uffer order by [d]irectory";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>bl";
          action = "<cmd>BufferOrderByLanguage<CR>";
          options = {
            desc = "[b]uffer order by [l]anguage";
            noremap = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>bw";
          action = "<cmd>BufferOrderByWindowNumber<CR>";
          options = {
            desc = "[b]uffer order by [w]indow number";
            noremap = true;
            silent = true;
          };
        }
      ];
    }
  ]
