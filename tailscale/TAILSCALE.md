# Tailscale

> **Related:** `cgnat-route.sh`, `com.studioboxcat.tailscale-cgnat-fix.plist` · Tailscale on the 100.x range: https://tailscale.com/kb/1015/100.x-addresses

Mesh VPN for stable Mac Mini access (`macmini.studioboxcat.com` → tailnet IP),
installed as the `tailscale` cask.

## The CGNAT route collision

Tailscale assigns every node a `100.64.0.0/10` IP (RFC 6598 CGNAT). The
home/office **LG U+ Davolink CHGW** gateways run DS-Lite — the ISP's own CGNAT in
that same range — and push LAN clients a DHCP route `100.64.0.0/10 → router`,
which **hijacks all tailnet traffic** to the router, where it drops.

Tell-tale: `tailscale ping` works (disco bypasses the route table) but **every TCP
connection times out** (`ssh macmini`, the git daemon, …). Intermittent, because
the two routers share an SSID and the Mac only sometimes leases the bad route from
the CGNAT one. The CHGW exposes no toggle (it's intrinsic to DS-Lite) and Bridge
mode would kill the LAN's NAT/IPTV — so the fix lives on the Mac.

## The fix

`cgnat-route.sh` (a LaunchDaemon installed by `setup.sh`) re-points
`100.64.0.0/10` at Tailscale's `utun` at boot, on network change, and every 30s.

```sh
tailscale/cgnat-route.sh install   # (re)install the daemon
route -n get 100.64.0.1            # interface: should be Tailscale's utun
log show --last 1h --predicate 'eventMessage contains "tailscale-cgnat-fix"'
```

> If tailnet traffic still drops once the bad route is gone, **iCloud Private
> Relay** may be capturing it — disable *Limit IP address tracking* for the Wi-Fi.
