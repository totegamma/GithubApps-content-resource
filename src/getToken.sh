#!/bin/bash
set -ex

PAYLOAD="$(cat <&0)"

KEYSTRING=$(jq -r '.source.private_key // ""' <<< $PAYLOAD)
ACCOUNT=$(jq -r '.source.account // ""' <<< $PAYLOAD)
APPID=$(jq -r '.source.appID // ""' <<< $PAYLOAD)

echo $KEYSTRING > privatekey.pem
JWT=$(jwt encode --secret @privatekey.pem --iss $APPID --exp +5min --alg RS256)
rm privatekey.pem

INSTALLATION_ID=$(curl -s -X GET -H "Authorization: Bearer $JWT" -H "Accept: application/vnd.github+json" https://api.github.com/app/installations \
                | jq -r --arg target $ACCOUNT 'map(select(.account.login==$target)) | .[0].id')
TOKEN=$(curl -s -X POST -H "Authorization: Bearer $JWT" -H "Accept: application/vnd.github+json" https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens \
      | jq -r '.token')

echo $TOKEN

