#!/bin/bash

# I suggest to store client credentials somewhere secure
CLIENT_ID=`cat ~/client_id.txt`
CLIENT_SECRET=`cat ~/client_secret.txt`
SCOPE='data:read%20account:read'

while true; do

  DATA=$(curl 'https://developer.api.autodesk.com/authentication/v1/authenticate' \
    -X 'POST' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d 'client_id='$CLIENT_ID'&client_secret='$CLIENT_SECRET'&grant_type=client_credentials&scope='$SCOPE'')

  echo $DATA | jq -r '.access_token' > ~/access_token.txt # to-do: maybe store token in a more elegant way...

  echo we got token
  
  cat ~/access_token.txt

  EXPIRES=$(echo $DATA | jq -r '.expires_in')

  echo "expires in" $EXPIRES

  SLEEP=$(($EXPIRES - 200))

  echo "sleep is" $SLEEP

  sleep $SLEEP

done
