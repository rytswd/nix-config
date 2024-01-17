{ pkgs
, ... }:

let ryota =
  if pkgs.stdenv.isDarwin then {
    home = "/Users/ryota";
  } else {
    home = "/home/ryota";

    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialHashedPassword = "$6$hGTdy9p9p203$8oeOAgXLzkKdo5HUkydZkEYQbWxzXgtjMsmSB76PkO6p/JWbJuJ9FhMXmhibm.XqZD58pR8hlc5EocdncS72s/"; # root
  };
  in {
    users.users.ryota = ryota;
  }
