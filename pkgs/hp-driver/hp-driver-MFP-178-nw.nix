{ stdenv, lib, glibc, libusb1, cups }:
let
  installationPath =
    if stdenv.hostPlatform.system == "x86_64-linux" then "x86_64" else "i386";
  appendPath =
    if stdenv.hostPlatform.system == "x86_64-linux" then "64" else "";
  libPath = lib.makeLibraryPath [ cups libusb1 ]
    + ":$out/lib:${stdenv.cc.cc.lib}/lib${appendPath}";
in
stdenv.mkDerivation rec {
  name = "HP-MFP-178-nw-driver-${version}";
  version = "1.00.39.12_00.15";
  src = fetchTarball {
    url =
      "https://ftp.hp.com/pub/softlib/software13/printers/MFP170/uld-hp_V${version}.tar.gz";
    sha256 = "02h4if0zx7x9fnfa0na4kpz1y1g3838wa9shjmrcqzs5wmpilrcf";
  };

  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    cd ${installationPath}
    mkdir -p $out/lib/cups/{backend,filter}
    install -Dm755 smfpnetdiscovery $out/lib/cups/backend/
    install -Dm755 pstosecps rastertospl $out/lib/cups/filter/
    install -Dm755 libscmssc.so $out/lib/
    GLOBIGNORE=*.so
    for exe in $out/lib/cups/**/*; do
      echo "Patching $exe"
      patchelf \
        --set-rpath ${libPath} \
        --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
        $exe
    done
    unset GLOBIGNORE
    install -v libsane-smfp.so.1.0.1 $out/lib
    cd $out/lib
    ln -s -f libsane-smfp.so.1.0.1 libsane-smfp.so.1
    ln -s -f libsane-smfp.so.1 libsane-smfp.so
    for lib in $out/lib/*.so; do
      echo "Patching $lib"
      patchelf \
        --set-rpath ${libPath} \
        $lib
    done
    mkdir -p $out/share/cups/model/hp
    cd -
    cd ../noarch/share/ppd/
    for i in *.ppd; do
      sed -i $i -e \
        "s,pstosecps,$out/lib/cups/filter/pstosecps,g; \
         s,pstospl,$out/lib/cups/filter/pstospl,g; \
         s,rastertospl,$out/lib/cups/filter/rastertospl,g"
    done;
    cp -r ./* $out/share/cups/model/hp
  '';

  meta = with lib; {
    description = "HP driver for MFP178-nw";
    homepage = "http://hp.com";
    license = licenses.unfree;
    platforms = platforms.linux;
    # broken = true;   # Not tested
  };
}
