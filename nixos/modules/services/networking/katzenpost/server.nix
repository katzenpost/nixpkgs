{ config, lib, pkgs, ... }:
with lib;

let
  katzenpost-server = pkgs.callPackage ../../../../../pkgs/networking/katzenpost/server/default.nix {};
  cfg = config.services.katzenpost-server;
  dataDir = "/var/lib/katzenpost-server";
  confFile = pkgs.writeText "katzenpost-server.conf" ''
    ${cfg.config}
  '';
in

{
  meta = {
    maintainers = with maintainers; [ TealG ];
  };

  options = {
    services.katzenpost-server = {
      enable = mkEnableOption "Katzenpost server";

      config = mkOption {
        default     = null;
        type        = types.nullOr types.str;
        description = ''
          Contents of Katzenpost server configuration file
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion   = cfg.config != null;
        message     = "Please provide Katzenpost server configuration file contents";
      }
    ];

    users.users.katzen-server = {
      description   = "Katzenpost server daemon";
      isSystemUser  = true;
      group         = "katzen-server";
      home          = dataDir;
    };
    users.groups.katzen-server = {};

    systemd.services.katzenpost-server = {
      description   = "Katzenpost server";
      after         = [ "network.target" ];
      wantedBy      = [ "multi-user.target" ];
      preStart      = "install -o katzen-server -g katzen-server -m 700 -d ${dataDir}";

      serviceConfig = {
        Type        = "simple";
        ExecStart   = "${katzenpost-server}/bin/server -f ${confFile}";
        Restart     = "always";
        PermissionsStartOnly = true;
        User        = "katzen-server";
        Group       = "katzen-server";
      };
    };
  };
}
