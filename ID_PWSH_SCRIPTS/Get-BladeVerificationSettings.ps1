Function Get-BladeSettingsVerification ($servername){
    $NetworkPath = "\\$servername\C$\Build\Logs\Imaging.log"

    if (Test-Path -Path $NetworkPath -ErrorAction SilentlyContinue) {
    
    Write-Host "`nImage Completion Status" -ForegroundColor Cyan
    $buildLog = get-content -Path $NetworkPath | Select-String -Pattern "imaging pass completed"
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
    $cores | ForEach-Object{$coresum += $_}
    $lp | ForEach-Object{$lpsum += $_}
    Write-Host "Number of cores: $coresum"
    Write-Host "Number of Logical Processors: $lpsum"

    Write-Host "`nEnabled Power Plan" -ForegroundColor Cyan
    $pp = Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -ComputerName $servername -Filter "isActive='true'" | Select-Object ElementName 
    $pp.ElementName

    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $servername)
    $RegKey= $Reg.OpenSubKey("SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002")
    $NetbackupVersion1 = $RegKey.GetValue("Functions")
    
    Write-Host "`nTLS Reg Settings`n" -ForegroundColor Cyan
    Write-Host "`nTLS CupherSuites are:`n" $NetbackupVersion1  
    } else {
        Write-Error "Path is not accessible: $NetworkPath - Ensure correct path, permissions, and network connectivity."
        break
    }

}
