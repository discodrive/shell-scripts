param (
    [string[]]$directories,
    [string]$endpointUrl = "****"
)

if (-not $directories) {
    Write-Host "Please provide an array of directories to delete."
    Write-Host "Example: .\delete-s3-directories.ps1 -directories @('9617', '9618')"
    exit 1
}

$jobs = @()
foreach ($dir in $directories) {
    $jobs += Start-Job -ScriptBlock {
        param ($path, $endpoint)
        aws s3 rm "s3://assets/kickstart-dev/$path" --endpoint-url $endpoint --recursive
    } -ArgumentList $dir, $endpointUrl
}

$jobs | ForEach-Object { Receive-Job -Job $_ -Wait }

Write-Host "All specified directories have been deleted."

# .\delete-s3-directories.ps1 -directories @('9617', '9618')

