
function Global:Run-Phantom-ADS-Health-Check {

    $ErrorActionPreference = "SilentlyContinue"
    
    $user = whoami
    $from_Server = hostname
    
    function Global:Write_Log {
    
    param (
    [string]$log,
    [int]$event_ID,
    [string]$type,
    [string]$server
    )
    
    #$event_is = Get-EventLog -computername $server -Source 'Run-Phantom-ADS-Health-Check' -LogName Application | select -first 1
    #if(!($event_is)){
    New-EventLog -computername $server -Source 'Run-Phantom-ADS-Health-Check' -LogName Application
    #}
    
    Write-EventLog -computername $server -LogName "Application" -Source "Run-Phantom-ADS-Health-Check" -EventID $event_ID -EntryType $type -Message "$log" -Category 1 -RawData 10,20
    
    }
    
    Write_Log -server $from_Server -log "Run-Phantom-ADS-Health-Check powershell module has been initated by $user" -event_ID 1001 -type Information
    
    function Global:colorMyconsole {
    
    [console]::BackgroundColor = "black"
    $a = (Get-Host).PrivateData
    $a.ErrorBackgroundColor = "Black"
    $a.ErrorForegroundColor = "White"
    $a.WarningBackgroundColor = "Black"
    $a.WarningForegroundColor = "DarkYellow"
    
    Set-PSReadlineOption -TokenKind Comment -ForegroundColor Gray
    Set-PSReadlineOption -TokenKind Parameter DarkGreen
    Set-PSReadlineOption -TokenKind Variable DarkCyan
    Set-PSReadlineOption -TokenKind Member DarkGray
    clear
    } 
    
    colorMyconsole
    
    cls
    
    $timestamp = get-date
    $n = 0
    $array = @()
    
    #$ads_servers = (Get-ADComputer -filter 'Objectclass -eq "Computer"' | where-object {$_.dnshostname -like "*5ADS*"}).dnshostname | sort
    $promoted=((get-adcomputer -filter 'Objectclass -eq "computer"' | where-object {$_.DistinguishedName -like "*OU=DOMAIN*"})).dnshostname | sort
    
    $ads_servers= (
    'BN1RGR5ADS601.GRN005.US.MSFT.NET',
    'BN1RGR5ADS602.GRN005.US.MSFT.NET',
    'BN1RGR5ADS603.GRN005.US.MSFT.NET',
    'BN1RGR5ADS604.GRN005.US.MSFT.NET',
    'P20AGR5ADS601.GRN005.US.MSFT.NET',
    'P20AGR5ADS602.GRN005.US.MSFT.NET',
    'P20AGR5ADS603.GRN005.US.MSFT.NET',
    'P20AGR5ADS604.GRN005.US.MSFT.NET',
    'P20RGR5ADS601.GRN005.US.MSFT.NET',
    'P20RGR5ADS602.GRN005.US.MSFT.NET',
    'P20RGR5ADS603.GRN005.US.MSFT.NET',
    'P20RGR5ADS604.GRN005.US.MSFT.NET',
    'SN5AGR5ADS601.GRN005.US.MSFT.NET',
    'SN5AGR5ADS602.GRN005.US.MSFT.NET',
    'SN5AGR5ADS603.GRN005.US.MSFT.NET',
    'SN5AGR5ADS604.GRN005.US.MSFT.NET'
    )
    
    $ads_servers | % {
    
    Write_Log -server $_ -log "Phantom-ADS-Health-Check is initated by $user from $from_Server machine and scaned for the $($_)" -event_ID 1001 -type Information
    
    $obj=New-Object PSObject -Property @{
    "ID"=$_.ID;
    "Server"=$_.Server;
    "CPU" = $_.CPU;
    "Power On/Off"=$_.Power;
    "0x800705B4"=$_.w32tmflag;
    "NTDS"=$_.NTDS;
    "ADWS"=$_.ADWS;
    "DNS"=$_.DNS;
    "DNS Cache"=$_.Cache;
    "KDC"=$_.KDC;
    "w32Time"=$_.w32Time;
    "netlogon"=$_.netLogon;
    "DHCP"=$_.DHCP;
    "Promoted"=$_.Promoted;
    "hidden_flag"="$_.flag"
    } | select "ID","Server","CPU","Power On/Off","0x800705B4","NTDS","ADWS","DNS","DNS Cache","KDC","w32Time","netlogon","DHCP","Promoted","Flag"
    
    $n++ 
    $obj.ID = '{0:d2}' -f $n + "  "
    $sub_servername = $($_).Substring(0,13)
    $obj.Server = "$sub_servername"
    
    $obj.Promoted = 'N'
    #foreach ($a_promoted in $promoted){if($a_promoted -like "$($_)"){$obj.Promoted = "Y"}}
    foreach ($a_promoted in $promoted){if("$($_)" -like $a_promoted){$obj.Promoted = "Y"}}
    
    $read_w32tm=w32tm /stripchart /computer:$($_) /samples:3 /dataonly
    
    Write-host -f Gray -nonewline "health check for $($_) Server : "
    $connection = (Test-Connection -ComputerName $_ -Quiet -Count 1)
    
    if($connection -eq $true){Write-host -f green "Up";$obj."Power On/Off" = 'Y'}else{Write-host -f red "Down";$obj."Power On/Off" = 'N'}
    
    Write-host -f Gray -nonewline "- 0x800705B4 : "
    
    if($connection -eq $true) {
    if($read_w32tm -match '0x800705B4'){
    $w32tmflag = 1;
    $obj."0x800705B4" = 'Y'
    Write-host -f Red "Y"
    }else{
    $w32tmflag = 0
    $obj."0x800705B4" = 'N'
    Write-host -f Green "N"
    }
    }else {
    
    $obj."0x800705B4" = ''
    $obj.CPU = 'N'
    $obj.Power = 'N'
    $obj.w32tmflag = 'N'
    $obj.NTDS = 'N'
    $obj.ADWS = 'N'
    $obj.DNS = 'N'
    $obj.Cache = 'N'
    $obj.KDC = 'N'
    $obj.w32Time = 'N'
    $obj.netLogon = 'N'
    $obj.DHCP = 'N'
    $obj.Promoted = 'N'
    
    }
    
    if($connection -eq $true) {
    
    #$s = New-CimSession -ComputerName $_
    #$cpu_usage = (Get-CimInstance win32_processor -CimSession $s | Measure-Object -Property LoadPercentage -Average).Average
    
    $cpu_usage=((get-Counter -ComputerName $_ '\Processor(_Total)\% Processor Time' -SampleInterval 3 -MaxSamples 3 | select -last 1).CounterSamples).CookedValue
    
    $usage_percent = "$cpu_usage"
    $usage_percent=[math]::Round($usage_percent)
    $obj.CPU = "$usage_percent"
    
    $running_adsServices_ntds=(Get-Service -Name ntds -computername $($_) | where-object {$_.status -eq 'Running'} -ErrorAction silentlycontinue).count 
    $running_adsServices_adws=(Get-Service -Name adws -computername $($_) | where-object {$_.status -eq 'Running'} -ErrorAction silentlycontinue).count
    $running_adsServices_dns=(Get-Service -Name dns -computername $($_) | where-object {$_.status -eq 'Running'} -ErrorAction silentlycontinue).count
    $running_adsServices_dnscache=(Get-Service -Name dnscache -computername $($_) | where-object {$_.status -eq 'Running'} -ErrorAction silentlycontinue).count
    $running_adsServices_kdc=(Get-Service -Name kdc -computername $($_) | where-object {$_.status -eq 'Running'} -ErrorAction silentlycontinue).count
    $running_adsServices_w32time=(Get-Service -Name w32time -computername $($_) | where-object {$_.status -eq 'Running'} -ErrorAction silentlycontinue).count
    $running_adsServices_netlogon=(Get-Service -Name netlogon -computername $($_) | where-object {$_.status -eq 'Running'} -ErrorAction silentlycontinue).count
    $running_adsServices_dhcp=(Get-Service -Name dhcp -computername $($_) | where-object {$_.status -eq 'Running'} -ErrorAction silentlycontinue).count
    
    $flagcount=(Get-Service -Name ntds,adws,dns,dnscache,kdc,w32time,netlogon,dhcp -computername $($_) | where-object {$_.status -ne 'Running'} -ErrorAction silentlycontinue).Count
    $obj.flag = $flagcount
    
    Write-host -f Gray -nonewline "- CPU Usage : "
    if($cpu_usage -le 65){Write-host -f Green "$usage_percent"}else{Write-host -f Red "$usage_percent"}
    
    Write-host -f Gray -nonewline "- NTDS Service : "
    if($running_adsservices_ntds -eq 1){Write-host -f Green 'Y';$obj.NTDS = 'Y'}else{Write-host -f Red 'N';$obj.NTDS = 'N'}
    
    Write-host -f Gray -nonewline "- ADWS Service : "
    if($running_adsservices_adws -eq 1){Write-host -f Green 'Y';$obj.ADWS = 'Y'}else{Write-host -f Red 'N';$obj.ADWS = 'N'}
    
    Write-host -f Gray -nonewline "- DNS Service : "
    if($running_adsservices_dns -eq 1){Write-host -f Green 'Y';$obj.DNS = 'Y'}else{Write-host -f Red 'N';$obj.DNS = 'N'}
    
    Write-host -f Gray -nonewline "- DNSCACHE Service : "
    if($running_adsservices_dnscache -eq 1){Write-host -f Green 'Y';$obj."DNS Cache" = 'Y'}else{Write-host -f Red 'N';$obj."DNS Cache" = 'N'}
    
    Write-host -f Gray -nonewline "- KDC Service : "
    if($running_adsservices_kdc -eq 1){Write-host -f Green 'Y';$obj.KDC = 'Y'}else{Write-host -f Red 'N';$obj.KDC = 'N'}
    
    Write-host -f Gray -nonewline "- w32time Service : "
    if($running_adsservices_w32time -eq 1){Write-host -f Green 'Y';$obj.w32Time = 'Y'}else{Write-host -f Red 'N';$obj.w32Time = 'N'}
    
    Write-host -f Gray -nonewline "- Netlogon Service : "
    if($running_adsservices_netlogon -eq 1){Write-host -f Green 'Y';$obj.netlogon = 'Y'}else{Write-host -f Red 'N';$obj.netlogon = 'N'}
    
    Write-host -f Gray -nonewline "- DHCP Service : "
    if($running_adsservices_dhcp -eq 1){Write-host -f Green 'Y';$obj.DHCP = 'Y'}else{Write-host -f Red 'N';$obj.DHCP = 'N'}
    
    }
    
    Write-host -f Gray -nonewline "- Promoted : "
    if($obj.'Promoted' -eq 'Y'){Write-host -f Green 'Y'}else{Write-host -f Red 'N';$obj.Promoted = "N"}
    
    $array += $obj
    Write_Log -server $_ -log "Phantom-ADS-Health-Check has completed its scan, CpuUsage: $cpu_usage" -event_ID 1001 -type Information
    ''
    }
    
    clear
    
    
    #$array | select "ID","Server","Power On/Off","0x800705B4","NTDS","ADWS","DNS","DNS Cache","KDC","w32Time","netlogon","DHCP" | Format-Table
    
    ''
    ''
    ''
    ''
    
    write-host -f Gray "---------------------------------------------------"
    ''
    write-host -f White "*Arlington Domain Controller Daily Health Check"
    Write-host -f Gray " Date: $timestamp"
    ''
    write-host -f Gray "---------------------------------------------------"
    
    $array | Format-Table @{
        Label = "$([char]0x1b)[30;43m ID $([char]0x1b)[2m"
        Expression =
        {
            if ($_.'Power On/Off' -eq 'Y')
            {
                $color = "96"
                $b = 30
        } else {
                 $color = '93'
                $b = 91
            }
        if ($_.flag -gt 0){$color = '93';$b = 91}
            if ($_.'Promoted' -ne 'Y'){$color = '93';$b = 91}
            $e = [char]27
            #"$e[${color}m$($_.'ID')${e}[0m"
            "$([char]0x1b)[$b;43m $($_.'ID') $([char]0x1b)[0m"
        };align='left'
     },@{
        Label = "$([char]0x1b)[30;43m Server $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'Power On/Off' -eq 'Y')
            {
                $color = "96"
        } else {
                 $color = '93'
            }
        if ($_.flag -gt 0){
            $color = '93'
                  }
            if ($_.'Promoted' -ne 'Y'){
             $color = '93'
                   }
           $e = [char]27
           "$e[${color}m$($_.'Server')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m CPU $([char]0x1b)[2m"
        Expression =
        {
            if (!($_.'CPU' -gt 65))
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'CPU' +'%')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m Power $([char]0x1b)[2m"
        Expression =
        {
            if ($_.'Power On/Off' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'Power On/Off')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m 0x800705B4 $([char]0x1b)[2m"
        Expression =
        {
            if ($_.'0x800705B4' -eq 'N')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'0x800705B4')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m NTDS $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'NTDS' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'NTDS')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m ADWS $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'ADWS' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'ADWS')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m DNS $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'DNS' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'DNS')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m DNS Cache $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'DNS Cache' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'DNS Cache')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m KDC $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'KDC' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'KDC')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m w32time $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'w32Time' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'w32Time')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m netlogon $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'netlogon' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.'netlogon')${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m DHCP $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'DHCP' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.DHCP)${e}[0m"
        };align='center'
     },@{
        Label = "$([char]0x1b)[30;43m Promoted $([char]0x1b)[2m"
        Expression =
        {
             if ($_.'Promoted' -eq 'Y')
            {
                $color = "96"
        } else {
    
                 $color = '93'
            }
            $e = [char]27
           "$e[${color}m$($_.Promoted)${e}[0m"
        };align='center'
     }
    
    }
    
    Run-Phantom-ADS-Health-Check
    