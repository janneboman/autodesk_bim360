#!/bin/bash

ACCOUNT_ID=`cat ~/account_id.txt`
LIMIT=100
OFFSET=0

echo 'id;account_id;project_type;status;country;business_unit_id;language;construction_type;last_sign_in;created_at;updated_at' > projects.csv

while [ "$DATA" != "[]" ]; do

  ACCESS_TOKEN=`cat ~/access_token.txt`

  DATA=$(curl -X GET \
  'https://developer.api.autodesk.com/hq/v1/accounts/'$ACCOUNT_ID'/projects?limit='$LIMIT'&offset='$OFFSET'' \
  -H 'Authorization: Bearer '$ACCESS_TOKEN'' \
  -H 'cache-control: no-cache')

  echo $DATA | jq -r '.[] | (.id|tostring) + ";" + (.account_id|tostring) + ";" + (.project_type|tostring) + ";" + (.status|tostring) + ";" + (.country|tostring) + ";" + (.business_unit_id|tostring) + ";" + (.language|tostring) + ";" + (.construction_type|tostring) + ";" + (.last_sign_in|tostring) + ";" + (.created_at|tostring) + ";" + (.updated_at|tostring)' >> projects.csv

  let OFFSET=OFFSET+100

done

