{ withExa ? false }:

{
  # Use default ls.
  # -G should handle the colouring, but zsh seems to have trouble with it.
  ls = "ls -F --color=auto";
  l = "ls -lF --color=auto";
  la = "ls -laF --color=auto";
  ll = "ls -ltrF --color=auto";
}
# If exa is the preference, override the ls based commands. Otherwise, add
# equivalent commands with an "x" prefix.
// (if (withExa) then {
  ls = "exa --group-directories-first --classify";
  l = "exa -l --group-directories-first --classify";
  ll = "exa -lT --group-directories-first --classify";
  la = "exa -la --group-directories-first --classify";
  llt = "exa -laTF --git --group-directories-first --git-ignore --ignore-glob .git";
} else {
  xls = "exa --group-directories-first --classify";
  xl = "exa -l --group-directories-first --classify";
  xll = "exa -laTF --git --group-directories-first --git-ignore --ignore-glob .git";
  xla = "exa -la --group-directories-first --classify";
})
