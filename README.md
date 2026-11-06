# nixos-config
My NixOS/NixOps configuration

## VPS

deploy with:
```sh
nix run github:serokell/deploy-rs .#vps
```

## oursbook3

### USBGuard rules

USBGuard rules are managed by NixOS in
`deployments/oursbook3-usbguard-rules.conf` (read-only at runtime, so
`usbguard allow-device -p` cannot persist changes).

To allow a new device, plug it in, then regenerate the rules from all
currently connected devices and rebuild:
```sh
sudo usbguard generate-policy | sed 's/[[:space:]]*$//' > deployments/oursbook3-usbguard-rules.conf
git diff deployments/oursbook3-usbguard-rules.conf  # review the new rules
sudo nixos-rebuild switch --flake .#oursbook3
```
The `sed` strips trailing whitespace, which makes the USBGuard rule parser fail.
