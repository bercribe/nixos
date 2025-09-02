{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      telescope-fzf-native-nvim
      neo-tree-nvim
      nvim-web-devicons
    ];
    extraConfig = ''
      " Fix tabs
      set tabstop=2 shiftwidth=2 smarttab
      " Use spaces instead of tabs
      set expandtab
      " Use system clipboard
      " set clipboard=unnamedplus
      " Find files using Telescope command-line sugar.
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      " Show file tree
      nnoremap <leader>tr :Neotree reveal right<cr>
      nnoremap <leader>tt :Neotree toggle right<cr>
    '';
  };
}
