cd "C:\Users\V-MARIORIVAS\Work Folders\Desktop\PublicSecurity"

Connect-AzAccount 

Select-AzSubscription -Subscription 851a47f9-7201-4e7e-aecd-09ce41c0a124 -Name "ResumeChallenge" -Force
$VmStatus = Get-AzVM -ResourceGroupName WINDESKRG -Name windeskvm01 -Status

#$VmStatus

$VmDisplayStatus = $VmStatus.Statuses[1].DisplayStatus

#Write-Host $VmDisplayStatus

Write-Host "Status of VM is" "$VmDisplayStatus `n" -foregroundcolor green 

#IfElse loop to check if VM is running#

if ($VmDisplayStatus -eq "VM running")
{
    Write-Host "VM is running `n" -foregroundcolor green   

}
elseif ($VmDisplayStatus -ne "VM running")
{
    Write-Host "Vm is being Started `n" -foregroundcolor green 
    Start-AzVM -ResourceGroupName WINDESKRG -Name windeskvm01
    Write-Host "Vm Started `n" -foregroundcolor green 
}

$key = Get-AzKeyVaultSecret -VaultName Windeskkeyvault -SecretName windeskvmpassword -AsPlainText

$admin = Get-AzKeyVaultSecret -VaultName Windeskkeyvault -SecretName windeskvmadminusername -AsPlainText

$GetAzPubAddress = Get-AzPublicIpAddress -Name windeskvm01-ip

$VMIPAddress = $GetAzPubAddress.IpAddress

cmdkey /generic:TERMSRV/"$VMIPAddress" /user:"$admin" /pass:"$key"

#mstsc /v:"$VMIPAddress"

$CurrentConnectionStatus = netstat -ano | Where-Object { $_ -match $VMIPAddress} | ConvertFrom-String

Write-Host "Getting NetStat information `n"

$CurrentConnectionStatusBoolean = $null

$CurrentConnectionStatusBoolean = if ($CurrentConnectionStatus) { 'True' } else { 'False' }

Write-Host "Determing if connection is active `n"

if ($CurrentConnectionStatusBoolean -eq "True")
{   
    Write-Host "Connection currently established, deleting connection stored on device `n"
    cmdkey /delete:"$VMIPAddress"
}
elseif ($CurrentConnectionStatusBoolean -eq "False")
{
    Write-Host "Connection starting `n"
    mstsc /v:"$VMIPAddress"
    Write-Host "Self deleting key after use `n"
    cmdkey /delete:"$VMIPAddress"
}


#netstat -n | find "$VMIPAdress" | find "ESTABLISHED"

#netstat -ano | findstr ":3389"

