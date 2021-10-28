<#

    Updates
        
  		1.0.0 - 8/29/2018 - v-jospr
			-Script created to track AIRS tasks
            -Includes tickets that need approval and ticket that need to be worked

#>

$version = "1.0.0"

$host.ui.RawUI.WindowTitle = "AIRS - Version: $version"

try{
	Import-Module C:\TFS\mod-tfs.psm1
}
catch{
	wa -LoadFromLocal
	Write-Progress -Activity "This is needed to clear the progress bar"
	Write-Progress -Completed "This is needed to clear the progress bar"
}

$KPIDefinition = @{
    "0" = New-TimeSpan -Minutes 1440;
    "1" = New-TimeSpan -Minutes 1440;
    "2" = New-TimeSpan -Minutes 1440;
    "3" = New-TimeSpan -Minutes 1440;
    "4" = New-TimeSpan -Minutes 1440
}

# All tasks that are not approved
$TFSToApproveQuery = "SELECT [System.Id]
            FROM WorkItems 
            WHERE 
                [System.TeamProject] = 'Fairfax' AND 
                [System.WorkItemType] = 'RDTask' AND
                [System.Title] contains 'Provision' AND

                [System.State] = 'Active' AND
                [Microsoft.RD.KeywordSearch] not contains 'WADE_RTO' AND
                (
                    
			        [System.AssignedTo] = 'WADE' or 
                        
                    [System.AssignedTo] = 'WALS' or 
                    
			        [System.AssignedTo] = 'WA Deployment Core' or 
                    
			        [System.AssignedTo] = 'WA Deployment Engineering' or 
					
					[System.AssignedTo] = 'Windows Azure Livesite' or
                    
			        [System.AssignedTo] = 'Fairfax Partner Operations'
                ) AND
                ([Microsoft.RD.KeywordSearch] contains 'AIRSSub' OR
                [Microsoft.RD.KeywordSearch] contains 'FF_AIRSSub')
            ORDER BY [Microsoft.Azure.Incident.Severity], [System.ID]"


Function Get-AIRSTasks()
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

    # Load TFS Querys
    $Appitems = $WorkItemStore.Query($TFSToApproveQuery)

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

    $Appitems | %{
        
		$rev = $_.revisions
		$cdate = $_.CreatedDate
		$teams = 'WA Deployment Core', 'WA Deployment Engineering', 'WA Deployment Platform Services', 'WADE', 'WALS'

		$rev | %{$revdate = $_.fields['Changed Date'].Value
	
			$AssignedTo = $_.fields['Assigned To'].Value
			$PStatus = $_.fields["Work Status"].Originalvalue
			$PAssTo = $_.fields["Assigned To"].Originalvalue
			$PState = $_.fields["State"].Originalvalue

			if ($teams -contains $AssignedTo -AND !($teams -contains $PAssTo)){
				if($revdate -gt $cdate){$cdate = $revdate}}
			if ($AssignedTo -match "Accenture" -AND $PStatus -eq "Blocked"){
				if($revdate -gt $cdate){$cdate = $revdate}}
			if ($AssignedTo -match "Accenture" -AND $Pstate -eq "Resolved"){
				if($revdate -gt $cdate){$cdate = $revdate}}
			}


        # Timespan is how long the individual task has been in the saved task list.
        $Timespan = New-TimeSpan -Start $cdate -End ($Now)

        $KPIThreshold = $KPIDefinition."$($_.fields['Priority'].Value)".TotalMinutes

        $OutputEntry = New-Object psobject
        $OutputEntry | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N0}" -f (($KPIThreshold - $Timespan.TotalMinutes)))
        $OutputEntry | Add-Member -MemberType noteproperty -Name "TimeSortable" -Value ($KPIThreshold - $Timespan.TotalMinutes)
        $OutputEntry | Add-Member -MemberType noteproperty -Name "KPIThreshold" -Value $KPIThreshold
        $OutputEntry | Add-Member -MemberType noteproperty -Name "ID" -Value $_.ID
        $OutputEntry | Add-Member -MemberType noteproperty -Name "Title" -Value $_.Title
        $OutputEntry | Add-Member -MemberType noteProperty -Name "State" -Value "Active"

        $OutputData += $OutputEntry

        #write-host "$("{0:N}" -f ($Timespan.TotalSeconds - $KPIDefinition["WADE"]["Time To Acknowledge"]["3"].TotalSeconds))   $($Details.ID)   $($Details.Title)"

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
                                 
" _____ _____ _____ _____  " 
"|  _  |_   _| __  |   __|" 
"|     |_| |_|    -|__   |"
"|__|__|_____|__|__|_____|`n"
    
    Write-Host "Last Execution: " (Get-Date)
    ""

    "{0,-8}  {1,14}  {2,5}  {3,-20}" -f ("ID", "State", "KPI", "Title")
    "{0,-8}  {1,14}  {2,5}  {3,-20}" -f ("--------", "-------", "-----", "----------")


    $TitleLengthLimit = 45
    $OutputData | Sort-Object -Property @{Expression = "State"; Descending = $True}, @{Expression = "TimeSortable"; Descending = $False} | %{
        if ($_.Title.Length -lt $TitleLengthLimit) {
            $TitleLengthLimit = $_.Title.Length
        }
        "{0,-8}  {1,14}  {2,5}  {3,-20}" -f ($_.ID, $_.State, $_.Time, $_.Title.Substring(0, $TitleLengthLimit))
    }
  
}

while($true)
{
    $sleepDuration = 30
    
    ##############
    ### QUERY TFS
    ##############

    Get-AIRSTasks

    #Write-Host "Sleeping for $sleepDuration seconds"
    Start-Sleep -Seconds $sleepDuration
}