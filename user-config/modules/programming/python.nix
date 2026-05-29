{ pkgs, ... }:
{
  home.packages = [
    pkgs.uv # https://github.com/astral-sh/uv
    pkgs.poetry # https://python-poetry.org/

    # Packages that I want to ensure is available all the time.
    (pkgs.python3.withPackages (
      ps: with ps; [
        pyyaml
        pandas
        requests   # HTTP client — default in ad-hoc scripts
        rich       # pretty terminal output (tables, tracebacks, progress)
        ipython    # nicer REPL than the default `python`
      ]
    ))
    pkgs.python3.pkgs.pip
  ];
}
