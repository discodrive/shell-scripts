$backendPool = @{

}

foreach ($vm in $backendPool.GetEnumerator()) {
    # Remove this VM from the backend pool and restart
    az network application-gateway address-pool update --gateway-name control-app-gateway --name default-backend-pool --resource-group ApplicationGateways --remove backendAddresses ipAddress=$vm.Value
    az vm restart --name $vm.Key --resource-group vms

    # Wait until the VM is back online (check up to 2 times)
    $maxRetries = 2
    $retryCount = 0
    $vmRunning = $false
    
    while (-not $vmRunning -and $retryCount -lt $maxRetries) {
        $vmStatus = az vm list -d --query "[?name=='$($vm.Key)' && powerState=='VM running']" -o table
        
        if ($vmStatus) {
            Write-Host "$($vm.Key) is running."
            $vmRunning = $true
        } else {
            $retryCount++
            Write-Host "Waiting for $($vm.Key) to start... Attempt $retryCount of $maxRetries"
            Start-Sleep -Seconds 10
        }
    }

    # If the VM is not running after 2 attempts, exit the script
    if (-not $vmRunning) {
        Write-Host "Error: $($vm.Key) did not start after $maxRetries attempts. Exiting script."
        exit 1
    }

    # Add back to the pool and then check health
    az network application-gateway address-pool update --gateway-name control-app-gateway --name default-backend-pool --resource-group ApplicationGateways --add backendAddresses ipAddress=$vm.Value

    $backendHealth = az network application-gateway show-backend-health --name control-app-gateway --resource-group ApplicationGateways --query "backendAddressPools[].backendHttpSettingsCollection[].servers[].{Server:address, Status:health}" -o json
    $backendHealthObj = $backendHealth | ConvertFrom-Json

    foreach ($server in $backendHealthObj) {
        Write-Host "Server: $($server.Server), Status: $($server.Status)"
    }
}
