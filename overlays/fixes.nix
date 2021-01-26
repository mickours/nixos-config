self: super: {
  bluez = super.bluez.overrideAttrs (old: rec {
    version = "5.54";
    src = super.fetchurl {
      url = "mirror://kernel/linux/bluetooth/${old.pname}-${version}.tar.xz";
      sha256 = "sha256-aM2rnmPogysTDVl53IyW/bCHsxJ480KHTZkq8+VmVtw=";
    };
  });
}
