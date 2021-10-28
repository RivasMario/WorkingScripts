cd "C:\Users\V-MARIORIVAS\Work Folders\Desktop\KaliLinux"

Connect-AzAccount 

Select-AzSubscription -Subscription 851a47f9-7201-4e7e-aecd-09ce41c0a124 -Name "ResumeChallenge" 

$VmStatus = Get-AzVM -ResourceGroupName virtual_machine_rg -Name kalilinuxlearning -Status

$VmStatus

$VmDisplayStatus = $VmStatus.Statuses[1].DisplayStatus

#Write-Host $VmDisplayStatus

Write-Host "Status of VM is" $VmDisplayStatus

#IfElse loop to check if VM is running#

if ($VmDisplayStatus -eq "VM running")
{
    Write-Host "VM is running"   

}
elseif ($VmDisplayStatus -eq "VM deallocated")
{
    Write-Host "Vm is being Started" 
    Start-AzVM -ResourceGroupName virtual_machine_rg -Name kalilinuxlearning
    Write-Host "Vm Started"
}

$VmIpAddress = Get-AzPublicIpAddress -Name kalilinuxlearning-ip

$Piped = $VmIpAddress.IpAddress | out-String

$SshInput = "kaliadmin@$Piped"

$SshInput

#Connect via SSH using PEM file#

#Test-Connection -ComputerName kalilinuxlearning

plink.exe -i "C:\Users\V-MARIORIVAS\Work Folders\Desktop\KaliLinux\kalilinuxlearning.ppk" -ssh $SshInput