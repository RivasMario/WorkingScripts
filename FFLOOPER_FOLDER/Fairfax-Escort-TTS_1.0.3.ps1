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
			-Added logic to find latest version of HUDFunctions module
	
		3/10/2017 - v-pemic 	- 	Fixed sorting so that severity sorts corectly
									Added color to high sev escorts
									Added failover for TFS
	
        2/25/2016 - Tyler Wiegers - Simplified Time to Start logic to make it more clear
                                    Removed dependency on module file for script specific functions (added Get-EscortTTS function to script)
                                    Added counter to show how long it takes the query to execute
                                    Added Severity column to output, and formatted output to be consistent with other hud views
                                    Updated error checking to be more consistent across scripts
                                    Updated title on output to ESCORT instead of WALS
                                    Consolodated Time to Schedule and Time to Start scripts into one visual
                                    Updated KPI value to be an integer for sorting purposes

#>

$version = "1.0.1"

$host.ui.RawUI.WindowTitle = "Escort-TTS - Version: $version"

$ScriptDirectory = split-path $MyInvocation.MyCommand.path
if($ScriptDirectory -match "\\archive"){
    $cd = $ScriptDirectory.Replace("\archive", "")
    $ScriptDirectory = $cd}

$getLatestMod = Get-ChildItem $ScriptDirectory\Modules\ | Where-Object {$_.Name -match ("HUDFunctions.*.ps1")} | Sort-Object $_.Name -Descending
$latestMod = $getLatestMod[0].Name

. $ScriptDirectory\Modules\$latestMod


Function Get-EscortTTS {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $EventTime = $Ticket.fields['Event Time'].Value
    $CurrentTime = Get-Date

    If (!$EventTime) {
        $EventTime = $Ticket.Fields['Created Date'].Value
    }

    $TTS = new-timespan -Start $EventTime -End $CurrentTime

    return $TTS.TotalMinutes

}


function DisplayHud() {

    $quiet = $error.Clear()

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

    $QueryStart = Get-Date

    $ScheduledTickets = $WorkItemStore.Query(
        "SELECT [System.Id] 
        FROM WorkItems 
        WHERE 
            [System.TeamProject] = 'Fairfax' AND 
            [System.WorkItemType] = 'Escort Request' AND
            [System.State] = 'Escorting Scheduled'
        ORDER BY [System.CreatedDate]")

    $NewTickets = $WorkItemStore.Query(
        "SELECT [System.Id] 
        FROM WorkItems 
        WHERE 
            [System.TeamProject] = 'Fairfax' AND 
            [System.WorkItemType] = 'Escort Request' AND
            [System.State] = 'Escorting Requested'
        ORDER BY [System.CreatedDate]")

    $QueryFinish = Get-Date
    $QueryDuration = "{0:N2}" -f (New-TimeSpan -Start $QueryStart -End $QueryFinish).TotalSeconds

    # Check for errors with the query
    if ($error.Count -gt 0) {

        $Host.UI.RawUI.BackgroundColor = 'Red'
        $Host.UI.RawUI.ForegroundColor = 'White'
        Clear-Host
        Write-Host "TFS Connection appears to be down, please check TFS!"
        return

    } 

    $OutputData = @()

    $NewTickets | %{ 
        
        $ID = $_.ID
        $Title = $_.Title
        $TTS = Get-EscortTTS -Ticket $_
        $State = "New"
        $Severity = $_.fields['IncidentSeverity'].Value

        $ticketinfo = New-Object psobject
        $ticketinfo | Add-Member -MemberType noteproperty -Name "ID" -Value $id
        $ticketinfo | Add-Member -MemberType noteproperty -Name "Title" -Value $title
        $ticketinfo | Add-Member -MemberType noteproperty -Name "TTS" -Value ([int]("{0:N0}" -f $TTS))
        $ticketinfo | Add-Member -MemberType noteproperty -Name "State" -Value $State
        $ticketinfo | Add-Member -MemberType noteproperty -Name "Severity" -Value $Severity

        $OutputData += $ticketinfo    
    
    }

    $ScheduledTickets | %{ 

        $ID = $_.ID
        $Title = $_.Title
        $TTS = Get-EscortTTS -Ticket $_
        $State = "Sched"
        $Severity = $_.fields['IncidentSeverity'].Value

        $ticketinfo = New-Object psobject
        $ticketinfo | Add-Member -MemberType noteproperty -Name "ID" -Value $id
        $ticketinfo | Add-Member -MemberType noteproperty -Name "Title" -Value $title
        $ticketinfo | Add-Member -MemberType noteproperty -Name "TTS" -Value ([int]("{0:N0}" -f $TTS))
        $ticketinfo | Add-Member -MemberType noteproperty -Name "State" -Value $State
        $ticketinfo | Add-Member -MemberType noteproperty -Name "Severity" -Value $Severity

        $OutputData += $ticketinfo            

    }


    $WarnThreshhold = 0
    $FailThreshhold = 3


    # Check Validations
    $Status = "pass"
	$HS = "Red"
	
    $HighestTTS = ($OutputData.TTS | Measure -Maximum).Maximum
        
    if ($HighestTTS -ne $null -and $HighestTTS -ge -30) {
        $Status = "new"
		$HS = "Yellow"
    }

    switch ($HighestTTS) {

        {$_ -ge $WarnThreshhold} {
            $Status = "warn"
			$HS = "Red"
        }

        {$_ -ge $FailThreshhold} {
            $Status = "fail"
			$HS = "Yellow"
        }

    }

    Set-UIColors -Status $Status

    Clear-Host
    " _____ _____ _____ _____ _____ _____ "
    "|   __|   __|     |     | __  |_   _|"
    "|   __|__   |   --|  |  |    -| | |  "
    "|_____|_____|_____|_____|__|__| |_|  `n"
    Write-Host "Last Execution: " (Get-Date)
    #Write-Host "Last Execution: $(Get-Date).  Query took $QueryDuration seconds to execute."
    ""

    "{0,-8}  {1,4}  {2,4}  {3,-8} {4,-20}" -f ("ID", "KPI", "Sev", "State", "Title")
    "{0,-8}  {1,4}  {2,4}  {3,-8} {4,-20}" -f ("--------", "----", "----", "------", "----------")        
    #"{0,-8}  {1,6}  {2,6}  {3,-20}" -f ("ID", "KPI", "State", "Severity")
    #"{0,-8}  {1,6}  {2,6}  {3,-20}" -f ("--------", "------", "------", "----------")

    $OutputData | sort-object -property @{Expression = "Severity"; Descending = $False}, @{Expression = "TTS"; Descending = $True} | %{
            $writeline = "{0,-8}  {1,4}  {2,4}  {3,-10} {4, -20}" -f ($_.ID, $_.TTS, $_.Severity, $_.State, $_.Title)
			if($_.Severity -lt 3)
			{
				Write-Host $writeline -ForegroundColor $HS
			}
			else
			{
				Write-Host $writeline
			}
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
    DisplayHud
    Start-Sleep -Seconds 15
}
