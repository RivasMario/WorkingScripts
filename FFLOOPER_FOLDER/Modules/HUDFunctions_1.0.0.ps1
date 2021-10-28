
$KPIDefinition = @{

    "WALS" = @{
        "Time To Triage" = @{
            "0" = New-TimeSpan -Minutes 5;
            "1" = New-TimeSpan -Minutes 5;
            "2" = New-TimeSpan -Minutes 5;
            "3" = New-TimeSpan -Minutes 5;
            "4" = New-TimeSpan -Minutes 5
        }
    
        "Time To Engagement" = @{
            "0" = New-TimeSpan -Minutes 10;
            "1" = New-TimeSpan -Minutes 10;
            "2" = New-TimeSpan -Minutes 10;
            "3" = New-TimeSpan -Minutes 15;
            "4" = New-TimeSpan -Minutes 1440
        }
        
        "Time To Escalate Or Mitigate" = @{
            "0" = New-TimeSpan -Minutes 15;
            "1" = New-TimeSpan -Minutes 15;
            "2" = New-TimeSpan -Minutes 60;
            "3" = New-TimeSpan -Minutes 240;
            "4" = New-TimeSpan -Minutes 4320
        }
    }

    "WADE" = @{
        "Time To Triage" = @{
            "0" = New-TimeSpan -Minutes 10;
            "1" = New-TimeSpan -Minutes 10;
            "2" = New-TimeSpan -Minutes 10;
            "3" = New-TimeSpan -Minutes 15;
            "4" = New-TimeSpan -Minutes 15
        }

        "Time To Engagement" = @{
            "0" = New-TimeSpan -Minutes 10;
            "1" = New-TimeSpan -Minutes 10;
            "2" = New-TimeSpan -Minutes 15;
            "3" = New-TimeSpan -Minutes 360;
            "4" = New-TimeSpan -Minutes 1440
        }
    
        "Time To Escalate Or Mitigate" = @{
            "0" = New-TimeSpan -Minutes 10;
            "1" = New-TimeSpan -Minutes 10;
            "2" = New-TimeSpan -Minutes 60;
            "3" = New-TimeSpan -Minutes 720;
            "4" = New-TimeSpan -Minutes 720
        }
    }

"WASU" = @{
        "Time To Triage" = @{
            "0" = New-TimeSpan -Minutes 10;
            "1" = New-TimeSpan -Minutes 10;
            "2" = New-TimeSpan -Minutes 10;
            "3" = New-TimeSpan -Minutes 15;
            "4" = New-TimeSpan -Minutes 15
        }
    }

}


Function Get-KPIStatus {
    Param(
        [Parameter(Mandatory=$True)]$TicketList
    )

    # Assume we're passing
    $Status = "pass"

    # Check to see if we have any tickets to display
    if ($stats.count -gt 0) {
        $Status = "new"
    }

    # Calc what we should show individually, and pick the worst
    foreach ($Ticket in $TicketList) {

        $WarnThreshold = -$Ticket.Threshold * .25
        $FailThreshold = -$Ticket.Threshold * .1

        if ($Ticket.KPI -gt $FailThreshold) {
            $Status = "fail"

            # First fail we get we can break out
            Return $Status

        } elseif ($Ticket.KPI -gt $WarnThreshold) {
            $Status = "warn"
        }

    }

    Return $Status

}

Function Set-UIColors {
    Param(
        [Parameter(Mandatory=$True)]$Status
    )
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

        Defualt {
            Throw "Unknown Status recorded: $Status.  Valid values are warn, fail, new, or pass.  Please contact the script owner to debug."
        }

    }

}

# Feed this an execution policy and it will verify that it is set, or throw an error if it's not set.  Defaults to Unrestricted.  Only changes for current user
Function Verify-ExecutionPolicy {
    Param(
        [string]$ExecutionPolicy="Unrestricted"
    )

    $quiet = $error.Clear()

    $CurrentExecutionPolicy = Get-ExecutionPolicy

    if ($CurrentExecutionPolicy -ne $ExecutionPolicy) {

        switch ($ExecutionPolicy) {

            "Unrestricted" { Set-ExecutionPolicy Unrestricted -Scope CurrentUser }
            "AllSigned"    { Set-ExecutionPolicy AllSigned -Scope CurrentUser }
            "RemoteSigned" { Set-ExecutionPolicy RemoteSigned -Scope CurrentUser }
            "Restricted"   { Set-ExecutionPolicy Restricted -Scope CurrentUser }
            default { Set-ExecutionPolicy Unrestricted -Scope CurrentUser }

        }

        if ($error.Count -gt 0) {
            Throw "Failed to set Execution Policy from $CurrentExecutionPolicy to $ExecutionPolicy.  Please set Execute Policy with 'Set-ExecutionPolicy $ExecutionPolicy"
        }

    }

}

Function Check-WA-Tools {
    if (test-path Alias:wa) {
	    wa -loadfromlocal
    } else {
        if (Test-Path \\phx.gbl\public\wautil\public\tools\powershell\start-windowsazure.ps1) {
            \\phx.gbl\public\wautil\public\tools\powershell\start-windowsazure.ps1
        } else {
            Throw "Unable to load Azure Powershell toolset.  Please download WA Tools manually, then re-try"
        }
    }
}





Function Get-TicketHUDStats {
    Param(
        [Parameter(Mandatory=$True)]$Ticket,
        [Parameter(Mandatory=$True)]$Role,
        [Parameter(Mandatory=$True)]$KPIName
    )
    
    switch ($KPIName) {
        "TimeToEscalateOrMitigate" {
            $TicketData = Get-TimeToEscalateOrMitigate -ticket $Ticket -Role $Role
        }
        "TimeToEngage" {
            $TicketData = Get-TimeToEngageData -ticket $Ticket -Role $Role
        }
        "TimeToTriage" {
            $TicketData = Get-TimeToTriageData -ticket $Ticket -Role $Role
        }
    }
         
    # If the KPI has not been triggered, then we want to return data
    if (!$TicketData.Time) {
                
        $Time = "{0:N2}" -f (((Get-Date) - $TicketData."Created Date").TotalMinutes - $TicketData."Threshold")

        $TicketData | Add-Member -MemberType noteproperty -Name "TimeLong" -Value ([double]$Time)
        $TicketData | Add-Member -MemberType noteproperty -Name "Time" -Value ([int]$Time)



        if (([int]$TicketData."Severity") -le 2) {
            $TicketData."Threshold" = 1000
        }

        return $TicketData

    } 

    return $null

}


Function Get-GenericTicketDetails {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $Result = New-Object psobject

    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID'].Value
    $Result | Add-Member -MemberType noteproperty -Name "Title" -Value $Ticket.Fields['Title'].Value
    $Result | Add-Member -MemberType noteproperty -Name "Severity" -Value $Ticket.Fields['IncidentSeverity'].Value
    $Result | Add-Member -MemberType noteproperty -Name "Created Date" -Value $Ticket.Fields['Created Date'].Value

    # Assume severity 4 if it isn't set in the ticket.
    if ($Result."Severity" -eq "") {
        $Result."Severity" = "4"
    }

    return $Result

}

Function Get-TimeToTriageData {
    Param(
        [Parameter(Mandatory=$True)]$Ticket,
        [Parameter(Mandatory=$True)]$Role
    )
    $function = "Get-TimeToTriage:"

    Write-Debug "$function Entering"
    $KPIName = "Time To Triage"

    $Result = Get-GenericTicketDetails -Ticket $Ticket
    $Result | Add-Member -MemberType noteproperty -Name "Threshold" -Value $KPIDefinition["$Role"]["$KPIName"][$Result.'Severity'.ToString()].TotalMinutes

    ForEach ($Revision in $Ticket.revisions) {
        
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 1: " + $Revision.fields['State'].OriginalValue + " == Triage")
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 2: " + $Revision.fields['State'].Value + " == Investigate")

        if ($Revision.fields['State'].OriginalValue -eq "Triage" -and $Revision.fields['State'].Value -eq "Investigate") {
            Write-Debug "$function KPI Triggered"
            
            $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            $Result | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N2}" -f $Time.TotalMinutes)

            # If we get here, we fail, break out of the loop
            break
         
        }
    }

    Write-Debug "$function Exiting"
    return $Result

}


Function Get-TimeToEngageData {
    Param(
        [Parameter(Mandatory=$True)]$Ticket,
        [Parameter(Mandatory=$True)]$Role
    )
    $function = "Get-TimeToEngage:"

    Write-Debug "$function Entering"
    $KPIName = "Time To Engagement"

    $Result = Get-GenericTicketDetails -Ticket $Ticket
    $Result | Add-Member -MemberType noteproperty -Name "Threshold" -Value $KPIDefinition["$Role"]["$KPIName"][$Result.'Severity'.ToString()].TotalMinutes

    ForEach ($Revision in $Ticket.revisions) {
        
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 1: " + $Revision.fields['Assigned To'].OriginalValue + " /= " + $Revision.fields['Assigned To'].Value)
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 2: " + $Revision.fields['Assigned To'].Value + " CONTAINS Lockheed")
        
        if ($Revision.fields['Assigned To'].OriginalValue -ne $Revision.fields['Assigned To'].Value -and $Revision.fields['Assigned To'].Value -like "*Lockheed*") {
            Write-Debug "$function KPI Triggered"
            
            $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            $Result | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N2}" -f $Time.TotalMinutes)

            break
         
        }
    }

    Write-Debug "$function Exiting"
    return $Result

}


Function Get-TimeToResolve {
    Param(
        [Parameter(Mandatory=$True)]$Ticket,
        [Parameter(Mandatory=$True)]$Role
    )
    $function = "Get-TimeToResolve:"

    Write-Debug "$function Entering"
    $KPIName = "Time To Escalate Or Mitigate"

    $Result = Get-GenericTicketDetails -Ticket $Ticket
    $Result | Add-Member -MemberType noteproperty -Name "Threshold" -Value $KPIDefinition["$Role"]["$KPIName"][$Result.'Severity'.ToString()].TotalMinutes

    ForEach ($Revision in $Ticket.revisions) {
    
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 1: " + $Revision.fields['State'].OriginalValue + " == Investigate")
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 2: " + $Revision.fields['State'].Value + " == Mitigate or Resolved")

        if ($Revision.fields['State'].OriginalValue -eq 'Investigate' -and ($Revision.fields['State'].Value -eq 'Mitigate' -or $Revision.fields['State'].Value -eq 'Resolved')) {
            Write-Debug "$function KPI Triggered"
            
            $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            $Result | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N2}" -f $Time.TotalMinutes)

            break
         
        }
    }

    Write-Debug "$function Exiting"
    return $Result

}

Function Get-TimeToEscalate {
    Param(
        [Parameter(Mandatory=$True)]$Ticket,
        [Parameter(Mandatory=$True)]$Role
    )
    $function = "Get-TimeToEscalate:"

    Write-Debug "$function Entering"
    $KPIName = "Time To Escalate Or Mitigate"

    $Result = Get-GenericTicketDetails -Ticket $Ticket
    $Result | Add-Member -MemberType noteproperty -Name "Threshold" -Value $KPIDefinition["$Role"]["$KPIName"][$Result.'Severity'.ToString()].TotalMinutes

    ForEach ($Revision in $Ticket.revisions) {

        $RevID = $Revision.Index
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 1: " + $Revision.fields['EscalationStatus'].OriginalValue + " == ")
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 2: " + $Revision.fields['EscalationStatus'].Value + " == 1. Contacted")

        if ($Revision.fields['EscalationStatus'].OriginalValue -eq '' -and $Revision.fields['EscalationStatus'].Value -eq "1. Contacted") {
            Write-Debug "$function KPI Triggered"
            
            $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            $Result | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N2}" -f $Time.TotalMinutes)

            break
         
        }
    }

    Write-Debug "$function Exiting"
    return $Result

}

Function Get-TimeToEscalateOrMitigate {
    Param(
        [Parameter(Mandatory=$True)]$Ticket,
        [Parameter(Mandatory=$True)]$Role
    )
    $function = "Get-TimeToEscalateOrMitigate:"

    # Get time to mitigate/resolve
    $TimeToResolve = Get-TimeToResolve -Ticket $Ticket -Role $Role

    # Get time to escalate:
    $TimeToEscalate = Get-TimeToEscalate -Ticket $Ticket -Role $Role

    if (!$TimeToResolve.Time -and !$TimeToEscalate.Time) {
        return $TimeToResolve
    } elseif ($TimeToResolve.Time) {
        return $TimeToResolve
    } elseif ($TimeToEscalate.Time) {
        return $TimeToEscalate
    }

}

Function Get-TimeToTrackingTeamSet {
    Param(
        [Parameter(Mandatory=$True)]$Ticket,
        [Parameter(Mandatory=$True)]$Role
    )

    $Result = New-Object psobject
    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID'].Value

    # Need to get Time to Triage to determine who should have set the value
    $TimeToTriage = Get-TimeToTriage -Ticket $Ticket -Role $Role
    $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value $TimeToTriage.Operator

    ForEach ($Revision in $Ticket.revisions) {
        
        if ($Revision.fields['Owner Team'].Value -eq 'Windows Azure Operations Center/WALS') {

            $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            
            $Result | Add-Member -MemberType noteproperty -Name "Time" -Value $Time

            # Note: need a pass/fail for if the person doesn't change it at triage time

            return $Result
            
        }

    }

    return $Result

}

Function Get-EscortTTS {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $Result = New-Object psobject
    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID'].Value
    
    $EventTime = $Ticket.fields['Event Time'].Value
    $CurrentTime = Get-Date

    If (!$EventTime) {
        $EventTime = $Ticket.Fields['Created Date'].Value
    }

    $TTS = new-timespan -Start $EventTime -End $CurrentTime

    $Result | Add-Member -MemberType noteproperty -Name "Time" -Value $TTS

    return $Result

}

Function Get-ResponsibleShift {
    Param(
        [Parameter(Mandatory=$True)]$CreatedDate
    )

    switch ($CreatedDate.Hour) {

        {(( $_ -ge 0  ) -and ( $_ -lt 6  ))}  { return "Night" }
        {(( $_ -ge 6  ) -and ( $_ -lt 14 ))}  { return "Day"   }
        {(( $_ -ge 14 ) -and ( $_ -lt 22 ))}  { return "Swing" }
        {(( $_ -ge 22 ) -and ( $_ -le 24 ))}  { return "Night" }
        

    }

}

