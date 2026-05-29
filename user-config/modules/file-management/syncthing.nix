{
  services.syncthing = {
    enable = true;

    settings = {
      options = {
        # Private only — no external discovery or relay servers
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };

    };
  };
}
