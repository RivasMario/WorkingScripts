<#

    Updates
		1.3.0 - 3/25/2018 - v-pemic
			-Added new combined RDTaks loopera and new SCRAP looper
		1.3.0 - 2/26/2018 - v-pemic
			-Removed Approve and Deploy loopers and added SQL and Service Account looper
		
		1.1.1 - 9/7/2017 - v-pemic
			-Added EscortAvi.ps1 to the looper startup
	
		1.1.0 - 8/22/2017 - v-pemic
			-Changed window sizing to be compatible with PS 5.0
            -If script to be run in not in main folder will now check archive for last version there
			-If script is run from the archive folder it will set the script directory to the directory above the archive folder
			
		1.0.0 - 7/20/2017 - v-pemic
			-Adding versioning
			-Added logic to find latest version of script in the script path
	
#>

# Window Setup Variables
$Windows = @(


    <#
        X/Y Coordinates: Location of the top left pixel of the window starting from the top-left of the leftmost screen
        X: Location of window on the X (left/right) axis
        Y: Location of the window on the Y (up/down) axis

        X/Y Size Values: Pixel size of the window, may be rounded to the nearest character size, so don't expect it to be precision necessarily.
        X_Size: Size of the window on the X (left/right) axis
        Y_Size: Size of the window on the Y (up/down) axis
    #>


    <#
	Order of HUD's/Queries
        | WALS Ack/Esc   | WASH Ack/Esc 
        | RDTask Triage  | RTO/WARM
        | RDTask	     | WADE Ack/Esc
		| Deployment     | Escort

    #>

$ScriptDirectory = split-path $MyInvocation.MyCommand.path
if($ScriptDirectory -match "\\archive"){
    $cd = $ScriptDirectory.Replace("\archive", "")
    $ScriptDirectory = $cd}

	$getLatestAIRS = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-AIRS"} | Sort-Object $_.Name -Descending
if(!($getLatestAIRS)){
    $getLatestAIRS = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-Deployment-TTS"} | Sort-Object $_.Name -Descending
    $AIRSname = $getLatestAIRS[0].Name
    $AIRS = "archive\$AIRSname"
	}
else{
	$AIRS = $getLatestAIRS[0].Name}
	
	
$getLatestSQL = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-SQL"} | Sort-Object $_.Name -Descending
if(!($getLatestSQL)){
    $getLatestSQL = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-Deployment-TTS"} | Sort-Object $_.Name -Descending
    $SQLname = $getLatestSQL[0].Name
    $SQL = "archive\$SQLname"
	}
else{
	$SQL = $getLatestSQL[0].Name}
	
$getLatestSVC = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "SvcAcctLooper"} | Sort-Object $_.Name -Descending
if(!($getLatestSVC)){
    $getLatestSVC = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-Deployment-TTS"} | Sort-Object $_.Name -Descending
    $SVCname = $getLatestSVC[0].Name
    $SVC = "archive\$SVCname"
	}
else{
	$SVC = $getLatestSVC[0].Name}
	
$getLatestRTOTTS = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-RTO-TTStart-withBlocked"} | Sort-Object $_.Name -Descending
if(!($getLatestRTOTTS)){
    $getLatestRTOTTS = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-RTO-TTStart-withBlocked"} | Sort-Object $_.Name -Descending
    $RTOTTSname = $getLatestRTOTTS[0].Name
    $RTOTTS = "archive\$RTOTTSname"
	}
else{
	$RTOTTS = $getLatestRTOTTS[0].Name}

$getLatestRDTTS = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-SCRAP"} | Sort-Object $_.Name -Descending
if(!($getLatestRDTTS)){
    $getLatestRDTTS = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-RDTask-TTStart"} | Sort-Object $_.Name -Descending
    $RDTTSname = $getLatestRDTTS[0].Name
    $RDTTS = "archive\$RDTTSname"
	}
else{
	$RDTTS = $getLatestRDTTS[0].Name}

$getLatestRDTri = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-RDTask-All"} | Sort-Object $_.Name -Descending
if(!($getLatestRDTri)){
    $getLatestRDTri = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-RDTask-Triage"} | Sort-Object $_.Name -Descending
    $RDTriname = $getLatestRDTri[0].Name
    $RDTri = "archive\$RDTriname"
	}
else{
	$RDTri = $getLatestRDTri[0].Name}

$getLatestEscort = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-Escort-TTS"} | Sort-Object $_.Name -Descending
if(!($getLatestEscort)){
    $getLatestEscort = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-Escort-TTS"} | Sort-Object $_.Name -Descending
    $Escortname = $getLatestEscort[0].Name
    $Escort = "archive\$Escortname"
	}
else{
	$Escort = $getLatestEscort[0].Name}
	
$getLatestOnShift = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "OnShift"} | Sort-Object $_.Name -Descending
if(!($getLatestOnShift)){
    $getLatestOnShift = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "OnShift"} | Sort-Object $_.Name -Descending
    $OnShiftName = $getLatestOnShift[0].Name
    $OnShift = "archive\$Escortname"
	}
else{
	$OnShift = $getLatestOnShift[0].Name}

    $xsize = 88
	$ysize = 25
	$ydsize = 40
	
    # Screen 1
    @{ "X" = 0;     "Y" = 0;   "X_SIZE" = $xsize;  "Y_SIZE" = $ysize; "Script" = ".\$RDTri" }                                         # Row 1 Left
    @{ "X" = 700;   "Y" = 0;   "X_SIZE" = $xsize;  "Y_SIZE" = $ysize; "Script" = ".\$RTOTTS" }                                	     	 # Row 1 Right
    @{ "X" = 0;     "Y" = 300;   "X_SIZE" = $xsize;  "Y_SIZE" = $ysize; "Script" = ".\$AIRS" }                                        # Row 2 Left
	@{ "X" = 700;   "Y" = 300;   "X_SIZE" = $xsize;  "Y_SIZE" = $ysize; "Script" = ".\ICMLooper_New\IcmODataOperationsClient.exe WADE TimeToAcknowledge" } # Row 2 Right
    @{ "X" = 0;     "Y" = 350;   "X_SIZE" = $xsize;  "Y_SIZE" = 150; "Script" = ".\$SQL" } 											 # Row 3 Left
    @{ "X" = 700;   "Y" = 350;   "X_SIZE" = $xsize;  "Y_SIZE" = 150; "Script" = ".\$SVC" }       									 # Row 3 Right
	@{ "X" = 1420;   "Y" = 0;   "X_SIZE" = 66;  "Y_SIZE" = 73; "Script" = ".\$OnShift" }       									 # Right wall
	#@{ "X" = 1420;   "Y" = 750;   "X_SIZE" = 68;  "Y_SIZE" = 25; "Script" = ".\$AIRS" }       									 
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
    $ProcessAttributes.SetPropertyValue("XCountChars", 100)

    $ProcessAttributes.SetPropertyValue("Y", $Window.Y)
    $ProcessAttributes.SetPropertyValue("YCountChars", 2500)
	
	$script = $Window.Script
	$height = $Window.X_SIZE
	$width = $Window.Y_SIZE
	
    $ProcessManager.create("powershell -noexit $("[console]::WindowWidth=$height; [console]::WindowHeight=$width
							$script")", "$ScriptDirectory", $ProcessAttributes)

    Start-Sleep -Milliseconds 1000

}