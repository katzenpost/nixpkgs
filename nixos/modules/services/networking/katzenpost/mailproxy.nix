{ config, lib, pkgs, ... }:
with lib;

let
  katzenpost-daemons = pkgs.callPackage ../../../../../pkgs/networking/katzenpost/daemons/default.nix {};
  cfg = config.services.katzenpost-mailproxy;
  dataDir = "/var/lib/katzenpost-mailproxy";
  confFile = pkgs.writeText "katzenpost-mailproxy.conf" ''
    ${cfg.config}
  '';
in

{
  meta = {
    maintainers = with maintainers; [ TealG ];
  };

  options = {
    services.katzenpost-mailproxy = {
      enable = mkEnableOption "Katzenpost mailproxy";

      config = mkOption {
        default     = null;
        type        = types.nullOr types.str;
        description = ''
          Contents of Katzenpost mailproxy configuration file
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion   = cfg.config != null;
        message     = "Please provide Katzenpost mailproxy configuration file contents";
      }
    ];

    users.users.katzen-mailproxy = {
      description   = "Katzenpost mailproxy daemon";
      isSystemUser  = true;
      group         = "katzen-mailproxy";
      home          = dataDir;
    };
    users.groups.katzen-mailproxy = {};

    systemd.services.katzenpost-mailproxy = {
      description   = "Katzenpost mailproxy";
      after         = [ "network.target" ];
      wantedBy      = [ "multi-user.target" ];
      preStart      = "install -o katzen-mailproxy -g katzen-mailproxy -m 700 -d ${dataDir}";

      serviceConfig = {
        Type        = "simple";
        ExecStart   = "${katzenpost-daemons}/bin/mailproxy -f ${confFile}";
        Restart     = "always";
        PermissionsStartOnly = true;
        User        = "katzen-mailproxy";
        Group       = "katzen-mailproxy";
      };
    };
  };
}
