source $stdenv/setup

arch=$(uname -m)
echo "$arch" | egrep -q '^i[3456]86$' && arch=i386
echo "Installing for $arch"

unpackPhase
patchPhase

set -v
set -u

cd $src
ls -al

INSTALL_DIR=$out
INSTALL_DIR_DATA=$INSTALL_DIR/share
INSTDIR_PPD=$INSTALL_DIR_DATA/ppd
INSTDIR_CMS=$INSTDIR_PPD/cms

SUBDIR_VENDOR_PPD=uld-hp
INSTDIR_LSB_PPD=$INSTALL_DIR/share/ppd/$SUBDIR_VENDOR_PPD

INSTDIR_CUPS_DATA=$INSTALL_DIR/share/cups
INSTDIR_CUPS_PPD=$INSTDIR_CUPS_DATA/model/$SUBDIR_VENDOR_PPD
mkdir -p $INSTDIR_CUPS_PPD
mkdir -p $INSTDIR_CUPS_DATA
mkdir -p $INSTDIR_LSB_PPD

DIST_PPD_PATH="./noarch/share/ppd"


## packet specific files
## install ppd
mkdir -p "$INSTALL_DIR_DATA"
mkdir -p "$INSTDIR_PPD"
cp -r "$DIST_PPD_PATH" "$INSTDIR_PPD"

ln -sf "$INSTDIR_PPD" "$INSTDIR_CUPS_PPD"
ln -sf "$INSTDIR_PPD" "$INSTDIR_LSB_PPD"

# Install cups filter files
INSTDIR_COMMON_PRINTER_LIB="$INSTALL_DIR/lib"
INSTDIR_COMMON_PRINTER_BIN="$INSTALL_DIR/bin"
INSTDIR_COMMON_PRINTER_SHARE="$INSTALL_DIR/share"

# binaries
INSTDIR_CUPS_BIN=$out/lib/cups
INSTDIR_CUPS_FILTERS="$INSTDIR_CUPS_BIN/filter"
INSTDIR_CUPS_BACKENDS="$INSTDIR_CUPS_BIN/backend"
ARCH_SUBDIR=$arch

mkdir -p "$INSTDIR_COMMON_PRINTER_LIB"	#was install -v -m 755
install  "./${ARCH_SUBDIR}/libscmssc.so" "$INSTDIR_COMMON_PRINTER_LIB"

mkdir -p "$INSTDIR_COMMON_PRINTER_BIN"
mkdir -p "$INSTDIR_CUPS_BACKENDS"
install "./${ARCH_SUBDIR}/smfpnetdiscovery" "$INSTDIR_COMMON_PRINTER_BIN"
ln -sf "$INSTDIR_COMMON_PRINTER_BIN/smfpnetdiscovery" "$INSTDIR_CUPS_BACKENDS"

mkdir -p "$INSTDIR_CUPS_FILTERS"
install "./${ARCH_SUBDIR}/rastertospl" "$INSTDIR_COMMON_PRINTER_BIN"
ln -sf "$INSTDIR_COMMON_PRINTER_BIN/rastertospl" "$INSTDIR_CUPS_FILTERS"

install "./${ARCH_SUBDIR}/pstosecps" "$INSTDIR_COMMON_PRINTER_BIN"
ln -sf "$INSTDIR_COMMON_PRINTER_BIN/pstosecps" "$INSTDIR_CUPS_FILTERS"


ls -al $out
ls -al $out/*

cd $out/lib/cups/filter
for i in $(ls); do
    echo "Patching $i..."
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $i ||
      echo "Couldn't set interpreter!"
    patchelf --set-rpath $cups/lib:$gcc/lib:$glibc/lib:$libusb/lib $i  # This might not be necessary.
done

ln -s $ghostscript/bin/gs $out/lib/cups/filter
