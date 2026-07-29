{ lib, inputs, osConfig, ... }:
let
  mkRaw = lib.nixvim.mkRaw;
in {
  performance.combinePlugins.pathsToLink = lib.mkAfter [ "/lib" ];
  plugins = {
    friendly-snippets.enable = true;
    colorful-menu.enable = true;

    blink-cmp = {
      enable = true;
      package = inputs.blink-cmp.packages.${osConfig.terra.system}.blink-cmp;
      luaConfig.pre = ''
        local function is_ascii_keyword(ctx)
          local bounds = ctx.get_bounds("full")
          local keyword = ctx.line:sub(bounds.start_col, bounds.start_col + bounds.length - 1)
          return not keyword:find("[^%w_-]")
        end

        local completion_list = require("blink.cmp.completion.list")
        local show_completion_list = completion_list.show

        completion_list.show = function(ctx, items_by_source)
          local lsp_items = items_by_source.lsp
          local buffer_items = items_by_source.buffer

          if lsp_items and buffer_items then
            local lsp_labels = {}
            for _, item in ipairs(lsp_items) do
              lsp_labels[item.label] = true
            end

            items_by_source = vim.tbl_extend("force", {}, items_by_source)
            items_by_source.buffer = vim
              .iter(buffer_items)
              :filter(function(item) return not lsp_labels[item.label] end)
              :totable()
          end

          return show_completion_list(ctx, items_by_source)
        end
      '';

      settings = {
        fuzzy.implementation = "rust";
        signature = {
          enabled = true;
          window.border = "rounded";
          trigger = {
            enabled = true;
            show_on_trigger_character = false;
            show_on_keyword = true;
          };
        };

        completion = {
          keyword.range = "full";
          list.selection.preselect = false;
          ghost_text.enabled = true;
          menu = {
            max_height = 25;
            border = "rounded";
            draw = {
              columns = mkRaw ''{ { "kind_icon" }, { "label", gap = 1 } }'';
              components.label = {
                text = mkRaw ''
                  function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end
                '';
                highlight = mkRaw ''
                  function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end
                '';
              };
            };
          };
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 50;
            window.border = "rounded";
          };
        };

        keymap = {
          "<Tab>" = [ "select_next" "snippet_forward" "fallback" ];
          "<S-Tab>" = [ "select_prev" "snippet_backward" "fallback" ];
          "<A-Tab>" = [ "snippet_forward" "fallback" ];
          "<A-S-Tab>" = [ "snippet_backward" "fallback" ];
          "<A-k>" = [ "show_signature" "hide_signature" "fallback" ];
          "<CR>" = [ "accept" "fallback" ];
        };

        sources = {
          default = [
            "lsp"
            "snippets"
            "path"
            "buffer"
          ];

          per_filetype = {
            markdown = [ "buffer" "snippets" ];
            gitcommit = [ "buffer" ];
          };

          providers = {
            lsp = {
              fallbacks = mkRaw "{}";
              should_show_items = mkRaw ''function(ctx) return is_ascii_keyword(ctx) end'';
              transform_items = mkRaw ''
                function(_, items)
                  local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                  return vim.tbl_filter(function(item)
                    return item.kind ~= CompletionItemKind.Text
                  end, items)
                end
              '';
            };

            buffer = {
              should_show_items = mkRaw ''function(ctx) return is_ascii_keyword(ctx) end'';
            };

            snippets = {
              score_offset = 0;
              opts.use_label_description = true;
            };

            cmdline.min_keyword_length = 3;
          };
        };
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<A-Tab>";
      action = mkRaw ''
        function()
          if vim.snippet.active({ direction = 1 }) then
            vim.snippet.jump(1)
          end
        end
      '';
      options.desc = "blink.cmp: snippet forward";
    }
    {
      mode = "n";
      key = "<A-S-Tab>";
      action = mkRaw ''
        function()
          if vim.snippet.active({ direction = -1 }) then
            vim.snippet.jump(-1)
          end
        end
      '';
      options.desc = "blink.cmp: snippet backward";
    }
  ];
}
