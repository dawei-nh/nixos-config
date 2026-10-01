{ lib
, stdenv
, stdenvNoCC
, fetchurl
, makeWrapper
, patchelf
, alsa-lib
, libpulseaudio
, zlib
, writableTmpDirAsHomeHook
}:

let
  version = "18.4.4";
  sources = {
    x86_64-linux = {
      asset = "omp-linux-x64";
      sha256 = "24c830fceb0bd6884bf5bf2c7a2b7407bc23fafe655e924c695ef9be308e46f3";
    };
    aarch64-linux = {
      asset = "omp-linux-arm64";
      sha256 = "602eefddc0fd87043f8f08d8628d72592e5802c003a05f203f1ecbc63a8fdd30";
    };
    aarch64-darwin = {
      asset = "omp-darwin-arm64";
      sha256 = "e76e02821242fb36844676a9dfb79fbe5fb069d93ef3bf62625ec339fe9d092b";
    };
  };
  source = sources.${stdenv.hostPlatform.system} or (throw "No OMP release binary for ${stdenv.hostPlatform.system}");
  linuxLibraryPath = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    stdenv.cc.cc.libgcc
    stdenv.cc.libc
    zlib
    libpulseaudio
    alsa-lib
  ];
in
stdenvNoCC.mkDerivation {
  pname = "omp-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/${source.asset}";
    inherit (source) sha256;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ makeWrapper patchelf ];
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Bun appends its compiled payload to the executable. Preserve it, and avoid
  # RPATH rewrites that can invalidate its ELF version-definition pointers.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    ${if stdenv.hostPlatform.isLinux then ''
      install -Dm755 "$src" "$out/libexec/omp"
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" "$out/libexec/omp"
      # The bundled native addon is extracted at runtime, so supply its library
      # path through the wrapper rather than patching the embedded archive.
      makeWrapper "$out/libexec/omp" "$out/bin/omp" \
        --prefix LD_LIBRARY_PATH : "${linuxLibraryPath}"
    '' else ''
      install -Dm755 "$src" "$out/bin/omp"
    ''}
    runHook postInstall
  '';

  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  nativeInstallCheckInputs = [ writableTmpDirAsHomeHook ];
  installCheckPhase = ''
    runHook preInstallCheck
    # Keep the daemon smoke test's temporary-directory cleanup inside a private
    # directory, away from the rest of the build and its source directory.
    ompCheckDir=$(mktemp -d)
    export XDG_DATA_HOME="$ompCheckDir/data"
    export TMPDIR="$ompCheckDir/tmp"
    mkdir -p "$XDG_DATA_HOME/omp" "$TMPDIR"
    test "$("$out/bin/omp" --version)" = "omp/${version}"
    "$out/bin/omp" --smoke-test
    runHook postInstallCheck
  '';

  meta = {
    description = "Terminal coding agent packaged from upstream release binaries";
    homepage = "https://github.com/can1357/oh-my-pi";
    changelog = "https://github.com/can1357/oh-my-pi/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
