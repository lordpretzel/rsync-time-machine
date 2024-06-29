{
  description = "rsync-tmbackup.py -- Rsync time machine backup script";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    rsync-time-machine = {
      type = "github";
      owner = "laurent22";
      repo = "rsync-time-backup";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, rsync-time-machine }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          #rsync-src = rsync-time-machine;
          
          dependencies = with pkgs; [
            rsync
            bashInteractive
          ];

          # package settings
          scriptname="rsync_tmbackup.sh";
          package-version = "1.0";
          package-name = "rsync-time-machine";
          
        in with pkgs;
          {
            ###################################################################
            #                       package                                   #
            ###################################################################
            packages = {
              rsync-time-machine = stdenv.mkDerivation {
                name= "${package-name}";
                src = rsync-time-machine;
                
                buildInputs = dependencies;
                nativeBuildInputs = [ makeWrapper ];
                installPhase = ''
                  mkdir -p $out/bin/
                  mkdir -p $out/share/
                  cp $src/${scriptname} $out/share/${scriptname}
                  chmod +x $out/share/${scriptname}
                  makeWrapper $out/share/${scriptname} $out/bin/${scriptname}
                '';                
              };
            };

            ###################################################################
            #                       development shell                         #
            ###################################################################
            devShells.default = mkShell
              {
                buildInputs = dependencies;

                shellHook = ''
                export PATH=${rsync-time-machine}:$PATH
                '';
              };
          }
      );
}
