# List pipelines and choose one
$pipeline = (az pipelines list --query '[].{Path: path, Name: name, Id: id}' --output table | gum filter)

Clear-Host

# Get the path, name and id of the pipeline
$path, $name, $id = $pipeline -split '\s+'

$message = "Pipeline started successfully"
$status = (az pipelines runs list --pipeline-id $id --query "[0].{Name: definition.name, Status: status, Result: result, StartTime: startTime, FinishTime: finishTime}" --output tsv)

# Split the values in $status into separate variables
$pipelineName, $pipelineStatus, $pipelineResult, $pipelineStartTime, $pipelineFinishTime = $status -split "`t"

gum style --border normal --margin "1" --padding "1 2" --border-foreground 99 --border double "What do you want to do with this $(gum style --foreground 212 'pipeline?')."
$option = (gum choose --limit=1 ('Check status','Run the pipeline'))

Start-Sleep -Seconds 1
Clear-Host

switch ($option) {
  "Check status" {
      gum style --foreground 212 --border-foreground 99 --border double --align left --width 60 --margin "1 2" --padding "2 4" "Pipeline: $pipelineName`nStatus: $pipelineStatus`nResult: $pipelineResult`nStart Time: $pipelineStartTime`nFinish Time: $pipelineFinishTime"
    }
  "Run the pipeline" {
      gum confirm "Run the $name Pipeline for $path"

      if ($? -eq 1) {
          gum spin --spinner line --title "Running the $name pipeline..." -- az pipelines run --branch main --id $id
          $message = "Pipeline run successful."
      } else {
          $message = "Cancelled - Pipeline not run"
      }

      gum style --foreground 212 --border-foreground 99 --border double --align center --width 50 --margin "1 2" --padding "2 4" "$message"

      Start-Sleep -Seconds 2
  }
}
