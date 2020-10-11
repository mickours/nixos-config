{ stdenv, glibc, gcc, libusb, patchelf, cups, ghostscript}:
let
  cups' = stdenv.lib.getLib cups;
in stdenv.mkDerivation rec {
  name = "HP-MFP-178-nw-driver-${version}";
  version = "1.00.39.12_00.15";
  src = fetchTarball {
    url = "https://ftp.hp.com/pub/softlib/software13/printers/MFP170/uld-hp_V${version}.tar.gz";
    sha256 = "02h4if0zx7x9fnfa0na4kpz1y1g3838wa9shjmrcqzs5wmpilrcf";
  };

  nativeBuildInputs = [ patchelf ];
  buildInputs = [ glibc gcc libusb cups ghostscript ];
  inherit glibc gcc libusb cups ghostscript;

  builder = ./builder.sh;

  meta = with stdenv.lib; {
    description = "HP driver for MFP178-nw";
    homepage = http://hp.com;
    license = licenses.unfree;
    platforms = platforms.linux;
    # broken = true;   # Not tested
  };
}
