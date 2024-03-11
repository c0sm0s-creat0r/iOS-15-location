#!/bin/bash
url='http://www.mapquestapi.com/geocoding/v1/address?key='
args='&location='
key='VzDGw2u65p0PeEWA1MNIDZSFbCyZs6ek'
addr="$(echo $* | sed 's/ /+/g' | tr -d ',')"
echo "$(curl -s "$url$key$args$addr" | cut -d, -f30,31 | sed 's/[^0-9\.\,\-]//g;s/,$//' | tr ',' ' ')"
