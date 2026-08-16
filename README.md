## Build installer ISO

Build on any x86_64 Linux system with Nix:

```bash
nix build .#installer-iso
```

## Install from the live USB

```bash
sudo -i
lsblk -f
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

To update an existing bootstrap from a newer live USB, mount the existing
filesystems without formatting them, then run:

```bash
install-bootstrap
reboot
```

This updates only the installed NixOS generation and preserves hostname, users,
passwords, SSH keys, `hardware.nix`, and `/home`.

## Connect to the installed system

Connect Wi-Fi if needed:

```bash
impala
```

Transfer files and connect from a trusted machine:

```bash
sudo scp /path/to/config.yaml <username>@<hostname>.local:~/config.yaml
scp <username>@<hostname>.local:~/hardware.nix /tmp/hardware.nix
ssh <username>@<hostname>.local
```

Install a Mihomo configuration and start the service:

```bash
sudo install -Dm600 ~/config.yaml /var/lib/private/mihomo/config.yaml
sudo systemctl restart mihomo

clashtui
```

## Prepare the full configuration

On the new machine, print host and user public keys:

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
cat ~/.ssh/id_ed25519.pub
```

On a trusted machine, add both keys to `secrets/keys.nix`, add the user key to
GitHub, then rekey and push:

```bash
cd ~/.config/nixos
git pull --ff-only

mkdir hosts/<hostname>
cp hosts/host-template.nix hosts/<hostname>/default.nix
cp /tmp/hardware.nix hosts/<hostname>

$EDITOR # secrets/keys.nix hosts/<hostname>/default.nix ...

(cd secrets && agenix -r)

git add .
git commit -m "feat: add new host: <hostname>"
git push
```

## Initialize and enable the full configuration

On the new machine:

```bash
ssh -T git@github.com
git clone git@github.com:dokee39/terra.nixos.git ~/nixos-config
sudo cp -a ~/nixos-config/. /etc/nixos/
sudo chown -R "$USER":users /etc/nixos

sudo nixos-rebuild switch --flake /etc/nixos#<hostname>

rm -v -rf ~/nixos-config ~/config.yaml ~/hardware.nix
```
