<#

    Updates
					
        1.0.3 - 8/22/2017 - v-pemic
            -Added logic to change script directory if file has been archived allowing it to load the module file
			
		1.0.2 - 8/18/2017 - v-pemic
			-Made Import Module Import-Module C:\TFS\mod-tfs.psm1 the default for pulling in the Connect-AzureTfs command
	
		1.0.1 - 7/21/2017 - v-pemic
		    -Added version to window title
		    -Fixed issue with module not loading corectly if script started by itself 
	
		1.0.0 - 7/20/2017 - v-pemic
			-Adding versioning
			-Added Try/Catch to import powershell tools so same script can be run on all loopers
			-Added logic to find latest version of MetricFunctions module
			
		3/15/2017 - v-pemic 	-	Added failover for TFS

#>

$version = "1.0.1"

$host.ui.RawUI.WindowTitle = "Deployment-TTS - Version: $version"

$ScriptDirectory = split-path $MyInvocation.MyCommand.path

$ScriptDirectory = split-path $MyInvocation.MyCommand.path
if($ScriptDirectory -match "\\archive"){
    $cd = $ScriptDirectory.Replace("\archive", "")
    $ScriptDirectory = $cd}
	
$getLatestMod = Get-ChildItem $ScriptDirectory\Modules\ | Where-Object {$_.Name -match ("MetricFunctions.*.ps1")} | Sort-Object $_.Name -Descending
$latestMod = $getLatestMod[0].Name

. $ScriptDirectory\Modules\$latestMod

function get-deployments() {

    #GET THE TFS OBJECT 
	try
	{
		Connect-AzureTfs | Out-Null
		$WorkItemStore = Connect-AzureTfs https://vstfrd:443
	}
	catch
	{
		$WorkItemStore = Connect-AzureTfs -TfsUri https://vstfrd:443
		$error.Clear()
	}

    If($WorkItemStore) {

        $workitems = $WorkItemStore.Query(
        @"
            SELECT [System.Id] 
            FROM WorkItems 
            WHERE 
                [System.TeamProject] = 'Fairfax' AND 
                [System.WorkItemType] = 'DeploymentTask' AND
                [System.State] <> 'Cancelled' AND
                [System.State] <> 'Completed' AND
                [System.State] <> 'Deploying' AND
                [System.State] <> 'Blocked' AND
                [System.State] <> 'On-Hold' AND
                [Microsoft.VSTS.Scheduling.BaselineStartDate] <> ''
            ORDER BY [System.CreatedDate]
"@)
    
        $now = Get-Date

        $stats = @()
        $workitems | %{ 

            $id = $_.ID
            $title = $_.Title
            $TTS = Get-DeploymentTTS -Ticket $_

            $ticketinfo = New-Object psobject
            $ticketinfo | Add-Member -MemberType noteproperty -Name "ID" -Value $id
            $ticketinfo | Add-Member -MemberType noteproperty -Name "Title" -Value $title
            $ticketinfo | Add-Member -MemberType noteproperty -Name "TTS" -Value ("{0:N0}" -f $TTS.TTS.TotalMinutes)

            $stats += $ticketinfo            

        }

        $WarnThreshhold = 10
        $FailThreshhold = 25

        # Check Validations
        $fail = "pass"

        $HighestTTT = ($stats.TTS | Measure -Maximum).Maximum
        
        if ($HighestTTT -ne $null -and $HighestTTT -ge -30) {
            "Got Here $highestTTT"
            $fail = "new"
        }

        switch ($HighestTTT) {

            {$_ -ge $WarnThreshhold} {
                $fail = "warn"
            }

            {$_ -ge $FailThreshhold} {
                $fail = "fail"
            }

        }

        switch ($fail) {

            "warn" {
                $Host.UI.RawUI.BackgroundColor = 'Yellow'
                $Host.UI.RawUI.ForegroundColor = 'Black'
            }
            
            "fail" {
                $Host.UI.RawUI.BackgroundColor = 'Red'
                $Host.UI.RawUI.ForegroundColor = 'White'
            }
            
            "new" {
                $Host.UI.RawUI.BackgroundColor = 'DarkGreen'
                $Host.UI.RawUI.ForegroundColor = 'White'
            }
            
            "pass" {
                $Host.UI.RawUI.BackgroundColor = 'Black'
                $Host.UI.RawUI.ForegroundColor = 'Gray'
            }

        }


        Clear-Host
        " ____  _____ _____ __    _____ __ __ "
        "|    \|   __|  _  |  |  |     |  |  |"
        "|  |  |   __|   __|  |__|  |  |_   _|"
        "|____/|_____|__|  |_____|_____| |_|  `n"
        Write-Host "Last Execution: " (Get-Date)

        if ($stats.Length -eq 0) {
            ""
            "There are currently no tickets in the queue"
        }

        $stats | Select 'TTS', 'ID', 'Title' |ft -a

    } else {
        Write-Error "ERROR: Connection to TFS is not available" -BackgroundColor "Yellow"
    }

}

Function isAdmin {
    [System.Security.Principal.WindowsPrincipal]$currentPrincipal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent());
    [System.Security.Principal.WindowsBuiltInRole]$administratorsRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;
    return $currentPrincipal.IsInRole($administratorsRole)
}

Function Restart-Elevated {
    Start-Process "powershell.exe" -Verb Runas -ArgumentList "-file `"$($MyInvocation.ScriptName)`" n" -ErrorAction 'stop'
    Exit
}

if (!(isAdmin)) {
    Restart-Elevated
}

Set-ExecutionPolicy Unrestricted
try{
	Import-Module C:\TFS\mod-tfs.psm1
}
catch{
	wa -LoadFromLocal
	Write-Progress -Activity "This is needed to clear the progress bar"
	Write-Progress -Completed "This is needed to clear the progress bar"
}
# Have to load this to work on the display machines
[Void][Reflection.Assembly]::LoadFrom("$AzureToolsRoot\TFS\64\Microsoft.TeamFoundation.WorkItemTracking.Client.DataStoreLoader.dll")

while(1)
{
    $date = Get-Date 
    get-deployments
    Start-Sleep -Seconds 15
}
