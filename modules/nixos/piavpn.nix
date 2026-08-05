{ lib, config, pkgs, ... }:

let
  cfg = config.my.nixos.piavpn;
in
{
  options.my.nixos.piavpn = {
    enable = lib.mkEnableOption "Private Internet Access VPN";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../pkgs/piavpn.nix { };
      description = "Private Internet Access VPN client package.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.networking.networkmanager.enable;
        message = "my.nixos.piavpn requires networking.networkmanager.enable = true";
      }
      {
        assertion = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
        message = "PIA's official Linux desktop installer is only packaged here for x86_64-linux";
      }
    ];

    environment.systemPackages = [
      cfg.package
      pkgs.wireguard-tools
    ];

    networking = {
      wireguard.enable = true;
      networkmanager.unmanaged = lib.mkAfter [ "interface-name:wgpia*" ];
      nftables.enable = true;
    };

    users.groups = {
      piavpn = { };
      piahnsd = { };
    };

    users.users.dawei.extraGroups = [
      "piavpn"
      "piahnsd"
    ];

    systemd.services.piavpn = {
      description = "Private Internet Access VPN daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        Environment = [
          "LD_LIBRARY_PATH=${cfg.package.runtimeLibPath}"
          "PATH=${cfg.package.runtimePath}"
        ];
        ExecStart = "${cfg.package.piaOptDir}/bin/pia-daemon";
        Restart = "always";
        User = "root";
        Group = "root";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.package.piaOptDir} 0755 root root -"
      "d ${cfg.package.piaOptDir}/etc 0755 root piavpn -"
      "d ${cfg.package.piaOptDir}/etc/cgroup 0755 root piavpn -"
      "L+ ${cfg.package.piaOptDir}/etc/ssl - - - - ${cfg.package}${cfg.package.piaOptDir}/etc/ssl"
      "d ${cfg.package.piaOptDir}/var 0755 root piavpn -"
      "d ${cfg.package.piaOptDir}/var/crashes 0755 root piavpn -"
      "L+ ${cfg.package.piaOptDir}/bin - - - - ${cfg.package}${cfg.package.piaOptDir}/bin"
      "L+ ${cfg.package.piaOptDir}/lib - - - - ${cfg.package}${cfg.package.piaOptDir}/lib"
      "L+ ${cfg.package.piaOptDir}/plugins - - - - ${cfg.package}${cfg.package.piaOptDir}/plugins"
      "L+ ${cfg.package.piaOptDir}/qml - - - - ${cfg.package}${cfg.package.piaOptDir}/qml"
      "L+ ${cfg.package.piaOptDir}/share - - - - ${cfg.package}${cfg.package.piaOptDir}/share"
      "L+ ${cfg.package.piaOptDir}/nix-bin - - - - ${cfg.package}${cfg.package.piaOptDir}/nix-bin"
      "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
    ];

    environment.etc."apport/blacklist.d/piavpn".text = ''
      /opt/piavpn/bin/pia-client
      /opt/piavpn/bin/pia-daemon
    '';

    security.wrappers.pia-unbound = {
      source = "${cfg.package}${cfg.package.piaOptDir}/bin/pia-unbound";
      capabilities = "cap_net_bind_service+ep";
      owner = "root";
      group = "root";
    };
  };
}
