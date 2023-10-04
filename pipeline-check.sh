#! bin/bash

# Azure Devops variables
ORG_NAME=""
PROJECT_NAME=""
PERSONAL_ACCESS_TOKEN="aqk37ersqj7pbiwkgluelmu3ogve3vmmiraid4e5n6wqzyon5m6q"

# Pipeline variables
PIPELINE_NAME=""

# Azure Devops REST API url
API_URL="https://dev.azure.com/${ORG_NAME}/${PROJECT_NAME}/_apis/pipelines?api-version=6.0"

# Get pipeline ID by name
pipeline_id=$(curl -s -X GET -u ":${PERSONAL_ACCESS_TOKEN}" "$API_URL" | jq -r ".value[] | select(.name == \"$PIPELINE_NAME\") | .id")

if [ -z "$pipeline_id" ]; then
    echo "Pipeline not found with the name '$PIPELINE_NAME'."
    exit 1
fi
