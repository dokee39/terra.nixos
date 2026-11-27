{ lib, pkgs, inputs, osConfig, sources, customPackages, ... }:

let
  clice = pkgs.vimUtils.buildVimPlugin {
    pname = "clice-nvim";
    version = sources.clice-nvim.version;
    src = "${pkgs.fetchFromGitHub {
      inherit (sources.clice-nvim) owner repo rev hash;
    }}/editors/nvim";
    postInstall = ''
      # Override nvim-lspconfig's bundled config.
      mkdir -p $out/after
      mv $out/lsp $out/after/lsp
    '';
  };
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
  extraPackages = [ pkgs.nixfmt ];
  extraPlugins = [ clice ];

  lsp = {
    onAttach = ''
      if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
      end
    '';

    servers = {
      "*".config.capabilities = mkRaw "require('blink.cmp').get_lsp_capabilities()";

      nixd = {
        enable = true;
        config.settings = {
          nixd = {
            formatting.command = [ "nixfmt" ];
            nixpkgs.expr = ''
              import ((builtins.getFlake "/etc/nixos").inputs.nixpkgs) { }
            '';

            options = {
              nixos.expr = ''
                (builtins.getFlake "/etc/nixos")
                  .nixosConfigurations."${osConfig.terra.hostName}"
                  .options
              '';

              home-manager.expr = ''
                (builtins.getFlake "/etc/nixos")
                  .nixosConfigurations."${osConfig.terra.hostName}"
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

      clice = {
        enable = true;
        package = customPackages.clice;
        config.init_options.code_completion = {
          insert_includes = false;
          insert_imports = false;
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
      tinymist.enable = true;
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
        action = mkRaw ''
          function()
            vim.lsp.buf.hover({ border = "rounded" })
          end
        '';
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
        action = mkRaw "require('fzf-lua').lsp_code_actions";
        options.desc = "LSP: FzfLua Code [a]ction";
      }

      {
        key = "gd";
        mode = "n";
        action = mkRaw "require('fzf-lua').lsp_definitions";
        options.desc = "LSP: FzfLua [g]oto [d]efinition";
      }
      {
        key = "gt";
        mode = "n";
        action = mkRaw "require('fzf-lua').lsp_typedefs";
        options.desc = "LSP: [g]oto [t]ype Definition";
      }
      {
        key = "gr";
        mode = "n";
        action = mkRaw "require('fzf-lua').lsp_references";
        options = {
          desc = "LSP: FzfLua [g]oto [r]eferences";
          nowait = true;
        };
      }
      {
        key = "gi";
        mode = "n";
        action = mkRaw "require('fzf-lua').lsp_implementations";
        options.desc = "LSP: FzfLua [g]oto [i]mplementation";
      }
      {
        key = "gs";
        mode = "n";
        action = mkRaw "require('fzf-lua').lsp_document_symbols";
        options.desc = "LSP: FzfLua [g]oto document [s]ymbols";
      }
      {
        key = "gS";
        mode = "n";
        action = mkRaw "require('fzf-lua').lsp_live_workspace_symbols";
        options.desc = "LSP: FzfLua [g]oto workspace [S]ymbols";
      }
      {
        key = "<leader>D";
        mode = "n";
        action = mkRaw "require('fzf-lua').diagnostics_workspace";
        options.desc = "LSP: FzfLua list [D]iagnostics";
      }
    ];
  };

  plugins.rustaceanvim = {
    enable = true;
    settings = {
      tools.float_win_config.border = "rounded";
      tools.code_actions.ui_select_fallback = true;
      server = {
        on_attach = mkRaw ''
          function(_, bufnr)
            vim.keymap.set("n", "K", function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end, { buffer = bufnr, desc = "Rust hover actions" })

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
      mappings = lib.genAttrs [ "/" "t" ] (_: {
        description = "Fuzzy search current level with fzf-lua";
        callback = mkRaw ''
          function(display)
            local fzf = require("fzf-lua")
            local navic = require("nvim-navic.lib")
            local nodes = display.focus_node.parent.children
            local filename = vim.api.nvim_buf_get_name(display.for_buf)
            local entries = {}
            for i, node in ipairs(nodes) do
              local kind = navic.adapt_lsp_num_to_str(node.kind)
              local pos = node.name_range["start"]
              -- Keep the buffer location for preview; only the symbol is displayed.
              entries[i] = string.format("%d\t[%d]%s%s:%d:%d:\t%s %s",
                i, display.for_buf, fzf.utils.nbsp, filename, pos.line, pos.character + 1,
                fzf.utils.ansi_from_hl("Navbuddy" .. kind, string.format("%-14s", kind:lower())),
                node.name)
            end

            display:close()
            fzf.fzf_exec(entries, {
              winopts = {
                title = " Navbuddy ",
                height = 0.8,
                width = 0.8,
                on_close = vim.schedule_wrap(function()
                  require("nvim-navbuddy.display").new(display)
                end),
              },
              previewer = "builtin",
              no_resume = true,
              fzf_opts = {
                ["--delimiter"] = "\t",
                ["--with-nth"] = "3..",
              },
              actions = {
                enter = function(selected)
                  if selected[1] then
                    display.focus_node = nodes[tonumber(selected[1]:match("^%d+"))]
                  end
                end,
              },
            })
          end
        '';
      });
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
