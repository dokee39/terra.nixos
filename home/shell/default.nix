{ pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./zellij.nix
  ];

  home.shellAliases = {
    # system
    rbt = "systemctl reboot";
    std = "systemctl poweroff";
    scst = "systemctl status";

    # git
    gad = "git add --all";
    gst = "git status -s";
    gci = "git commit -m";
    gbr = "git branch --all";
    glg = ''git log --pretty=format:"%C(auto)%h%Creset - %C(green)%s%Creset%n    %C(bold cyan)@%Creset%C(bold blue)%an%Creset, %C(cyan)%ah%Creset%C(auto)%d%Creset" --graph --all'';

    # shell
    type = "type -a";
    cr = "cd $(pwd -P)";
    chmox = "chmod u+x";
    z = "zellij";

    mntfs = "sudo mount -t ntfs3 -o uid=$(id -u),gid=$(id -g),fmask=0133,dmask=0022,windows_names,prealloc,force";
  };

  home.packages = with pkgs; [
    bat
  ];

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    colors = "auto";
    extraOptions = [
      "--group-directories-first"
    ];
  };

  programs.fzf = {
    enable = true;

    defaultOptions = [
      "--height=45%"
      "--layout=reverse"
      "--border"
      "--info=inline"
    ];

    fileWidgetOptions = [
      "--walker-skip=.git,node_modules,target,result"
      "--preview=bat -n --color=always {}"
      "--bind=ctrl-/:change-preview-window(hidden|right,60%)"
    ];

    changeDirWidgetOptions = [
      "--walker-skip=.git,node_modules,target,result"
      "--preview=eza --tree --level=2 --color=always {} | head -200"
    ];

    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };
}
