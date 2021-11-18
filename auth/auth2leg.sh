#!/bin/bash

# I suggest to store client credentials somewhere secure
CLIENT_ID=`cat ~/client_id.txt`
CLIENT_SECRET=`cat ~/client_secret.txt`

while true; do

  DATA=$(curl 'https://developer.api.autodesk.com/authentication/v1/authenticate' \
    -X 'POST' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d 'client_id='$CLIENT_ID'&client_secret='$CLIENT_SECRET'&grant_type=client_credentials&scope=data:read')

  echo $DATA | jq -r '.access_token' > access_token.txt

  echo we got token

  echo $DATA | jq -r '.access_token'

  EXPIRES=$(echo $DATA | jq -r '.expires_in')

  echo "expires in" $EXPIRES

  SLEEP=$(($EXPIRES - 200))

  echo "sleep is" $SLEEP

  sleep $SLEEP

done
