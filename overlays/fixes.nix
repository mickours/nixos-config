self: super: {
  bluez = super.bluez.overrideAttrs (old: rec {
    # Using old package
    version = "5.54";
    src = super.fetchurl {
      url = "mirror://kernel/linux/bluetooth/${old.pname}-${version}.tar.xz";
      sha256 = "1p2ncvjz6alr9n3l5wvq2arqgc7xjs6dqyar1l9jp0z8cfgapkb8";
    };

    # Using master
    #version = "5.54";
    #src = super.fetchgit {
    #  url = "https://git.kernel.org/pub/scm/bluetooth/bluez.git";
    #  rev = "d8e7311bcd3b756481bc1f99e324a2df9e21ada6";
    #  sha256 = "sha256-XOrM8286AOOmXDI/Hn9XSSSUSp/bjBejWiZAQQ3HPtA=";
    #};
  });
}
