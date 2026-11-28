{ config, lib, pkgs, ... }:

let
  inherit (import ./identity.nix) githubUser macUser;
  inherit (config.homebrew) prefix user;
  brewfile = pkgs.writeText "Brewfile" config.homebrew.brewfile;
in
{
  home-manager.backupFileExtension = "hm-bak";

  # Homebrew supplies interactive shells; Nix still generates system settings.
  programs.zsh.enable = false;
  programs.bash.enable = false;
  documentation.info.enable = false;
  environment.shells = [ "/opt/homebrew/bin/zsh" ];
  environment.etc."zshenv".text = ''
    if [[ -o rcs ]]; then
      if [[ -z "''${__NIX_DARWIN_SET_ENVIRONMENT_DONE-}" ]]; then
        . ${config.system.build.setEnvironment}
      fi
      [[ -r /etc/zshenv.local ]] && source /etc/zshenv.local
    fi
  '';
  # Run after Homebrew installation, including on the first bootstrap.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    if [[ ! -x /opt/homebrew/bin/zsh ]]; then
      echo "Homebrew zsh is missing; cannot set the login shell." >&2
      exit 1
    fi
    if [[ "$(dscl . -read /Users/${macUser} UserShell)" != "UserShell: /opt/homebrew/bin/zsh" ]]; then
      dscl . -create /Users/${macUser} UserShell /opt/homebrew/bin/zsh
    fi
  '';

  nix-homebrew = {
    autoMigrate = true;
    taps."${githubUser}/homebrew-dotfiles" = pkgs.runCommandLocal "dotfiles-homebrew-tap" {} ''
      mkdir -p "$out"
      cp -R ${./homebrew}/. "$out/"
    '';
  };

  # Bundle's install --force-cleanup path ignores cleanup type filters.
  # Run the explicit cleanup command so App Store apps are preserved.
  system.activationScripts.homebrew.text = lib.mkIf config.homebrew.enable (lib.mkForce ''
    echo >&2 "Homebrew bundle..."
    if [ -f "${prefix}/bin/brew" ]; then
      PATH="${prefix}/bin:${lib.makeBinPath [ pkgs.mas ]}:$PATH" \
        sudo --preserve-env=PATH --user=${lib.escapeShellArg user} --set-home \
        env HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_BUNDLE_NO_UPGRADE=1 \
        brew bundle cleanup --install --force --zap --no-mas --file=${brewfile}
    else
      echo >&2 "Homebrew is not installed, skipping Homebrew Bundle."
    fi
  '');

  homebrew = {
    # Update tools deliberately, separately from applying machine settings.
    onActivation.autoUpdate = lib.mkForce false;
    onActivation.upgrade = lib.mkForce false;
    taps = [
      "automic-vault/isotopes"
      "databricks/tap"
      "wxtsky/tap"
      "${githubUser}/dotfiles"
    ];
    # Homebrew also loads the unversioned definition when inspecting Core Tools v4.
    # Use the native DSL for item-specific tap trust, without installing that formula.
    extraConfig = ''
      tap "azure/functions", trusted: { formula: "azure-functions-core-tools" }
    '';
    # This host owns its complete inventory, including tools also in the base.
    # Upstream package changes are adopted deliberately before zap cleanup.
    brews = lib.mkForce [
      "aws-vault"
      "awscli"
      "azure-cli"
      "azure/functions/azure-functions-core-tools@4"
      "bash"
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
      # Provides gh; Vault's hardener replaces upstream gh with this formula.
      # The two formulae conflict, so declare the final managed package only.
      "automic-vault/isotopes/gh-cli"
      "git"
      "git-delta"
      "git-filter-repo"
      "git-gui"
      "git-lfs"
      "gitleaks"
      "gnupg"
      "herdr"
      { name = "imagemagick-full"; link = true; }
      "jq"
      "k9s"
      "lazygit"
      "libpq"
      "libtiff"
      "mas"
      "minikube"
      "mkcert"
      "mysql-client"
      "neovim"
      "nss"
      "nvm"
      { name = "openssl@3"; link = true; }
      "p7zip"
      "php@8.1"
      "pi-coding-agent"
      "pipx"
      "poppler"
      "pyenv"
      "resvg"
      "ripgrep"
      "saml2aws"
      "sevenzip"
      "starship"
      "stow"
      { name = "texinfo"; link = true; }
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
      "zsh"
      "zsh-autosuggestions"
      "zsh-syntax-highlighting"
    ];
    casks = lib.mkForce [
      "antigravity-cli"
      "automic-vault/isotopes/automic-vault"
      "claude-code"
      "codex"
      "codexbar"
      "cursor-cli"
      "dbeaver-community"
      "discord"
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-symbols-only-nerd-font"
      "google-drive"
      "${githubUser}/dotfiles/ice-2"
      "input-source-pro"
      "maccy"
      "macfuse"
      "moom"
      "obsidian"
      "opensuperwhisper"
      "session-manager-plugin"
      "thebrowsercompany-dia"
      "ticktick"
      "typora"
      "wezterm"
      "wxtsky/tap/codeisland"
      "zed"
      "zen"
      "zulu@17"
    ];
    masApps = {
      Amphetamine = 937984704;
      Xnip = 1221250572;
    };
  };
}
