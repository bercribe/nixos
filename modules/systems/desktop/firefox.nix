{
  config,
  pkgs,
  ...
}: {
  users.users.mawz.packages = [
    pkgs.firefox
  ];

  programs.firefox = {
    enable = true;
    policies = {
      DisplayBookmarksToolbar = "always";
      # found at about:support
      # details here https://mozilla.github.io/policy-templates/#extensionsettings
      # to apply changes, click "Refresh Firefox..."
      ExtensionSettings = let
        mozillaAddon = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
        installation_mode = "normal_installed";
      in {
        "firefox@betterttv.net" = {
          inherit installation_mode;
          install_url = mozillaAddon "betterttv";
          default_area = "menupanel";
        };
        "addon@darkreader.org" = {
          inherit installation_mode;
          install_url = mozillaAddon "darkreader";
          default_area = "navbar";
        };
        "enhancerforyoutube@maximerf.addons.mozilla.org" = {
          inherit installation_mode;
          install_url = mozillaAddon "enhancer-for-youtube";
          default_area = "menupanel";
        };
        "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
          inherit installation_mode;
          install_url = mozillaAddon "i-dont-care-about-cookies";
          default_area = "menupanel";
        };
        "search@kagi.com" = {
          inherit installation_mode;
          install_url = mozillaAddon "kagi-search-for-firefox";
          default_area = "menupanel";
        };
        "keepassxc-browser@keepassxc.org" = {
          inherit installation_mode;
          install_url = mozillaAddon "keepassxc-browser";
          default_area = "menupanel";
        };
        "clipper@obsidian.md" = {
          inherit installation_mode;
          install_url = mozillaAddon "web-clipper-obsidian";
          default_area = "navbar";
        };
        "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
          inherit installation_mode;
          install_url = mozillaAddon "old-reddit-redirect";
          default_area = "menupanel";
        };
        "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = {
          inherit installation_mode;
          install_url = mozillaAddon "raindropio";
          default_area = "navbar";
        };
        "jid1-xUfzOsOFlzSOXg@jetpack" = {
          inherit installation_mode;
          install_url = mozillaAddon "reddit-enhancement-suite";
          default_area = "menupanel";
        };
        "sponsorBlocker@ajay.app" = {
          inherit installation_mode;
          install_url = mozillaAddon "sponsorblock";
          default_area = "menupanel";
        };
        "treestyletab@piro.sakura.ne.jp" = {
          inherit installation_mode;
          install_url = mozillaAddon "tree-style-tab";
          default_area = "menupanel";
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          inherit installation_mode;
          install_url = mozillaAddon "vimium-ff";
          default_area = "navbar";
        };
        "uBlock0@raymondhill.net" = {
          inherit installation_mode;
          install_url = mozillaAddon "ublock-origin";
          default_area = "navbar";
        };
      };
    };
  };
}
