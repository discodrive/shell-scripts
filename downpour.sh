#!/bin/bash

# Select a profile using fzf
profiles="$(aws configure list-profiles | fzf)"

# Use the selected profile to list distributions and 
# select a distribution with fzf
distibution="$(aws cloudfront list-distributions --query "DistributionList.Items[].{Id : Id}" --output json --profile $profiles | jq -c '.[] | .Id' | fzf)"
