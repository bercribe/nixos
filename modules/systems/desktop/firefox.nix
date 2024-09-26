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
      ExtensionSettings = {
        "firefox@betterttv.net" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/betterttv/latest.xpi";
          "default_area" = "menupanel";
        };
        "addon@darkreader.org" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          "default_area" = "navbar";
        };
        "enhancerforyoutube@maximerf.addons.mozilla.org" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/enhancer-for-youtube/latest.xpi";
          "default_area" = "menupanel";
        };
        "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies/latest.xpi";
          "default_area" = "menupanel";
        };
        "search@kagi.com" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
          "default_area" = "menupanel";
        };
        "keepassxc-browser@keepassxc.org" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
          "default_area" = "menupanel";
        };
        "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/old-reddit-redirect/latest.xpi";
          "default_area" = "menupanel";
        };
        "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/raindropio/latest.xpi";
          "default_area" = "navbar";
        };
        "jid1-xUfzOsOFlzSOXg@jetpack" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
          "default_area" = "menupanel";
        };
        "sponsorBlocker@ajay.app" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          "default_area" = "menupanel";
        };
        "treestyletab@piro.sakura.ne.jp" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
          "default_area" = "menupanel";
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          "default_area" = "navbar";
        };
        "uBlock0@raymondhill.net" = {
          "installation_mode" = "normal_installed";
          "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          "default_area" = "navbar";
        };
      };
    };
  };
}
