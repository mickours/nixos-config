{ config, lib, ... }:

with lib;
let
  cfg = config.services.xserver;
  fcfg = cfg.localectlFix;
in
{
  options.services.xserver.localectlFix =
  { enable = mkEnableOption "Enables localectl fix.";
  };

  config = mkIf fcfg.enable {
    environment.etc = mkAssert cfg.enable ''
      X11 must be enabled for the fix to work.
      '' { "X11/xorg.conf.d/00-keyboard.conf".text = ''
          Section "InputClass"
            Identifier "Keyboard catchall"
            MatchIsKeyboard "on"
            Option "XkbRules" "base"
            Option "XkbModel" "${cfg.xkbModel}"
            Option "XkbLayout" "${cfg.layout}"
            Option "XkbOptions" "${cfg.xkbOptions}"
            Option "XkbVariant" "${cfg.xkbVariant}"
          EndSection
      '';
    };
  };
}
