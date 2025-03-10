param (
    [string[]]$directories,
    [string]$endpointUrl = "https://7a80e4b7053d01ea3a2ca9d4b8ec3a44.r2.cloudflarestorage.com"
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

