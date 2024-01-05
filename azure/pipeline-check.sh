#!/bin/bash

# List pipelines and choose one
pipeline="$(az pipelines list --query '[].{Path: path, Name: name, Id: id}' --output table | gum filter )"

sleep 1; clear

# Get the path, name and id of the pipeline
path=$(printf '%s' "$pipeline" | awk '{print $1}')
name=$(printf '%s' "$pipeline" | awk '{print $2}')
id=$(printf '%s' "$pipeline" | awk '{print $3}')

message="Pipeline started successfully"
status=$(az pipelines runs list --pipeline-id $id --query "[0].{Name: definition.name, Status: status, Result: result, StartTime: startTime, FinishTime: finishTime}" --output tsv)

IFS=$'\t' read -ra properties <<< "$status"
pipelineName="${properties[0]}" 
pipelineStatus="${properties[1]}" 
pipelineResult="${properties[2]}" 
pipelineStartTime="${properties[3]}" 
pipelineFinishTime="${properties[4]}"

newStatus=$(printf "Pipeline:$pipelineName Status:$pipelineStatus Result:$pipelineResult Start-Time:$pipelineStartTime Finish-Time:$pipelineFinishTime")

# What do you want to do with this pipeline?
gum style --border normal --margin "1" --padding "1 2" --border-foreground 99 "What do you want to do with this $(gum style --foreground 212 'pipeline?')."
option="$(gum choose --limit 1 {'Check status','Run the pipeline'})"

sleep 1; clear

case $option in
  "Check status")
    gum style \
      --foreground 212 --border-foreground 99 --border double \
      --align left --width 60 --margin "1 2" --padding "2 4" \
      $newStatus
    ;;
  "Run the pipeline")
    gum confirm "Run the $name Pipeline for $path" && \
    gum spin --spinner line --title "Running the $name pipeline..." -- az pipelines run --branch main --id $id || message="Cancelled - Pipeline not run"

    gum style \
      --foreground 212 --border-foreground 99 --border double \
      --align center --width 50 --margin "1 2" --padding "2 4" \
      "$message"

    sleep 2
    ;;
esac

