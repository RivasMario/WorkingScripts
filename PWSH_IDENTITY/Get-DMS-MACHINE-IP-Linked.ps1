& (Join-Path (Get-ChildItem 'C:\Program Files\DmsClientCmdLets' | Sort | Select-Object -Last 1).FullName 'grn005\DmsClientCommands.ps1')

$P20A_DMS_IPS = (Get-Item grn005:\P20-GRN005-ANCHOR\10.19.104.0\10.19.104.*).Name

$P20A_MACHINE_IP_ARRAY = @()

foreach ($P20A_DMS_IP in $P20A_DMS_IPS) {

    $ipAddress = (Get-Item grn005:\P20-GRN005-ANCHOR\10.19.104.0\$P20A_DMS_IP)

    $machine = Get-Link $ipAddress -DependsOn

    $MachineName = $machine.Name 

    $IP_MACHINE_NAME_OBJECT = New-Object -TypeName PSObject

    $IP_MACHINE_NAME_OBJECT | Add-Member -Name 'IP' -MemberType NoteProperty -Value $P20A_DMS_IP

    $IP_MACHINE_NAME_OBJECT | Add-Member -Name 'MACHINE' -MemberType NoteProperty -Value $MachineName

    $P20A_MACHINE_IP_ARRAY += $IP_MACHINE_NAME_OBJECT 
}

$P20A_MACHINE_IP_ARRAY | Format-Table -AutoSize

# Get the desktop path for the current user
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Desktop')

# Set the output file path
$csvFilePath = Join-Path -Path $desktopPath -ChildPath "DMS_IP_MACHINE.csv"

# Output the array to a CSV file on the desktop
$P20A_MACHINE_IP_ARRAY | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "CSV file created at: $csvFilePath"
