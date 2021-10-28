<#

    Updates

        1.1.2 - 10/11/2017 - v-pemic
			-Updated SQL Query to exclude WARM's from the Component Team "Skype"
		
		1.1.1 - 8/18/2017 - v-pemic
			-Made Import Module Import-Module C:\TFS\mod-tfs.psm1 the default for pulling in the Connect-AzureTfs command

		1.1.0 - 7/21/2017 - v-pemic
			-Overhauled how KPI is calculated.  Removed timer functions and instead calculate from ticket assigned time based on last time assinged to WADE
	
		1.0.1 - 7/20/2017 - v-pemic
			-Added version to window title
			
		1.0.0 - 7/20/2017 - v-pemic
			-Adding versioning
			-Added Try/Catch to import powershell tools so same script can be run on all loopers

		4/25/2017 - v-timah 	- 	AddedPFGold to go staright to RTO Looper
		
		3/15/2017 - v-pemic 	-	Added failover for TFS
		
		

#>

$version = "1.1.3"

$host.ui.RawUI.WindowTitle = "RTO-TTS - Version: $version"

try{
	Import-Module C:\TFS\mod-tfs.psm1
}
catch{
	wa -LoadFromLocal
	Write-Progress -Activity "This is needed to clear the progress bar"
	Write-Progress -Completed "This is needed to clear the progress bar"
}

$KPIThreshold = @{
    "RTO" = (New-TimeSpan -Minutes 30).TotalMinutes;
    "WARM" = (New-TimeSpan -Minutes 15).TotalMinutes
}

$TFSQuery = "SELECT [System.Id]
            FROM WorkItems 
            WHERE 
                (
                    [System.TeamProject] = 'Fairfax' AND 
                    [System.WorkItemType] = 'RDTask' AND 
                    [System.State] = 'Active' AND
                    (
					[Microsoft.RD.KeywordSearch] contains 'PFGold_Replication' OR
					[Microsoft.RD.KeywordSearch] contains 'FairfaxDoD' OR
                    [Microsoft.RD.KeywordSearch] contains 'RTO'
					) AND
                    (
                        [Microsoft.Azure.WorkStatus] = 'Not Started' OR 
                        [Microsoft.Azure.WorkStatus] = '' OR
                        [Microsoft.Azure.WorkStatus] = 'Ready' OR
						[Microsoft.Azure.WorkStatus] = 'Blocked'						
                    ) AND
                    (
                        [System.AssignedTo] = 'WADE' OR 
                        [System.AssignedTo] = 'WA Deployment Core' OR 
                        [System.AssignedTo] = 'WA Deployment Engineering' OR 
                        [System.AssignedTo] = 'WA Deployment Platform Services' OR 
                        [System.AssignedTo] contains 'Lockheed'
                    )
                ) OR
                (
                    [System.TeamProject] = 'Fairfax' AND  
                    [System.WorkItemType] = 'Deployment' AND  
                    [System.State] = 'Pending Approval' AND 
                    [Team] != 'Skype' AND 
                    [System.AssignedTo] = 'Warm Prod' AND
					[System.Title] NOT CONTAINS 'WARMTestJo'
                )
            ORDER BY [Microsoft.Azure.Incident.Severity], [System.ID]"


Function Get-RTOTasks($QueryText)
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
    $workitems = $WorkItemStore.Query($QueryText)

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
    $workitems | %{
        
		$rev = $_.revisions
		$cdate = $_.CreatedDate
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

		
		# Get the length of time the task as been in the queue
        $Timespan = New-TimeSpan -Start $cdate -End ($Now)
		
		if ($_.Fields['Work Item Type'].Value -eq "Deployment") {
            $Type = "WARM"
        } else {
            $Type = "RTO"
        }

        # Add generic output data to the output entry
        $OutputEntry = New-Object psobject
        $OutputEntry | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N0}" -f (($KPIThreshold.$Type - $Timespan.TotalMinutes)))
        $OutputEntry | Add-Member -MemberType noteproperty -Name "ID" -Value $_.ID
        $OutputEntry | Add-Member -MemberType noteproperty -Name "Title" -Value $_.Title
        $OutputEntry | Add-Member -MemberType noteproperty -Name "Type" -Value $Type

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

        $WarnThreshold = $NewKPIThreshold."$($Ticket.Type)" * .6
        $FailThreshold = $NewKPIThreshold."$($Ticket.Type)" * .4

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
    " _____ _____ _____       _ _ _ _____ _____ _____"
    "| __  |_   _|     |   / | | | |  _  | __  |     |"
    "|    -| | | |  |  |  /  | | | |     |    -| | | |"
    "|__|__| |_| |_____| /   |_____|__|__|__|__|_|_|_| `n"
    
    Write-Host "Last Execution: " (Get-Date)
    ""

    "{0,-8}  {1,4}  {2,4}  {3,-20}" -f ("ID", "KPI", "Type", "Title")
    "{0,-8}  {1,4}  {2,4}  {3,-20}" -f ("--------", "----", "----", "----------")

    $OutputData  | sort-object -property Time -Descending | %{
         "{0,-8}  {1,4}  {2:N0,4}  {3,-20}" -f ($_.ID, $_.Time, $_.Type, $_.Title)
    }


    # "Incidents that successfully got saved to carry over:"
    # $Global:IncidentList
   
}


while($true)
{
    $sleepDuration = 20
    
    ##############
    ### QUERY IcM
    ##############

    Get-RTOTasks $TFSQuery

    #Write-Host "Sleeping for $sleepDuration seconds"
    Start-Sleep -Seconds $sleepDuration
}