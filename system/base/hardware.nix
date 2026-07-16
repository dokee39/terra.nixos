{ ... }:

{
  hardware.enableRedistributableFirmware = true;
  hardware.i2c.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    LE = {
      MinConnectionInterval = 7;
      MaxConnectionInterval = 9;
      ConnectionLatency = 0;
    };
  };

  hardware.xpadneo = {
    enable = true;
    settings.disabled_deadzones = 1;
  };

  services.udisks2 = {
    enable = true;
    settings."mount_options.conf" = {
      defaults = {
        "ntfs:ntfs3_defaults" =
          "uid=$UID,gid=$GID,fmask=0133,dmask=0022,windows_names,prealloc,force";
        "ntfs:ntfs3_allow" =
          "uid=$UID,gid=$GID,umask,dmask,fmask,iocharset,discard,nodiscard,sparse,nosparse,hidden,nohidden,sys_immutable,nosys_immutable,showmeta,noshowmeta,prealloc,noprealloc,hide_dot_files,nohide_dot_files,windows_names,nocase,case,force";
        ntfs_drivers = "ntfs3";
      };
    };
  };

  services.auto-cpufreq.enable = true;
}
