###BN1R
$BN1R_DMS_IPS = (Get-Item grn005:\BN1-GRN005-RELAY\10.19.96.0\10.19.96.*).Name

$BN1R_MACHINE_IP_ARRAY = @()

foreach ($BN1R_DMS_IP in $BN1R_DMS_IPS) {

    $ipAddress = (Get-Item grn005:\BN1-GRN005-RELAY\10.19.96.0\$BN1R_DMS_IP)

    $machine = Get-Link $ipAddress -DependsOn

    $MachineName = ($machine.Name -split ",").Trim() | Out-String

    $IP_MACHINE_NAME_OBJECT = New-Object -TypeName PSObject

    $IP_MACHINE_NAME_OBJECT | Add-Member -Name 'IP' -MemberType NoteProperty -Value $BN1R_DMS_IP

    $IP_MACHINE_NAME_OBJECT | Add-Member -Name 'MACHINE' -MemberType NoteProperty -Value $MachineName

    $BN1R_MACHINE_IP_ARRAY += $IP_MACHINE_NAME_OBJECT 
}

$BN1R_MACHINE_IP_ARRAY | Format-Table -AutoSize

# Get the desktop path for the current user
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Desktop')

# Set the output file path
$csvFilePath = Join-Path -Path $desktopPath -ChildPath "DMS_IP_MACHINE.csv"

# Output the array to a CSV file on the desktop
$BN1R_MACHINE_IP_ARRAY | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "CSV file created at: $csvFilePath"

###SN5A

$SN5A_DMS_IPS = (Get-Item grn005:\SN5-GRN005-ANCHOR\10.19.100.0\10.19.100.*).Name

$SN5A_MACHINE_IP_ARRAY = @()

foreach ($SN5A_DMS_IP in $SN5A_DMS_IPS) {

    $ipAddress = (Get-Item grn005:\SN5-GRN005-ANCHOR\10.19.100.0\$SN5A_DMS_IP)

    $machine = Get-Link $ipAddress -DependsOn

    $MachineName = ($machine.Name -split ",").Trim() | Out-String

    $IP_MACHINE_NAME_OBJECT = New-Object -TypeName PSObject

    $IP_MACHINE_NAME_OBJECT | Add-Member -Name 'IP' -MemberType NoteProperty -Value $SN5A_DMS_IP

    $IP_MACHINE_NAME_OBJECT | Add-Member -Name 'MACHINE' -MemberType NoteProperty -Value $MachineName

    $SN5A_MACHINE_IP_ARRAY += $IP_MACHINE_NAME_OBJECT 
}

$SN5A_MACHINE_IP_ARRAY | Format-Table -AutoSize

# Get the desktop path for the current user
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Desktop')

# Set the output file path
$csvFilePath = Join-Path -Path $desktopPath -ChildPath "DMS_IP_MACHINE.csv"

# Output the array to a CSV file on the desktop
$SN5A_MACHINE_IP_ARRAY | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "CSV file created at: $csvFilePath"


####P20R

$P20R_DMS_IPS = (Get-Item grn005:\P20-GRN005-RELAY\10.19.108.0\10.19.108.*).Name

$P20R_MACHINE_IP_ARRAY = @()

foreach ($P20R_DMS_IP in $P20R_DMS_IPS) {

    $ipAddress = (Get-Item grn005:\P20-GRN005-RELAY\10.19.108.0\$P20R_DMS_IP)

    $machine = Get-Link $ipAddress -DependsOn

    $MachineName = ($machine.Name -split ",").Trim() | Out-String

    $IP_MACHINE_NAME_OBJECT = New-Object -TypeName PSObject

    $IP_MACHINE_NAME_OBJECT | Add-Member -Name 'IP' -MemberType NoteProperty -Value $P20R_DMS_IP

    $IP_MACHINE_NAME_OBJECT | Add-Member -Name 'MACHINE' -MemberType NoteProperty -Value $MachineName

    $P20R_MACHINE_IP_ARRAY += $IP_MACHINE_NAME_OBJECT 
}

$P20R_MACHINE_IP_ARRAY | Format-Table -AutoSize

# Get the desktop path for the current user
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Desktop')

# Set the output file path
$csvFilePath = Join-Path -Path $desktopPath -ChildPath "DMS_IP_MACHINE.csv"

# Output the array to a CSV file on the desktop
$P20R_MACHINE_IP_ARRAY | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "CSV file created at: $csvFilePath"

###P20A

$P20A_DMS_IPS = (Get-Item grn005:\P20-GRN005-ANCHOR\10.19.104.0\10.19.104.*).Name

$P20A_MACHINE_IP_ARRAY = @()

foreach ($P20A_DMS_IP in $P20A_DMS_IPS) {

    $ipAddress = (Get-Item grn005:\P20-GRN005-ANCHOR\10.19.104.0\$P20A_DMS_IP)

    $machine = Get-Link $ipAddress -DependsOn

    $MachineName = ($machine.Name -split ",").Trim() | Out-String

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


