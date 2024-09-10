{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.nushell.enable = lib.mkEnableOption "Enable Nushell.";
  };

  config = lib.mkIf config.shell.nushell.enable {
    programs.nushell = {
      enable = true;
      shellAliases = (import ./aliases-ls.nix { withEza = true; }) //
        {
          # Any aliases specific for fish can be defined here.
          # NOTE: Because of the way Nushell aliases work, Nushell cannot make
          # use of the `home.shellAliases` like other shells. I need to list
          # out all the aliases I use here instead.
          # Ref: https://github.com/nix-community/home-manager/pull/4616#issuecomment-1817812397
          k = "kubectl";
          gccact = "gcloud config configurations activate";
          gccls = "gcloud config configurations list";
          tf = "terraform";
        };
   };
  };
}
