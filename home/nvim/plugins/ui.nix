{ lib, pkgs, inputs, osConfig, ... }:

let
  mkRaw = lib.nixvim.mkRaw;
in
  lib.mkMerge [
    {
      plugins.notify = {
        enable = true;
        autoLoad = true;
        settings = {
          stages = "static";
          fps = 1;
          background_colour = "#000000";
          max_width = mkRaw "math.floor(vim.api.nvim_win_get_width(0) / 2)";
          max_height = mkRaw "math.floor(vim.api.nvim_win_get_height(0) / 4)";
        };
      };
    }
    {
      plugins.noice = {
        enable = true;
        autoLoad = true;
        settings = {
          presets = {
            command_palette = true;
            long_message_to_split = true;
            lsp_doc_border = true;
          };
          lsp.progress.enabled = false;
        };
      };
    }
    {
      plugins.blink-pairs = {
        enable = true;
        autoLoad = true;
        package = inputs.blink-pairs.packages.${osConfig.terra.system}.blink-pairs;
        settings = {
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
                  local line = vim.fn.search([[\s\+$]], "nwc")
                  return line ~= 0 and ("TW:" .. line) or ""
                end,
                color = "DiagnosticWarn",
              },
              {
                  function()
                    local space_line = vim.fn.search([[\v^ +]], "nwc")
                    local tab_line = vim.fn.search([[\v^\t+]], "nwc")
                    local same_line = vim.fn.search([[\v^(\t+ | +\t)]], "nwc")

                    local min_line = nil

                    if space_line > 0 and tab_line > 0 then
                      min_line = math.min(space_line, tab_line)
                    end

                    if same_line > 0 then
                      min_line = min_line and math.min(min_line, same_line) or same_line
                    end

                    return min_line and ("MI:" .. min_line) or ""
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
          desc = "Bridge persistence.nvim to barbar session hook";
          callback = mkRaw ''
            function()
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
