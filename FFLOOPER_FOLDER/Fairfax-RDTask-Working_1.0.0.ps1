<#

    Updates

		1.0.0 - 7/20/2017 - v-pemic
			-Script created
		

#>

$Host.UI.RawUI.BackgroundColor = 'Black'

$version = "1.0.0"

$host.ui.RawUI.WindowTitle = "RDTask Working - Version: $version"

try{
	Import-Module C:\TFS\mod-tfs.psm1
}
catch{
	wa -LoadFromLocal
	Write-Progress -Activity "This is needed to clear the progress bar"
	Write-Progress -Completed "This is needed to clear the progress bar"
}


$TFSQuery = "SELECT [System.Id]
            FROM WorkItems 
            WHERE 
                 [System.TeamProject] = 'Fairfax' AND 
                 [System.WorkItemType] = 'RDTask' AND  
                 [Microsoft.VSTS.Common.Triage] = 'Approved' AND
                 [Microsoft.Azure.WorkStatus] = 'In Progress' AND 
                 [System.State] = 'Active' AND

                 (
                  [System.AssignedTo] contains 'Lockheed' OR
                  [System.AssignedTo] contains 'Accenture' OR
                  [System.AssignedTo] contains 'Leidos'
                  ) AND

                  (
                  [Microsoft.RD.KeywordSearch] contains 'WADECORE' OR
                  [Microsoft.RD.KeywordSearch] contains 'PFGold_Replication' OR
                  [Microsoft.RD.KeywordSearch] contains 'FairfaxDoD'
                  ) AND

                  [System.CreatedDate] >= @today - 40
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


    #$workitems = Compare-Object -ReferenceObject $excludeworkitems -DifferenceObject $allworkitems -PassThru

    # Check for errors with the query
    if ($error.Count -gt 0) {

        Clear-Host

        Write-Host "TFS Connection appears to be down, please check TFS!"

        return

    } 
    
    $Now = Get-Date

    $OutputData = @()

    # Now add the incident details to a table to display/sort/etc
    $workitems | %{
		
        $AssignedTo = $_.fields['Assigned To'].Value.split('(')
        $RawTitle = $_.Title

        $state = $_.fields["State"].Originalvalue


        $OutputEntry = New-Object psobject
        $OutputEntry | Add-Member -MemberType noteproperty -Name "AssignedTo" -Value $AssignedTo[0]
        $OutputEntry | Add-Member -MemberType noteproperty -Name "State" -Value $state
        $OutputEntry | Add-Member -MemberType noteproperty -Name "ID" -Value $_.ID
        $OutputEntry | Add-Member -MemberType noteproperty -Name "Title" -Value $RawTitle

        $OutputData += $OutputEntry

    }



    # Assume we're passing (nothing to display)
    $Status = "pass"


   Clear-Host
                                                              
" _____ ____  _____         _      _ _ _         _   _         "
"| __  |    \|_   _|___ ___| |_   | | | |___ ___| |_|_|___ ___ "
"|    -|  |  | | | | .'|_ -| '_|  | | | | . |  _| '_| |   | . |"
"|__|__|____/  |_| |__,|___|_,_|  |_____|___|_| |_,_|_|_|_|_  |"
"                                                         |___|`n"
               
    Write-Host "Last Execution: " (Get-Date)
    ""

    "{0,-8}  {1,-10}  {2,-25}  {3,-20}" -f ("ID", "State", "AssignedTo", "Title")
    "{0,-8}  {1,-10}  {2,-25}  {3,-20}" -f ("--------", "------", "----------", "----------")

    $TitleLengthLimit = 70
    $OutputData | Sort-Object -Property 'ID' | %{
        if ($_.Title.Length -lt $TitleLengthLimit) {
            $TitleLengthLimit = $_.Title.Length}
        $Writeline = "{0,-8}  {1,-10}  {2,-25}  {3,-20}" -f ($_.ID, $_.State, $_.AssignedTo, $_.Title.Substring(0, $TitleLengthLimit))
        if ($_.State -eq 'Active'){
            Write-Host $Writeline -ForegroundColor green}
        else{
            Write-Host $Writeline}           
    } 
 
}

while($true)
{
    $sleepDuration = 90
    
    ##############
    ### QUERY IcM
    ##############

    Get-RTOTasks

    #Write-Host "Sleeping for $sleepDuration seconds"
    Start-Sleep -Seconds $sleepDuration
}