{ config, pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;

      addons = with pkgs; [
        fcitx5-gtk
        kdePackages.fcitx5-qt
        qt6Packages.fcitx5-chinese-addons
        fcitx5-rose-pine
      ];

      settings = {
        inputMethod = {
          GroupOrder."0" = "Group 1";

          "Groups/0" = {
            Name = "Group 1";
            "Default Layout" = "us";
            DefaultIM = "pinyin";
          };

          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "pinyin";
        };


        addons = {
          pinyin = {
            globalSection = {
              PageSize = 5;
              CloudPinyinEnabled = "True";
            };
            sections = {
              Fuzzy = {
                EN_ENG = "True";
                IN_ING = "True";
              };
              PrevCandidate."0" = "Left";
              NextCandidate."0" = "Right";
              PrevPage."0" = "minus";
              PrevPage."1" = "Shift+Tab";
              PrevPage."2" = "Up";
              PrevPage."3" = "KP_Up";
              PrevPage."4" = "Page_Up";
              NextPage."0" = "equal";
              NextPage."1" = "Tab";
              NextPage."2" = "Down";
              NextPage."3" = "KP_Down";
              NextPage."4" = "Next";
            };
          };

          classicui.globalSection = {
            "Vertical Candidate List" = "False";
            Font = "\"LXGW Bright 12\"";
            MenuFont = "\"LXGW Bright 12\"";
            TrayFont = "\"LXGW Bright Medium 12\"";
            Theme = "rose-pine-moon";
            DarkTheme = "rose-pine-moon";
            PerScreenDPI = "False";
          };

          punctuation.globalSection.Enabled = "False";
        };
      };
    };
  };


  xdg.dataFile = {
    "fcitx5/pinyin/dictionaries/moegirl.dict".source =
      "${pkgs.fcitx5-pinyin-moegirl}/share/fcitx5/pinyin/dictionaries/moegirl.dict";

    "fcitx5/pinyin/dictionaries/zhwiki.dict".source =
      "${pkgs.fcitx5-pinyin-zhwiki}/share/fcitx5/pinyin/dictionaries/zhwiki.dict";
  };

  home.sessionVariables = {
    XMODIFIERS="@im=fcitx";
    QT_IM_MODULE="fcitx";
    QT_IM_MODULES="wayland;fcitx";
  };
}
