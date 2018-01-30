{ config, pkgs, ... }:

{
  imports = [
    ./nixos/modules/services/networking/katzenpost/authority-nonvoting.nix
    ./nixos/modules/services/networking/katzenpost/server.nix
    ./nixos/modules/services/networking/katzenpost/mailproxy.nix
  ];
}
