{ perlPackages
, fetchFromGitHub
, lib
, makeWrapper
, dmidecode
, pciutils
, hdparm
, openssh
, nettools
}:
perlPackages.buildPerlPackage rec {
  pname = "glpi-agent";
  version = "1.9";

  src = fetchFromGitHub {
    owner = "glpi-project";
    repo = "glpi-agent";
    rev = version;
    hash = "sha256-3OblgKco7/vYCXDuWzEWq+3Rwr032HSeBISQI74IEYs=";
  };

  preConfigure = ''
    sed \
      -e "s/logger = .*/logger = stderr/" \
      -e 's|include "conf\.d/"|include "/etc/glpi-agent/conf\.d/"|' \
      -i etc/agent.cfg
  '';

  makeMakerFlags = [
    "SYSCONFDIR=${builtins.placeholder "out"}/etc/glpi-agent" # use bundled configs
    "LOCALSTATEDIR=/var/lib/glpi-agent"
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = with perlPackages; [
    ModuleInstall
  ];

  # https://github.com/glpi-project/glpi-agent?tab=readme-ov-file#dependencies
  propagatedBuildInputs = with perlPackages; [
    # Core
    ## Mandatory Perl modules
    FileWhich
    LWPUserAgent
    NetIP
    TextTemplate
    UNIVERSALrequire
    XMLLibXML
    CpanelJSONXS
    ## Optional Perl modules
    CompressZlib
    HTTPDaemon
    IOSocketSSL
    LWPProtocolhttps
    ProcDaemon
    ProcPIDFile

    # Inventory task
    ## Optional Perl modules:
    NetCUPS
    ParseEDID
    DateTime

    # Network discovery tasks
    ## Mandatory Perl modules
    ThreadQueue
    ## Optional Perl modules
    # NetNBName
    NetSNMP

    # Network inventory tasks
    ## Mandatory Perl modules
    NetSNMP
    ThreadQueue
    ## Optional Perl modules
    CryptDES

    # Wake on LAN task
    ## Optional Perl modules
    # NetWriteLayer2

    # Deploy task
    ## Mandatory Perl modules
    ArchiveExtract
    DigestSHA
    FileCopyRecursive
    CpanelJSONXS
    URI #Escape
    # Mandatory Perl modules for P2P Support
    NetPing
    ParallelForkManager

    # Not declared
    DataUUID
  ];

  postInstall = ''
    for file in $out/bin/*; do
      wrapProgram "$file" \
        --prefix PATH : ${lib.makeBinPath [
          dmidecode
          pciutils
          hdparm
          # monitor-get-edid-using-vbe ?
          openssh
          nettools
        ]}
    done
  '';

  outputs = [ "out" ];

  doCheck = false;

  meta = {
    description = "GLPI inventory agent";
    mainProgram = "glpi-agent";
    homepage = "https://github.com/glpi-project/glpi-agent";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ viperML ];
  };
}
