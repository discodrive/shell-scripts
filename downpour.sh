#!/bin/bash

# Select a profile using fzf
profiles="$(aws configure list-profiles | fzf)"

# Use the selected profile to list distributions and select with fzf
distribution="$(aws cloudfront list-distributions --query "DistributionList.Items[].{Id : Id, Name: Origins.Items[0].Id}" --output json --profile $profiles)"

name=$(echo $distribution | jq -c '.[] | .Name' | tr -d \" | tr ' ' '\n')
id=$(echo $distribution | jq -c '.[] | .Id')

echo $name

