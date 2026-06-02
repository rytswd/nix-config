# Display managers are mutually exclusive, so this bundle picks none. Hosts
# import exactly one of ./sddm, ./gdm, or ./cosmic-greeter directly
# (same pattern as ../core/boot, which leaves the bootloader choice to the
# host).
#
# The bundle exists so hosts can keep a uniform `./login-manager` import line
# alongside the per-implementation path -- today it's a no-op; future shared
# login-manager setup (greetd theme defaults, etc.) would land here.
{ }
