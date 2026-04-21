{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options = {
    editor.neovim.enable = lib.mkEnableOption "Enable NeoVim.";
  };

  config = lib.mkIf config.editor.neovim.enable {
    programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
      extraPackages = with pkgs; [
        gcc       # Treesitter compilation
        ripgrep   # telescope / grep
        fd        # telescope / file finder
        stylua    # Lua formatter (conform.nvim)
      ];
    };

    xdg.configFile = {
      # NvChad-based config → ~/.config/nvim (default)
      # NvChad and lazy.nvim still manage plugins at runtime — Nix only
      # ensures the config files and runtime dependencies are in place.
      # recursive = true symlinks individual files, allowing lazy.nvim to
      # write runtime files (lazy-lock.json, base46 cache) alongside them.
      "nvim" = {
        source = ./config;
        recursive = true;
      };
    };

    xdg.dataFile = {
      "nvim/parser" = {
        source = "${
          inputs.treesitter-grammars.packages.${pkgs.stdenv.hostPlatform.system}.nvim-treesit-grammars
        }/parser";
        recursive = true;
      };
      "nvim-hasliberg/parser" = {
        source = "${
          inputs.treesitter-grammars.packages.${pkgs.stdenv.hostPlatform.system}.nvim-treesit-grammars
        }/parser";
        recursive = true;
      };
    };
  };
}
