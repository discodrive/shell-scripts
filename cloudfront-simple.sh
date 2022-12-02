#!/bin/bash

profile="$(aws configure list-profiles | sort -k 2 | fzf)"
selected=$(printf "$(aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,Origins.Items[0].Id]' --output text --profile $profile | fzf)")
id=$(printf %s "$selected" | awk '{print $1}')
read -p "Invalidation path: " path
aws cloudfront create-invalidation --distribution-id "$id" --paths "$path" --profile "$profile"
