{
  stdenv,
  lib,
  fetchurl,
  makeWrapper,
  qt6,
  autoPatchelfHook,
  wrapQtAppsHook ? qt6.wrapQtAppsHook,
  libcap_ng,
  bash,
  libnl,
  iptables,
  xterm,
  libnsl,
  libatomic_ops,
  libxkbcommon,
  psmisc,
  makeDesktopItem,
  copyDesktopItems,
  iproute2,
  gawk,
  mount,
  systemd,
  openresolv,
  util-linux,
  coreutils,
  xkeyboardconfig,
  wireguard-tools,
  installOutDir ? "$out/opt/piavpn",
  ...
}:
let
  runtimeTools = [
    bash
    iptables
    psmisc
    iproute2
    gawk
    mount
    systemd
    openresolv
    util-linux
    coreutils
    wireguard-tools
  ];
  runtimeToolDirs = lib.concatMapStringsSep " " (tool: "${tool}/bin ${tool}/sbin") runtimeTools;
in
stdenv.mkDerivation rec {
  pname = "piavpn";
  version = "3.7.2-08420";

  src = fetchurl {
    url = "https://privateinternetaccess-storage.s3.amazonaws.com/pub/pia_desktop/builds/pia-linux-${version}.run";
    hash = "sha256-CKiK8ERiqeB4ru9SsmvNtW8Kmwh6D7dgb5i363m7Pdk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    qt6.qt3d
    qt6.qtquicktimeline
    qt6.qtvirtualkeyboard
    qt6.qtlottie
    qt6.qtscxml
    libcap_ng
    bash
    libxkbcommon
    libnl.out
    libnsl.out
    iptables
    psmisc
    libatomic_ops
    xterm
    iproute2
  ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "Private Internet Access (PIA)";
      comment = "Private Internet Access VPN client";
      exec = "${coreutils}/bin/env XDG_SESSION_TYPE=X11 /opt/piavpn/bin/pia-client %u";
      icon = pname;
      terminal = false;
      categories = [ "Network" ];
      keywords = [
        "pia"
        "vpn"
      ];
      startupWMClass = "pia-client";
      mimeTypes = [ "x-scheme-handler/piavpn" ];
    })
  ];

  dontBuild = true;

  autoPatchelfIgnoreMissingDeps = [ "libQt6Bodymovin.so.6" ];

  unpackPhase = ''
    runHook preUnpack

    cp "$src" pia-installer.run
    chmod +x pia-installer.run
    ./pia-installer.run --target source --noexec --keep --nox11

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p ${installOutDir}
    cp -a source/piafiles/. ${installOutDir}/
    cp source/installfiles/*.sh ${installOutDir}/bin/
    patchShebangs ${installOutDir}/bin

    mkdir -p ${installOutDir}/nix-bin
    for dir in ${runtimeToolDirs}; do
      if [ -d "$dir" ]; then
        for executable in "$dir"/*; do
          [ -e "$executable" ] || continue
          ln -sf "$executable" ${installOutDir}/nix-bin/
        done
      fi
    done

    for binary in pia-client pia-daemon pia-hnsd pia-openvpn pia-ss-local pia-support-tool pia-unbound pia-wireguard-go piactl support-tool-launcher; do
      makeWrapper ${installOutDir}/bin/$binary ${installOutDir}/bin/$binary-wrapped \
        --prefix PATH : "${lib.makeBinPath runtimeTools}" \
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            installOutDir
            libxkbcommon
            libnl.out
            libnsl.out
          ]
        }" \
        --set QT_QPA_PLATFORM xcb \
        --set QT_XKB_CONFIG_ROOT "${xkeyboardconfig}/share/X11/xkb"
    done

    mkdir -p $out/share/icons/hicolor/128x128/apps
    cp source/installfiles/app-icon.png $out/share/icons/hicolor/128x128/apps/piavpn.png

    substituteInPlace ${installOutDir}/bin/openvpn-updown.sh \
      --replace-fail "/usr/bin/busctl" "${systemd}/bin/busctl"

    mkdir -p $out/bin
    for binary in piactl pia-client; do
      ln -s ${installOutDir}/bin/$binary-wrapped $out/bin/$binary
    done

    runHook postInstall
  '';

  passthru = {
    groupName = pname;
    libDir = "${installOutDir}/lib";
    piaOptDir = "/opt/piavpn";
    runtimePath = "/opt/piavpn/nix-bin:/opt/piavpn/bin:/run/wrappers/bin";
  };

  meta = {
    description = "Private Internet Access (PIA) VPN client";
    homepage = "https://github.com/pia-foss/desktop";
    license = lib.licenses.unfree;
    mainProgram = "pia-client";
    platforms = [ "x86_64-linux" ];
  };
}
