$sourceVault=""
$destinationVault=""

$secrets=(az keyvault secret list --vault-name $sourceVault --query "[].{id:id,name:name}") | ConvertFrom-Json | ForEach-Object { 
  $secretName = $_.name
  $secretExists=(az keyvault secret list --vault-name $destinationVault --query "[?name=='$secretName']" -o tsv)
  
  if($secretExists -eq $null) {
    write-host "Copying Secret: $secretName"
    $secretValue=(az keyvault secret show --vault-name $sourceVault -n $secretName --query "value" -o tsv)
    az keyvault secret set --vault-name $destinationVault -n $secretName --value "$secretValue"
  } else {
    write-host "$secretName already exists in $destinationVault"
  } 
}
