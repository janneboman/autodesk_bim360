#!/bin/bash

# This script reads info about all files in a project (or projects) and puts info to a mongo db
# Could also be modified to output to a csv file, etc..
# The basic idea is to request folder contents, starting from BIM project top folders (like Plans, Project Files..)
# and then get details for folder contents. If contents contain files, get item details. If contents are more (sub)folders, add those folders
# to a "to-do" list and repeat until all folders are checked
# script takes as input a list of project ids (project_ids.txt)

account_id=`cat ~/account_id.txt`

options="-s"

foldercontents () {

  access_token=`cat ~/access_token.txt`

  curl $options -o folder.json $urn -H 'Authorization: Bearer '$access_token''

  mongoimport --quiet --db bim --collection folder --file folder.json

  nextlist=()
    for value in "${urn[@]}"
     do
       [[ $value != $urn ]] && nextlist+=($value)
    done

  urn=("${nextlist[@]}")

  next=$(jq -r '.links.next.href' folder.json)

  if [ "$next" != "null" ]
    then urn+=( "$next" )
  fi

  for row in $(jq -r '.data[] | @base64' folder.json); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
     }

    item_id=$(_jq '.id')
    item_type=$(_jq '.attributes.extension.type')

    # check folder contents:

    if [ $item_type = "folders:autodesk.bim360:Folder" ]
      then urn+=( 'https://developer.api.autodesk.com/data/v1/projects/b.'$project_id'/folders/'$item_id'/contents?page%5Blimit%5D='$pagelimit'' )
      else itemdata "$item_id"
    fi

  done

}


itemdata () {

  access_token=`cat ~/access_token.txt` # get access token using 2 leg auth

  item_urn=$(echo 'https://developer.api.autodesk.com/data/v1/projects/b.'$project_id'/items/'$item_id'')
  curl $options -o item.json $item_urn -H 'Authorization: Bearer '$access_token''

  mongoimport --quiet --db bim --collection item --file item.json

  tip_urn=$(echo 'https://developer.api.autodesk.com/data/v1/projects/b.'$project_id'/items/'$item_id'/tip')
  curl $options -o tip.json $tip_urn -H 'Authorization: Bearer '$access_token''

  mongoimport --quiet --db bim --collection tip --file tip.json

  parent_urn=$(echo 'https://developer.api.autodesk.com/data/v1/projects/b.'$project_id'/items/'$item_id'/parent')
  curl $options -o parent.json $parent_urn -H 'Authorization: Bearer '$access_token''

  mongoimport --quiet --db bim --collection parent --file parent.json

}

while read project_id; do

echo "reading files from project "$project_id

start=`date +%s`

  access_token=`cat ~/access_token.txt`
  curl $options -o topfolder.json 'https://developer.api.autodesk.com/project/v1/hubs/b.'$account_id'/projects/b.'$project_id'/topFolders' \
    -H 'Authorization: Bearer '$access_token''

  mongoimport --quiet --db bim --collection topfolder --file topfolder.json

  for row in $(jq -r '.data[] | @base64' topfolder.json); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
     }

    topfolder_id=$(_jq '.id')
    topfolder_name=$(_jq '.attributes.displayName')

    urn+=( 'https://developer.api.autodesk.com/data/v1/projects/b.'$project_id'/folders/'$topfolder_id'/contents' )

    while (( ${#urn[@]} )); do

      for folder in "${urn[@]}"; do foldercontents "$folder"; done

    done


  done

end=`date +%s`
runtime=$((end-start))

echo project id was $project_id, runtime was $runtime

done < project_ids.txt
