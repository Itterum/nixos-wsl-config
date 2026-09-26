{ pkgs, ... }:

{
  imports = [
    ./programs/helix
  ];

  home.packages = with pkgs; [
    kubectl
    k9s
    teleport
    kubectx
    fzf
    ripgrep
    fd
    eza
    jq
    yq-go
  ];

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        ls = "eza";
        ll = "eza -lah";
        la = "eza -a";
        gs = "git status --short";
      };
      initExtra = ''
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
      '';
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    gh.enable = true;
    bat.enable = true;

    git = {
      enable = true;
      settings = {
        user.name = "lyashenko.ivan";
        user.email = "ivan.lyashenko.it@gmail.com";
        init.defaultBranch = "main";
      };
    };
  };

  home.stateVersion = "26.05";
}
