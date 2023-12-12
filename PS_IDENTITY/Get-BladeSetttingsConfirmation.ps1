Function Get-ServerSettingsVerification ($servername){
    Write-Host "`nImage Completion Status" -ForegroundColor Cyan
    $buildLog = get-content -Path "\\$servername\C$\Build\Logs\Imaging.log" | Select-String -Pattern "imaging pass completed"
    Write-Host $buildLog

    Write-Host "`nDisk Info" -ForegroundColor Cyan
    $vd = Get-VirtualDisk -CimSession "$servername.GRN005.US.MSFT.NET" | Select-Object -Property ResiliencySettingName
    $vd.ResiliencySettingName

    Write-Host "`nHyper Threading Info" -ForegroundColor Cyan
    $ht = Get-WmiObject -ComputerName $servername -Class Win32_Processor | Select-Object -Property Name, Number*
    $cores = $ht.NumberofCores
    $lp = $ht.NumberOfLogicalProcessors
    $coresum = 0
    $lpsum = 0
    $cores | %{$coresum += $_}
    $lp | %{$lpsum += $_}
    Write-Host "Number of cores: $coresum"
    Write-Host "Number of Logical Processors: $lpsum"

    Write-Host "`nEnabled Power Plan" -ForegroundColor Cyan
    $pp = Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -ComputerName $servername -Filter "isActive='true'" | Select ElementName 
    $pp.ElementName

    $reg0 = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine", $servername)
    $regpath0 = $reg0.OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client\")
    $dbd0 = $regpath0.GetValue("DisabledByDefault")
    $e0 = $regpath0.GetValue("Enabled")

    $reg1 = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine", $servername)
    $regpath1 = $reg1.OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client\")
    $dbd1 = $regpath1.GetValue("DisabledByDefault")
    $e1 = $regpath1.GetValue("Enabled")

    Write-Host "`nTLS Reg Settings`n" -ForegroundColor Cyan
    Write-Host "TLS1.0 Disabled by Defalut: $dbd0"
    Write-Host "TLS1.0 Enabled: $e0"
    
    Write-Host "`nTLS1.1 Disabled by Defalut: $dbd1"
    Write-Host "TLS1.1 Enabled: $e1`n"

}

<#

#CONFIRM ONLY CIPHERSUITES IN LIST ARE ON THE MACHINE
Set-CipherSuiteOrder.ps1 -CipherSuiteList 
"TLS_AES_256_GCM_SHA384,
TLS_AES_128_GCM_SHA256,
TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,
TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,
TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,
TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"

#CONFIRM DRIVES ARE SET TO SIMPLE
Get-VirtualDisk | Select-Object  -Property  ResiliencySettingName

(Get-TlsCipherSuite).Name
#>