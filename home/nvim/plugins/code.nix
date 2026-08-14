{ lib, pkgs, ... }:

let
  repeatmove = pkgs.vimUtils.buildVimPlugin {
    pname = "repeatmove.nvim";
    version = "unstable";
    src = ./custom/repeatmove.nvim;
  };
  mkRaw = lib.nixvim.mkRaw;
in
  lib.mkMerge [
    {
      plugins.flash.enable = true;
      keymaps = [
        {
          mode = [ "n" ];
          key = "s";
          action = mkRaw ''function() require("flash").jump() end'';
          options.desc = "Flash";
        }
        {
          mode = [ "n" ];
          key = "S";
          action = mkRaw ''function() require("flash").treesitter() end'';
          options.desc = "Flash Treesitter";
        }
        {
          mode = "o";
          key = "r";
          action = mkRaw ''function() require("flash").remote() end'';
          options.desc = "Flash [r]emote";
        }
        {
          mode = [ "o" "x" ];
          key = "R";
          action = mkRaw ''function() require("flash").treesitter_search() end'';
          options.desc = "Flash Treesitter Search";
        }
        {
          mode = "c";
          key = "<C-s>";
          action = mkRaw ''function() require("flash").toggle() end'';
          options.desc = "Flash Search Toggle";
        }
      ];
    }
    {
      plugins.treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
      };
    }
    {
      plugins.treesitter-textobjects = {
        enable = true;
        settings.move.set_jumps = true;
      };
    }
    {
      plugins.mini-ai = {
        enable = true;
        settings = {
          n_lines = 100;
          silent = true;
          search_method = "cover_or_nearest";

          custom_textobjects = {
            f = mkRaw "require('mini.ai').gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {})";
            p = mkRaw "require('mini.ai').gen_spec.treesitter({ a = '@parameter.outer', i = '@parameter.inner' }, {})";
            c = mkRaw "require('mini.ai').gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {})";
            l = mkRaw "require('mini.ai').gen_spec.treesitter({ a = '@loop.outer', i = '@loop.inner' }, {})";
            o = mkRaw ''{ { '%b()', '%b[]', '%b{}', '%b<>' }, '^.().*().$' }'';
            q = mkRaw ''{ { '%b""', "%b'''", '%b``' }, '^.().*().$' }'';
          };

          mappings = {
            around_next = "";
            inside_next = "";
            around_last = "";
            inside_last = "";
            goto_left = "[";
            goto_right = "]";
          };
        };
      };
    }
    {
      extraPlugins = [ repeatmove ];
      extraConfigLua = ''
        require('repeatmove').setup({
          move = {
            { '[f', ']f' },
            { '[p', ']p' },
            { '[c', ']c' },
            { '[l', ']l' },
            { '[d', ']d' },
            { 'm[', 'm]' },
            { 'm{', 'm}' },
          },
          repeat_keys = {
            { '{', '}' },
            { '[', ']' },
            { ',', ';' },
          },
        })
        '';
    }
    {
      plugins.nvim-surround.enable = true;
    }
    {
      plugins.marks = {
        enable = true;
      };
      keymaps = [
        {
          mode = [ "x" ];
          key = "s";
          action = "<Plug>(nvim-surround-visual)";
          options.desc = "Add a surrounding pair around a visual selection";
        }
        {
          mode = [ "x" ];
          key = "S";
          action = "<Plug>(nvim-surround-visual-line)";
          options.desc = "Add a surrounding pair around a visual selection, on new lines";
        }
      ];
    }
    {
      plugins.sleuth.enable = true;
    }
    {
      plugins.highlight-colors = {
        enable = true;
        settings = {
          render = "virtual";
          virtual_symbol = "";
          virtual_symbol_suffix = "";
          virtual_symbol_position = "eol";
        };
      };
    }
    {
      plugins.render-markdown.enable = true;
    }
    {
      plugins.ts-comments.enable = true;
    }
    {
      plugins.image = {
        enable = true;
        settings.integrations.markdown = {
          only_render_image_at_cursor = true;
          only_render_image_at_cursor_mode = "inline";
        };
      };
    }
    {
      plugins.typst-preview.enable = true;
      keymaps = [
        {
          mode = "n";
          key = "<leader>tp";
          action = "<cmd>TypstPreviewToggle<cr>";
          options.desc = "Typst [p]review";
        }
      ];
    }
  ]
