#! bin/bash

IAM_TOKEN=$IC_IAM_TOKEN
base_url=$base_url
access_group_id=$access_group_id
response=$(curl -X GET --location --header "Authorization: Bearer ${IAM_TOKEN}" --header "Accept: application/json" "${base_url}/v2/groups/${access_group_id}/members")
members=$(echo "$response" | jq '.members[] | .iam_id')
curl -X POST --location --header "Authorization: Bearer ${IAM_TOKEN}" --header "Accept: application/json" --header "Content-Type: application/json" --data '{ "members": [ '${members}' ]}' "${base_url}/v2/groups/${access_group_id}/members/delete"
curl -X DELETE --location --header "Authorization: Bearer ${IAM_TOKEN}" "${base_url}/v2/groups/${access_group_id}"
