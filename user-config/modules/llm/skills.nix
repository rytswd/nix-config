{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.skills.homeModules.default ];

  programs.agent-skills = {
    enable = true;
    skills = with inputs.skills.packages.${pkgs.stdenv.hostPlatform.system}; [
      # context7
      kagi-search
      team-play
      # workmux
      # workmux-workflow
    ];

    localSkills =
      let
        # Derived from `local.ghRoot` (see lib/paths.nix) so a host whose
        # checkouts live off-$HOME -- e.g. coder, on the persistent
        # `$HOME/src` volume -- resolves these without editing this file.
        rytswd-root = "${config.local.ghRoot}/rytswd";
        withre-root = "${config.local.ghRoot}/withre";
      in
      {
        air = "${withre-root}/air/skills/air/SKILL.md";
        air-hand-hold = "${withre-root}/air/skills/air-hand-hold/SKILL.md";
        chronoa = "${withre-root}/chronoa/SKILL.md";
        ever = "${withre-root}/ever/SKILL.md";
        # Combination of all the above
        ace-stack = "${withre-root}/ace-stack/SKILL.md";
        ace-supervisor = "${withre-root}/ace-stack/skills/ace-supervisor/SKILL.md";
        ace-support = "${withre-root}/ace-stack/skills/ace-support/SKILL.md";

        # Pi specific skill
        crosstalk = "${rytswd-root}/pi-agent-extensions-extra/skills/crosstalk/SKILL.md";

        # User-context suite -- machine, tools, prose style, and git/PR
        # workflow preferences. Edits to these .md files take effect
        # instantly (out-of-store symlinks). See:
        #   ./my-context/*.md
        my-env = "${rytswd-root}/nix-config/user-config/modules/llm/my-context/my-env.md";
        my-tools = "${rytswd-root}/nix-config/user-config/modules/llm/my-context/my-tools.md";
        my-style = "${rytswd-root}/nix-config/user-config/modules/llm/my-context/my-style.md";
        my-workflow = "${rytswd-root}/nix-config/user-config/modules/llm/my-context/my-workflow.md";
      };

    pi.enable = true;     # ~/.agents/skills/
    claude.enable = true; # ~/.claude/skills/
    gemini.enable = true; # ~/.gemini/extensions/skills/
  };
}
