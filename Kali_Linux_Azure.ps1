<#
5/26/2022 = Changed Script for new version of Kali Linux Server
#>

#Set-Location "$PWD\.ssh"

Connect-AzAccount 

Select-AzSubscription -Subscription 851a47f9-7201-4e7e-aecd-09ce41c0a124 -Name "ResumeChallenge" -Force

$VmStatus = Get-AzVM -ResourceGroupName windeskrg -Name KaliVM -Status

$VmStatus

$VmDisplayStatus = $VmStatus.Statuses[1].DisplayStatus

#Write-Host $VmDisplayStatus

Write-Host "Status of VM is" $VmDisplayStatus

#IfElse loop to check if VM is running#

if ($VmDisplayStatus -eq "VM running")
{
    Write-Host "VM is running"   

}
elseif ($VmDisplayStatus -ne "VM running")
{
    Write-Host "Vm is being Started" 
    Start-AzVM -ResourceGroupName windeskrg -Name KaliVM
    Write-Host "Vm Started"
}

<#
$VmIpAddress = Get-AzPublicIpAddress -Name kalilinuxlearning-ip

$Piped = $VmIpAddress.IpAddress | out-String

$SshInput = "kaliadmin@$Piped"

$SshInput

Connect via SSH using PEM file#

Test-Connection -ComputerName kalilinuxlearning

 Start-Sleep -seconds 15 <# sleep #>

#plink.exe -i "C:\Users\V-MARIORIVAS\Work Folders\Desktop\KaliLinux\kalilinuxlearning.ppk" -ssh $SshInput

#>