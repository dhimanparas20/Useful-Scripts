#!/bin/sh
# FreeDNS updater script

UPDATEURL="http://freedns.afraid.org/dynamic/update.php?__AUTH_TOKEN_HERE__"
DOMAIN="mst-services.mooo.com"

registered=$(nslookup $DOMAIN | tail -n2 | grep A | sed s/[^0-9.]//g)
current=$(wget -q -O - http://checkip.dyndns.org | sed s/[^0-9.]//g)

if [ "$current" != "$registered" ]; then
    wget -q -O /dev/null "$UPDATEURL"
    echo "DNS updated on:"; date
else
    echo "IP already updated, no need to update."
fi
