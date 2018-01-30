{ config, lib, pkgs, ... }:
with lib;

let
  katzenpost-authority-nonvoting = pkgs.callPackage ../../../../../pkgs/networking/katzenpost/authority/nonvoting/default.nix {};
  cfg = config.services.katzenpost-authority-nonvoting;
  dataDir = "/var/lib/katzenpost-authority-nonvoting";
  confFile = pkgs.writeText "katzenpost-authority-nonvoting.conf" ''
    ${cfg.config}
  '';
in

{
  meta = {
    maintainers = with maintainers; [ TealG ];
  };

  options = {
    services.katzenpost-authority-nonvoting = {
      enable = mkEnableOption "Katzenpost non-voting authority";

      config = mkOption {
        default     = null;
        type        = types.nullOr types.str;
        description = ''
          Contents of Katzenpost non-voting authority configuration file
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion   = cfg.config != null;
        message     = "Please provide Katzenpost non-voting authority configuration file contents";
      }
    ];

    users.users.katzen-auth-nonvoting = {
      description   = "Katzenpost non-voting authority daemon";
      isSystemUser  = true;
      group         = "katzen-auth-nonvoting";
      home          = dataDir;
    };
    users.groups.katzen-auth-nonvoting = {};

    systemd.services.katzenpost-authority-nonvoting = {
      description   = "Katzenpost non-voting authority";
      after         = [ "network.target" ];
      wantedBy      = [ "multi-user.target" ];
      preStart      = "install -o katzen-auth-nonvoting -g katzen-auth-nonvoting -m 700 -d ${dataDir}";

      serviceConfig = {
        Type        = "simple";
        ExecStart   = "${katzenpost-authority-nonvoting}/bin/nonvoting -f ${confFile}";
        Restart     = "always";
        PermissionsStartOnly = true;
        User        = "katzen-auth-nonvoting";
        Group       = "katzen-auth-nonvoting";
      };
    };
  };
}
