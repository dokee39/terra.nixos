{ lib, pkgs, inputs, ... }:

let
  navbuddy = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-navbuddy";
    version = "unstable-${inputs.navbuddy.lastModifiedDate}";
    src = inputs.navbuddy;
    dependencies = with pkgs.vimPlugins; [
      nvim-navic
      nui-nvim
    ];
  };
  mkRaw = lib.nixvim.mkRaw;
in {
  lsp = {
    onAttach = ''
      if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
      end
    '';

    servers = {
      nixd = {
        enable = true;
        config.settings = {
          nixd = {
            nixpkgs.expr = ''
              import ((builtins.getFlake "/etc/nixos").inputs.nixpkgs) { }
            '';

            options = {
              nixos.expr = ''
                (builtins.getFlake "/etc/nixos")
                  .nixosConfigurations."nixos-pc"
                  .options
              '';

              home-manager.expr = ''
                (builtins.getFlake "/etc/nixos")
                  .nixosConfigurations."nixos-pc"
                  .options."home-manager".users.type.getSubOptions []
              '';
            };
          };
        };
      };

      lua_ls = {
        enable = true;
        config.settings = {
          Lua = {
            workspace.checkThirdParty = false;
            telemetry.enable = false;
            hint.enable = true;
          };
        };
      };

      clangd = {
        enable = true;
        config = {
          cmd = [
            "clangd"
            "--header-insertion=never"
            "--experimental-modules-support"
          ];
        };
      };

      ts_ls.enable = true;
      cssls.enable = true;
      jsonls.enable = true;

      ruff.enable = true;
      basedpyright = {
        enable = true;
        config.settings.basedpyright = {
          disableOrganizeImports = true;
          analysis.typeCheckingMode = "basic";
          analysis.diagnosticSeverityOverrides = {
            reportUnusedImport = "none";
            reportUnusedVariable = "none";
            reportDuplicateImport = "none";
            reportUndefinedVariable = "none";
            reportUnboundVariable = "none";
          };
        };
      };

      wgsl_analyzer.enable = true;
    };

    keymaps = [
      {
        key = "<leader>d";
        mode = "n";
        action = mkRaw "vim.diagnostic.open_float";
        options.desc = "LSP: show line [d]iagnostics";
      }

      {
        key = "K";
        mode = "n";
        lspBufAction = "hover";
        options.desc = "LSP: hover documentation";
      }
      {
        key = "gD";
        mode = "n";
        lspBufAction = "declaration";
        options.desc = "LSP: [g]oto [D]eclaration";
      }
      {
        key = "+";
        mode = [ "n" "x" ];
        lspBufAction = "format";
        options.desc = "LSP: format";
      }
      {
        key = "<leader>rn";
        mode = "n";
        lspBufAction = "rename";
        options.desc = "LSP: [r]e[n]ame";
      }
      {
        key = "<leader>a";
        mode = [ "n" "x" ];
        lspBufAction = "code_action";
        options.desc = "LSP: Code [a]ction";
      }

      {
        key = "gd";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_definitions";
        options.desc = "LSP: Telescope [g]oto [d]efinition";
      }
      {
        key = "gt";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_type_definitions";
        options.desc = "LSP: [g]oto [t]ype Definition";
      }
      {
        key = "gr";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_references";
        options.desc = "LSP: Telescope [g]oto [r]eferences";
      }
      {
        key = "gi";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_implementations";
        options.desc = "LSP: Telescope [g]oto [i]mplementation";
      }
      {
        key = "gs";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_document_symbols";
        options.desc = "LSP: Telescope [g]oto document [s]ymbols";
      }
      {
        key = "gS";
        mode = "n";
        action = mkRaw "require('telescope.builtin').lsp_dynamic_workspace_symbols";
        options.desc = "LSP: Telescope [g]oto workspace [S]ymbols";
      }
      {
        key = "<leader>D";
        mode = "n";
        action = mkRaw "require('telescope.builtin').diagnostics";
        options.desc = "LSP: Telescope list [D]iagnostics";
      }
    ];
  };

  plugins.rustaceanvim = {
    enable = true;
    settings = {
      tools.float_win_config.border = "rounded";
      server = {
        on_attach = mkRaw ''
          function(_, bufnr)
            vim.keymap.set("n", "K", function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end, { buffer = bufnr, desc = "Rust hover actions" })

            vim.keymap.set("n", "<leader>a", function()
              vim.cmd.RustLsp("codeAction")
            end, { buffer = bufnr, desc = "Rust code action" })

            vim.keymap.set("n", "<leader>e", function()
              vim.cmd.RustLsp("explainError")
            end, { buffer = bufnr, desc = "Rust explain error" })
          end
        '';

        default_settings.rust-analyzer.check.command = "clippy";
      };
    };
  };

  extraConfigLua = ''
    local group = vim.api.nvim_create_augroup("rust_insert_diagnostics", { clear = true })

    vim.api.nvim_create_autocmd("InsertEnter", {
      group = group,
      pattern = "*.rs",
      callback = function(args)
        vim.diagnostic.enable(false, { bufnr = args.buf })
      end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
      group = group,
      pattern = "*.rs",
      callback = function(args)
        vim.diagnostic.enable(true, { bufnr = args.buf })
      end,
    })
  '';

  plugins.nvim-lightbulb = {
    enable = true;
    settings = {
      priority = 5;
      sign.text = "󰌶";
      number.enabled = true;
      autocmd = {
        enabled = true;
        events = mkRaw ''{ "CursorHold" }'';
        updatetime = 50;
      };
    };
  };

  plugins.navic.enable = true;
  plugins.navbuddy = {
    enable = true;
    package = navbuddy;
    settings = {
      window = {
        border = "rounded";
        size = {
          height = "80%";
          width = "80%";
        };
        sections.mid.size = "32%";
      };
      lsp.auto_attach = true;
      mappings."/" = mkRaw ''
        require("nvim-navbuddy.actions").telescope({
          layout_config = {
            height = 0.80,
            width = 0.80,
            prompt_position = "top",
          },
          layout_strategy = "flex"
        }),
        '';
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>n";
      action = "<CMD>Navbuddy<CR>";
      options.desc = "[n]avbuddy";
    }
  ];
}
