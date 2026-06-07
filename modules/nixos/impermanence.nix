let
  persistedDirectories = [
    "/var/lib/flatpak"
    { directory = "/var/lib/tailscale"; mode = "0700"; }
    { directory = "/var/lib/docker"; mode = "0710"; }
    "/var/lib/nixos"
    "/var/lib/NetworkManager"
    "/var/lib/systemd/backlight"
    "/var/lib/systemd/rfkill"
    { directory = "/var/lib/AccountsService"; mode = "0775"; }
    "/var/lib/fwupd"
    { directory = "/var/lib/sddm"; mode = "0700"; }
    { directory = "/var/tmp"; mode = "1777"; }
  ];

  persistedDirectoryPaths = map (
    directory:
    if builtins.isString directory then
      directory
    else
      directory.directory
  ) persistedDirectories;
in
{
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = persistedDirectories;
  };

  fileSystems = builtins.listToAttrs (map (directory: {
    name = directory;
    value.fsType = "none";
  }) persistedDirectoryPaths);
}
