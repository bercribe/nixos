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
        makeExtension = id: default_area: {
          installation_mode = "normal_installed";
          install_url = mozillaAddon id;
          inherit default_area;
        };
      in {
        "firefox@betterttv.net" = makeExtension "betterttv" "menupanel";
        "addon@darkreader.org" = makeExtension "darkreader" "navbar";
        "enhancerforyoutube@maximerf.addons.mozilla.org" = makeExtension "enhancer-for-youtube" "menupanel";
        "jid1-KKzOGWgsW3Ao4Q@jetpack" = makeExtension "i-dont-care-about-cookies" "menupanel";
        "search@kagi.com" = makeExtension "kagi-search-for-firefox" "menupanel";
        "keepassxc-browser@keepassxc.org" = makeExtension "keepassxc-browser" "menupanel";
        "clipper@obsidian.md" = makeExtension "web-clipper-obsidian" "navbar";
        "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = makeExtension "old-reddit-redirect" "menupanel";
        "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = makeExtension "raindropio" "navbar";
        "jid1-xUfzOsOFlzSOXg@jetpack" = makeExtension "reddit-enhancement-suite" "menupanel";
        "sponsorBlocker@ajay.app" = makeExtension "sponsorblock" "menupanel";
        "treestyletab@piro.sakura.ne.jp" = makeExtension "tree-style-tab" "menupanel";
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = makeExtension "vimium-ff" "navbar";
        "{6b733b82-9261-47ee-a595-2dda294a4d08}" = makeExtension "yomitan" "navbar";
        "uBlock0@raymondhill.net" = makeExtension "ublock-origin" "navbar";
      };
    };
  };
}
