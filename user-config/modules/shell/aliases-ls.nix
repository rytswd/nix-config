{ withEza ? false }:

{
  # Use default ls.
  # -G should handle the colouring, but zsh seems to have trouble with it.
  # ls  = "ls -F --color=auto --group-directories-first";
  l   = "ls -lF --color=auto --group-directories-first";
  la  = "ls -laF --color=auto --group-directories-first";
  ll  = "ls -ltrF --color=auto --group-directories-first";
}
# If eza is the preference, override the ls based commands. Otherwise, add
# equivalent commands with an "x" prefix.
// (if (withEza) then {
  # ls  = "eza --group-directories-first --classify";
  l   = "eza -l --group-directories-first --classify";
  la  = "eza -la --group-directories-first --classify";
  lt  = "eza -lT --group-directories-first --classify";
  ll  = "eza -lT --group-directories-first --classify --sort modified";
  llt = "eza -laTF --git --group-directories-first --git-ignore --ignore-glob .git --sort modified";
} else {
  xls = "eza --group-directories-first --classify";
  xl  = "eza -l --group-directories-first --classify";
  xla = "eza -la --group-directories-first --classify";
  xlt  = "eza -lT --group-directories-first --classify";
  xll  = "eza -lT --group-directories-first --classify --sort modified";
  xllt = "eza -laTF --git --group-directories-first --git-ignore --ignore-glob .git --sort modified";
})
