#!/bin/sh
# Keep the 100.64.0.0/10 route pointed at Tailscale, defeating the LG U+ DS-Lite
# CGNAT route the router pushes via DHCP. See [[TAILSCALE.md]] for the why.
#
#   cgnat-route.sh           heal the route now (default; run as root by the daemon)
#   cgnat-route.sh install   (re)install the LaunchDaemon (uses sudo)

set -u

SELF=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")
LABEL=com.studioboxcat.tailscale-cgnat-fix
PLIST=/Library/LaunchDaemons/$LABEL.plist
CGNAT=100.64.0.0/10
PROBE=100.64.0.1   # any tailnet IP not covered by a more-specific /32 route

install() {
	sed "s|@SCRIPT@|$SELF|g" "$(dirname "$SELF")/$LABEL.plist" | sudo tee "$PLIST" >/dev/null
	sudo chmod 644 "$PLIST"
	sudo launchctl bootout system "$PLIST" 2>/dev/null || true
	sudo launchctl bootstrap system "$PLIST"
}

heal() {
	# Tailscale's utun is the only utun carrying an IPv4 in 100.64/10 (iCloud
	# Private Relay utuns have none). Empty => Tailscale is down, nothing to do.
	ts_if=$(/sbin/ifconfig 2>/dev/null | /usr/bin/awk \
		'/^utun[0-9]+:/{gsub(/:/,"",$1); i=$1} /inet 100\./{print i; exit}')
	[ -n "$ts_if" ] || exit 0

	cur_if=$(/sbin/route -n get "$PROBE" 2>/dev/null | /usr/bin/awk '/interface:/{print $2}')
	[ "$cur_if" = "$ts_if" ] && exit 0

	# Drop the hijacking global route (router's DHCP one, or stale); Tailscale's
	# own route is interface-scoped so a plain delete leaves it. Then claim it.
	/sbin/route -n delete -net "$CGNAT" >/dev/null 2>&1 || true
	/sbin/route -n add -net "$CGNAT" -interface "$ts_if" >/dev/null 2>&1 || true
	/usr/bin/logger -t "$LABEL" "repointed $CGNAT: ${cur_if:-none} -> $ts_if"
}

case "${1:-heal}" in
	heal) heal ;;
	install) install ;;
	*) echo "usage: $0 [heal|install]" >&2; exit 2 ;;
esac
