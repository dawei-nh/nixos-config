{
  config,
  lib,
  pkgs,
  ...
}:

let
  xb270_edid = pkgs.runCommand "xb270_edid" { compressFirmware = false; } ''
    mkdir -p $out/lib/firmware/edid
    cp ${./xb270hu.bin} $out/lib/firmware/edid/xb270hu.bin
  '';

  sunshineOutput = "DP-1";
  sunshineDesktopMode = "3440x1440@144";
  kscreenDoctor = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor";
  steam = "${config.programs.steam.package}/bin/steam";
  setsid = "${pkgs.util-linux}/bin/setsid";
  setpriv = "${pkgs.util-linux}/bin/setpriv";
  timeout = "${pkgs.coreutils}/bin/timeout";

  sunshineSetClientMode = pkgs.writeShellScript "sunshine-set-client-mode" ''
    set -u
    ${timeout} --kill-after=1 5 \
      ${kscreenDoctor} "output.${sunshineOutput}.mode.''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}" \
      || true
  '';

  sunshineRestoreDesktop = pkgs.writeShellScript "sunshine-restore-desktop" ''
    ${setpriv} --inh-caps=-all --ambient-caps=-all ${setsid} ${steam} steam://close/bigpicture || true
    ${timeout} --kill-after=1 5 ${kscreenDoctor} output.${sunshineOutput}.mode.${sunshineDesktopMode} || true
  '';

  sunshineOpenSteamBigPicture = pkgs.writeShellScript "sunshine-open-steam-big-picture" ''
    exec ${setpriv} --inh-caps=-all --ambient-caps=-all ${setsid} ${steam} -gamepadui steam://open/bigpicture
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/f3aa695b-9f31-4673-bc6f-04110984ba54";
    fsType = "btrfs";
    options = [ "subvol=persist" ];
    neededForBoot = true;
  };

  networking.hostName = "valendia";

  my.nixos = {
    impermanence.enable = true;
    profiles.linuxDesktop.enable = true;
    sunshine.enable = true;
    steam.enable = true;
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  hardware.firmware = [ xb270_edid ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.sunshine = {
    settings.output_name = 1;
    applications = {
      env.PATH = "$(PATH):$(HOME)/.local/bin";
      apps = [
        {
          name = "Steam Big Picture";
          output = "/var/log/sunshine.log";
          prep-cmd = [
            {
              do = "${sunshineSetClientMode}";
              undo = "${sunshineRestoreDesktop}";
            }
          ];
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          image-path = "steam.png";
          detached = [ "${sunshineOpenSteamBigPicture}" ];
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; lib.optional (kdePackages ? xwaylandvideobridge) kdePackages.xwaylandvideobridge ++ [
    gamescope
    mangohud
  ];

  services.udev.packages = with pkgs; [
    ledger-udev-rules
  ];

  system.stateVersion = "24.05";
}
