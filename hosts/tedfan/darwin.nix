{ lib, pkgs, ... }:

let
  inherit (import ./identity.nix) githubUser;
in
{
  home-manager.backupFileExtension = "hm-bak";

  nix-homebrew = {
    autoMigrate = true;
    taps."${githubUser}/homebrew-dotfiles" = pkgs.runCommandLocal "dotfiles-homebrew-tap" {} ''
      mkdir -p "$out"
      cp -R ${./homebrew}/. "$out/"
    '';
  };

  homebrew = {
    # Update tools deliberately, separately from applying machine settings.
    onActivation.autoUpdate = lib.mkForce false;
    onActivation.upgrade = lib.mkForce false;
    taps = [
      "automic-vault/isotopes"
      "azure/functions"
      "databricks/tap"
      "wxtsky/tap"
      "${githubUser}/dotfiles"
    ];
    # This host owns its complete inventory, including tools also in the base.
    # Upstream package changes are adopted deliberately before zap cleanup.
    brews = lib.mkForce [
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
      "automic-vault/isotopes/gh-cli"
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
    casks = lib.mkForce [
      "claude-code"
      "codex"
      "codexbar"
      "${githubUser}/dotfiles/reasonix"
      "font-jetbrains-mono-nerd-font"
      "font-symbols-only-nerd-font"
      "${githubUser}/dotfiles/ice-2"
      "maccy"
      "macfuse"
      "moom"
      "opensuperwhisper"
      "session-manager-plugin"
      "wezterm"
      "wxtsky/tap/codeisland"
      "zulu@17"
    ];
  };
}
