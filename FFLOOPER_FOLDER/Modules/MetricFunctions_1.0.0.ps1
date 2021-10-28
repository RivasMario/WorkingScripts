
# Features:
#   Verify whether an incident escalation status was set correctly (detect change in assigned to and check for contacted flag)


$KPIDefinition = @{

    "WALS" = @{
        "Time To Triage" = @{
            "0" = New-TimeSpan -Minutes 10;
            "1" = New-TimeSpan -Minutes 10;
            "2" = New-TimeSpan -Minutes 10;
            "3" = New-TimeSpan -Minutes 10;
            "4" = New-TimeSpan -Minutes 10
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

}

Function Get-DeploymentTTS {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $Result = New-Object psobject
    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID']
    
    $EventTime = $Ticket.fields['Planned Start Date'].Value
    $CurrentTime = Get-Date

    If (!$EventTime) {
        $EventTime = $Ticket.Fields['Created Date'].Value
    }

    $TTS = new-timespan -Start $EventTime -End $CurrentTime

    $Result | Add-Member -MemberType noteproperty -Name "TTS" -Value $TTS

    return $Result

}

Function Get-HighestSeverity {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $HighestSeverity = 4

    ForEach ($Revision in $Ticket.revisions) {

        if ($Revision.fields['IncidentSeverity'].Value -ne "" -and ($Revision.fields['IncidentSeverity'].Value -as [int]) -lt $HighestSeverity) {
            $HighestSeverity = $Revision.fields['IncidentSeverity'].Value
        }

    }

    return $HighestSeverity

}

Function Get-GenericTicketDetails {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $Result = New-Object psobject

    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID'].Value
    $Result | Add-Member -MemberType noteproperty -Name "Created Date" -Value $Ticket.Fields['Created Date'].Value
    $Result | Add-Member -MemberType noteproperty -Name "Title" -Value $Ticket.Fields['Title'].Value
    $Result | Add-Member -MemberType noteproperty -Name "Highest Severity" -Value (Get-HighestSeverity -Ticket $Ticket)
    $Result | Add-Member -MemberType noteproperty -Name "State" -Value $Ticket.Fields['State'].Value
    $Result | Add-Member -MemberType noteproperty -Name "Shift" -Value (Get-ResponsibleShift -CreatedDate $Ticket.Fields['Created Date'].Value)

    $Result | Add-Member -MemberType noteproperty -Name "Miss Type" -Value $null
    $Result | Add-Member -MemberType noteproperty -Name "Updated Fields" -Value $null

    return $Result

}

Function Get-KPIResultsFromRevision {
    Param(
        [Parameter(Mandatory=$True)]$Revision,
        [Parameter(Mandatory=$True)]$Details
    )
    
    $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
    $KPIResult | Add-Member -MemberType noteproperty -Name "Time" -Value $Time

    if ($Time -le $KPIDefinition["$Role"]["$KPIName"]["$Severity"]) {
        # If we pass, set some fields and return

        if ($Revision.fields['Changed By'].Value -like "*Lockheed*") {
            $KPIResult | Add-Member -MemberType noteproperty -Name "Operator" -Value $Revision.fields['Changed By'].Value
            $KPIResult | Add-Member -MemberType noteproperty -Name "KPI" -Value $true
            return $Result
        }
                
    }

    $KPIResult | Add-Member -MemberType noteproperty -Name "Operator" -Value (Get-ResponsibleShift $Ticket.fields['Created Date'].Value)
    $KPIResult | Add-Member -MemberType noteproperty -Name "KPI" -Value $false

    return $KPIResult

}





Function MergePSObject {
    Param(
        [Parameter(Mandatory=$True)]$Left,
        [Parameter(Mandatory=$True)]$Right
    )


}

Function Get-TimeToTriage {
    Param(
        [Parameter(Mandatory=$True)]$Ticket,
        [Parameter(Mandatory=$True)]$Role
    )
    $function = "Get-TimeToTriage:"

    Write-Debug "$function Entering"
    $KPIName = "Time To Triage"

    $Result = Get-GenericTicketDetails -Ticket $Ticket

    $Result | Add-Member -MemberType noteproperty -Name "KPI Name" -Value $KPIName
    $Result | Add-Member -MemberType noteproperty -Name "KPI Definition" -Value $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()].TotalMinutes

    ForEach ($Revision in $Ticket.revisions) {
        
        $RevID = $Revision.Index
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 1: " + $Revision.fields['State'].OriginalValue + " == Triage")
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 2: " + $Revision.fields['State'].Value + " == Investigate")

        if ($Revision.fields['State'].OriginalValue -eq "Triage" -and $Revision.fields['State'].Value -eq "Investigate") {
            Write-Debug "$function KPI Triggered"
            
            #Get-KPIResultsFromRevision -Revision $Revision -Details $Result

            $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            $Result | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N2}" -f $Time.TotalMinutes)

            Write-Debug ("$function KPI Time Check: " + ("{0:N2}" -f $Time.TotalMinutes) + " <= " + $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()].TotalMinutes)
            # Check to see if we pass or fail
            if ($Time -le $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()]) {
                # If we pass, set some fields and return
                Write-Debug "$function KPI Time Check: Passed"

                if ($Revision.fields['Changed By'].Value -like "*Lockheed*") {
                    $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value $Revision.fields['Changed By'].Value
                    $Result | Add-Member -MemberType noteproperty -Name "KPI" -Value $true

                    Write-Debug "$function Exiting"
                    return $Result
                }
                
            } else {
                Write-Debug "$function KPI Time Check: Failed"
            }

            # If we get here, we fail, break out of the loop
            break
         
        }
    }
    # If we're here then we failed the KPI
    $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value (Get-ResponsibleShift $Ticket.fields['Created Date'].Value)
    $Result | Add-Member -MemberType noteproperty -Name "KPI" -Value $false

    Write-Debug "$function Exiting"
    return $Result

}


Function Get-TimeToEngage {
    Param(
        [Parameter(Mandatory=$True)]$Ticket,
        [Parameter(Mandatory=$True)]$Role
    )
    $function = "Get-TimeToEngage:"

    Write-Debug "$function Entering"
    $KPIName = "Time To Engagement"

    $Result = Get-GenericTicketDetails -Ticket $Ticket

    $Result | Add-Member -MemberType noteproperty -Name "KPI Name" -Value $KPIName
    $Result | Add-Member -MemberType noteproperty -Name "KPI Definition" -Value $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()].TotalMinutes

    ForEach ($Revision in $Ticket.revisions) {
        
        $RevID = $Revision.Index
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 1: " + $Revision.fields['Assigned To'].OriginalValue + " /= " + $Revision.fields['Assigned To'].Value)
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 2: " + $Revision.fields['Assigned To'].Value + " CONTAINS Lockheed")
        
        if ($Revision.fields['Assigned To'].OriginalValue -ne $Revision.fields['Assigned To'].Value -and $Revision.fields['Assigned To'].Value -like "*Lockheed*") {
            Write-Debug "$function KPI Triggered"
            
            #Get-KPIResultsFromRevision -Revision $Revision -Details $Result

            $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            $Result | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N2}" -f $Time.TotalMinutes)

            Write-Debug ("$function KPI Time Check: " + ("{0:N2}" -f $Time.TotalMinutes) + " <= " + $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()].TotalMinutes)
            # Check to see if we pass or fail
            if ($Time -le $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()]) {
                # If we pass, set some fields and return
                Write-Debug "$function KPI Time Check: Passed"

                if ($Revision.fields['Changed By'].Value -like "*Lockheed*") {
                    $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value $Revision.fields['Changed By'].Value
                    $Result | Add-Member -MemberType noteproperty -Name "KPI" -Value $true

                    Write-Debug "$function Exiting"
                    return $Result
                }
                
            } else {
                Write-Debug "$function KPI Time Check: Failed"
            }

            # If we get here, we fail, break out of the loop
            break
         
        }
    }
    # If we're here then we failed the KPI
    $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value (Get-ResponsibleShift $Ticket.fields['Created Date'].Value)
    $Result | Add-Member -MemberType noteproperty -Name "KPI" -Value $false

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

    $Result | Add-Member -MemberType noteproperty -Name "KPI Name" -Value $KPIName
    $Result | Add-Member -MemberType noteproperty -Name "KPI Definition" -Value $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()].TotalMinutes

    ForEach ($Revision in $Ticket.revisions) {
    
        $RevID = $Revision.Index
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 1: " + $Revision.fields['State'].OriginalValue + " == Investigate")
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 2: " + $Revision.fields['State'].Value + " == Mitigate or Resolved")

        if ($Revision.fields['State'].OriginalValue -eq 'Investigate' -and ($Revision.fields['State'].Value -eq 'Mitigate' -or $Revision.fields['State'].Value -eq 'Resolved')) {
            Write-Debug "$function KPI Triggered"
            
            #Get-KPIResultsFromRevision -Revision $Revision -Details $Result

            $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            $Result | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N2}" -f $Time.TotalMinutes)

            Write-Debug ("$function KPI Time Check: " + ("{0:N2}" -f $Time.TotalMinutes) + " <= " + $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()].TotalMinutes)
            # Check to see if we pass or fail
            if ($Time -le $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()]) {
                # If we pass, set some fields and return
                Write-Debug "$function KPI Time Check: Passed"

                if ($Revision.fields['Changed By'].Value -like "*Lockheed*") {
                    $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value $Revision.fields['Changed By'].Value
                    $Result | Add-Member -MemberType noteproperty -Name "KPI" -Value $true
                } else {
                    $Result | Add-Member -MemberType noteproperty -Name "KPI" -Value $true
                }

                Write-Debug "$function Exiting"
                return $Result
                
            } else {
                Write-Debug "$function KPI Time Check: Failed"
            }

            # If we get here, we fail, break out of the loop
            break
         
        }
    }
    # If we're here then we failed the KPI
    $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value (Get-ResponsibleShift $Ticket.fields['Created Date'].Value)
    $Result | Add-Member -MemberType noteproperty -Name "KPI" -Value $false

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

    $Result | Add-Member -MemberType noteproperty -Name "KPI Name" -Value $KPIName
    $Result | Add-Member -MemberType noteproperty -Name "KPI Definition" -Value $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()].TotalMinutes

    ForEach ($Revision in $Ticket.revisions) {

        $RevID = $Revision.Index
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 1: " + $Revision.fields['EscalationStatus'].OriginalValue + " == ")
        Write-Debug ("$function Revision Index $RevID KPI Trigger Check 2: " + $Revision.fields['EscalationStatus'].Value + " == 1. Contacted")

        if ($Revision.fields['EscalationStatus'].OriginalValue -eq '' -and $Revision.fields['EscalationStatus'].Value -eq "1. Contacted") {
            Write-Debug "$function KPI Triggered"
            
            #Get-KPIResultsFromRevision -Revision $Revision -Details $Result

            $Time = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            $Result | Add-Member -MemberType noteproperty -Name "Time" -Value ("{0:N2}" -f $Time.TotalMinutes)

            Write-Debug ("$function KPI Time Check: " + ("{0:N2}" -f $Time.TotalMinutes) + " <= " + $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()].TotalMinutes)
            # Check to see if we pass or fail
            if ($Time -le $KPIDefinition["$Role"]["$KPIName"][$Result.'Highest Severity'.ToString()]) {
                # If we pass, set some fields and return
                Write-Debug "$function KPI Time Check: Passed"

                if ($Revision.fields['Changed By'].Value -like "*Lockheed*") {
                    $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value $Revision.fields['Changed By'].Value
                    $Result | Add-Member -MemberType noteproperty -Name "KPI" -Value $true

                    Write-Debug "$function Exiting"
                    return $Result
                }
                
            } else {
                Write-Debug "$function KPI Time Check: Failed"
            }

            # If we get here, we fail, break out of the loop
            break
         
        }
    }
    # If we're here then we failed the KPI
    Write-Debug "$function KPI Never Triggered.  Failing"
    $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value (Get-ResponsibleShift $Ticket.fields['Created Date'].Value)
    $Result | Add-Member -MemberType noteproperty -Name "KPI" -Value $false

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

    
    # Figure out which one is authoritative:
    if ($TimeToResolve.KPI -and $TimeToEscalate.KPI) {
        # If they both passed, then use the shorter of the two for the Result

        if ([double]$TimeToEscalate.Time -lt [double]$TimeToResolve.Time) {
            Write-Debug ("$function Decided to use Time to Escalate because " + $TimeToEscalate.Time + " < " + $TimeToResolve.Time)
            $TTEorM = $TimeToEscalate
        } else {
            Write-Debug ("$function Decided to use Time to Resolve because " + $TimeToEscalate.Time + " > " + $TimeToResolve.Time)
            $TTEorM = $TimeToResolve
        }

    } elseif ($TimeToResolve.KPI) {
        # If only TimeToResolve Passed, then use that for the Result

        Write-Debug ("$function Decided to use Time to Resolve because it Passed and Time to Escalate Failed")
        $TTEorM = $TimeToResolve

    } elseif ($TimeToEscalate.KPI) {
        # If only TimeToEscalate Passed, then use that for the Result

        Write-Debug ("$function Decided to use Time to Escalate because it Passed and Time to Resolve Failed")
        $TTEorM = $TimeToEscalate

    } elseif (!$TimeToResolve.KPI -and !$TimeToEscalate.KPI) {
        # If both of them failed, then we fail the KPI.  Find out

        Write-Debug ("$function Time to Escalate = " + $TimeToEscalate.KPI + " and Time to Resolve = " + $TimeToResolve.KPI + ", will determine the best one to use for reporting")

        If ($timeToResolve.Time -and $TimeToEscalate.Time) {

            if ([double]$TimeToResolve.Time -lt [double]$TimeToEscalate.Time) {
                Write-Debug ("$function Decided to use Time to Resolve because " + $TimeToEscalate.Time + " > " + $TimeToResolve.Time)
                $TTEorM = $TimeToResolve
            } else {
                Write-Debug ("$function Decided to use Time to Escalate because " + $TimeToEscalate.Time + " < " + $TimeToResolve.Time)
                $TTEorM = $TimeToEscalate
            }

        } elseif ($timeToResolve.Time) {

            Write-Debug ("$function Decided to use Time to Resolve because it has a Time value and Time to Escalate does not")
            $TTEorM = $TimeToResolve

        } elseif ($TimeToEscalate.Time) {
            
            Write-Debug ("$function Decided to use Time to Escalate because it has a Time value and Time to Resolve does not")
            $TTEorM = $TimeToEscalate

        } else {
            Write-Debug ("$function Decided to use Time to Escalate because Time to Escalate and Time to Resolve both have no Time value")
            $TTEorM = $TimeToResolve
        }

    }

    return $TTEorM

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

