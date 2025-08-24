# Helpful: - man page: configuration.nix(5)
# - https://search.nixos.org/options
# - NixOS manual, `nix-help`

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix  # Read result of hardware scan
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.graceful = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "pavilion";

  # Either wireless or networkmanager
  networking.wireless = {
    enable = true;
    networks = {
      "WLAN-729910" = {
        pskRaw = "8032ad60239d8b9c1a6e66999d11c06ed15596539c6b791f3380d555bca7c101";
      };
    };
  };  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = false;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Internationalisation, else "de_DE.UTF-8" for german locale
  i18n.defaultLocale = "en_US.UTF-8";

  # TTY settings
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # Replicate xkb.options in tty
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Use Hyprland
  programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.moellh = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # Packages installed in user profile
    ];
    shell = pkgs.zsh;
    home = "/home/moellh";
    uid = 1000;
  };

  programs = {
    firefox.enable = true;
    zsh = {
      enable = true;

    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "moellh";
    group = "users";
    configDir = "/home/moellh/.config/syncthing/";
    dataDir = "/home/moellh/syncthing/";
    settings = {
      devices = {
        "raspberrypi" = {
	  id = "NMDJBVX-HVAY2FO-ZDFJJCZ-PW6UMJ6-L3D363P-WTPWTYN-KZU44RO-XXNRSAT";
	};
        "aspire" = {
	  id = "YHOWDGN-GI4XJGH-2ZTUVUW-VFXOVR2-KAUSXSK-WXWTYXL-O3OA7SG-735JSAA";
	};
        "galaxy" = {
	  id = "DY5RBFP-Z7X2CHM-SIZQY2S-4PISW6Q-Q6YTY7O-MSZN7GA-25PUXKK-BKO7BAV";
	};
        "ipad" = {
	  id = "4HBNGEI-IUNIL2P-MJ53UBQ-PIOUPY4-TNV75UR-PAV7OK2-65RRPWI-GRZPNQG";
	};
      };
      folders = {
	"98jxb-jvk6g" = {
	  label = "devault";
	  path = "/home/moellh/Documents/devault";
	  devices = [ "raspberrypi" "aspire" "galaxy" "ipad" ];
	  versioning = {
	    type = "staggered";
	    params = {
	      cleanInterval = "3600";
	      maxAge = "31536000";
	    };
	  };
	};
	"nigpq-7bjoh" = {
	  label = "Music";
	  path = "/home/moellh/Music";
	  devices = [ "raspberrypi" "aspire" "galaxy" "ipad" ];
	  versioning = {
	    type = "trashcan";
	    params.cleanoutDays = "30";
	  };
	};
	"zeqnu-gop7k" = {
	  label = "gq";
	  path = "/home/moellh/studies/gq";
	  devices = [ "raspberrypi" "aspire" "galaxy" "ipad" ];
	};
	"zbxy6-sjxot" = {
	  label = "pn";
	  path = "/home/moellh/studies/pn";
	  devices = [ "raspberrypi" "aspire" "galaxy" "ipad" ];
	};
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";

  };

  # home-manager.users.moellh = {
  #
  # };

  fonts = {
    packages = with pkgs; [
      inter
      nerd-fonts.jetbrains-mono
      stix-two
    ];
    fontconfig = {
      defaultFonts = {
       sansSerif = [ "Inter" ];
       monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  environment.variables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE  = "24";

    # Fixes nvim not finding imagemagick with pkg-config. Also otherwise, PKG_CONFIG_PATH is unset
    PKG_CONFIG_PATH = [
      "${pkgs.imagemagick.dev}/lib/pkgconfig"
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # e.g. Show battery charge of Bluetooth devices
      };
    };
  };
  services.blueman.enable = true;

  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Add XDG MIME and menu support
  xdg.mime.enable = true;
  xdg.menus.enable = true;

  # Fix empty "Open With" menu in Dolphin in Hyprland
  # This copies the plasma-applications.menu file from plasma-workspace to /etc/xdg/menus/applications.menu
  environment.etc."/xdg/menus/applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  nix.gc = {
    automatic = true;
    dates = "weekly";
      options = "--delete-older-than 30d";
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      run-shell ${pkgs.tmuxPlugins.sensible}/share/tmux-plugins/sensible/sensible.tmux  # Basic sensible defaults
      run-shell ${pkgs.tmuxPlugins.vim-tmux-navigator}/share/tmux-plugins/vim-tmux-navigator/vim-tmux-navigator.conf  # Navigate between tmux and nvim splits interchangeably
      run-shell ${pkgs.tmuxPlugins.yank}/share/tmux-plugins/yank/yank.tmux  # Copy to system clipboard
      run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux  # Save and restore tmux session
      set -g @resurrect-capture-pane-contents 'on'
      '';
  };

  programs.java.enable = true;

  programs.gnupg.agent.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
# If you want to use JACK applications, uncomment the following
    jack.enable = true;
  };

  services.mpd = {
    enable = true;
    user = "moellh";
    group = "users";
    musicDirectory = "/home/moellh/Music";
    startWhenNeeded = true;
    extraConfig = ''
      audio_output {
	type "pipewire"
	name "MPD PipeWire Output"
      }
    '';
  };

  systemd.services.mpd.environment = {
  #   # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.moellh.uid}"; # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme  # Mouse cursor theme
    android-studio  # Android IDE
    ani-cli  # CLI for watching anime
    anki-bin  # Anki flashcard
    kdePackages.ark  # File archiver, to be used in dolphin
    bat  # Cat command with syntax highlighting
    bc  # Arbitrary precision calculator language
    bluetui  # TUI bluetooth manager
    brave  # Alternative web browser
    kdePackages.breeze-icons
    brightnessctl
    btop-cuda  # TUI system monitor with NVIDIA GPU support
    calibre  # Ebook management
    clang  # C language family frontend for LLVM
    cliphist
    cmake
    cmake-format
    cudaPackages.cudatoolkit  # NVIDIA CUDA toolkit
    cudaPackages.cuda_nvvp
    cudaPackages.nsight_compute
    diffutils
    kdePackages.dolphin
    dunst
    gcc
    gimp
    git
    gnumake
    go
    grim
    fzf
    htop
    hyprpaper
    hyprlock
    imagemagick
    inotify-tools
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.kio-admin
    kdePackages.konsole  # Terminal emulator, to be used in dolphin
    kdePackages.dolphin-plugins
    pkgs.kitty
    kdePackages.kservice
    lua
    luajitPackages.luarocks
    neovim
    networkmanagerapplet
    nodejs
    obsidian
    playerctl
    pkg-config
    pyenv
    python3
    kdePackages.qtsvg
    ripgrep
    rmpc
    rofi-calc
    rofi-emoji
    rofi-wayland
    rustup
    shared-mime-info
    shotcut
    slurp
    spotify
    stow
    syncthing
    syncthingtray
    texlive.combined.scheme-full  # Full TeX Live distribution
    tree-sitter
    unzip
    vlc
    waybar
    wf-recorder
    wget
    wl-clipboard
    yazi
    yt-dlp
    zoxide
    zsh-powerlevel10k
    zig
    discord
    doxygen
    davinci-resolve
    drawio
    duf
    ffmpegthumbnailer
    kdePackages.ffmpegthumbs
    kdePackages.filelight
    gfortran
    gdb
    ghostscript
    gh
    gparted
    gradle
    swayimg
    inkscape-with-extensions
    jetbrains.idea-ultimate
    jujutsu
    jupyter
    kotlin
    krita
    lazygit
    libreoffice
    love
    lsd
    maven
    prismlauncher
    neo
    ocaml
    ocaml-top
    zathura
    pdfgrep
    plocate
    python312Packages.matplotlib
    python312Packages.pygame
    python312Packages.scikit-learn
    python312Packages.scipy
    python312Packages.sympy
    python312Packages.tqdm
    python312Packages.numpy
    python312Packages.pandas
    python312Packages.mutagen
    rclone
    rsync
    speedtest-cli
    spicetify-cli
    thunderbird
    tmuxPlugins.sensible
    tmuxPlugins.vim-tmux-navigator
    tmuxPlugins.yank
    tmuxPlugins.resurrect
    tor-browser
    tree
    unrar
    vim
    vscode
    xournalpp
    typst
    ollama-cuda
    ungoogled-chromium
    audacity
    hyprpolkitagent
    picard
    steam
    space-cadet-pinball
    librewolf
    nvtopPackages.full
    mpi
    qbittorrent
    sshfs
    ruby
    gemini-cli
    localsend
    glfw
    notion-app-enhanced
    keepassxc
    tldr
    pavucontrol
    mpc
  ];
}
