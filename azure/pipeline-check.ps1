# List pipelines and choose one
$pipeline = (az pipelines list --query '[].{Path: path, Name: name, Id: id}' --output table | gum filter)

# Get the path, name and id of the pipeline
$path = ($pipeline -split '\s+')[0]
$name = ($pipeline -split '\s+')[1]
$id = ($pipeline -split '\s+')[2]

$message = "Pipeline started successfully"
$status = (az pipelines runs list --pipeline-id $id --query "[0].{Name: definition.name, Status: status, Result: result, StartTime: startTime, FinishTime: finishTime}" --output tsv)

# What do you want to do with this pipeline?
Write-Host "What do you want to do with this pipeline?"
$option = (gum choose --limit=1 ('Check status','Run the pipeline'))

switch ($option) {
  "Check status" {
      gum style --foreground 212 --border-foreground 212 --border double --align center --width 75 --margin "1 2" --padding "2 4" "$status"
  }
  "Run the pipeline" {
      gum confirm "Run the $name Pipeline for $path"

      if ($? -eq 1) {
          gum spin --spinner line --title "Running the $name pipeline..." -- az pipelines run --branch main --id $id
          $message = "Pipeline run successful."
      } else {
          $message = "Cancelled - Pipeline not run"
      }

      gum style --foreground 212 --border-foreground 212 --border double --align center --width 50 --margin "1 2" --padding "2 4" "$message"

      Start-Sleep -Seconds 2
  }
}
