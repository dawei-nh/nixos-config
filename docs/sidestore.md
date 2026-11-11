# SideStore on Valendia

Valendia enables `my.nixos.sidestore`, which installs iLoader and the
`libimobiledevice` diagnostic tools, and enables NixOS's `usbmuxd` service for
USB access to iPhones. iLoader can install SideStore, manage pairing files,
and load other IPA files.

## Apply the configuration

Build from the repository:

```sh
nix build .#nixosConfigurations.valendia.config.system.build.toplevel --show-trace
```

Then, on Valendia, apply it:

```sh
sudo nixos-rebuild switch --flake .#valendia --show-trace
```

## Install SideStore

Follow the current [SideStore prerequisites](https://docs.sidestore.io/docs/installation/prerequisites)
and [installation guide](https://docs.sidestore.io/docs/installation/install.html).
The desktop packages are provided by this configuration; no AppImage download
is needed.

1. On the iPhone, install LocalDevVPN from the App Store and allow its VPN
   configuration. SideStore requires iOS 15 or later and a device passcode.
2. Connect the unlocked iPhone to Valendia with a USB data cable. Accept
   **Trust This Computer** on the phone and enter its passcode if prompted.
3. Launch **iLoader** from Plasma's application launcher, or run `iloader` in
   a terminal as your normal desktop user.
4. Sign into your Apple Account in iLoader, select the intended iPhone, and
   choose **Install SideStore (Stable)**. iLoader handles pairing file placement.
5. On the phone, trust the developer app under **Settings > General > VPN &
   Device Management**. On iOS 16 or later, also enable **Developer Mode** under
   **Privacy & Security** and complete the restart prompts.
6. Connect to Wi-Fi and enable LocalDevVPN. Open SideStore, sign into the same
   Apple Account used in iLoader, and refresh SideStore from **My Apps** before
   installing other apps.

For another iPhone, repeat these steps and select that device in iLoader.
Each phone needs its own pairing record.

## Load IPA files

Use iLoader's IPA import feature to install a local `.ipa` over USB, or transfer
the IPA to the phone and import it in SideStore. Keep Wi-Fi and LocalDevVPN
connected when installing or refreshing through SideStore. With a free Apple
Account, apps need refreshing within seven days; the normal limit is three
active apps including SideStore. See the [SideStore FAQ](https://docs.sidestore.io/docs/faq.html).

## Pairing and troubleshooting

Valendia persists `/var/lib/lockdown` under `/persist/system` so desktop USB
pairing records survive its ephemeral root. iLoader's user data is on the
already persistent `/home` filesystem. Keep exported pairing files private and
out of this repository.

If a phone is missing in iLoader, unlock it, reconnect the cable, accept the
trust prompt, and check:

```sh
systemctl status usbmuxd
idevice_id -l
idevicepair -u <UDID> validate
journalctl -u usbmuxd -b
```

Use a UDID from `idevice_id -l` to select the intended phone. If it is not paired,
run `idevicepair -u <UDID> pair` and accept the trust prompt. A phone update or
reset can invalidate its pairing file; use iLoader to replace it as described
in the [SideStore installation guide](https://docs.sidestore.io/docs/installation/install.html).

iLoader's **View Logs** and `~/.local/share/me.nabdev.iloader/logs/` provide
application diagnostics. See the [iLoader project](https://github.com/nab138/iloader)
for upstream support.
