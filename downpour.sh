#!/bin/bash

# Select a profile using fzf
profiles="$(aws configure list-profiles | fzf)"

# Use the selected profile to list distributions and select with fzf
distibution="$(aws cloudfront list-distributions --query "DistributionList.Items[].{Id : Id, Name: Origins.Items[0].Id}" --output json --profile $profiles)"

name=`printf "$($distribution | jq -c '.[] | .Name')"`
#id=printf "${distribution}" | jq-c '.[] | .Id'

