#!/bin/bash

# Select a profile using gum filter
 profile="$(aws configure list-profiles | sort -k 2 | gum filter --placeholder='Select a profile...')"

# Use the selected profile to list distributions and select with gum filter, prompt for an invalidation path
selected=`printf "$(gum spin --spinner line --title 'Finding distributions' --show-output -- aws cloudfront list-distributions --query 'DistributionList.Items[*].[Origins.Items[0].Id,Id]' --output text --profile $profile | gum filter)"`
name=`printf "$selected" | awk '{print $1}'`
id=`printf "$selected" | awk '{print $2}'`
path="$(gum input --placeholder 'Enter an invalidation path:')"

message="Invalidation successfully created."

# Create the invalidation using the selected ID and the invalidation path
gum confirm "Invalidate the CloudFront cache for $name distribution on the following path: $path" && \
gum spin --spinner line --title 'Creating the invalidation...' -- aws cloudfront create-invalidation  \
    --distribution-id $id  \
    --paths $path \
    --profile $profile || message="No invalidation created."

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	$message

sleep 2


