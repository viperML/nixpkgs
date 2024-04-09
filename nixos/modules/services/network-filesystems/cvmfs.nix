{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.cvmfs;
in
{
  options = {
    services.cvmfs = {
      enable = lib.mkEnableOption "CernVM-FileSystem";
      package = lib.mkPackageOption pkgs "cvmfs" { };
    };
  };

  config = {
    environment.systemPackages = lib.mkIf cfg.enable [ cfg.package ];

    systemd.tmpfiles.settings."10-cvmfs" = {
      "/var/lib/cvmfs-server" = rec {
        d = {
          user = "cvmfs";
          group = "cvmfs";
          mode = "755";
        };
        z = d;
      };
      "/cvmfs" = rec {
        d = {
          user = "cvmfs";
          group = "cvmfs";
          mode = "755";
        };
        z = d;
      };
    };

    security.wrappers = {
      "cvmfs_suid_helper" = {
        setuid = true;
        owner = "root";
        group = "root";
        source = "${cfg.package}/bin/cvmfs_suid_helper";
      };
    };

    environment.etc =
      {
        "cvmfs/default.local".text = ''
          CVMFS_REPOSITORIES=atlas.cern.ch,atlas-condb.cern.ch,grid.cern.ch,sft.cern.ch,lhcb.cern.ch,lhcbdev.cern.ch
          CVMFS_HTTP_PROXY=DIRECT
        '';
        "auto.cvmfs".source = "${cfg.package}/libexec/cvmfs/auto.cvmfs";
      }
      // (lib.genAttrs
        (map (f: "cvmfs/${f}") [
          "config.d"
          "config.sh"
          "cvmfs_server_hooks.sh.demo"
          "default.conf"
          "default.d"
          "domain.d"
          "keys"
          "serverorder.sh"
        ])
        (f: { source = "${cfg.package}/etc/${f}"; })
      );

    services.autofs = {
      enable = true;
      autoMaster = ''
        /cvmfs /etc/auto.cvmfs
      '';
    };

    users.users."cvmfs" = {
      isSystemUser = true;
      group = "cvmfs";
    };

    users.groups."cvmfs" = { };

    environment.sessionVariables.CVMFS_LIBRARY_PATH = "${cfg.package}/lib";
  };
}
