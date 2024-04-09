Import-Module "\\usme.gbl\services\ProdDSL\GFS-DSL\IS\MDS\dSMS.psm1"

$ComputerName = Get-Content "D:\blbarnet\servers.txt"

$SecurePassword = Read-Host -Prompt "Bootstrap.pfx password" -AsSecureString

#Run Install-Bootstrap

Install-Bootstrap -ComputerName $ComputerName -PFXFile "D:\blbarnet\bootstrap.pfx" -Thumbprint $BootStrapThumbprint -SecurePassword $SecurePassword