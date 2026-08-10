## Build installer ISO

Build on any x86_64 Linux system with Nix:

```bash
nix build .#installer-iso
ls result/iso
```

## Install from the live USB

```bash
sudo -i
lsblk
fdisk /dev/<target-disk>
```

Use GPT for a new partition table:

```text
/boot   +512M      EFI System
/       +120G      Linux filesystem
/home   remaining  Linux filesystem
```

Skip creating a new EFI partition when reusing an existing one. Check partition names before formatting:

```bash
lsblk

# Only for a newly created EFI partition
mkfs.fat -F 32 -n NIXOS_BOOT /dev/<efi-partition>

# For an existing FAT EFI partition without a label
fatlabel /dev/<efi-partition> NIXOS_BOOT

mkfs.ext4 -L nixos-root /dev/<root-partition>
mkfs.ext4 -L nixos-home /dev/<home-partition>
```

Mount filesystems and install the system already contained in the ISO:

```bash
mount /dev/<root-partition> /mnt
mount --mkdir /dev/<efi-partition> /mnt/boot
mount --mkdir /dev/<home-partition> /mnt/home

install-bootstrap <hostname> <username>
reboot
```

Installation does not require network access.

## Connect to the installed system

Connect Wi-Fi if needed:

```bash
impala
```

Continue locally or connect from a trusted machine:

```bash
ssh <username>@<hostname>.local
```

Install a Mihomo configuration and start the service:

```bash
sudo install -Dm600 /path/to/config.yaml \
  /var/lib/private/mihomo/config.yaml
sudo systemctl restart mihomo

clashtui
```

## Rekey secrets

On the new machine, print host and user public keys:

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
cat ~/.ssh/id_ed25519.pub
```

On a trusted machine, add host key to `hosts` and user key to `users`, then rekey and push:

```bash
cd ~/.config/nixos/secrets
$EDITOR keys.nix
agenix -r
git add -- keys.nix *.age
git commit -m "feat: rekey secrets for <hostname>"
git push
```

## Initialize the configuration repository

On the new machine:

```bash
nix run github:dokee39/terra.nixos#init-config
```

## Enable the full configuration

```bash
cp ~/.config/nixos/hosts/host-template.nix \
  ~/.config/nixos/hosts/<hostname>/default.nix

sed -i 's/"user_name"/"<username>"/' \
  ~/.config/nixos/hosts/<hostname>/default.nix

$EDITOR ~/.config/nixos/hosts/<hostname>/default.nix
git -C ~/.config/nixos add -- hosts/<hostname>

nix flake check ~/.config/nixos

sudo nixos-rebuild switch \
  --flake ~/.config/nixos#<hostname>
```
