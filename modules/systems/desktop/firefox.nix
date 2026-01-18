{
  pkgs,
  lib,
  local,
  ...
}: let
  homepage = local.utils.serviceUrl "homepage-dashboard";
  miniflux = local.utils.serviceUrl "miniflux";
in {
  # to apply these, visit about:support and click "Refresh Firefox..."
  programs.firefox = {
    enable = true;
    policies = {
      # found at about:support
      # details here https://mozilla.github.io/policy-templates/#extensionsettings
      ExtensionSettings = let
        mozillaAddon = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
        makeExtension = name: {
          id,
          default_area,
        }: {
          installation_mode = "normal_installed";
          install_url = mozillaAddon id;
          inherit default_area;
        };

        extensions = {
          "firefox@betterttv.net" = {
            id = "betterttv";
            default_area = "menupanel";
          };
          "addon@darkreader.org" = {
            id = "darkreader";
            default_area = "navbar";
          };
          "enhancerforyoutube@maximerf.addons.mozilla.org" = {
            id = "enhancer-for-youtube";
            default_area = "menupanel";
          };
          "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
            id = "i-dont-care-about-cookies";
            default_area = "menupanel";
          };
          "search@kagi.com" = {
            id = "kagi-search-for-firefox";
            default_area = "menupanel";
          };
          "addon@karakeep.app" = {
            id = "karakeep";
            default_area = "navbar";
          };
          "keepassxc-browser@keepassxc.org" = {
            id = "keepassxc-browser";
            default_area = "menupanel";
          };
          "clipper@obsidian.md" = {
            id = "web-clipper-obsidian";
            default_area = "menupanel";
          };
          "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
            id = "old-reddit-redirect";
            default_area = "menupanel";
          };
          "readeck@readeck.com" = {
            id = "readeck";
            default_area = "navbar";
          };
          "jid1-xUfzOsOFlzSOXg@jetpack" = {
            id = "reddit-enhancement-suite";
            default_area = "menupanel";
          };
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
            id = "return-youtube-dislikes";
            default_area = "menupanel";
          };
          "sponsorBlocker@ajay.app" = {
            id = "sponsorblock";
            default_area = "menupanel";
          };
          "treestyletab@piro.sakura.ne.jp" = {
            id = "tree-style-tab";
            default_area = "menupanel";
          };
          "{d07ccf11-c0cd-4938-a265-2a4d6ad01189}" = {
            id = "view-page-archive";
            default_area = "menupanel";
          };
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
            id = "vimium-ff";
            default_area = "menupanel";
          };
          "{6b733b82-9261-47ee-a595-2dda294a4d08}" = {
            id = "yomitan";
            default_area = "navbar";
          };
          "uBlock0@raymondhill.net" = {
            id = "ublock-origin";
            default_area = "navbar";
          };
        };
      in
        with lib; mapAttrs makeExtension extensions;
    };
    profiles.mawz = {
      isDefault = true;
      # found at about:config
      # apply with a browser restart
      settings = {
        "browser.startup.homepage" = homepage;
        "browser.toolbars.bookmarks.visibility" = "never";
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;
        "sidebar.new-sidebar.has-used" = true;
        "sidebar.main.tools" = "syncedtabs,history,bookmarks";
        "browser.uiCustomization.horizontalTabstrip" = ["tabbrowser-tabs"];
      };
      bookmarks = {
        force = true;
        settings = [
          {
            toolbar = true;
            bookmarks = [
              {
                name = "Homepage";
                keyword = "home";
                url = homepage;
              }
              {
                name = "Add to Miniflux";
                url = "javascript:location.href='${miniflux}/bookmarklet?uri='+encodeURIComponent(window.location.href)";
              }
            ];
          }
        ];
      };
      search = {
        default = "Kagi";
        force = true;
        engines = {
          "Kagi" = {
            urls = [
              {template = "https://kagi.com/search?q={searchTerms}";}
              {
                template = "https://kagi.com/api/autosuggest?q={searchTerms}";
                type = "application/x-suggestions+json";
              }
            ];
            iconUpdateUrl = "https://assets.kagi.com/v2/favicon-32x32.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@kagi"];
          };
          "Nix Packages" = {
            urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "Nix Options" = {
            urls = [{template = "https://search.nixos.org/options?query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@no"];
          };
          "Home Manager" = {
            urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@hm"];
          };
          "Github" = {
            urls = [{template = "https://github.com/search?type=code&q={searchTerms}";}];
            iconUpdateUrl = "https://github.githubassets.com/favicons/favicon-dark.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@gh"];
          };
        };
      };
    };
  };

  stylix.targets.firefox.profileNames = ["mawz"];
}
