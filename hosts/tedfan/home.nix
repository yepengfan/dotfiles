{ config, lib, ... }:

let
  identity = import ./identity.nix;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  link = rel: {
    source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hosts/tedfan/${rel}");
    force = true;
  };
in
{
  programs.zsh = {
    initContent = lib.mkMerge [
      (lib.mkOrder 1050 ''
        [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
      '')
      # Keep upstream aliases available, except these permission shortcuts.
      (lib.mkOrder 1200 ''
        unalias cc co 2>/dev/null || true
      '')
    ];
    shellAliases = {
      cat = "bat";
      ls = "eza";
      ll = "eza -la --icons --git";
      la = "eza -a --icons";
      lt = "eza --tree --icons --level=2";
      lg = "lazygit";
      v = "nvim";
      vim = "nvim";
      reload = "source ~/.zshrc";
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = identity.git;
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      credential.helper = "osxkeychain";
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  home.file = {
    ".zshrc.local" = link "files/.zshrc.local";
    ".zprofile" = link "files/.zprofile";
    ".config/wezterm" = link "files/.config/wezterm";
    ".claude/settings.json" = link "files/.claude/settings.json";
    ".cursor/rules/lavish-human-review.mdc" = link "files/.cursor/rules/lavish-human-review.mdc";

    # Link only preferences, leaving Herdr's sockets and sessions outside Git.
    ".config/herdr".enable = lib.mkForce false;
    ".config/herdr/config.toml" = link "files/.config/herdr/config.toml";

    ".config/nvim".force = true;
    ".claude/CLAUDE.md" = link "files/AGENTS.md";
    ".codex/AGENTS.md" = link "files/AGENTS.md";
    ".config/opencode/AGENTS.md" = link "files/AGENTS.md";
    ".cursor/rules/global-agents.mdc" = {
      force = true;
      text = ''
        ---
        description: Global agent instructions (shared with Claude/Codex/opencode)
        alwaysApply: true
        ---

      '' + builtins.readFile ./files/AGENTS.md;
    };

    # The upstream Pi resources remain available, but are not enabled here.
    ".pi/agent/themes".enable = lib.mkForce false;
    ".pi/agent/extensions".enable = lib.mkForce false;
    ".pi/agent/models.json".enable = lib.mkForce false;
    ".pi/agent/settings.json".enable = lib.mkForce false;
  };
}
