{ inputs, ... }:
{
  imports = [ inputs.swapdir.homeModules.swapdir ];

  programs.swapdir = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
  };
}
