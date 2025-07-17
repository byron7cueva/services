## Install Nix

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
nix --version
```

Habilitar flakes

sudo mkdir -p /etc/nix
sudo nano /etc/nix/nix.conf

Agregar:
experimental-features = nix-command flakes


Instalar devenv.sh
nix profile install github:cachix/devenv


Integrar con direnv (activar automaticamente por directorio)
nix profile install nixpkgs#direnv

echo 'eval "$(direnv hook bash)"' >> ~/.zshrc
source ~/.zshrc
