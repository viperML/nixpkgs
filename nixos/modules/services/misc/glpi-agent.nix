{ pkgs
, config
, lib
, ...
}:
let
  cfg = config.services.glpi-agent;
in
{
  options.services.glpi-agent = {
    enable = lib.mkEnableOption "glpi-agent";

    package = lib.mkPackageOption pkgs "glpi-agent" { };

    extraConfig = lib.mkOption {
      description = "Literal glpi-agent configuration";
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      glpi-agent
    ];

    environment.etc."glpi-agent/conf.d/nixos.cfg".text = cfg.extraConfig;

    # https://github.com/glpi-project/glpi-agent/blob/develop/contrib/unix/glpi-agent.service
    systemd.services.glpi-agent = {
      enable = true;
      description = "GLPI agent";
      documentation = [ "man:glpi-agent" ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} --daemon --no-fork $OPTIONS";
        ExecReload = "${pkgs.util-linux.bin}/bin/kill -HUP $MAINPID";
        CapabilityBoundingSet = [ "~CAP_SYS_PTRACE" ];
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
    };
  };
}
