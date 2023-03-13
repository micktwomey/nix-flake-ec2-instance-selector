{
  description = "A CLI tool and go library which recommends instance types based on resource criteria like vcpus and memory.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-compat }:
    let
      version = "2.4.1";

      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.buildGoModule {
            pname = "ec2-instance-selector";
            inherit version;
            src = pkgs.fetchFromGitHub {
              owner = "aws";
              repo = "amazon-ec2-instance-selector";
              rev = "v${version}";
              # hash = pkgs.lib.fakeSha256;
              hash = "sha256-LRAKWmxpQJ2QIM3hdWxDN4fNASxLp/fy1A259rwrcLE=";
            };

            # vendorHash = pkgs.lib.fakeSha256;
            vendorHash = "sha256-bCk4Ins+zGBEEDZpAlLjc/2o0oBp+w6wogpNPn6rcbM=";

            # The readme-tests are built so filter those out using subPackages
            subPackages = [ "cmd/." ];

            # TODO: find the better way of handling this
            # The problem is the source is in cmd/main.go, not cmd/ec2-instance-selector/main.go
            # This results in an output of `cmd` which has to be renamed
            postInstall = ''
              mv $out/bin/cmd $out/bin/ec2-instance-selector
            '';
          };
        });

      apps = forAllSystems (system: {
        default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/ec2-instance-selector";
        };
      });
      
      # Add dependencies that are only needed for development
      devShells = forAllSystems (system:
        let 
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ go gopls gotools go-tools ];
          };
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.default);
    };
}
