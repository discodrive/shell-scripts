# #!/bin/bash

# Select an AWS profile from ~/.aws with fzf
# Use this profile to list any cloudfront distributions
# Select a distribution with fzf
# Get the distribution ID and create an invalidation

profile="$(aws configure list-profiles | sort -k 2 | fzf)"

# Use the selected profile to list distributions and select with fzf
selected=`printf "$(aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,Origins.Items[0].Id]' --output text --profile $profile | fzf)"`
id=`printf "$selected" | awk '{print $1}'`
read -p "Invalidation path: " path

aws cloudfront create-invalidation --distribution-id $id --paths "$path" --profile $profile
