{ lib, pkgs, inputs, osConfig, ... }:

let
  faster-jk = pkgs.vimUtils.buildVimPlugin {
    pname = "faster-jk.nvim";
    version = "unstable";
    src = ./custom/faster-jk.nvim;
  };
  beacon = pkgs.vimUtils.buildVimPlugin {
    pname = "beacon.nvim";
    version = "unstable-${inputs.beacon.lastModifiedDate}";
    src = inputs.beacon;
  };
  mkRaw = lib.nixvim.mkRaw;
in
  lib.mkMerge [
    {
      extraPlugins = [ pkgs.vimPlugins.vim-lastplace ];
    }
    {
      plugins.persistence.enable = true;
      keymaps = [
        {
          mode = "n";
          key = "<leader>s";
          action = mkRaw ''function() require("persistence").load() end'';
          options.desc = "Load [s]ession";
        }
      ];
    }
    {
      extraPlugins = [ beacon ];
      extraConfigLua = "require('beacon').setup()";
    }
    {
      extraPlugins = [ faster-jk ];
    }
    {
      plugins.better-escape = {
        enable = true;
        luaConfig.pre = ''
          local esc = function()
            local ok, blink = pcall(require, "blink.cmp")
            if ok then
              blink.cancel()
            end
            vim.schedule(function()
              vim.api.nvim_input("<Esc>")
            end)
          end
        '';
        settings = {
          timeout = mkRaw "vim.o.timeoutlen / 8";
          default_mappings = false;
          mappings = {
            i = {
              j = { k = mkRaw ''esc''; };
              k = { j = mkRaw ''esc''; };
            };
          };
        };
      };
    }
    {
      extraPlugins = [ pkgs.vimPlugins.nvim-rip-substitute ];
      extraConfigLua = "require('rip-substitute').setup()";
      keymaps = [
        {
          mode = "n";
          key = "<leader>rr";
          action = mkRaw ''function() require("rip-substitute").sub() end'';
          options.desc = "[r]ip [r]eplace";
        }
        {
          mode = "x";
          key = "<leader>r";
          action = mkRaw ''function() require("rip-substitute").sub() end'';
          options.desc = "[r]ip substitute";
        }
      ];
    }
    (lib.mkIf osConfig.terra.desktop.enable {
      extraPlugins = [ pkgs.vimPlugins.im-select-nvim ];
      extraConfigLua = ''require('im_select').setup({
        default_im_select  = "keyboard-us",
        default_command = "fcitx5-remote",
        set_default_events = { "InsertLeave", "CmdlineLeave" },
        set_previous_events = { "InsertEnter" },
        keep_quiet_on_no_binary = false,
        async_switch_im = true
      })'';
    })
    {
      globals.loaded_netrwPlugin = 1;
      plugins.yazi = {
        enable = true;
        settings.open_for_directories = true;
      };
      keymaps = [
        {
          mode = [ "n" "x" ];
          key = "<leader>y";
          action = "<CMD>Yazi<CR>";
          options.desc = "[y]azi";
        }
        {
          mode = "n";
          key = "<leader>Y";
          action = "<CMD>Yazi cwd<CR>";
          options.desc = "[Y]azi cwd";
        }
        {
          mode = "n";
          key = "<A-y>";
          action = "<CMD>Yazi toggle<CR>";
          options.desc = "Resume [y]azi";
        }
      ];
    }
  ]
