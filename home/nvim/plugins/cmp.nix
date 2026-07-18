{ lib, ... }:
let
  mkRaw = lib.nixvim.mkRaw;
in {
  plugins = {
    friendly-snippets.enable = true;
    colorful-menu.enable = true;

    blink-cmp = {
      enable = true;
      luaConfig.pre = ''
        local function completion_keyword_tail(line, col)
          local keyword = line:sub(1, col):match("([%w_-]+)$") or ""
          local base = keyword:gsub("[_-]+$", "")
          local segment = base:match("([^-_]+)$") or ""
          local tail =
            segment:match("([A-Z][a-z0-9]+)$")
            or segment:match("([A-Z]+)$")
            or segment

          return keyword, tail
        end

        local function is_ascii_keyword(ctx)
          local bounds = ctx.get_bounds("full")
          local keyword = ctx.line:sub(bounds.start_col, bounds.start_col + bounds.length - 1)
          return not keyword:find("[^%w_-]")
        end

        local function to_lsp_character(line, byte_col, item)
          local client = item.client_id and vim.lsp.get_client_by_id(item.client_id)
          local encoding = client and client.offset_encoding or "utf-8"

          if encoding == "utf-8" then
            return byte_col
          end

          return vim.str_utfindex(line, encoding, byte_col, false)
        end

        -- TODO: migrate to ctx.pos after nixpkgs updates blink.cmp
        local function patch_midword_completion(ctx, items, opts)
          local keyword, tail = completion_keyword_tail(ctx.line, ctx.cursor[2])
          if tail == "" then
            return items
          end

          local row = ctx.cursor[1] - 1
          local col = ctx.cursor[2]
          local start_col = col - #tail
          local prefix = keyword:sub(1, #keyword - #tail)
          local right = ctx.line:sub(col + 1):match("^([%w_-]*)") or ""

          for _, item in ipairs(items) do
            local text = (item.textEdit and item.textEdit.newText) or item.insertText or item.label
            if text ~= nil and text ~= "" then
              local starts_with_tail = text:sub(1, #tail) == tail

              if not opts.require_tail_match or starts_with_tail then
                local end_col = col
                local consume_right =
                  right ~= ""
                  and starts_with_tail
                  and text:sub(-#right) == right

                if consume_right then
                  end_col = col + #right
                end

                item.filterText = prefix .. text

                local range = {
                  start = {
                    line = row,
                    character = to_lsp_character(ctx.line, start_col, item),
                  },
                  ["end"] = {
                    line = row,
                    character = to_lsp_character(ctx.line, end_col, item),
                  },
                }

                if item.textEdit and not opts.force_plain_range then
                  item.textEdit.newText = text
                  if item.textEdit.range then
                    item.textEdit.range = range
                  else
                    item.textEdit.insert = vim.deepcopy(range)
                    item.textEdit.replace = vim.deepcopy(range)
                  end
                else
                  item.textEdit = {
                    newText = text,
                    range = range,
                  }
                  item.insertText = nil
                end
              end
            end
          end

          return items
        end
      '';

      settings = {
        completion = {
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
            auto_show_delay_ms = 200;
            window.border = "rounded";
          };
        };

        keymap = {
          "<Tab>" = [ "select_next" "snippet_forward" "fallback" ];
          "<S-Tab>" = [ "select_prev" "snippet_backward" "fallback" ];
          "<A-Tab>" = [ "snippet_forward" "fallback" ];
          "<A-S-Tab>" = [ "snippet_backward" "fallback" ];
          "<CR>" = [ "select_and_accept" "fallback" ];
        };

        sources = {
          default = [
            "lsp"
            "snippets"
            "path"
            "buffer"
          ];

          providers = {
            lsp = {
              should_show_items = mkRaw ''function(ctx) return is_ascii_keyword(ctx) end'';
              transform_items = mkRaw ''
                function(ctx, items)
                  local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                  items = vim.tbl_filter(function(item)
                    return item.kind ~= CompletionItemKind.Text
                  end, items)
                  return patch_midword_completion(ctx, items, {
                    require_tail_match = true,
                  })
                end
              '';
            };

            buffer = {
              should_show_items = mkRaw ''function(ctx) return is_ascii_keyword(ctx) end'';
              transform_items = mkRaw ''
                function(ctx, items)
                  return patch_midword_completion(ctx, items, {
                    require_tail_match = true,
                  })
                end
              '';
            };

            snippets.score_offset = 0;

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
