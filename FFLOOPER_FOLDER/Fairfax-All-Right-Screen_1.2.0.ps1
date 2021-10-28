<#

    Updates

		1.1.0 - 8/22/2017 - v-pemic
            -If script to be run in not in main folder will now check archive for last version there
			-If script is run from the archive folder it will set the script directory to the directory above the archive folder
						
		1.0.1 - 7/21/2017 - v-pemic
			-Removed "Title" property value as it was not working
			
		1.0.0 - 7/20/2017 - v-pemic
			-Adding versioning
			-Added logic to find latest version of script in the script path
			-Windows will now open with version info if available
	
#>

$ScriptDirectory = split-path $MyInvocation.MyCommand.path
if($ScriptDirectory -match "\\archive"){
    $cd = $ScriptDirectory.Replace("\archive", "")
    $ScriptDirectory = $cd}

$getLatestSQL = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-SQL"} | Sort-Object $_.Name -Descending
if(!($getLatestSQL)){
    $getLatestSQL = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-Deployment-TTS"} | Sort-Object $_.Name -Descending
    $SQLname = $getLatestSQL[0].Name
    $SQL = "archive\$SQLname"
	}
else{
	$SQL = $getLatestSQL[0].Name}
	
$getLatestOnShift = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "OnShift"} | Sort-Object $_.Name -Descending
if(!($getLatestOnShift)){
    $getLatestOnShift = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "OnShift"} | Sort-Object $_.Name -Descending
    $OnShiftName = $getLatestOnShift[0].Name
    $OnShift = "archive\$getLatestOnShift"
	}
else{
	$OnShift = $getLatestOnShift[0].Name}


# Window Setup Variables
$Windows = @(
    
    # Upper Left
    @{ "X" = 0;  "Y" = 0;  "X_SIZE" = 945; "Y_SIZE" = 1000; "Script" = ".\$SQL" }

    # Upper Right
    @{ "X" = 955;  "Y" = 0; "X_SIZE" = 945; "Y_SIZE" = 1000; "Script" = ".\$OnShift"}

)

$ProcessManager = ([WMICLASS]"ROOT\CIMV2:Win32_Process")

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

foreach ($Window in $Windows) {

    $ProcessAttributes = ([WMICLASS]"ROOT\CIMV2:Win32_ProcessStartup")

    $ProcessAttributes.SetPropertyValue("X", $Window.X)
    $ProcessAttributes.SetPropertyValue("XSize", $Window.X_SIZE)
    $ProcessAttributes.SetPropertyValue("XCountChars", 100)

    $ProcessAttributes.SetPropertyValue("Y", $Window.Y)
    $ProcessAttributes.SetPropertyValue("YSize", $Window.Y_SIZE)
    $ProcessAttributes.SetPropertyValue("YCountChars", 2500)

    $ProcessManager.create("powershell -noexit $($Window.Script)", "$ScriptDirectory", $ProcessAttributes)

    Start-Sleep -Milliseconds 1000

}



