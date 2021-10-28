

Function Get-Ticket {
    Param(
        [Parameter(Mandatory=$True)][int]$id,
        [Parameter(Mandatory=$True)]$WorkItemStore
    )

    $WorkItemStore.GetWorkItem($id)

}

Function Get-TTT {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $Result = New-Object psobject
    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID']

    ForEach ($Revision in $Ticket.revisions) {
        if ($Revision.fields['State'].OriginalValue -eq "Triage" -and $Revision.fields['State'].Value -eq "Investigate") {

            $TTT = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)
            
            $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value $Revision.fields['Changed By'].Value
            $Result | Add-Member -MemberType noteproperty -Name "TTT" -Value $TTT

            return $Result
            
        }
    }
}


Function Get-TTLE {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )
    
    $Result = New-Object psobject
    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID']

    $initialAssignedTo = $Ticket.revisions[0].fields['Assigned To'].Value

    ForEach ($Revision in $Ticket.revisions) {
        if ($Revision.fields['Assigned To'].Value -like '*Lockheed*') {

            $TTLE = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)

            $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value $Revision.fields['Changed By'].Value
            $Result | Add-Member -MemberType noteproperty -Name "TTLE" -Value $TTLE

            return $Result

        }
    }
}


Function Get-TTE {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $Result = New-Object psobject
    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID']

    ForEach ($Revision in $Ticket.revisions) {
        if ($Revision.fields['EscalationStatus'].OriginalValue -eq '' -and $Revision.fields['EscalationStatus'].Value -eq "1. Contacted") {

            $TTE = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)

            $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value $Revision.fields['Changed By'].Value
            $Result | Add-Member -MemberType noteproperty -Name "TTE" -Value $TTE

            return $Result

        }
    }
}


Function Get-TTR {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $Result = New-Object psobject
    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID']

    ForEach ($Revision in $Ticket.revisions) {
        if ($Revision.fields['State'].OriginalValue -eq 'Investigate' -and ($Revision.fields['State'].Value -eq 'Mitigated' -or $Revision.fields['State'].Value -eq 'Resolved')) {

            $TTR = new-timespan -end ($Revision.fields['Changed Date'].Value) -start ($Revision.fields['Created Date'].Value)

            $Result | Add-Member -MemberType noteproperty -Name "Operator" -Value $Revision.fields['Changed By'].Value
            $Result | Add-Member -MemberType noteproperty -Name "TTR" -Value $TTR

            return $Result

        }
    }
}


Function Get-EscortTTS {
    Param(
        [Parameter(Mandatory=$True)]$Ticket
    )

    $Result = New-Object psobject
    $Result | Add-Member -MemberType noteproperty -Name "ID" -Value $Ticket.Fields['ID']
    
    $EventTime = $Ticket.fields['Event Time'].Value
    $CurrentTime = Get-Date

    If (!$EventTime) {
        $EventTime = $Ticket.Fields['Created Date'].Value
    }

    $TTS = new-timespan -Start $EventTime -End $CurrentTime

    $Result | Add-Member -MemberType noteproperty -Name "TTS" -Value $TTS

    return $Result

}

