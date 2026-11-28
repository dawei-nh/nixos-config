{ lib
, appimageTools
, fetchurl
}:

let
  pname = "snapmaker-orca";
  version = "2.4.1";
  src = fetchurl {
    url = "https://github.com/Snapmaker/OrcaSlicer/releases/download/v${version}/Snapmaker_Orca_Linux_AppImage_Ubuntu2404_V${version}.AppImage";
    hash = "sha256-K1EX4i0Eo6J7zfxahzxV0o/zt86XIZRt4fE0+pfSzAY=";
  };
  contents = appimageTools.extract { inherit pname version src; };
  desktopFile = "io.github.Snapmaker.Snapmaker_Orca.desktop";
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    webkitgtk_4_1
    glib-networking
    mesa-demos
  ];

  profile = ''
    export SSL_CERT_FILE="''${SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}"
    export GIO_EXTRA_MODULES="/usr/lib/gio/modules''${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}"
  '';

  extraInstallCommands = ''
    install -Dm644 ${contents}/${desktopFile} "$out/share/applications/${desktopFile}"
    substituteInPlace "$out/share/applications/${desktopFile}" \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
    sed -i '/^X-KDE-RunOnDiscreteGpu=/d' "$out/share/applications/${desktopFile}"
    install -Dm644 ${contents}/usr/share/icons/hicolor/192x192/apps/Snapmaker_Orca.png \
      "$out/share/icons/hicolor/192x192/apps/Snapmaker_Orca.png"
  '';

  meta = {
    description = "OrcaSlicer customized for Snapmaker 3D printers";
    homepage = "https://github.com/Snapmaker/OrcaSlicer";
    changelog = "https://github.com/Snapmaker/OrcaSlicer/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
