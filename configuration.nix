{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    # All existing user-installed tools are declared before enabling cleanup.
    onActivation.cleanup = "zap";
    # Update tools deliberately, separately from applying machine settings.
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "azure/functions"
      "databricks/tap"
      "esengine/reasonix"
      "wxtsky/tap"
    ];
    brews = [
      "aws-vault"
      "awscli"
      "azure-cli"
      "azure/functions/azure-functions-core-tools@4"
      "bat"
      "chafa"
      "colima"
      "databricks/tap/databricks"
      "direnv"
      "docker"
      "docker-compose"
      "eza"
      "fd"
      { name = "ffmpeg-full"; link = true; }
      "fzf"
      "gh"
      "git"
      "git-delta"
      "git-filter-repo"
      "git-gui"
      "gitleaks"
      "herdr"
      { name = "imagemagick-full"; link = true; }
      "jq"
      "k9s"
      "lazygit"
      "libpq"
      "libtiff"
      "minikube"
      "mkcert"
      "mysql-client"
      "neovim"
      "nss"
      { name = "openssl@3"; link = true; }
      "p7zip"
      "php@8.1"
      "pipx"
      "poppler"
      "pyenv"
      "resvg"
      "ripgrep"
      "saml2aws"
      "sevenzip"
      "starship"
      "stow"
      "tig"
      "tmux"
      "uv"
      "watch"
      "watchman"
      "yarn"
      "yazi"
      "yq"
      "zellij"
      "zoxide"
    ];
    casks = [
      "claude-code"
      "codex"
      "codexbar"
      "esengine/reasonix/reasonix"
      "font-jetbrains-mono-nerd-font"
      "font-symbols-only-nerd-font"
      "jordanbaird-ice"
      "maccy"
      "macfuse"
      "opensuperwhisper"
      "session-manager-plugin"
      "wezterm"
      "wxtsky/tap/codeisland"
      "zulu@17"
    ];
  };
}
