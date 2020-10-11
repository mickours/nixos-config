{ pkgs ? import <nixpkgs> { } }:

pkgs.callPackage ../pkgs/hp-driver/hp-driver-MFP-178-nw.nix { }
