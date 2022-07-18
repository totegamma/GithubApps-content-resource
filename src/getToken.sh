#!/bin/bash
set -x

PAYLOAD="$(cat <&0)"

ACCOUNT=$(jq -r '.source.account // ""' <<< $PAYLOAD)
if [ -z "$ACCOUNT" ]; then
	echo "source parameter 'account' missing." >&2
	exit 1
fi

APPID=$(jq -r '.source.appID // ""' <<< $PAYLOAD)
if [ -z "$APPID" ]; then
	echo "source parameter 'appID' missing." >&2
	exit 1
fi

jq -r '.source.private_key // ""' <<< $PAYLOAD | tr -d '\n' > privatekey.pem
JWT=$(jwt encode --secret @privatekey.pem --iss $APPID --exp +3min --alg RS256)
rm privatekey.pem

if [ -z "$JWT" ]; then
	echo "failed to generagte JWT (is private_key valid?)" >&2
	exit 1
fi

INSTALLATION_ID=$(curl -s -X GET -H "Authorization: Bearer $JWT" -H "Accept: application/vnd.github+json" https://api.github.com/app/installations \
                | jq -r --arg target $ACCOUNT 'map(select(.account.login==$target)) | .[0].id // ""')
if [ -z "$INSTALLATION_ID" ]; then
	echo "failed to get INSTALLATION_ID (is your application installed to target?)" >&2
	exit 1
fi

TOKEN=$(curl -s -X POST -H "Authorization: Bearer $JWT" -H "Accept: application/vnd.github+json" https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens \
      | jq -r '.token // ""')
if [ -z "$TOKEN" ]; then
	echo "failed to get token (is your application installed to target?)" >&2
	exit 1
fi

echo $TOKEN

