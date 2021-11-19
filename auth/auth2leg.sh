#!/bin/bash

# I suggest to store client credentials somewhere secure
client_id=`cat ~/client_id.txt`
client_secret=`cat ~/client_secret.txt`
scope='data:read%20account:read' # set your scope according to what access the token needs to have

while true; do

  data=$(curl 'https://developer.api.autodesk.com/authentication/v1/authenticate' \
    -X 'POST' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d 'client_id='$client_id'&client_secret='$client_secret'&grant_type=client_credentials&scope='$scope'')

  echo $data | jq -r '.access_token' > ~/access_token.txt # to-do: maybe store token in a more elegant way...

  echo we got token
  cat ~/access_token.txt
  expires=$(echo $data | jq -r '.expires_in')
  echo "expires in" $expires
  sleep_time=$(($expires - 200))
  echo "sleep is" $sleep_time
  sleep $sleep_time

done
