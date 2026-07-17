## Install from a NixOS liveUSB

After partitioning and formatting the disk, mount the target filesystems. UEFI example:

```bash
sudo -i
mount /dev/<root-partition> /mnt
mkdir -p /mnt/boot
mount /dev/<efi-partition> /mnt/boot
swapon /dev/<swap-partition>
```

Run installer:

```bash
nix run github:dokee39/terra.nixos#install-minimal -- <hostname> <username>
```

Installer will:

- generate hardware configuration
- install minimal system
- copy repository to `/home/<username>/.config/nixos`
- set repository ownership
- create `/etc/nixos` symlink
- prompt for root and user passwords

Installer does not partition or format disks.

Reboot:

```bash
reboot
```

## Enable default configuration

After booting into new system, copy host configuration:

```bash
cp ~/.config/nixos/templates/default.nix ~/.config/nixos/hosts/<hostname>/default.nix
```

Edit host and hardware settings:

```bash
$EDITOR ~/.config/nixos/hosts/<hostname>/default.nix
```

Before enabling secrets, print new machine's SSH host key:

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
```

On an existing trusted machine, add this public key and re-encrypt secrets:

```bash
cd ~/.config/nixos
$EDITOR secrets/keys.nix
RULES=secrets/secrets.nix agenix -r -i <private-key>
```

Check and apply configuration:

```bash
nix flake check ~/.config/nixos
sudo nixos-rebuild switch \
  --flake ~/.config/nixos#<hostname>
```

Minimal configuration temporarily disables secret-backed services. `default.nix` enables them by default.
