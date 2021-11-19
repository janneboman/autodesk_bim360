#!/bin/bash

account_id=`cat ~/account_id.txt`
limit=100
offset=0

echo 'id;account_id;project_type;status;country;business_unit_id;language;construction_type;last_sign_in;created_at;updated_at' > projects.csv

while [ "$data" != "[]" ]; do

  access_token=`cat ~/access_token.txt`

  data=$(curl -X GET \
  'https://developer.api.autodesk.com/hq/v1/accounts/'$account_id'/projects?limit='$limit'&offset='$offset'' \
  -H 'Authorization: Bearer '$access_token'' \
  -H 'cache-control: no-cache')

  echo $data | jq -r '.[] | (.id|tostring) + ";" + (.account_id|tostring) + ";" + (.project_type|tostring) + ";" + (.status|tostring) + ";" + (.country|tostring) + ";" + (.business_unit_id|tostring) + ";" + (.language|tostring) + ";" + (.construction_type|tostring) + ";" + (.last_sign_in|tostring) + ";" + (.created_at|tostring) + ";" + (.updated_at|tostring)' >> projects.csv

  let offset=offset+100

done

