{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.skills.homeModules.default ];

  options = {
    llm.skills.enable = lib.mkEnableOption "Enable Skills.md setup for LLM agents.";
  };

  config = lib.mkIf config.llm.skills.enable {
    programs.agent-skills = {
      enable = true;
      skills = with inputs.skills.packages.${pkgs.stdenv.hostPlatform.system}; [
        # context7
        kagi-search
        team-play
        # workmux
        # workmux-workflow
      ];

      localSkills = let
        rytswd-root = "${config.home.homeDirectory}/Coding/github.com/rytswd";
      in {
        # User-context suite — machine, tools, prose style, and git/PR
        # workflow preferences. Edits to these .md files take effect
        # instantly (out-of-store symlinks). See:
        #   ./my-context/*.md
        my-env      = "${rytswd-root}/nix-config/user-config/modules/llm/my-context/my-env.md";
        my-tools    = "${rytswd-root}/nix-config/user-config/modules/llm/my-context/my-tools.md";
        my-style    = "${rytswd-root}/nix-config/user-config/modules/llm/my-context/my-style.md";
        my-workflow = "${rytswd-root}/nix-config/user-config/modules/llm/my-context/my-workflow.md";
      };

      pi.enable = true;       # → ~/.agents/skills/
      claude.enable = true;   # → ~/.claude/skills/
      gemini.enable = true;   # → ~/.gemini/extensions/skills/
    };
  };
}
