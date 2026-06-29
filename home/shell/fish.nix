{ ... }:

{
  home.shell.enableFishIntegration = true;

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      status get-file prompts/nim.fish | source

      set -g fish_pager_color_selected_background --background=green
      set -g fish_pager_color_selected_completion brwhite
    '';

    functions = {
      fish_greeting = ''
        echo
        printf "Welcome to "
        set_color --bold blue
        if set -q IN_NIX_SHELL
          printf 'Nix Shell'
        else if test "$SHLVL" -gt 1; and string match -qr '^/nix/store/' -- $PATH[1]
          printf 'Nix Shell'
        else
          printf "NixOS"
        end
        set_color normal
        printf "!\n\n"
      '';

      fish_right_prompt = ''
        if set -q DEVSHELL_NAME
          set_color --bold yellow
          printf "[dev#%s]" $DEVSHELL_NAME
          set_color normal
        else if set -q IN_NIX_SHELL
          set_color --bold blue
          printf "[nix shell]"
          set_color normal
        else if test "$SHLVL" -gt 1; and string match -qr "^/nix/store/" -- $PATH[1]
          set_color --bold blue
          printf "[nix shell]"
          set_color normal
        end

        if set -q SSH_CONNECTION; or set -q SSH_TTY
          printf " "
          set_color --bold green
          printf "[ssh]"
          set_color normal
        end
      '';
    };

    shellAbbrs = {
      mv = "mv -v";
      rm = "rm -v";
      cp = "cp -v";
    };
  };
}
