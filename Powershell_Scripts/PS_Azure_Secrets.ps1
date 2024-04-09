<#
First version then secure string was needed or an error was thrown
#>

$subscriptionId = "e0340a70-4dca-4f08-a7cf-bb25fe8f6d1f"
$keys = Get-AzApiManagementSubscriptionKey -Context $ctx -SubscriptionId $subscriptionId
$secret = ConvertTo-SecureString -String $keys.PrimaryKey -AsPlainText -Force
$discard = Set-AzKeyVaultSecret -VaultName ProtectionSigAndIntel -Name ProtectionSigAndIntelGeoApiAzPrimaryKey -SecretValue $secret

$secret = ConvertTo-SecureString -String $keys.SecondaryKey -AsPlainText -Force
$discard= Set-AzKeyVaultSecret -VaultName ProtectionSigAndIntel -Name ProtectionSigAndIntelGeoApiAzSecondaryKey -SecretValue $secret

##Second version that fixed the issue


$subscriptionId = "e0340a70-4dca-4f08-a7cf-bb25fe8f6d1f"

$keys = Get-AzApiManagementSubscriptionKey -Context $ctx -SubscriptionId $subscriptionId
$secret = ConvertTo-SecureString -String $keys.PrimaryKey -AsPlainText -Force
$discard = Set-AzKeyVaultSecret -VaultName ProtectionSigAndIntel -Name ProtectionSigAndIntelGeoApiAzPrimaryKey -SecretValue $secret

$secret = ConvertTo-SecureString -String $keys.SecondaryKey -AsPlainText -Force
$discard= Set-AzKeyVaultSecret -VaultName ProtectionSigAndIntel -Name ProtectionSigAndIntelGeoApiAzSecondaryKey -SecretValue $secret