{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local.keyboard;
in {
  options.local.keyboard.device = with lib;
  with types;
    mkOption {
      type = enum ["standard" "glove80"];
      default = "standard";
      description = "Determines layout to use for kanata";
    };

  config = {
    # Enable Japanese and Chinese keyboards
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
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
          addons = {
            clipboard = {
              globalSection = {
                # Paste Primary
                PastePrimaryKey = "";
                # Number of entries
                "Number of entries" = 5;
                # Do not show password from password managers
                IgnorePasswordFromPasswordManager = false;
                # Hidden clipboard content that contains a password
                ShowPassword = false;
                # Seconds before clearing password
                ClearPasswordAfter = 30;
              };
              sections.TriggerKey."0" = "Super+semicolon";
            };
            quickphrase = {
              globalSection = {
                # Choose key modifier
                "Choose Modifier" = null;
                # Enable Spell check
                Spell = true;
                # Fallback Spell check language
                FallbackSpellLanguage = "en";
              };
              sections.TriggerKey."0" = "Super+grave";
            };
          };
        };
      };
    };

    # Enable Japanese and Chinese fonts
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
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
        extraDefCfg = "process-unmapped-keys yes";
        config = let
          defsrc = {
            standard = ''
              (defsrc
                q w e r t y u i o p
                caps a s d f g h j k l ;
                lsft z x c v b n m
                lctl lmet lalt ralt
              )
            '';
            glove80 = ''
              (defsrc
                q w e r t y u i o p
                esc a s d f g h j k l ;
                z x c v b n m
                lsft rsft
              )
            '';
          };
          deflayers = {
            standard = ''
              (deflayer base
                _ _ _ _ _ _ _ _ _ _
                @escsw _ @smet @dalt @fctl _ _ @jctl @kalt @lmet _
                XX _ _ _ _ _ _ _
                XX XX @lsft @rsft
              )
              (deflayer colemak
                q w f p b j l u y ;
                @escsw a @rmet @salt @tctl g m @nctl @ealt @imet o
                z x c d v XX k h
                XX XX @lsft @rsft
              )
              (deflayer colemak-nomods
                q w f p b j l u y ;
                @escsw a r s t g m n e i o
                z x c d v XX k h
                XX XX @lsft @rsft
              )
              (deflayer shift
                _ _ _ _ _ _ _ _ _ _
                _ _ _ _ _ _ _ _ _ _ _
                _ _ _ _ _ _ _ _
                _ _ @tmux @tmux
              )

              (deflayer switch
                _ _ _ _ _ _ _ _ _ _
                _ _ _ _ _ _ _ @sbs @sps @scm @scn
                _ _ _ _ _ _ _ _
                _ _ _ _
              )
              (deflayer pass
                _ _ _ _ _ _ _ _ _ _
                @escsw _ _ _ _ _ _ _ _ _ _
                _ _ _ _ _ _ _ _
                _ _ _ _
              )
            '';
            glove80 = ''
              (deflayer base
                _ _ _ _ _ _ _ _ _ _
                @escsw _ @smet @dalt @fctl _ _ @jctl @kalt @lmet _
                _ _ _ _ _ _ _
                @lsft @rsft
              )
              (deflayer colemak
                q w f p b j l u y ;
                @escsw a @rmet @salt @tctl g m @nctl @ealt @imet o
                z x c d v k h
                @lsft @rsft
              )
              (deflayer colemak-nomods
                q w f p b j l u y ;
                @escsw a r s t g m n e i o
                z x c d v k h
                @lsft @rsft
              )
              (deflayer shift
                _ _ _ _ _ _ _ _ _ _
                _ _ _ _ _ _ _ _ _ _ _
                _ _ _ _ _ _ _
                @tmux @tmux
              )

              (deflayer switch
                _ _ _ _ _ _ _ _ _ _
                _ _ _ _ _ _ _ @sbs @sps @scm @scn
                _ _ _ _ _ _ _
                _ _
              )
              (deflayer pass
                _ _ _ _ _ _ _ _ _ _
                @escsw _ _ _ _ _ _ _ _ _ _
                _ _ _ _ _ _ _
                _ _
              )
            '';
          };
        in ''
          (defvar
            tap-time 200
            hold-time 200
          )

          (defalias
            ;; modifier mods
            escsw (tap-hold-release $tap-time $hold-time esc (layer-while-held switch))
            lsft (multi lsft (layer-while-held shift))
            rsft (multi rsft (layer-while-held shift))
            tmux (macro C-b)

            ;; home row mods
            smet (tap-hold-release $tap-time $hold-time s lmet)
            dalt (tap-hold-release $tap-time $hold-time d lalt)
            fctl (tap-hold-release $tap-time $hold-time f lctl)
            jctl (tap-hold-release $tap-time $hold-time j rctl)
            kalt (tap-hold-release $tap-time $hold-time k ralt)
            lmet (tap-hold-release $tap-time $hold-time l rmet)
            rmet (tap-hold-release $tap-time $hold-time r lmet)
            salt (tap-hold-release $tap-time $hold-time s lalt)
            tctl (tap-hold-release $tap-time $hold-time t lctl)
            nctl (tap-hold-release $tap-time $hold-time n rctl)
            ealt (tap-hold-release $tap-time $hold-time e ralt)
            imet (tap-hold-release $tap-time $hold-time i rmet)

            ;; layer switching
            sbs (layer-switch base)
            scm (layer-switch colemak)
            scn (layer-switch colemak-nomods)
            sps (layer-switch pass)
          )

          ${defsrc.${cfg.device}}
          ${deflayers.${cfg.device}}
        '';
      };
    };
  };
}
