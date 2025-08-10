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
  # NOTE: "--sort Name" sorts with capital letters first, and "--sort name" is
  # case insensitive sorting.
  # ls  = "eza --group-directories-first --classify --sort Name";
  l   = "eza -l --group-directories-first --classify --sort Name";
  la  = "eza -la --group-directories-first --classify --sort Name";
  lt  = "eza -lT --group-directories-first --classify --sort Name";
  ll  = "eza -lT --group-directories-first --classify --sort modified";
  llt = "eza -laTF --git --group-directories-first --git-ignore --ignore-glob .git --sort modified";
} else {
  xls = "eza --group-directories-first --classify --sort Name";
  xl  = "eza -l --group-directories-first --classify --sort Name";
  xla = "eza -la --group-directories-first --classify --sort Name";
  xlt  = "eza -lT --group-directories-first --classify --sort Name";
  xll  = "eza -lT --group-directories-first --classify --sort modified";
  xllt = "eza -laTF --git --group-directories-first --git-ignore --ignore-glob .git --sort modified";
})
