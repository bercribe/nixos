{
  config,
  pkgs,
  ...
}: {
  # Enable Japanese and Chinese keyboards
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-chinese-addons
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            # Default Input Method
            "DefaultIM" = "keyboard-us";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = null;
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = null;
          };
          "Groups/0/Items/2" = {
            Name = "pinyin";
            Layout = null;
          };
          GroupOrder = {
            "0" = "Default";
          };
        };
        globalOptions = {
          "Hotkey" = {
            # Enumerate when press trigger key repeatedly
            EnumerateWithTriggerKeys = "True";
            # Enumerate Input Method Forward
            EnumerateForwardKeys = "";
            # Enumerate Input Method Backward
            EnumerateBackwardKeys = "";
            # Skip first input method while enumerating
            EnumerateSkipFirst = "False";
          };
          "Hotkey/TriggerKeys" = {
            "0" = "Super+space";
            "1" = "Zenkaku_Hankaku";
            "2" = "Hangul";
          };
          "Hotkey/AltTriggerKeys" = {
            "0" = "Shift_L";
          };
          "Hotkey/EnumerateGroupForwardKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/EnumerateGroupBackwardKeys" = {
            "0" = "Shift+Super+space";
          };
          "Hotkey/ActivateKeys" = {
            "0" = "Hangul_Hanja";
          };
          "Hotkey/DeactivateKeys" = {
            "0" = "Hangul_Romaja";
          };
          "Hotkey/PrevPage" = {
            "0" = "Up";
          };
          "Hotkey/NextPage" = {
            "0" = "Down";
          };
          "Hotkey/PrevCandidate" = {
            "0" = "Shift+Tab";
          };
          "Hotkey/NextCandidate" = {
            "0" = "Tab";
          };
          "Hotkey/TogglePreedit" = {
            "0" = "Control+Alt+P";
          };
          "Behavior" = {
            # Active By Default
            ActiveByDefault = "False";
            # Reset state on Focus In
            resetStateWhenFocusIn = "No";
            # Share Input State
            ShareInputState = "No";
            # Show preedit in application
            PreeditEnabledByDefault = "True";
            # Show Input Method Information when switch input method
            ShowInputMethodInformation = "True";
            # Show Input Method Information when changing focus
            showInputMethodInformationWhenFocusIn = "False";
            # Show compact input method information
            CompactInputMethodInformation = "True";
            # Show first input method information
            ShowFirstInputMethodInformation = "True";
            # Default page size
            DefaultPageSize = 5;
            # Override Xkb Option
            OverrideXkbOption = "False";
            # Custom Xkb Option
            CustomXkbOption = "";
            # Force Enabled Addons
            EnabledAddons = "";
            # Force Disabled Addons
            DisabledAddons = "";
            # Preload input method to be used by default
            PreloadInputMethod = "True";
            # Allow input method in the password field
            AllowInputMethodForPassword = "False";
            # Show preedit text when typing password
            ShowPreeditForPassword = "False";
            # Interval of saving user data in minutes
            AutoSavePeriod = 30;
          };
        };
      };
    };
  };

  # Enable Japanese and Chinese fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji

    liberation_ttf # times new roman, arial, and courier new replacements
    mplus-outline-fonts.githubRelease # google font

    # monospace
    fira-code
    fira-code-symbols
    dina-font
    proggyfonts
  ];

  # Key remapping
  # inspiration - https://www.youtube.com/watch?v=XuQVbZ0wENE
  services.kanata = {
    enable = true;
    keyboards.default = {
      config = ''
        (defsrc
          caps
        )

        (defalias
          ;; tap caps lock as escape, hold caps lock as left control
          escctrl (tap-hold 100 100 esc lctrl)
        )

        (deflayer base
          @escctrl
        )
      '';
    };
  };
}
