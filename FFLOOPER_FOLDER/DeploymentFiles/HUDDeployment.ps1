Param(
        [ValidateSet("Looper","WANetmon")]
        [Parameter(Mandatory=$true)]
        [string] $deploymentType,
        [ValidateSet("New","Redeploy")]
        [string] $deploymentStatus = "New",
        [ValidateSet("Left","Center","Right")]
        [string] $startupFlag)


if($deploymentType -eq "Looper"){
    $xmlblock = @'
<?xml version="1.0"?>
<Items>
  <UACDisabled complete="$false" retrys="0" MaxRetrys="2" />
  <DomainJoined complete="$false" retrys="0" MaxRetrys="2" />
  <AdminAccountsAdded complete="$false" retrys="0" MaxRetrys="2" />
  <AutoLogin complete="$false" retrys="0" MaxRetrys="10" />
  <FileSharing complete="$false" retrys="0" MaxRetrys="2" />
  <RDPEnabled complete="$false" retrys="0" MaxRetrys="2" />
  <FontSize complete="$false" retrys="0" MaxRetrys="2" />
  <PowerConfig complete="$false" retrys="0" MaxRetrys="2" />
  <AutoHide complete="$false" retrys="0" MaxRetrys="2" />
  <WDPopup complete="$false" retrys="0" MaxRetrys="2" />
  <PFX complete="$false" retrys="0" MaxRetrys="5" />
  <StartUp complete="$false" retrys="0" MaxRetrys="5" />
  <HudStart complete="$false" retrys="0" MaxRetrys="5" />
</Items>
'@
}

if($deploymentType -eq "WANetmon"){
$xmlblock = @'
<?xml version="1.0"?>
<Items>
  <UACDisabled complete="$false" retrys="0" MaxRetrys="2" />
  <DomainJoined complete="$false" retrys="0" MaxRetrys="2" />
  <AdminAccountsAdded complete="$false" retrys="0" MaxRetrys="2" />
  <AutoLogin complete="$false" retrys="0" MaxRetrys="10" />
  <FileSharing complete="$false" retrys="0" MaxRetrys="2" />
  <RDPEnabled complete="$false" retrys="0" MaxRetrys="2" />
  <FontSize complete="$false" retrys="0" MaxRetrys="2" />
  <PowerConfig complete="$false" retrys="0" MaxRetrys="2" />
  <AutoHide complete="$false" retrys="0" MaxRetrys="2" />
  <WDPopup complete="$false" retrys="0" MaxRetrys="2" />
  <IEShortcut complete="$false" retrys="0" MaxRetrys="5" />
  <IEHomepage complete="$false" retrys="0" MaxRetrys="5" />
  <IEZoom complete="$false" retrys="0" MaxRetrys="5" />
  <Clock complete="$false" retrys="0" MaxRetrys="5" />
  <WANetmonStart complete="$false" retrys="0" MaxRetrys="5" />
</Items>
'@
}

Function Disable-UAC(){

    Try{
        New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force | Out-Null
        return $true}
    Catch{
        return $false}

}

Function Domain-Check(){
    
    $computerDomain = (Get-WmiObject Win32_ComputerSystem).Domain

    if($computerDomain -ne "redmond.corp.microsoft.com"){
        Write-Host "Computer is not part of the Redmond domain.  Attempting to add then restarting" -ForegroundColor Yellow
        try{
            Add-Computer -DomainName "Redmond" -Restart}
        catch{

                return $false
                break}
        }

    else{
        return $true}
 
}
    
Function AdminAcount-Check(){

    $LocalAdminAccounts = "REDMOND\FFHud", "REDMOND\WA Fairfax Operators"
    $LocalAdmins = net localgroup administrators | where {$_ -and $_ -notmatch "command completed successfully"} | Select -Skip 4
    $passing = $true

    $LocalAdminAccounts | %{if(!($_ -in $LocalAdmins)){
        Write-Host "Adding '$_' to local Admin group" -ForegroundColor Green
        $hostName = hostname 
        $groupName = "Administrators"
        $domainName = ($_.split('\\'))[0]
        $accountName = ($_.split('\\'))[1]

        try{
            $addUser = [ADSI]"WinNT://$hostName/$groupName,group" 
            $addUser.psbase.Invoke("Add",([ADSI]"WinNT://$domainName/$accountName").path)}
        catch{
            Write-Host "Unable to add $_ to the Administrators group.  Please ensure you have admin access to the box."  -ForegroundColor Yellow
            $passing = $false}            
        }
    }

    return $passing
}

Function FFHud-AutoLogin(){

    $curentUser = $env:USERNAME

    if($curentUser -eq "FFHud"){
        return $true
        break}

    $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $userName = "DefaultUserName"
    $domainName = "DefaultDomainName"
    $defaultPW = "DefaultPassword"
    $adminLogon = "AutoAdminLogon"

    Write-Host "Please provide the FFHud PW: " -ForegroundColor Yellow -NoNewline
    $getPW = Read-Host
    cls
    
    try{
        New-ItemProperty -Path $path -Name $userName -PropertyType String -Value "FFHud" -Force | Out-Null
        New-ItemProperty -Path $path -Name $domainName -PropertyType String -Value "Redmond" -Force | Out-Null
        New-ItemProperty -Path $path -Name $defaultPW -PropertyType String -Value $getPW -Force | Out-Null
        New-ItemProperty -Path $path -Name $adminLogon -PropertyType String -Value 1 -Force | Out-Null
        Write-Host "Rebooting in 10 sec" -ForegroundColor Yellow
        sleep 10
        Shutdown /r /f /t 10
        exit}
    catch{
        return $false}

    return $false
}

Function TurnOn-FileSharing(){

    try{
        netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
        netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
        return $true}
    catch{
        return$false}

}

Function Enable-RDP(){

    try{
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0	 | Out-Null
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1  | Out-Null
        return $true}
    catch{
        return $false}

}

Function Set-ConsoleFontSize(){

    try{
        Set-ItemProperty -Path "HKCU:\HKEY_CURRENT_USER\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe" -Name "FontSize" –Value 0x000c0000	 | Out-Null
        return $true}
    catch{
        return $false}

}

Function Setup-PowerConfig(){
    
    $ContinuePowerConfig = $true
    powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    $getPowercfgs = powercfg -list

    $ffHudCheck = $getPowercfgs | %{if($_ -match "FFHud"){
        $findNewGUID = $_ -match ("\S+-\S+-\S+-\S+-\S+")
        $newPCGUID = $Matches.Values}
        }

    if(!($newPCGUID)){
        $findNewPC = $getPowercfgs | %{
            if($_ -match "High performance" -and $_ -notmatch "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"){
                $findNewGUID = $_ -match ("\S+-\S+-\S+-\S+-\S+")
                $newPCGUID = $Matches.Values}
                }
            }
    else{
        Write-Host "No Power Config GUID found.  Power Config not set up" -ForegroundColor Red
        $ContinuePowerConfig = $false}

    if($ContinuePowerConfig){
        powercfg -changename $newPCGUID "FFHud"

        $HDSubgroup = "0012ee47-9041-4b5d-9b77-535fba8b1442"
        $TurnOffHD = "6738e2c4-e8a5-4a42-b16a-e040e769756e"

        $DisplaySubgroup = "7516b95f-f776-4464-8c53-06167f40cc99"
        $TurnOffDisplay = "3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"

        powercfg -setacvalueindex $newPCGUID $HDSubgroup $TurnOffHD 0
        powercfg -setacvalueindex $newPCGUID $DisplaySubgroup $TurnOffDisplay 0

        powercfg -s $newPCGUID
        }

    return $ContinuePowerConfig
}

Function AutoHide-Taskbar(){

    try{
        $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
        $key = "settings"
        $getCurrentKeyValue = Get-ItemProperty -Path $path -Name $key
        $binaryValues = $getCurrentKeyValue.Settings
        if($binaryValues[8] -eq 2){
            $binaryValues[8] = 3
            Set-ItemProperty -Path $path -Name $key -Value ([byte[]]$binaryValues) | Out-Null}
        Stop-Process -name explorer
        return $true}
    catch{
        return $false}

}

Function Disable-WDPopup(){

    $IEpath = "HKCU:\Software\Microsoft\Windows Defender\"
    $keyName = "UIFirstRun"
    $setTo = 0

    if(!(Test-Path $IEpath)){
        New-Item -Path $IEpath | Out-Null} 
    
    try{
        Set-ItemProperty -Path $IEpath -Name $keyName -Value $setTo | Out-Null
        return $true}
    catch{
        return $false}
    
}

Function Install-PFX(){

    $PFXSource = "http://sharepoint/sites/CIS/waps/WAPartnerOps/Fairfax%20Documents/Fairfax/HUD%20Software/waocfairfax-tfsconnector.pfx"
    $looperFolder = "c:\TriageLoopers"

    if(!(Test-Path $looperFolder)){
        New-Item $looperFolder -type directory -Force | Out-Null}

    $PFXTarget = "$looperFolder\waocfairfax-tfsconnector.pfx"

    if(!(Test-Path $PFXTarget)){
        $webClient = New-Object System.Net.WebClient
        $webClient.UseDefaultCredentials = $true
        $webClient.DownloadFile($PFXSource, $PFXTarget)}

    Write-Host "Please enter the password for waocfairfax-tfsconnector.pfx: " -ForegroundColor Yellow -NoNewline
    $PFXPW = Read-Host
    cls
    $PFXPWSS = ConvertTo-SecureString -String $PFXPW -AsPlainText -Force

    try{
        Import-PfxCertificate -FilePath $PFXTarget -CertStoreLocation "Cert:LocalMachine\My" -Password $PFXPWSS
        Remove-Item $PFXTarget
        retrun $true}
    catch{
        return $false}

}

Function Add-StartUp(){
 
    $StartUpSource = "http://sharepoint/sites/CIS/waps/WAPartnerOps/Fairfax%20Documents/Fairfax/LooperScripts/StartUp.ps1"    
    $looperFolder = "c:\TriageLoopers"
    if(!(Test-Path $looperFolder)){
        New-Item $looperFolder -type directory -Force | Out-Null}

    $StartUpTarget = "$looperFolder\StartUp.ps1"

    try{
        $webClient = New-Object System.Net.WebClient
        $webClient.UseDefaultCredentials = $true
        $webClient.DownloadFile($StartUpSource, $StartUpTarget)
        return $true}
    catch{
        return $false}
}

Function Add-HUDStart(){
    
    $startupFolder = "C:\Users\ffhud\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    $HUDCmdPath = "$startupFolder\HUDStart.cmd"

    if($startupFlag){
        $flag = $startupFlag}

    try{
        New-Item $HUDCmdPath -ItemType File -Force | Out-Null
        $cmdText = @"
@echo off
call powershell C:\TriageLoopers\StartUp.ps1 $flag
"@
        Add-Content $HUDCmdPath $cmdText
        return $true}
    catch{
        return $false}

}

Function Create-IEShortcut(){
    
    $user = $env:USERNAME
    $shortcutDest = "c:\WANetmonInstallFiles\iexplore.lnk"
    $2ndShortcut = "C:\Users\$user\Desktop\WANetmon.lnk"
    try{
        $WscShell = New-Object -ComObject wscript.shell
        $createSC = $WscShell.CreateShortcut($shortcutDest)
        $createSC.TargetPath = "C:\Program Files\Internet Explorer\iexplore.exe"
        $createSC.Arguments = "-k"
        $createSC.save()
        $create2nd = $WscShell.CreateShortcut($2ndShortcut)
        $create2nd.TargetPath = "C:\Program Files\Internet Explorer\iexplore.exe"
        $create2nd.Arguments = "-k"
        $create2nd.save()
        return $true}
    catch{
        return $false}

}

Function Set-IEHomepage(){

    $IEpath = "HKCU:\Software\Microsoft\Internet Explorer\Main\"
    $keyName = "start page"
    $setTo = "https://usgovnetmon.cloudapp.net"
    
    try{
        Set-ItemProperty -Path $IEpath -Name $keyName -Value $setTo
        return $true}
    catch{
        return $false}
    
}

Function Set-IEZoom(){

    $IEpath = "HKCU:\Software\Microsoft\Internet Explorer\Zoom\"
    $keyName = "ZoomFactor"
    $setTo = 0x0001d4c0
    
    try{
        Set-ItemProperty -Path $IEpath -Name $keyName -Value $setTo
        return $true}
    catch{
        return $false}
    
}

Function Get-FFClock(){

    $clockSource = "http://sharepoint/sites/CIS/waps/WAPartnerOps/Fairfax%20Documents/Fairfax/HUD%20Software/Clock.exe"
    $clockDest = "c:\WANetmonInstallFiles\Clock.exe"
    $webClient = New-Object System.Net.WebClient
    $webClient.UseDefaultCredentials = $true        
    try{
        $webClient.DownloadFile($clockSource, $clockDest)
        return $true}
    catch{
        return $false}      

}

Function Add-wANetmonStart(){

    $startupFolder = "C:\Users\ffhud\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    $WANetMonCmdPath = "$startupFolder\HUDStart.cmd"

    try{
        New-Item $WANetMonCmdPath -ItemType File -Force | Out-Null
        $cmdText = @"
@echo off
start C:\WANetmonInstallFiles\iexplore.lnk
start C:\WANetmonInstallFiles\Clock.exe
"@
        Add-Content $WANetMonCmdPath $cmdText
        return $true}
    catch{
        return $false}

}

Function Deployment-Process($depStep, $depFunction, $successMSG, $failureMSG, $blockingStep){

    $deploymentStatus = [xml](get-content $deploymentXML)
    $maxRetrys = $deploymentStatus.Items.$depStep.MaxRetrys
    $depStatus = $deploymentStatus.Items.$depStep.Complete
    $depRetrys = $deploymentStatus.Items.$depStep.Retrys

    if($depStatus -eq "`$false" -and $depRetrys -lt $maxRetrys){
  
        switch($depFunction){
	        "DC"{$depFunction = Domain-Check}
	        "AC"{$depFunction = AdminAcount-Check}
            "FA"{$depFunction = FFHud-AutoLogin}
	        "DU"{$depFunction = Disable-UAC}
            "TF"{$depFunction = TurnOn-FileSharing}
	        "ER"{$depFunction = Enable-RDP}
            "FS"{$depFunction = Set-ConsoleFontSize}            
	        "SP"{$depFunction = Setup-PowerConfig}
	        "AT"{$depFunction = AutoHide-Taskbar}
            "WD"{$depFunction = Disable-WDPopup}
            "IP"{$depFunction = Install-PFX}
	        "AS"{$depFunction = Add-StartUp}
	        "AH"{$depFunction = Add-HUDStart}
            "IS"{$depFunction = Create-IEShortcut}
	        "IE"{$depFunction = Set-IEHomepage}
	        "IZ"{$depFunction = Set-IEZoom}
	        "GF"{$depFunction = Get-FFClock}
	        "AW"{$depFunction = Add-wANetmonStart}
            }

        if($depFunction){
            Write-Host $successMSG -ForegroundColor Green
            $deploymentStatus.Items.$depStep.Complete = "`$true"
            $deploymentStatus.Save($deploymentXML)}
        else{
            Write-Host $failureMSG -ForegroundColor Red
            [int]$currentRetryNum = $deploymentStatus.Items.$depStep.Retrys
            $currentRetryNum ++
            $deploymentStatus.Items.$depStep.Retrys = [string]$currentRetryNum
            $deploymentStatus.Save($deploymentXML)
            if($blockingStep){
                Write-Host "Script exiting, setup cannot continue until $depStep is complete" -ForegroundColor Red
                exit}
                }
        }
        
    if($depStatus -eq "`$false" -and $depRetrys -ge $maxRetrys){
        Write-Host "$depStep has been attemtped $maxRetrys and was unsuccessful.  Please complete the setup manualy" -ForegroundColor Yellow
        if($blockingStep){
            Write-Host "Script exiting, setup cannot continue until $depStep is complete" -ForegroundColor Red
            exit}
            }
        }

Function isAdmin {
    [System.Security.Principal.WindowsPrincipal]$currentPrincipal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent());
    [System.Security.Principal.WindowsBuiltInRole]$administratorsRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;
    return $currentPrincipal.IsInRole($administratorsRole)
}

Function Restart-Elevated {
    Start-Process "powershell.exe" -Verb Runas -ArgumentList " -file `"$($MyInvocation.ScriptName)`" n" -ErrorAction 'stop' 
    Exit
}

if (!(isAdmin)) {
    Restart-Elevated
}

Set-ExecutionPolicy Unrestricted -Force

$ErrorActionPreference = "Stop"

$workingDir = split-path $MyInvocation.MyCommand.path
$scriptName = $MyInvocation.MyCommand.Name 

if($deploymentType -eq "Looper"){
    $installPath = "c:\TriageLoopers\DeploymentFiles"
    if(!(Test-Path $installPath)){
        New-Item $installPath -type directory -Force | Out-Null}
    }

if($deploymentType -eq "WANetmon"){
    $installPath = "c:\WANetmonInstallFiles"
    if(!(Test-Path $installPath)){
        New-Item $installPath -type directory -Force | Out-Null}
    }

$expectedScriptPath = "$installPath\$scriptName"
$actualScriptPath = "$workingDir\$scriptName"

if($expectedScriptPath -ne $actuallScriptPath){
    Move-Item $actualScriptPath $expectedScriptPath -Force | Out-Null
    $workingDir = $installPath}
 
$currentStartupPath = "C:\Users\ffhud\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

if(Test-Path $currentStartupPath){
    $getStartupFiles = Get-ChildItem $currentStartupPath
    if($getStartupFiles){
        $getStartupFiles | %{Remove-Item "$currentStartupPath\$_" -Force}
        }
    }
    
       

#Start deployment loop
While(1){
    
    
    $deploymentXML = "$workingDir\deploymentStatus.xml"
    $startUpPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\RestartHUDDeployment.cmd"

    if(!(Test-Path $startUpPath)){
        New-Item $startUpPath -ItemType File -Force | Out-Null
        $cmdText = @"
@echo off
call powershell $workingDir\$scriptname $deploymentType $deploymentStatus $startupFlag
"@
        Add-Content $startUpPath $cmdText}    


    if(!(Test-Path $deploymentXML)){
        New-Item $deploymentXML -ItemType File | Out-Null
        Add-Content $deploymentXML $xmlblock}

    if($deploymentStatus -eq "New"){
        #Disable UAC
        $DUStep = "UACDisabled"
        $DUSuccess = "UAC has been disabled"
        $DUFail = "Failed to disable UAC.  Will try again next run"

        Deployment-Process $DUStep "DU" $DUSuccess $DUFail $false
    
    
        #Domain Check
        $DCStep = "DomainJoined"
        $DCSuccess = "Computer is part of the Redmond Domain"
        $DCFail = "Computer is not on the Redmond domain, will retry next run"

        Deployment-Process $DCStep "DC" $DCSuccess $DCFail $true


        #Admin Acount Check
        $ACStep = "AdminAccountsAdded"
        $ACSuccess = '"REDMOND\FFHud" and "REDMOND\WA Fairfax Operators" are part of the Admin group'
        $ACFail = "All users not added to Admin group, will retry next run"

        Deployment-Process $ACStep "AC" $ACSuccess $ACFail $true


        #Setup AutoLogon
        $FAStep = "AutoLogin"
        $FASuccess = "HUD has successfully loged on with the FFHud Account"
        $FAFail = "HUD is not logged on as FFHud.  This setting may take several attempts."

        Deployment-Process $FAStep "FA" $FASuccess $FAFail $true


        #Enable File Sharing
        $TFStep = "FileSharing"
        $TFSuccess = "File sharing has been enabled"
        $TFFail = "Failed to enable file sharing.  Will try again next run"

        Deployment-Process $TFStep "TF" $TFSuccess $TFFail $false


        #Enable RDP
        $ERStep = "RDPEnabled"
        $ERSuccess = "RDP has been Enabled"
        $ERFail = "Failed to enable RDP.  Will try again next run"

        Deployment-Process $ERStep "ER" $ERSuccess $ERFail $false


        #Enable RDP
        $FSStep = "FontSize"
        $FSSuccess = "Console Font Size has been set"
        $FSFail = "Failed to set Console Font Size.  Will try again next run"

        Deployment-Process $FSStep "FS" $FSSuccess $FSFail $false


        #Create power configuration
        $SPStep = "PowerConfig"
        $SPSuccess = "Power configuration successfully created"
        $SPFail = "Failed to create power configuration.  Will try again next run"

        Deployment-Process $SPStep "SP" $SPSuccess $SPFail $false


        #AutoHide Taskbar
        $ATStep = "AutoHide"
        $ATSuccess = "Taskbar set to auto hide"
        $ATFail = "Failed to set taskbar to autohide.  Will try again next run"

        Deployment-Process $ATStep "AT" $ATSuccess $ATFail $false


        #Disable WD Popup
        $WDStep = "WDPopup"
        $WDSuccess = "Windows Defender popup has been disabled"
        $WDFail = "Failed to set disable Windows Defender popup.  Will try again next run"

        Deployment-Process $WDStep "WD" $WDSuccess $WDFail $false
    }

    if($deploymentStatus -eq "Redeploy"){
        $newSetupItems = "UACDisabled", "DomainJoined", "AdminAccountsAdded", "AutoLogin", "FileSharing", "RDPEnabled", "PowerConfig", "AutoHide", "WDPopup"
        $deploymentXMLContent = [xml](get-content $deploymentXML)
        $newSetupItems | %{$deploymentXMLContent.Items.$_.Complete = "`$true"
        $deploymentXMLContent.Save($deploymentXML)}
        }

    if($deploymentType -eq "Looper"){
        
        if(Test-Path "C:\WANetmonInstallFiles"){
            $clockStop = Get-Process -Name "Clock"
            if($clockStop){
                Stop-Process $clockStop -Force
                sleep 5}
            Remove-Item "C:\WANetmonInstallFiles" -Force -Recurse
            try{
                Remove-Item "C:\Users\ffhud\Desktop\WANetmon.lnk" -Force -Recurse}
            catch{}
            }

        #Install PFX
        $IPStep = "PFX"
        $IPSuccess = "PFX installed"
        $IPFail = "Failed to install PFX.  Ensure you have the correct Password.  Will try again next run"

        Deployment-Process $ipStep "IP" $IPSuccess $IPFail $false


        #Install Startup Script
        $ASStep = "StartUp"
        $ASSuccess = "StartUp script installed"
        $ASFail = "Failed to install startup script.  Will try again next run"

        Deployment-Process $ASStep "AS" $ASSuccess $ASFail $false


        #Create HUD command
        $AHStep = "HudStart"
        $AHSuccess = "HUD startup command created"
        $AHFail = "Failed to create HUD startup command.  Will try again next run"

        Deployment-Process $AHStep "AH" $AHSuccess $AHFail $false
    }


    if($deploymentType -eq "WANetmon"){

        $curentUser = $env:USERNAME

        if($curentUser -ne "FFHud"){
            Write-Host "FFHud must be logged on to complete setup.  Press enter to reboot, select x to abort setup: " -ForegroundColor Yellow -NoNewline
            $userSelection = Read-Host
            if($userSelection.ToUpper() -eq "X"){
                Remove-Item $startUpPath
                break}
            else{
                Shutdown /r /f /t 10
                break}
            }

        if(Test-Path "C:\TriageLoopers"){
            Remove-Item "C:\TriageLoopers" -Force -Recurse}

        #Create IE Shortcut
        $ISStep = "IEShortcut"
        $ISSuccess = "IE Shortcut created"
        $ISFail = "Failed to create the IE shortcut"

        Deployment-Process $ISStep "IS" $ISSuccess $ISFail $false


        #Set IE Homepage
        $IEStep = "IEHomepage"
        $IESuccess = "IE Homepage successfully set"
        $IEFail = "Failed to set the IE Homepage"

        Deployment-Process $IEStep "IE" $IESuccess $IEFail $false


        #Set IE Zoom
        $IZStep = "IEZoom"
        $IZSuccess = "IE zoom settings successfully set"
        $IZFail = "Failed to set the IE zoom settings"

        Deployment-Process $IZStep "IZ" $IZSuccess $IZFail $false


        #Get Clock
        $GFStep = "Clock"
        $GFSuccess = "Got the FF clock"
        $GFFail = "Failed to get the FF clock"

        Deployment-Process $GFStep "GF" $GFSuccess $GFFail $false


        #Create WANetmon startup command
        $AWStep = "WANetmonStart"
        $AWSuccess = "WANetmonStart command created"
        $AWFail = "Failed to create the WANetmonStart command"

        Deployment-Process $AWStep "AW" $AWSuccess $AWFail $false
    }


    #Check Deployment Status
    $getDepXML = [xml](get-content $deploymentXML)
    $items = $getDepXML.SelectNodes("//*[@complete]")
    $completedItems = @()
    $itemsToComplete = @()
    $maxRetryReached = @()

    $items | %{

        if($_.complete -eq "`$true"){
            $completedItems += $_}
        else{
            $itemsToComplete += $_}

        if($_.retrys -eq $_.MaxRetrys){
            $maxRetryReached += $_}
        }

    $itemsScriptCanRetry = @()

    $itemsToComplete | %{
        if($_ -notin $maxRetryReached){
            $itemsScriptCanRetry += $_}
        }

    if(!($itemsScriptCanRetry) -and !($maxRetryReached)){
        Write-Host "Deployment has completed.  The following deployment steps finished successfully." -ForegroundColor Green
        $completedItems | %{Write-Host $_}
        Remove-Item $startUpPath
        Write-Host "The HUD needs now needs to be rebooted."  -ForegroundColor Yellow
        Write-Host "Press enter to reboot the HUD.  To exit without reboot select x: "  -ForegroundColor Yellow -NoNewline
        $userSelection = Read-Host
        if($userSelection.ToUpper() -eq "X"){
            break}
        else{
            Shutdown /r /f /t 10
            break}
        }

    elseif(!($itemsScriptCanRetry) -and $maxRetryReached){
        Write-Host "Deployment has completed all taskes that it can." -ForegroundColor Yellow
        Write-Host "The following items will have to be set up manualy." -ForegroundColor Yellow
        $maxRetryReached | %{Write-Host $_}
        Remove-Item $startUpPath
        break}
    
    else{
        Write-Host "The following items can be retried by the script." -ForegroundColor Yellow
        $itemsToComplete | %{Write-Host $_ }
        Write-Host "Press enter to retry, select r to reboot the HUD to try again, select x to abort setup: " -ForegroundColor Yellow -NoNewline
        $userSelection = Read-Host
        if($userSelection.ToUpper() -eq "R"){
            Shutdown /r /f /t 10}
        if($userSelection.ToUpper() -eq "X"){
            Remove-Item $startUpPath
            break}
        }
}
        