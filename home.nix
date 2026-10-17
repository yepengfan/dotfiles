{ config, pkgs, macUser, ... }:

let
  # Canonical repository for the permanent Nix environment.
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  # Configuration files are edited in this checkout and tracked by Git.
  link = rel: {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${rel}";
    force = true;
  };
in

{
  home.username = macUser;
  home.homeDirectory = "/Users/${macUser}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
      # Personal work environment (PATH, NVM, Bun, Kiro, secrets, nexus, ...).
      # Kept in a plain zsh file to avoid Nix ''${...} escaping; sourced last.
      [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      # Modern CLI aliases.
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
      user.name = "Yepeng Fan";
      user.email = "ted.fan@ciandt.com";
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

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm" = link "home/.config/wezterm";
  home.file.".config/nvim" = link "home/.config/nvim";
  home.file.".config/herdr/config.toml" = link "home/.config/herdr/config.toml";
  home.file.".claude/settings.json" = link "home/.claude/settings.json";

  # Personal work-environment shell (plain zsh, edit-in-place).
  home.file.".zshrc.local" = link "home/.zshrc.local";
  home.file.".zprofile" = link "home/.zprofile";

  # Pi remains optional and unmanaged.

  # One AGENTS.md, shared across every agent surface.
  home.file.".claude/CLAUDE.md" = link "home/AGENTS.md";
  home.file.".codex/AGENTS.md" = link "home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md" = link "home/AGENTS.md";

  # Cursor compatibility: the same AGENTS.md content as an always-apply user
  # rule (Cursor does not read ~/.cursor/AGENTS.md). Generated with frontmatter
  # so there is a single source of truth (home/AGENTS.md).
  home.file.".cursor/rules/global-agents.mdc" = {
    force = true;
    text = ''
    ---
    description: Global agent instructions (shared with Claude/Codex/opencode)
    alwaysApply: true
    ---

  '' + builtins.readFile ./home/AGENTS.md;
  };

  # Keep the personal Lavish human-review rule active.
  home.file.".cursor/rules/lavish-human-review.mdc" = link "home/.cursor/rules/lavish-human-review.mdc";
}
