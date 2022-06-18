#!/usr/bin/env sh

# This script checks whethere or not the bootsector reached the limit

set -e

[ -z "$1" ] && exit

FILESIZE="$(wc -c <"$1" | tr -d "")"

[ "$FILESIZE" -eq 509 ] && {
	echo "limit reached: $FILESIZE bytes (limit 509)"
	exit
}

echo "SIZE: $FILESIZE (limit 509) "
