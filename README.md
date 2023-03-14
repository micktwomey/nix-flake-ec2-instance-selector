# Nix Flake build of AWS ec2-instance-selector

Nix Flake build of [aws/amazon-ec2-instance-selector](https://github.com/aws/amazon-ec2-instance-selector)

This is learning exercise in packaging up go binaries.

Some notes:
- Used the nix flake go-hello template as a starting point (`nix flake new -t templates#go-hello .`)
- [Nix Flakes: an Introduction](https://xeiaso.net/blog/nix-flakes-1-2022-02-21) was a useful guide
- Start with `pkgs.lib.fakeSha256` for both the `hash` and the `vendorHash`, this allows Nix to fetch the go sources and tell you the correct SHA
- Used [flake-compat](https://github.com/edolstra/flake-compat) to provide a compatibility default.nix so I didn't need to update how I include the package in my home-manager (I haven't switched to flakes)
- I had to rename the build command from `cmd` to `ec2-instance-selector`. I'm not sure `postInstall` is the best way to do this.
