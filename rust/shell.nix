{ pkgs }:

{
  buildInputs = with pkgs; [
    firefox
    geckodriver
    openssl
    pkg-config
  ];
}
