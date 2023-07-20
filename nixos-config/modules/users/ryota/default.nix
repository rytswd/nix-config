{ pkgs, ... }:

{
    users.users = {
        ryota = {
            isNormalUser = true;
            home = "/home/ryota";
            extraGroups = [ "wheel" ];
            initialHashedPassword = "$6$hGTdy9p9p203$8oeOAgXLzkKdo5HUkydZkEYQbWxzXgtjMsmSB76PkO6p/JWbJuJ9FhMXmhibm.XqZD58pR8hlc5EocdncS72s/"; # root
        };
    };
}
