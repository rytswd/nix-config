{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.python.enable = lib.mkEnableOption "Enable Python development related tools.";
  };

  config = lib.mkIf config.programming.python.enable {
    home.packages = [
      pkgs.uv       # https://github.com/astral-sh/uv
      pkgs.poetry   # https://python-poetry.org/

      # Packages that I want to ensure is available all the time.
      (pkgs.python311.withPackages (ps: with ps; [
        pyyaml
        pandas
      ]))
      pkgs.python311.pkgs.pip

      # TODO: Check what the use case with this is.
      pkgs.python311.pkgs.diagrams
    ];
  };
}
