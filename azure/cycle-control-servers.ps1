$backendPool = @{
    'control-web-3' = '10.2.0.4';
    'control-web-1' = '10.2.0.5';
    'control-web-2' = '10.2.0.6';
    'control-web-4' = '10.2.0.8';
}

################ CHECK IF REMOVING AND ADDING INTO THE POOL IS GRACEFUL, QUICK AND SAFE ################
foreach ($vm in $backendPool.GetEnumerator()) {
    # Remove this VM from the backend pool and restart
    Remove-AzApplicationGatewayBackendAddressPool -ResourceGroupName "ApplicationGateways" -ApplicationGatewayName "control-app-gateway" -Name "default-backend-pool" -BackendAddresses $vm.Value
    Restart-AzVM -ResourceGroupName "vms" -Name $vm.Key

    # Wait until the VM is back online (check up to 2 times)
    $maxRetries = 2
    $retryCount = 0
    $vmRunning = $false
    
    while (-not $vmRunning -and $retryCount -lt $maxRetries) {
        $vmStatus = Get-AzVM -ResourceGroupName "vms" -Name $vm.Key -Status
        
        if ($vmStatus.Statuses[1].DisplayStatus -eq "VM running") {
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

    # Add back to the pool
    Add-AzApplicationGatewayBackendAddressPool -ResourceGroupName "ApplicationGateways" -ApplicationGatewayName "control-app-gateway" -Name "default-backend-pool" -BackendAddresses $vm.Value

    $maxHealthRetries = 5
    $healthRetryCount = 0
    $vmHealthy = $false

    while (-not $vmHealthy -and $healthRetryCount -lt $maxHealthRetries) {
        Start-Sleep -Seconds 10  # Wait a bit before checking health
        $backendHealth = Get-AzApplicationGatewayBackendHealth -ResourceGroupName "ApplicationGateways" -Name "control-app-gateway"

        # Check health status for this specific VM
        $serverHealth = $backendHealth.BackendAddressPools | Where-Object { $_.BackendHttpSettingsCollection.Servers.Address -eq $vm.Value }
        
        if ($serverHealth) {
            foreach ($server in $serverHealth.BackendHttpSettingsCollection.Servers) {
                Write-Host "Server: $($server.Address), Status: $($server.Health)"
                if ($server.Health -eq "Healthy") {
                    $vmHealthy = $true
                }
            }
        } else {
            Write-Host "Server $($vm.Value) not found in pool."
        }

        if (-not $vmHealthy) {
            $healthRetryCount++
            Write-Host "Waiting for $($vm.Key) to become healthy... Attempt $healthRetryCount of $maxHealthRetries"
        }
    }

    # If the server is not healthy after max retries, exit the script
    if (-not $vmHealthy) {
        Write-Host "Error: $($vm.Key) did not become healthy after $maxHealthRetries attempts. Exiting script."
        exit 1
    }
}
