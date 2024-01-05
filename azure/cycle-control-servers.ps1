$backendPool = @{

}

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

    # Add back to the pool and then check health
    Add-AzApplicationGatewayBackendAddressPool -ResourceGroupName "ApplicationGateways" -ApplicationGatewayName "control-app-gateway" -Name "default-backend-pool" -BackendAddresses $vm.Value

    $backendHealth = Get-AzApplicationGatewayBackendHealth -ResourceGroupName "ApplicationGateways" -ApplicationGatewayName "control-app-gateway"
    $backendHealth.BackendAddressPools | ForEach-Object {
        $_.BackendHttpSettingsCollection.Servers | ForEach-Object {
            Write-Host "Server: $($_.Address), Status: $($_.Health)"
        }
    }
}
