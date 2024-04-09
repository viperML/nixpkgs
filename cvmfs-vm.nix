# nix build -I nixos-config=$PWD/cvmfs-vm.nix -I nixpkgs=$PWD -f ./nixos config.system.build.vm -L
{ config, lib, modulesPath, ... }:
let
  mkVMDefault = lib.mkOverride 900;
in
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  services.getty.autologinUser = "root";
  users.users.root.password = "root";

  services.cvmfs = {
    enable = true;
  };

  virtualisation = {
    graphics = mkVMDefault false;
    memorySize = mkVMDefault 700;

    qemu.consoles = [
      "tty0"
      "hvc0"
    ];

    qemu.options = [
      "-serial null"
      "-device virtio-serial"
      "-chardev stdio,mux=on,id=char0,signal=off"
      "-mon chardev=char0,mode=readline"
      "-device virtconsole,chardev=char0,nr=0"
    ];
  };
}
