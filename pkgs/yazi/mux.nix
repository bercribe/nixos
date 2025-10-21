{
  lib,
  fetchFromGitHub,
  yaziPlugins,
}:
yaziPlugins.mkYaziPlugin {
  pname = "mux.yazi";
  version = "0.2.1-2025-10-02";

  src = fetchFromGitHub {
    owner = "peterfication";
    repo = "mux.yazi";
    rev = "266233e5225c5abb401d8f67078480acffb8bab7";
    hash = "sha256-c3K+aoFnEC3P67ebf0TJjNHlyqgkFVsee1O8lgaedcQ=";
  };

  meta = {
    description = "Enable multiple previewers per previewer entry";
    license = lib.licenses.mit;
  };
}
