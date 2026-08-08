## Install from a NixOS live USB

```bash
sudo -i

# Wi-Fi only
nmtui

timedatectl

lsblk
fdisk /dev/<target-disk>
```

Use GPT for a new partition table:

```text
/boot   +512M      EFI System
/       +120G      Linux filesystem
/home   remaining  Linux filesystem
```

Skip `/boot` when reusing an existing EFI system partition.

Check partition names before formatting:

```bash
lsblk

# Only for a newly created EFI partition
mkfs.fat -F 32 /dev/<efi-partition>

mkfs.ext4 /dev/<root-partition>
mkfs.ext4 /dev/<home-partition>
```

Mount filesystems and run installer:

```bash
mount /dev/<root-partition> /mnt
mount --mkdir /dev/<efi-partition> /mnt/boot
mount --mkdir /dev/<home-partition> /mnt/home

export http_proxy=http://<lan-device-ip>:<port>                                
export https_proxy="$http_proxy" 
nix --extra-experimental-features "nix-command flakes" run github:dokee39/terra.nixos#install-minimal -- <hostname> <username>

reboot
```

## After reboot

Reconnect Wi-Fi if needed:

```bash
impala
```

Continue locally or connect from a trusted machine:

```bash
ssh <username>@<hostname>.local
```

Print host and user public keys:

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
cat ~/.ssh/id_ed25519.pub
```

## Rekey secrets

On a trusted machine, add host key to `hosts` and user key to `users`:

```bash
cd ~/.config/nixos
$EDITOR secrets/keys.nix
RULES=secrets/secrets.nix agenix -r -i <private-key>
```

Sync `secrets/keys.nix` and `secrets/*.age` back to new machine.

## Enable default configuration

```bash
cp ~/.config/nixos/templates/default.nix \
  ~/.config/nixos/hosts/<hostname>/default.nix

sed -i 's/"user_name"/"<username>"/' \
  ~/.config/nixos/hosts/<hostname>/default.nix

$EDITOR ~/.config/nixos/hosts/<hostname>/default.nix
git -C ~/.config/nixos add -- hosts/<hostname>

nix flake check ~/.config/nixos

sudo nixos-rebuild switch \
  --flake ~/.config/nixos#<hostname>
```
