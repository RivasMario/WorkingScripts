<#

    Updates

        1.1.3 - 2/27/2018 - v-pemic
			-Updated query to reflect Leidos name change and the addition of Accenture 	

        1.1.2 - 10/11/2017 - v-pemic
			-Updated KPI times
		
		1.1.1 - 8/18/2017 - v-pemic
			-Made Import Module Import-Module C:\TFS\mod-tfs.psm1 the default for pulling in the Connect-AzureTfs command
		
		1.1.0 - 7/21/2017 - v-pemic
			-Fixed problem where task info was not populated on first loop
		
		1.1.0 - 7/21/2017 - v-pemic
			-Overhauled how KPI is calculated.  Removed timer functions and instead calculate from ticket assigned time based on last time assinged to WADE
			-Updated KPIDefinition per v-timah
					
		1.0.1 - 7/21/2017 - v-pemic
			-Added version to window title
			
		1.0.0 - 7/20/2017 - v-pemic
			-Adding versioning
			-Added Try/Catch to import powershell tools so same script can be run on all loopers
			-Commented out the Buffersize
		
		7/6/2017 - v-timah	- Updated KPI Timespans (2,3,4 to 60 min)
		
		3/15/2017 - v-pemic 	-	Added failover for TFS

#>

$version = "1.1.3"

$host.ui.RawUI.WindowTitle = "RDTask-TTS - Version: $version"

try{
	Import-Module C:\TFS\mod-tfs.psm1
}
catch{
	wa -LoadFromLocal
	Write-Progress -Activity "This is needed to clear the progress bar"
	Write-Progress -Completed "This is needed to clear the progress bar"
}

$KPIDefinition = @{
    "0" = New-TimeSpan -Minutes 15;
    "1" = New-TimeSpan -Minutes 30;
    "2" = New-TimeSpan -Minutes 60;
    "3" = New-TimeSpan -Minutes 60;
    "4" = New-TimeSpan -Minutes 60
}

$TFSQuery = "SELECT [System.Id]
            FROM WorkItems 
            WHERE 
                [System.TeamProject] = 'Fairfax' AND 
                [System.WorkItemType] = 'RDTask' AND
                [Microsoft.VSTS.Common.Triage] = 'Approved' AND
                [Microsoft.RD.KeywordSearch] contains 'WADECORE' AND
                [System.CreatedDate] >= @today - 40
            ORDER BY [Microsoft.Azure.Incident.Severity], [System.ID]"

$TFSExcludeQuery = "SELECT [System.Id]
            FROM WorkItems 
            WHERE 
                [System.TeamProject] = 'Fairfax' AND 
                [System.WorkItemType] = 'RDTask' AND
                [Microsoft.VSTS.Common.Triage] = 'Approved' AND
                [Microsoft.RD.KeywordSearch] contains 'WADECORE' AND
                [System.CreatedDate] >= @today - 40 AND
                [Microsoft.Azure.WorkStatus] EVER 'In Progress'
            ORDER BY [Microsoft.Azure.Incident.Severity], [System.ID]"

$TFSNormalQueue = "SELECT [System.Id]
            FROM WorkItems 
            WHERE 
                [System.TeamProject] = 'Fairfax' AND 
                [System.WorkItemType] = 'RDTask' AND
                [System.State] = 'Active' AND
                [Microsoft.VSTS.Common.Triage] = 'Approved' AND
                [Microsoft.Azure.WorkStatus] <> 'In Progress' AND 
                [Microsoft.RD.KeywordSearch] contains 'WADECORE' AND
                (
                    [System.AssignedTo] = 'WADE' or 
                    [System.AssignedTo] = 'WA Deployment Core' or 
                    [System.AssignedTo] = 'WA Deployment Engineering' or 
                    [System.AssignedTo] = 'Fairfax Partner Operations' or 
                    [System.AssignedTo] contains 'Leidos' or
                    [System.AssignedTo] contains 'Accenture'
                )
                ORDER BY [Microsoft.Azure.Incident.Severity], [System.ID]"

Function Get-RTOTasks()
{

    $quiet = $error.Clear()

    # "At the call, incidents that got saved:"
    # $IncidentList

    # Get TFS
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

    # Load TFS Query
    $workitems = $WorkItemStore.Query($TFSQuery)
    $excludeworkitems = $WorkItemStore.Query($TFSExcludeQuery)
    $normalqueue = $WorkItemStore.Query($TFSNormalQueue)

    $ValidTaskList = @()
    foreach ($task in $workitems) {
    
        $match = $false
        foreach ($goodtask in $excludeworkitems) {
            
            if ($match) { continue }

            if ($goodtask.ID -eq $task.ID) {
                # Found it, break out
                $match = $true
                
            }

        }
        if (!$match) {
           $ValidTaskList += ($task.ID)
        }
    }

    $normalqueue | % {if(!($_.ID -in $ValidTaskList)){
        $ValidTaskList += ($_.ID)
		}
    }

    #$workitems = Compare-Object -ReferenceObject $excludeworkitems -DifferenceObject $allworkitems -PassThru

    # Check for errors with the query
    if ($error.Count -gt 0) {

        $Host.UI.RawUI.BackgroundColor = 'Red'
        $Host.UI.RawUI.ForegroundColor = 'White'

        Clear-Host

        Write-Host "TFS Connection appears to be down, please check TFS!"

        return

    } 
    
    $Now = Get-Date

    $OutputData = @()

    # Now add the incident details to a table to display/sort/etc
    $ValidTaskList | %{
	
		$task = $_
		$Details = $Workitems | ? { $_.ID -eq $task }
		
		if(!($Details)){
			$Details = $normalqueue | ? { $_.ID -eq $task }
		}
              
		$rev = $Details.revisions
		$cdate = $Details.CreatedDate
		$teams = 'WA Deployment Core', 'WA Deployment Engineering', 'WA Deployment Platform Services', 'WADE'

		$rev | %{$revdate = $_.fields['Changed Date'].Value
	
			$AssignedTo = $_.fields['Assigned To'].Value
			$PStatus = $_.fields["Work Status"].Originalvalue
			$PAssTo = $_.fields["Assigned To"].Originalvalue
			$PState = $_.fields["State"].Originalvalue

			if ($teams -contains $AssignedTo -AND !($teams -contains $PAssTo)){
				if($revdate -gt $cdate){$cdate = $revdate}}
			if ($AssignedTo -match "Lockheed" -AND $PStatus -eq "Blocked"){
				if($revdate -gt $cdate){$cdate = $revdate}}
			if ($AssignedTo -match "Lockheed" -AND $Pstate -eq "Resolved"){
				if($revdate -gt $cdate){$cdate = $revdate}}
			}


        $Timespan = New-TimeSpan -Start $cdate -End ($Now)

		$KPIThreshold = $KPIDefinition."$($Details.fields['Priority'].Value)".TotalMinutes
		
        $OutputEntry = New-Object psobject
        $OutputEntry | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N0}" -f (($KPIThreshold - $Timespan.TotalMinutes)))
        $OutputEntry | Add-Member -MemberType noteproperty -Name "TimeSortable" -Value ($KPIThreshold - $Timespan.TotalMinutes)
        $OutputEntry | Add-Member -MemberType noteproperty -Name "KPIThreshold" -Value $KPIThreshold
        $OutputEntry | Add-Member -MemberType noteproperty -Name "ID" -Value $Details.ID
        $OutputEntry | Add-Member -MemberType noteproperty -Name "Title" -Value $Details.Title

        $OutputData += $OutputEntry

    }


    # Assume we're passing (nothing to display)
    $Status = "pass"

    # Check to see if we have any tickets to display
    if ($OutputData.count -gt 0) {
        $Status = "new"
    }


    # Calc what we should show individually, and pick the worst
    foreach ($Ticket in $OutputData) {

        $WarnThreshold = $Ticket.KPIThreshold * .5
        $FailThreshold = $Ticket.KPIThreshold * .25

        if ([int]$Ticket.Time -le [int]$FailThreshold) {

            $Status = "fail"

            # First fail we get we can break out
            break

        } elseif ([int]$Ticket.Time -le [int]$WarnThreshold) {
            $Status = "warn"
        }

    }

    # Set background/foreground based on status
    switch ($Status) {

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
    " _____ ____  _____ _____ _____ _____ "
    "| __  |    \|_   _|  _  |   __|  |  |"
    "|    -|  |  | | | |     |__   |    -|"
    "|__|__|____/  |_| |__|__|_____|__|__|`n"
    
    Write-Host "Last Execution: " (Get-Date)
    ""

    "{0,-8}  {1,5}  {2,-20}" -f ("ID", "KPI", "Title")
    "{0,-8}  {1,5}  {2,-20}" -f ("--------", "-----", "----------")


    $TitleLengthLimit = 45
    $OutputData | Sort-Object -Property 'TimeSortable' | %{
        if ($_.Title.Length -lt $TitleLengthLimit) {
            $TitleLengthLimit = $_.Title.Length
        }
        "{0,-8}  {1,5}  {2,-20}" -f ($_.ID, $_.Time, $_.Title.Substring(0, $TitleLengthLimit))
    }
  
}

while($true)
{
    $sleepDuration = 30
    
    ##############
    ### QUERY IcM
    ##############

    Get-RTOTasks

    #Write-Host "Sleeping for $sleepDuration seconds"
    Start-Sleep -Seconds $sleepDuration
}