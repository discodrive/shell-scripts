#!/bin/bash

# Select a profile using fzf
profile="$(aws configure list-profiles | fzf)"

# Use the selected profile to list distributions and select with fzf
selected=`printf "$(aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,Origins.Items[0].Id]' --output text --profile $profile | fzf)"`
id=`printf "$selected" | awk '{print $1}'`
read -p "Invalidation path: " path

aws cloudfront create-invalidation --distribution-id $id --paths "$path" --profile $profile
