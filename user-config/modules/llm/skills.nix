{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.skills-nix.homeModules.default ];

  options = {
    llm.skills.enable = lib.mkEnableOption "Enable Skills.md setup for LLM agents.";
  };

  config = lib.mkIf config.llm.skills.enable {
    programs.agent-skills = {
      enable = true;
      skills = with inputs.skills-nix.packages.${pkgs.system}; [
        # context7
        kagi-search
        workmux
        workmux-workflow
      ];

      pi.enable = true;       # → ~/.agents/skills/
      claude.enable = true;   # → ~/.claude/skills/
      gemini.enable = true;   # → ~/.gemini/extensions/skills-nix/
    };
  };
}
