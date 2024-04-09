
function Get-VLanFromIP {

    Param (
        
        [string]   
        $IpAddress,

        [string]
        $Subnet
    )
    

    # Convert the params into an IPAddress object to make sure it is valid
    [System.Net.IPAddress]$ip = [System.Net.IPAddress]::None
    $foo = [System.Net.IPAddress]::TryParse($ipAddress, [ref]$ip)
    if (!($foo))
    {
        # Return out with an error
        return;
    }

    [System.Net.IPAddress]$sn = [System.Net.IPAddress]::None
    if (!([System.Net.IPAddress]::TryParse($subnet, [ref]$sn)))
    {
        # Return out with an error
        return;
    }

    $ipBytes = $ip.GetAddressBytes();
    $snBytes = $sn.GetAddressBytes();
    $len = $ipBytes.Length
    $vlanBytes = New-Object Byte[] $len

    for($byteNumber=0; $byteNumber -lt $len; $byteNumber++)
    {
        
        $vlanBytes[$byteNumber] = $ipBytes[$byteNumber] -band $snBytes[$byteNumber]
                
    }

    $vlan = [System.String]::Join(".", $vlanBytes)

    return $vlan
    

}

function Get-Route {

    Param (
        
        [string]   
        $Destination,

        [string]
        $Mask,

        [string]
        $Gateway
    )


    #$routes = Get-WmiObject -Class Win32_IP4PersistedRouteTable
    $routes = Get-WmiObject -Class Win32_IP4RouteTable
    if ($routes | Where-Object {$_.Destination -eq $Destination -and $_.Mask -eq $Mask -and $_.NextHop -eq $Gateway})
    {
        #Skip this because it is already there
        return $true;
    }
    else
    {
        #Add the Route
        return $false;
    }


}
function Get-Route6 {

    Param (
        
        [string]
        $Destination6,

        [string]
        $Gateway6
    )
   
    
    $routes6 = Get-Netroute|Select-Object DestinationPrefix,NextHop
  
    if ($routes6 | Where-Object {$_.DestinationPrefix -eq $Destination6 -and $_.NextHop -eq $Gateway6})
    {
    
        #Skip this because it is already there
        return $true;
    }
    else
    {
    
        #Add the Route
        return $false;
    }


}

function Add-Route {

    Param (
        
        [string]   
        $Destination,

        [string]
        $Mask,

        [string]
        $Gateway
    )

    $routeCommand = "route add $Destination mask $Mask $Gateway -p"
    Write-Host $routeCommand
    Invoke-Expression $routeCommand
}

function Add-Route6 {

    Param (
        
        [string]   
        $Destination6,


        [string]
        $Gateway6
    )

    $routeCommand = "route add $Destination6  $Gateway6 -p"
    Write-Host $routeCommand
    Invoke-Expression $routeCommand
}

function Remove-Route {

    Param (
        
        [string]   
        $Destination,

        [string]
        $Mask,

        [string]
        $Gateway
    )

    $routeCommand = "route delete $Destination mask $Mask $Gateway "
    Invoke-Expression $routeCommand
}
function Remove-Route6 {

    Param (
        
        [string]   
        $Destination6,


        [string]
        $Gateway6
    )

    $routeCommand = "route delete $Destination6  $Gateway6"
    Write-Host $routeCommand
    Invoke-Expression $routeCommand
}



$nic = Get-WmiObject -computer . -class "win32_networkadapterconfiguration" | Where-Object {$_.defaultIPGateway -ne $null}
$IP = $nic.ipaddress | select-object -first 1
$ClientMask = $nic.ipsubnet | select-object -first 1

$vlan = Get-VLanFromIP -IpAddress $ip -Subnet $ClientMask
[xml]$xml = Get-Content -Path ".\VLanToRouteMapping.xml"
$node = $xml.VLanRoutes.VLan | Where-Object {$_.name -eq $vlan }
if ($node)
{

    # If we get a node from the xml file, then machine sure that the 6
    # routes listed there are accurate

    Write-Host "Found VLan in XML File: " $node.Description
    $routes = Get-WmiObject -Class Win32_IP4PersistedRouteTable
    
    
    foreach($r in $node.Route)
    {
        $dest = $r.destinaton
        $mask = $r.mask
        $gateway = $r.nextHop


        Write-Host "Checking Route $dest;$mask;$gateway"
        if ($r.action -eq "add")
        {
        
     #       Write-Host "Validating"
            if (!(Get-Route -Destination $dest -Mask $mask -Gateway $gateway))
            {
                Write-Host "Route Does NOT exist.  Adding"
                Add-Route -Destination $dest -Mask $mask -Gateway $gateway

                if (!(Get-Route -Destination $dest -Mask $mask -Gateway $gateway))
                {
                    # Throw an error
                    Write-Host "ERROR Adding route"
                }
            }
            else
            {
                Write-Host "Route Already exists. No Action Needed"
            }
        }
        elseif ($r.action -eq "delete")
        {
            Write-Host "Route should not be present: $dest $mask $gateway"
            if (Get-Route -Destination $dest -Mask $mask -Gateway $gateway)
            {
                Write-Host "Route DOES exist.  Deleting..."
                Remove-Route -Destination $dest -Mask $mask -Gateway $gateway

                if (Get-Route -Destination $dest -Mask $mask -Gateway $gateway)
                {
                    # Throw an error
                    Write-Host "ERROR Deleting route"
                }
            }
            else
            {
                Write-Host "Route does not exist. No Action Needed"
            }

        }
    }
	foreach($r6 in $node.V6Route)
	{
        Write-Host "-=IPV6 Enabled VLAN=-"
		$dest6 = $r6.destination6
		$gateway6 = $r6.nextHop6
		
#		Write-Host "Checking IPv6 Route dest6 = $dest6 gateway6 = $gateway6"
#		Get-Route6 -Destination6 $dest6 -Gateway6 $gateway6
		if ($r6.action6 -eq "add")
		{	
			Write-Host "Verifying IPv6 Routing"
			if (!(Get-Route6 -Destination6 $dest6 -Gateway6 $gateway6))
			{
				Write-Host "IPv6 Route Does NOT exist. Adding.."
				Add-Route6 -Destination6 $dest6 -Gateway6 $gateway6 
				
				if (!(Get-Route6 -Destination6 $dest6 -Gateway6 $gateway6))
				{
					#Throw an error
					Write-Host "Error adding IPV6 Route"
				}
			}
			else
			{
				Write-Host "IPV6 Route Already Exists. No action needed"
			}
        }
        elseif ($r.action -eq "delete")
        {
            Write-Host "Route $dest6 $gateway6 should not be present"
            if (Get-Route6 -Destination6 $dest6 -Gateway6 $gateway6)
            {
                Write-Host "Route DOES exist.  Deleting..."
                Remove-Route6 -Destination6 $dest6 -Gateway6 $gateway6

                if (Get-Route6 -Destination6 $dest6 -Gateway6 $gateway6)
                {
                    # Throw an error
                    Write-Host "ERROR Deleting route"
                }
            }
            else
            {
                Write-Host "Route does not exist. No Action Needed"
            }

        }
	}


}
else
{
    Write-Host "No VLan found in the xml file: " $vlan
}

# SIG # Begin signature block
# MIIoBQYJKoZIhvcNAQcCoIIn9jCCJ/ICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAT6uwEv2BXOMqA
# zbMxQFwpKc49XXOYi5lhCW7l2UcmjqCCEWQwggh2MIIHXqADAgECAhM2AAAAh2rh
# X7Bvfrt0AAEAAACHMA0GCSqGSIb3DQEBCwUAMEExEzARBgoJkiaJk/IsZAEZFgNH
# QkwxEzARBgoJkiaJk/IsZAEZFgNBTUUxFTATBgNVBAMTDEFNRSBDUyBDQSAwMTAe
# Fw0xODA3MTAxMzA4NDlaFw0xOTA3MTAxMzA4NDlaMC8xLTArBgNVBAMTJE1pY3Jv
# c29mdCBBenVyZSBEZXBlbmRlbmN5IENvZGUgU2lnbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAPf3/ZREq1xrUwIv3rE+B+9hgWu6A+9pATQBXADzJ1qA
# hxEKwDgBnpI3w4my/XssamM1SXZ1Ly/RqiAhbBnWiu57Mak5zIctiVAoH+JIliQD
# 2F8CO+K1drdj+V+MouJnlhYFYw5zEjJxk8gQVXBj+VlEcIVPBd+FBpuhAfWGHC/8
# NZYS779+HrCG1i5qGBpVEFK0Yx9shdJ3wBVWD0L4ZziltKV3oOdjysJ8rL8iL/Ig
# DcIlmcb4BnL0th/MAJLUTBxWRyUxKYyolabZIExXia3DmNz2EFmKpix7URu7eVQM
# SgAMXtUdWmaX5vJPYEXFBszAwI2Kq3cs85EJSFUWJB8CAwEAAaOCBXcwggVzMCkG
# CSsGAQQBgjcVCgQcMBowDAYKKwYBBAGCN1sDATAKBggrBgEFBQcDAzA8BgkrBgEE
# AYI3FQcELzAtBiUrBgEEAYI3FQiGkOMNhNW0eITxiz6Fm90Wzp0SgWDigi2HkK4D
# AgFkAgENMIICdgYIKwYBBQUHAQEEggJoMIICZDBiBggrBgEFBQcwAoZWaHR0cDov
# L2NybC5taWNyb3NvZnQuY29tL3BraWluZnJhL0NlcnRzL0JZMlBLSUNTQ0EwMS5B
# TUUuR0JMX0FNRSUyMENTJTIwQ0ElMjAwMSgxKS5jcnQwUgYIKwYBBQUHMAKGRmh0
# dHA6Ly9jcmwxLmFtZS5nYmwvYWlhL0JZMlBLSUNTQ0EwMS5BTUUuR0JMX0FNRSUy
# MENTJTIwQ0ElMjAwMSgxKS5jcnQwUgYIKwYBBQUHMAKGRmh0dHA6Ly9jcmwyLmFt
# ZS5nYmwvYWlhL0JZMlBLSUNTQ0EwMS5BTUUuR0JMX0FNRSUyMENTJTIwQ0ElMjAw
# MSgxKS5jcnQwUgYIKwYBBQUHMAKGRmh0dHA6Ly9jcmwzLmFtZS5nYmwvYWlhL0JZ
# MlBLSUNTQ0EwMS5BTUUuR0JMX0FNRSUyMENTJTIwQ0ElMjAwMSgxKS5jcnQwUgYI
# KwYBBQUHMAKGRmh0dHA6Ly9jcmw0LmFtZS5nYmwvYWlhL0JZMlBLSUNTQ0EwMS5B
# TUUuR0JMX0FNRSUyMENTJTIwQ0ElMjAwMSgxKS5jcnQwga0GCCsGAQUFBzAChoGg
# bGRhcDovLy9DTj1BTUUlMjBDUyUyMENBJTIwMDEsQ049QUlBLENOPVB1YmxpYyUy
# MEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9
# QU1FLERDPUdCTD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlm
# aWNhdGlvbkF1dGhvcml0eTAdBgNVHQ4EFgQULZktR9nSbfs0Ys9sqwYAWWCZPxsw
# DgYDVR0PAQH/BAQDAgeAMEUGA1UdEQQ+MDykOjA4MR4wHAYDVQQLExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xFjAUBgNVBAUTDTIzNjE2OSs0MzgwNDcwggHUBgNVHR8E
# ggHLMIIBxzCCAcOgggG/oIIBu4Y8aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3Br
# aWluZnJhL0NSTC9BTUUlMjBDUyUyMENBJTIwMDEuY3Jshi5odHRwOi8vY3JsMS5h
# bWUuZ2JsL2NybC9BTUUlMjBDUyUyMENBJTIwMDEuY3Jshi5odHRwOi8vY3JsMi5h
# bWUuZ2JsL2NybC9BTUUlMjBDUyUyMENBJTIwMDEuY3Jshi5odHRwOi8vY3JsMy5h
# bWUuZ2JsL2NybC9BTUUlMjBDUyUyMENBJTIwMDEuY3Jshi5odHRwOi8vY3JsNC5h
# bWUuZ2JsL2NybC9BTUUlMjBDUyUyMENBJTIwMDEuY3JshoG6bGRhcDovLy9DTj1B
# TUUlMjBDUyUyMENBJTIwMDEsQ049QlkyUEtJQ1NDQTAxLENOPUNEUCxDTj1QdWJs
# aWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9u
# LERDPUFNRSxEQz1HQkw/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29i
# amVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MB8GA1UdIwQYMBaAFBtmohn8
# m+ul2oSPGJjpEKTDe5K9MB8GA1UdJQQYMBYGCisGAQQBgjdbAwEGCCsGAQUFBwMD
# MA0GCSqGSIb3DQEBCwUAA4IBAQDPWYN9t5RNknehD6HG/lGEJokcOcgxiCw5kMen
# fHjsQzVonpYznweZUGuy/yvR4FqCKejkJe38NFLB156IeV2RZwl8J5BBeM093b8c
# b4fWdPmAOixP43wFSKy4WHJKcpohSHCT/g5+nfwUP6/BYx0fqGKoISbJW6fyJ9NI
# gTBYkJ9g2awJg3dLRvRXeV53WONNBu1KrgJ9Ne6Yo1fKUI6VBUmS5fL3B0VbkUn1
# JdeP1H0exAV+Qk3mkfC0r28APVQ49i1gcc+rFaWc76bRZyj1lfBXZP3UVbLN6iDF
# G7NHSzlh15r4TgAuf8zKQklUhE30ZQc+24DFcoK0Gar3JX7IMIII5jCCBs6gAwIB
# AgITHwAAABS0xR/G8oC+cQAAAAAAFDANBgkqhkiG9w0BAQsFADA8MRMwEQYKCZIm
# iZPyLGQBGRYDR0JMMRMwEQYKCZImiZPyLGQBGRYDQU1FMRAwDgYDVQQDEwdhbWVy
# b290MB4XDTE2MDkxNTIxMzMwM1oXDTIxMDkxNTIxNDMwM1owQTETMBEGCgmSJomT
# 8ixkARkWA0dCTDETMBEGCgmSJomT8ixkARkWA0FNRTEVMBMGA1UEAxMMQU1FIENT
# IENBIDAxMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1VeBAtb5+tD3
# G4C53TfNJNxmYfzhiXKtKQzSGxuav660bTS1VEeDDjSnFhsmnlb6GkPCeYmCJwWg
# ZGs+3oWJ8yad3//VoP99bXG8azzTJmT2PFM1yKxUXUJgi7I9y3C4ll/ATfBwbGGR
# XD+2PdkdlVpxKWzeNEPVwbCtxWjUhHr6Ecy9R6O23j+2/RSZSgfzYctDzDWhNf0P
# vGPflm31PSk4+ozca337/Ozu0+naDKg5i/zFHhfSJZkq5dPPG6C8wDrdiwHh6G5I
# GrMd2QXnmvEfjtpPqE+G8MeWbszaWxlxEjQJQC6PBwn+8Qt4Vqlc0am3Z3fBw8kz
# RunOs8Mn/wIDAQABo4IE2jCCBNYwEAYJKwYBBAGCNxUBBAMCAQEwIwYJKwYBBAGC
# NxUCBBYEFJH8M85CnvaT5uJ9VNcIGLu413FlMB0GA1UdDgQWBBQbZqIZ/JvrpdqE
# jxiY6RCkw3uSvTCCAQQGA1UdJQSB/DCB+QYHKwYBBQIDBQYIKwYBBQUHAwEGCCsG
# AQUFBwMCBgorBgEEAYI3FAIBBgkrBgEEAYI3FQYGCisGAQQBgjcKAwwGCSsGAQQB
# gjcVBgYIKwYBBQUHAwkGCCsGAQUFCAICBgorBgEEAYI3QAEBBgsrBgEEAYI3CgME
# AQYKKwYBBAGCNwoDBAYJKwYBBAGCNxUFBgorBgEEAYI3FAICBgorBgEEAYI3FAID
# BggrBgEFBQcDAwYKKwYBBAGCN1sBAQYKKwYBBAGCN1sCAQYKKwYBBAGCN1sDAQYK
# KwYBBAGCN1sFAQYKKwYBBAGCN1sEAQYKKwYBBAGCN1sEAjAZBgkrBgEEAYI3FAIE
# DB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAf
# BgNVHSMEGDAWgBQpXlFeZK40ueusnA2njHUB0QkLKDCCAWgGA1UdHwSCAV8wggFb
# MIIBV6CCAVOgggFPhiNodHRwOi8vY3JsMS5hbWUuZ2JsL2NybC9hbWVyb290LmNy
# bIYxaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraWluZnJhL2NybC9hbWVyb290
# LmNybIYjaHR0cDovL2NybDIuYW1lLmdibC9jcmwvYW1lcm9vdC5jcmyGI2h0dHA6
# Ly9jcmwzLmFtZS5nYmwvY3JsL2FtZXJvb3QuY3JshoGqbGRhcDovLy9DTj1hbWVy
# b290LENOPUFNRVJPT1QsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2Vz
# LENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9QU1FLERDPUdCTD9jZXJ0
# aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJp
# YnV0aW9uUG9pbnQwggGrBggrBgEFBQcBAQSCAZ0wggGZMDcGCCsGAQUFBzAChito
# dHRwOi8vY3JsMS5hbWUuZ2JsL2FpYS9BTUVST09UX2FtZXJvb3QuY3J0MEcGCCsG
# AQUFBzAChjtodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpaW5mcmEvY2VydHMv
# QU1FUk9PVF9hbWVyb290LmNydDA3BggrBgEFBQcwAoYraHR0cDovL2NybDIuYW1l
# LmdibC9haWEvQU1FUk9PVF9hbWVyb290LmNydDA3BggrBgEFBQcwAoYraHR0cDov
# L2NybDMuYW1lLmdibC9haWEvQU1FUk9PVF9hbWVyb290LmNydDCBogYIKwYBBQUH
# MAKGgZVsZGFwOi8vL0NOPWFtZXJvb3QsQ049QUlBLENOPVB1YmxpYyUyMEtleSUy
# MFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9QU1FLERD
# PUdCTD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlv
# bkF1dGhvcml0eTANBgkqhkiG9w0BAQsFAAOCAgEAKLdKhpqPH6QBaM3CAOqQi8oA
# 4WQeZLW3QOXNmWm7UA018DQEa1yTqEQbuD5OlR1Wu/F289DmXNTdsZM4GTKEaZeh
# IiVaMoLvEJtu5h6CTyfWqPetNyOJqR1sGqod0Xwn5/G/zcTYSxn5K3N8KdlcDrZA
# Iyfq3yaEJYHGnA9eJ/f1RrfbJgeo/RAhICctOONwfpsBXcgiTuTmlD/k0DqogvzJ
# gPq9GOkIyX/dxk7IkPzX/n484s0zHR4IKU58U3G1oPSQmZ5OHAvgHaEASkdN5E20
# HyJv5zN7du+QY08fI+VIci6pagLfXHYaTX3ZJ/MUM9XU+oU5y4qMLzTj1JIG0LVf
# uHK8yoB7h2inyTe7bn6h2G8NxZ02aKZ0xa+n/JnoXKNsaVPG1SoTuItMsXV5pQtI
# ShsBqnXqFjY3bJMlMhIofMcjiuOwRCW+prZ+PoYvE2P+ML7gs3L65GZ9BdKF3fSW
# 3TvmpOujPQ23rzSle9WGxFJ02fNbaF9C7bG44uDzMoZU4P+uvQaB7KE4OMqAvYYf
# Fy1tv1dpVIN/qhx0H/9oNiOJpuZZ39ZibLt9DXbsq5qwyHmdJXaisxwB53wJshUj
# c1i76xqFPUNGb8EZQ3aFKl2w9B47vfBi+nU3sN0tpnLPtew4LHWq4LBD5uiNZVBO
# YosZ6BKhSlk1+Y/0y1IxghX3MIIV8wIBATBYMEExEzARBgoJkiaJk/IsZAEZFgNH
# QkwxEzARBgoJkiaJk/IsZAEZFgNBTUUxFTATBgNVBAMTDEFNRSBDUyBDQSAwMQIT
# NgAAAIdq4V+wb367dAABAAAAhzANBglghkgBZQMEAgEFAKCBxjAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQgnl8sUzE9sV3DNCCMpURYpl6hHOOpLFTss57UrbxuiwEw
# WgYKKwYBBAGCNwIBDDFMMEqgLIAqAE0AaQBjAHIAbwBzAG8AZgB0ACAAQwBvAHIA
# cABvAHIAYQB0AGkAbwBuoRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTANBgkq
# hkiG9w0BAQEFAASCAQDzgqSksHR0PGqzidskz9lKCwF/k+cHeVbZt+KgMSQJAn4N
# C5Q9OV5PBWSYlWuC3pyg1/+qCb0LRRrydHIK2fDQ0q+4j4fqIWrWyExOSgWgqOAC
# qyW7HODf3Qzcw6z84n6e73YvGZUfMnjEGBfirO9esNkj1+r/CBy7f1yBxvbgSIjf
# MoDpQkLirNvmdfRcZ17/b2L2nwuPkhV602mJOrWWrDbceQ4HUfub9b8EM+QC0gNn
# oDyrQxIESPA2tvaYwmXWPM5y9yPmpYpYkd14mZ97PMzozCZnaEz8egkdJC0AeSh4
# 3UM0YFuGuBM3GOd1hx+PIakcEVV2hGbW7MZlSwyxoYITpzCCE6MGCisGAQQBgjcD
# AwExghOTMIITjwYJKoZIhvcNAQcCoIITgDCCE3wCAQMxDzANBglghkgBZQMEAgEF
# ADCCAVQGCyqGSIb3DQEJEAEEoIIBQwSCAT8wggE7AgEBBgorBgEEAYRZCgMBMDEw
# DQYJYIZIAWUDBAIBBQAEIBx5HiiaKKO2QPSts0IwfvtBSxQSF05um9jMTZPWslug
# AgZb/HJxGOsYEzIwMTgxMTMwMjMyODMxLjg4NFowBwIBAYACAfSggdCkgc0wgcox
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1p
# Y3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOjU3QzgtMkQxNS0xQzhCMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNloIIPEzCCBnEwggRZoAMCAQICCmEJgSoAAAAAAAIwDQYJKoZIhvcN
# AQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAw
# BgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEw
# MB4XDTEwMDcwMTIxMzY1NVoXDTI1MDcwMTIxNDY1NVowfDELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgUENBIDIwMTAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCp
# HQ28dxGKOiDs/BOX9fp/aZRrdFQQ1aUKAIKF++18aEssX8XD5WHCdrc+Zitb8BVT
# JwQxH0EbGpUdzgkTjnxhMFmxMEQP8WCIhFRDDNdNuDgIs0Ldk6zWczBXJoKjRQ3Q
# 6vVHgc2/JGAyWGBG8lhHhjKEHnRhZ5FfgVSxz5NMksHEpl3RYRNuKMYa+YaAu99h
# /EbBJx0kZxJyGiGKr0tkiVBisV39dx898Fd1rL2KQk1AUdEPnAY+Z3/1ZsADlkR+
# 79BL/W7lmsqxqPJ6Kgox8NpOBpG2iAg16HgcsOmZzTznL0S6p/TcZL2kAcEgCZN4
# zfy8wMlEXV4WnAEFTyJNAgMBAAGjggHmMIIB4jAQBgkrBgEEAYI3FQEEAwIBADAd
# BgNVHQ4EFgQU1WM6XIoxkPNDe3xGG8UzaFqFbVUwGQYJKwYBBAGCNxQCBAweCgBT
# AHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgw
# FoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDov
# L2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0
# XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAx
# MC0wNi0yMy5jcnQwgaAGA1UdIAEB/wSBlTCBkjCBjwYJKwYBBAGCNy4DMIGBMD0G
# CCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vUEtJL2RvY3MvQ1BT
# L2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAFAAbwBs
# AGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4IC
# AQAH5ohRDeLG4Jg/gXEDPZ2joSFvs+umzPUxvs8F4qn++ldtGTCzwsVmyWrf9efw
# eL3HqJ4l4/m87WtUVwgrUYJEEvu5U4zM9GASinbMQEBBm9xcF/9c+V4XNZgkVkt0
# 70IQyK+/f8Z/8jd9Wj8c8pl5SpFSAK84Dxf1L3mBZdmptWvkx872ynoAb0swRCQi
# PM/tA6WWj1kpvLb9BOFwnzJKJ/1Vry/+tuWOM7tiX5rbV0Dp8c6ZZpCM/2pif93F
# SguRJuI57BlKcWOdeyFtw5yjojz6f32WapB4pm3S4Zz5Hfw42JT0xqUKloakvZ4a
# rgRCg7i1gJsiOCC1JeVk7Pf0v35jWSUPei45V3aicaoGig+JFrphpxHLmtgOR5qA
# xdDNp9DvfYPw4TtxCd9ddJgiCGHasFAeb73x4QDf5zEHpJM692VHeOj4qEir995y
# fmFrb3epgcunCaw5u+zGy9iCtHLNHfS4hQEegPsbiSpUObJb2sgNVZl6h3M7COaY
# LeqN4DMuEin1wC9UJyH3yKxO2ii4sanblrKnQqLJzxlBTeCG+SqaoxFmMNO7dDJL
# 32N79ZmKLxvHIa9Zta7cRDyXUHHXodLFVeNp3lfB0d4wwP3M5k37Db9dT+mdHhk4
# L7zPWAUu7w2gUDXa7wknHNWzfjUeCLraNtvTX4/edIhJEjCCBPEwggPZoAMCAQIC
# EzMAAADo+AcjNuFS1aYAAAAAAOgwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTAwHhcNMTgwODIzMjAyNzEyWhcNMTkxMTIzMjAyNzEy
# WjCByjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UE
# CxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEmMCQGA1UECxMdVGhhbGVz
# IFRTUyBFU046NTdDOC0yRDE1LTFDOEIxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCR
# JclNRxK+3piyBQKC4aGT+h9BurW4G32UXkZxtQpKZbiFlGuQYLL0sX34t2uAp9VW
# PNDQgZNjO4sT2G0FwRw0laF7UHZty/0Yd6kjfBMt2wvmBsYXcznyF5E1E8hqR1/s
# gY7RV7rtL9G3VpLQv8NotnmKiNuMJRfTpQ/v35JOtxjICIIigkmdDQUm6ecTJHbF
# n22o9wtGqMazrqa/W4LwW6AFvc+bFu0v47FhbrRtqxLUw6z+t99TBg79/7zPOMwu
# C3tqQDKM+9OOWgQCZOYeNO0Numd6dnPxDXVOFaoIJyosiUdC/4wAKnOxvp+WCJhJ
# qBSTKz+szom2sYdMugODAgMBAAGjggEbMIIBFzAdBgNVHQ4EFgQUFKBhS2aw5+8p
# Jcocf5GQ+zgcKlMwHwYDVR0jBBgwFoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYD
# VR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
# cHJvZHVjdHMvTWljVGltU3RhUENBXzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEB
# BE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9j
# ZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcnQwDAYDVR0TAQH/BAIwADAT
# BgNVHSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEASY4Rl1405e0z
# v7vynVQOOuQuozeznMqHUK8FMrJ3oNIxeqTL49mNiSh2kXvlx7a1vRSxuLAnD85U
# IDc2w3craEy9mI2VmdpktF1DzzlbAuQsesP5uVo5ho8NbLQ3QiNFZYiW93nj8UnP
# aRcTPKzbvtTxwXb7FXB7l4mShYOeh0lPs13QDnjSWbuzLo+WYTDmKx5XWTlWBx2+
# 3EIFjZYAWO+AJUCMQfYXOklzhJQdcZ2nVCAf8LCcUNp+JFFSXzKsdeQdKkZfdNPn
# dYTZaiM/u3oT0r2UAq4tOAnF9a6goG/zmuIlFyFfgNZah/GO3U7tw+G3bOvNgI0x
# mS9NaFLSTqGCA6UwggKNAgEBMIH6oYHQpIHNMIHKMQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBP
# cGVyYXRpb25zMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo1N0M4LTJEMTUtMUM4
# QjElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEBMAkG
# BSsOAwIaBQADFQBQBDnzeihbJLNeoQxQYYaUhzAWD6CB2jCB16SB1DCB0TELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9z
# b2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMebkNpcGhlciBOVFMgRVNO
# OjI2NjUtNEMzRi1DNURFMSswKQYDVQQDEyJNaWNyb3NvZnQgVGltZSBTb3VyY2Ug
# TWFzdGVyIENsb2NrMA0GCSqGSIb3DQEBBQUAAgUA36wpdDAiGA8yMDE4MTEzMDIx
# MjYxMloYDzIwMTgxMjAxMjEyNjEyWjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDf
# rCl0AgEAMAcCAQACAgn5MAcCAQACAhpcMAoCBQDfrXr0AgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwGgCjAIAgEAAgMW42ChCjAIAgEAAgMehIAwDQYJ
# KoZIhvcNAQEFBQADggEBAIVTtd2TTqbtxiyahrG/4BsbvTVttxjdHfSxnZFNiqWD
# xj+szu7YIHjTTX8KcE5aP+ZItEn0XN+9DYMUz7SI6OQdqhZqpL+kpvGI9pidQ6A1
# qdyl1oi2nRE4JXy7J4ptC8PKxSBCPun5jicsStEeQy2cL+jyki0wJoD9WiZ72ZnK
# e2ihKPMv+a8YuGjr108JH+Kwe6wvv4XyOq2vEs/uupStwBleK4aV9agWoPspMu9M
# gc7lX1pZ+8qDf+BSELAkwlbnKR2pAhMP6BJjT7kaYHLlyy/BZaxMjrJXSJUShJEe
# WgL1m0LR52XOBvS/KhfTe/hhOdyDD56Tb232o7IMN8kxggL1MIIC8QIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAOj4ByM24VLVpgAAAAAA
# 6DANBglghkgBZQMEAgEFAKCCATIwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCCebccBS0HA4OJpcLUc+0QwOG1LtcxJl+HxGSZKzTKh
# HjCB4gYLKoZIhvcNAQkQAgwxgdIwgc8wgcwwgbEEFFAEOfN6KFsks16hDFBhhpSH
# MBYPMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAADo
# +AcjNuFS1aYAAAAAAOgwFgQUFIxw7n0KKeoOtaxORDhL9X7zWvMwDQYJKoZIhvcN
# AQELBQAEggEAemHl3dn06fS93kmmpD5fjnhYYFFDNjp1Qv4rgHSz3bzbWEuBrCUE
# Q7zuBKY0BFOs5ArleVAN2UtcI3r9KdYSAnUqi1ShQbvSpUEbHvn1JQi0+NTWYxi/
# HvayU8K6V3eN9TKTUx1ypQBakbuTAUM+j3XMjZgYVg4dUliIB7rH5UMfC2Sd+pUG
# K/gpIm/Zw5MSvEl8rkWRyuzihaEa66USGIT+MQTw8nckH6mzo7LpPO9ZI5O0hTBq
# Asj3ZvowPjsKw9Y5dHXPgdsr5vWMJnobFsMdo05oS1f3K7S4VZxhjRl+NEWhPapD
# MZ/SB13gjRY3XB0inIf4KIIh38OAC46mIw==
# SIG # End signature block
