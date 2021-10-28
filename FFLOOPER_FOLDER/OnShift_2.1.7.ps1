<#

    Updates	
        
        7/22/2018 - v-pemic
            -Added 'TFO OOS' status handeling.

        3/12/2018 - v-pemic
            -Changed sort order for Other
	
		3/12/2018 - v-pemic
            -Added SME team
			
        3/12/2018 - v-pemic
            -Removed Physical Escorts from the In Flight list

		2/26/2018 - v-pemic
			-Added variable for color change for AFK and updated that to black when the background is green
			
		9/7/2017 - v-pemic 	- 	Script created

        10/29/2017 - v-pemic
            -Changed timeout to remove Operatore from OnLine list from 5 min to 1 min.
	
		1/1/2018 - v-pemic
			-Script no longer pulled RST data from SQL.  Data is pulled directly from OpStatus tool.
		10/10/19 - v-jospr
			-updated to allow Escort Anchor and add Lead as a team
#>

$version = "2.1.7"

$host.ui.RawUI.WindowTitle = "OnShift - Version: $version"

#Runs query to find operators that are curently online
Function Get-EscortTimeTS {
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

Function Get-OnLine(){

	#Creates DB conection
	$PowerBIServer   = "fairfaxopsteamdatabase.database.windows.net"
	$PowerBIDatabase = "FairfaxOpsTeamDatabase"
	$PowerBITable    = "Escort_Status"
	$PowerBIUsername = "EscortUser"
	$PowerBIPassword = 'u!UX$W$5`5'
	#old password = "5k!cWj22nRz:43O8"
	$PowerBIConnectionTimeout = 60
	$PowerBIConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Encrypt=True;Connect Timeout={4}" -f $PowerBIServer,$PowerBIDatabase,$PowerBIUsername,$PowerBIPassword,$PowerBIConnectionTimeout
	
	#SQL query.  Find operators that have updated the DB in the last 5 min.
	$SQLQuery = "
			SELECT UserName, LastLogin, Team, UserStatus, Anc, RST
			FROM Escort_Status
			WHERE LastLogin > DATEADD(minute, -1,  GETUTCDATE())"
			
	#Create data table
	$Data = New-Object System.Data.DataTable

	#Connect to the DB
	$PowerBIConnection = New-Object System.Data.SQLClient.SQLConnection
	$PowerBIConnection.ConnectionString = $PowerBIConnectionString
	$PowerBIConnection.Open()

	#Run the query and load the data to the data table
	$QueryCmd = New-Object System.Data.SQLClient.SQLCommand
	$QueryCmd.Connection  = $PowerBIConnection
	$QueryCmd.CommandText = $SQLQuery
	$Reader = $QueryCmd.ExecuteReader()
	$Data.Load($Reader)
	$PowerBIConnection.Close()		

    $OnLineList = @()

    $data | %{
    
        $operator = $_.Username.trim()
        $team = $_.Team
		$status = $_.UserStatus
		$anc = $_.Anc
        $rst = $_.RST

        switch ($anc) {
            "Lead"{$ancsort = 0}
			"Anchor"{$ancsort = 1}
            ""{$ancsort = 2}
            "Training"{$ancsort = 3}
            default{"4"}
        }
		
        $onlineinfo = New-Object psobject
		$onlineinfo | Add-Member -MemberType noteproperty -Name	"operator" $operator
		$onlineinfo | Add-Member -MemberType noteproperty -Name "team" -Value $team
        $onlineinfo | Add-Member -MemberType noteproperty -Name "status" -Value $status
        $onlineinfo | Add-Member -MemberType noteproperty -Name "anc" -Value $anc
        $onlineinfo | Add-Member -MemberType noteproperty -Name "ancsort" -Value $ancsort
        $onlineinfo | Add-Member -MemberType noteproperty -Name "los" -Value $rst

        $OnLineList += $onlineinfo    

        }

	return $OnLineList
}

Function DisplayHud() {

    $quiet = $error.Clear()

	#Connect to TFS
	try
	{
		Connect-AzureTfs | Out-Null
		$WorkItemStore = Connect-AzureTfs
	}
	catch
	{
		$WorkItemStore = Connect-AzureTfs -TfsUri https://vstfrd:443
		#http://vstfrd:8080
		$error.Clear()
	}

    #Find new Escort tickets
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

	#Find all escorts tickets in flight
    $InFlight = $WorkItemStore.Query(
        "SELECT [System.Id] 
        FROM WorkItems 
        WHERE 
            [System.TeamProject] = 'Fairfax' AND 
            [System.WorkItemType] = 'Escort Request' AND
            [System.State] = 'Escorting Started' AND
            [System.Title] not contains 'Physical Escort' AND
            [System.Title] not contains 'Physical Fairfax Escort'
        ORDER BY [System.CreatedDate]")

    # Check for errors with the query
    #if ($error.Count -gt 0) {

     #   $Host.UI.RawUI.BackgroundColor = 'Red'
      #  $Host.UI.RawUI.ForegroundColor = 'White'
       # Clear-Host
        #Write-Host "TFS Connection appears to be down, please check TFS!"
        #return

    #} 
	
    #Process New Escort tickets

    $ESOutputData = @()

    $NewTickets | %{ 
        
        $ID = $_.ID
        $Title = $_.Title
        $TTS = Get-EscortTimeTS -Ticket $_
        $State = "New"
        $Severity = $_.fields['IncidentSeverity'].Value

        $ticketinfo = New-Object psobject
        $ticketinfo | Add-Member -MemberType noteproperty -Name "ID" -Value $id
        $ticketinfo | Add-Member -MemberType noteproperty -Name "Title" -Value $title
        $ticketinfo | Add-Member -MemberType noteproperty -Name "TTS" -Value ([int]("{0:N0}" -f $TTS))
        $ticketinfo | Add-Member -MemberType noteproperty -Name "State" -Value $State
        $ticketinfo | Add-Member -MemberType noteproperty -Name "Severity" -Value $Severity

        $ESOutputData += $ticketinfo    
    
    }

    $ScheduledTickets | %{ 

        $ID = $_.ID
        $Title = $_.Title
        $TTS = Get-EscortTimeTS -Ticket $_
        $State = "Sched"
        $Severity = $_.fields['IncidentSeverity'].Value

        $ticketinfo = New-Object psobject
        $ticketinfo | Add-Member -MemberType noteproperty -Name "ID" -Value $id
        $ticketinfo | Add-Member -MemberType noteproperty -Name "Title" -Value $title
        $ticketinfo | Add-Member -MemberType noteproperty -Name "TTS" -Value ([int]("{0:N0}" -f $TTS))
        $ticketinfo | Add-Member -MemberType noteproperty -Name "State" -Value $State
        $ticketinfo | Add-Member -MemberType noteproperty -Name "Severity" -Value $Severity

        $ESOutputData += $ticketinfo            

    }
    
    # Check Validations
    $WarnThreshhold = 0
    $FailThreshhold = 3

    $TStatus = "pass"
	$HS = "Red"
    $IFC = "Green"
    $WALSC = "Cyan"
    $WADEC = "Magenta"
    $EscortC = "Yellow"
	$AFKC = "DarkGray"
	$LeadC = "Blue"
	
    $HighestTTS = ($ESOutputData.TTS | Measure -Maximum).Maximum
  
    if ($HighestTTS -ne $null -and $HighestTTS -ge -30) {
        $TStatus = "new"
		$HS = "Yellow"
        $IFC = "White"
        $WALSC = "Cyan"
        $WADEC = "Yellow"
        $EscortC = "White"
		$AFKC = "Black"
		$LeadC = "Blue"
    }

    switch ($HighestTTS) {

        {$_ -ge $WarnThreshhold} {
            $TStatus = "warn"
			$HS = "Red"
            $IFC = "Black"
            $WALSC = "DarkCyan"
            $WADEC = 13
            $EscortC = "Black"
			$AFKC = "DarkGray"
			$LeadC = "Blue"
        }

        {$_ -ge $FailThreshhold} {
            $TStatus = "fail"
			$HS = "Yellow"
            $IFC = "White"
            $WALSC = "Cyan"
            $WADEC = 6
            $EscortC = "Black"
			$AFKC = "DarkGray"
			$LeadC = "Blue"
        }

    }

    #Get Online and Shift list data

    $OnLine = Get-OnLine
	
	$OutputData = @()
	
	#Populate $OutputData with $InFlight data
    $InFlight | %{ 
      
		$operator = $_.Fields['assigned to'].Value
        $ID = $_.ID
        $Severity = $_.Fields['IncidentSeverity'].Value
		$now = Get-Date
		$getdur =  New-TimeSpan -start $_.Fields['starttime'].Value -End $now
		$duration = [int]$getdur.TotalMinutes
		$getexp = $_.Fields['External Milestone'].Value
		switch($getexp)
		{
			"1.Less than 30 minutes"{$exp = "< 30"}
			"2.Between 30 minutes and 1 hour"{$exp = "30 - 60"}
			"3.Between 1 hour and 2 hours"{$exp = "60 - 120"}
			"4.Between 2 hours and 4 hours"{$exp = "120 - 240"}
			"5.Longer than 4 hours"{$exp = "> 240"}		
		}
		
        $ticketinfo = New-Object psobject
		$ticketinfo | Add-Member -MemberType noteproperty -Name	"operator" $operator.split('(')[0].trim()
		$ticketinfo | Add-Member -MemberType noteproperty -Name "duration" -Value $duration
        $ticketinfo | Add-Member -MemberType noteproperty -Name "ID" -Value $id
        $ticketinfo | Add-Member -MemberType noteproperty -Name "Severity" -Value $Severity
		$ticketinfo | Add-Member -MemberType noteproperty -Name "Exp" -Value $exp

        $OutputData += $ticketinfo    
    
    }
	

	#Create list that we can remove operators from while comparing $ShiftList to $OutputData
	$OnShift = {$OnLine}.Invoke()
	
	#Compare $Shiftlist to $OutputData.  Any duplicate operators are removed from the $OnShift list.
	Foreach ($op in $OnLine)
	{
		$OutputData | %{
			if ($_.operator -eq $op.operator)
			{
				$OnShift.Remove($op) | Out-Null
			}
		}	
	}
	
    Set-UIColors -Status $TStatus

    Clear-Host

    " _____ _____ _____ _____ _____ _____ "
    "|   __|   __|     |     | __  |_   _|"
    "|   __|__   |   --|  |  |    -| | |  "
    "|_____|_____|_____|_____|__|__| |_|  `n"
    Write-Host "Last Execution: " (Get-Date)
    ""

    "{0,-8}  {1,4}  {2,4}  {3,-8} {4,-20}" -f ("ID", "KPI", "Sev", "State", "Title")
    "{0,-8}  {1,4}  {2,4}  {3,-8} {4,-20}" -f ("--------", "----", "----", "------", "----------")        

    $ESOutputData | sort-object -property @{Expression = "Severity"; Descending = $False}, @{Expression = "TTS"; Descending = $True} | %{
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

    ""
    ""
    ""
    "  ___        ___ _ _      _   _   "
    " |_ _|_ _   | __| (_)__ _| |_| |_ "
    "  | || ' \  | _|| | / _` | ' \  _|"
    " |___|_||_| |_| |_|_\__, |_||_\__|"
    "                   |___/         	`n"		

    "{0,-23}  {1,-8}  {2,4} {3,6} {4,10}" -f ("Operator", "ID", "Sev", "Dur", "Exp")
    "{0,-23}  {1,-8}  {2,4} {3,6} {4,10}" -f ("--------", "--------", "----", "----", "----")        
	
	#Write data for all InFlight escorts
    $OutputData | sort-object -property @{Expression = "Severity"; Descending = $False}, @{Expression = "duration"; Descending = $True} | %{
            $writeline = "{0,-23}  {1,-8}  {2,4} {3,6} {4,10}" -f ($_.operator, $_.ID, $_.Severity, $_.duration, $_.exp)
			if($_.Severity -lt 3)
			{
				Write-Host $writeline -ForegroundColor $HS
			}
			else
			{
				Write-Host $writeline -ForegroundColor $IFC
			}
		}

    $OnShift | %{
            $writeline = "{0,-23}  {1,-8}" -f ($_.operator, $_.anc)
			if($_.anc -eq 'TFS OOS')
			{
                Write-Host $writeline -ForegroundColor $IFC
		    }
        }


    ""
    "   ___       _    _          "
    "  / _ \ _ _ | |  (_)_ _  ___ "
    " | (_) | ' \| |__| | ' \/ -_)"
    "  \___/|_||_|____|_|_||_\___|`n"		

    "{0,-23}  {1,-6}  {2,-10} {3,8} {4,5}" -f ("Operator", "Team", "Status", "Other", "RST")
    "{0,-23}  {1,-6}  {2,-10} {3,8} {4,5}" -f ("--------", "------", "--------", "------", "-----")        
	
	#Write data for all InFlight escorts
    $OnShift | sort-object -property @{Expression = "Status"; Descending = $True}, @{Expression = "Team"; Descending = $False}, @{Expression = "ANCsort"; Descending = $False}, @{Expression = "los"; Descending = $False} | %{
            $writeline = "{0,-23}  {1,-6}  {2,-10} {3,8} {4,5}" -f ($_.operator, $_.team, $_.status, $_.anc, $_.los)
			if($_.Team -eq "Escort" -AND $_.anc -ne 'TFS OOS')
			{
				if($_.status -eq "Online"){
                    Write-Host $writeline -ForegroundColor $EscortC}
			
			    else{
				    Write-Host $writeline -ForegroundColor $AFKC}
		    }

            if($_.Team -eq "WADE" -AND $_.anc -ne 'TFS OOS')
			{
				if($_.status -eq "Online"){
                    Write-Host $writeline -ForegroundColor $WADEC}
			
			    else{
				    Write-Host $writeline -ForegroundColor $AFKC}
		    }

            if($_.Team -eq "WALS" -or $_.Team -eq "SME" -AND $_.anc -ne 'TFS OOS')
			{
				if($_.status -eq "Online"){
                    Write-Host $writeline -ForegroundColor $WALSC}
			
			    else{
				    Write-Host $writeline -ForegroundColor $AFKC}
		    }
			
            if($_.Team -eq "Lead" -AND $_.anc -ne 'TFS OOS')
			{
				if($_.status -eq "Online"){
                    Write-Host $writeline -ForegroundColor $LeadC}
			
			    else{
				    Write-Host $writeline -ForegroundColor $AFKC}
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

$TFSModule = "C:\TFS\mod-tfs.psm1"
$TFSPath = "C:\TFS"

if(!(Test-Path $TFSModule)){
    
    if(!(Test-Path $TFSPath)){
        New-Item $TFSPath -type directory -Force | Out-Null}

    $TFSsource = "http://sharepoint/sites/CIS/waps/WAPartnerOps/Fairfax%20Documents/Fairfax/HUD%20Software/TFS.zip"
    $TFSdest = "$TFSPath\TFS.zip"
    $webClient = New-Object System.Net.WebClient
    $webClient.UseDefaultCredentials = $true
    $webClient.DownloadFile($TFSsource, $TFSdest)
    $TFSinstallpath = $TFSPath.Split("TFS")
    Expand-Archive $TFSdest $TFSinstallpath[0]
    Remove-Item $TFSdest
    }

Import-Module $TFSModule

$ScriptDirectory = split-path $MyInvocation.MyCommand.path
if($ScriptDirectory -match "\\archive"){
    $cd = $ScriptDirectory.Replace("\archive", "")
    $ScriptDirectory = $cd}

$getLatestMod = Get-ChildItem $ScriptDirectory\Modules\ | Where-Object {$_.Name -match ("HUDFunctions.*.ps1")} | Sort-Object $_.Name -Descending
$latestMod = $getLatestMod[0].Name

. $ScriptDirectory\Modules\$latestMod


while(1)
{
    DisplayHud
    Start-Sleep -Seconds 15
	
}
