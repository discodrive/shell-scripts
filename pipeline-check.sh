#!/bin/bash

# Azure DevOps Organization URL
org_url="https://dev.azure.com/leeaplin"

# Azure DevOps Personal Access Token (PAT)
pat=$1

# Azure DevOps Project Name
project_name="kickstart"

# Azure DevOps API Version
api_version="6.1"

# REST API endpoint to list pipelines
url="$org_url/$project_name/_apis/pipelines?api-version=$api_version"

# Make the API request
response=$(curl -s -H "Authorization: Basic $pat" "$url")

# Check for errors in the response
if [[ "$response" == *"error"* ]]; then
  echo "Error: Unable to list pipelines. Please check your configuration."
  exit 1
fi

# Parse and display the pipeline information
pipelines=$(echo "$response" | jq -r '.value[] | "Pipeline ID: \(.id), Name: \(.name), Repository: \(.repository.name)"')

echo "Azure DevOps Pipelines in Project '$project_name':"
echo "$pipelines"
