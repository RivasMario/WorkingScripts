<#

    Updates

		1.0.0 - 7/20/2017 - v-pemic
			-Script created
		

#>

$Host.UI.RawUI.BackgroundColor = 'Black'

$version = "1.0.0"

$host.ui.RawUI.WindowTitle = "SQL - Version: $version"

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
                [System.WorkItemType] = 'DeploymentTask' AND
                ([System.State] in ('Pending', 'deploying', 'on-hold', 'blocked') OR
                [System.State] in ('Triage', 'investigate')) AND
                [System.Title] Contains 'cab'
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
        $regpat = '\[Step \d+ \w+ (Cab \d+ \w+ \S+)\](\[\S+\])'
        $RawTitle -match $regpat
        try{
            $front = $Matches[1]}
        catch{
            $front = ''}
        try{
            $back = $Matches[2]}
        catch{
            $back = ''}

        if ($back -match 'Manual'){
            $appendedtitle = $front + ' - ' + $back}
        else{
            $appendedtitle = $front}

        $state = $_.fields["State"].Originalvalue

        switch($state){

           'Deploying'{$sortnum = 0}
           'on-hold'{$sortnum = 1}
           'Blocked'{$sortnum = 2}
           'pending'{$sortnum = 3}
           }

        $OutputEntry = New-Object psobject
        $OutputEntry | Add-Member -MemberType noteproperty -Name "AssignedTo" -Value $AssignedTo[0]
        $OutputEntry | Add-Member -MemberType noteproperty -Name "State" -Value $state
        $OutputEntry | Add-Member -MemberType noteproperty -Name "ID" -Value $_.ID
        $OutputEntry | Add-Member -MemberType noteproperty -Name "Title" -Value $appendedtitle
        $OutputEntry | Add-Member -MemberType NoteProperty -Name "sortby" -Value $sortnum

        $OutputData += $OutputEntry

    }



    # Assume we're passing (nothing to display)
    $Status = "pass"


   Clear-Host
                   
" _____ _____ __    "
"|   __|     |  |   "
"|__   |  |  |  |__ "
"|_____|__  _|_____|"
"         |__|      `n"
               
    Write-Host "Last Execution: " (Get-Date)
    ""

    "{0,-8}  {1,-10}  {2,-25}  {3,-20}" -f ("ID", "State", "AssignedTo", "Title")
    "{0,-8}  {1,-10}  {2,-25}  {3,-20}" -f ("--------", "------", "----------", "----------")


    $OutputData | Sort-Object -Property 'sortby' | %{

        $Writeline = "{0,-8}  {1,-10}  {2,-25}  {3,-20}" -f ($_.ID, $_.State, $_.AssignedTo, $_.Title)
        if ($_.State -eq 'Deploying'){
            Write-Host $Writeline -ForegroundColor green}
        elseIf ($_.State -eq 'pending'){
            Write-Host $Writeline -ForegroundColor yellow}
        elseIf ($_.State -eq 'Blocked'){
            Write-Host $Writeline -ForegroundColor Red}
        elseIf ($_.State -eq 'on-hold'){
            Write-Host $Writeline -ForegroundColor Cyan}

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