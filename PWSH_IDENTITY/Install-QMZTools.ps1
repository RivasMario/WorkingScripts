<#	
.DESCRIPTION
        Install tools on a QMZ, either remotely or by running this tool as an ADMIN
        locally on machine.
        Also defined is a powershell lambda function/script block that is designed
        to install tools on  QMZ, ADM, WDS, and some additional infra roles. So is
        reusable.
.PARAMETER
        $ComputerName - name of remote machine to install on.  If blank we install
        on the localhost. 
        If you give "-" or "dotsource" a ComputerName, that indicates to not run
        on localhost and instead allow you to "dot source the code to get the value
        of $lambda_install_features for other uses.
.NOTES
        Direct questions to Thomas Popovich (thpopovi).
#>

param (
	[Parameter(Mandatory = $false)]
	[string]$ComputerName
)

#
# USAGE:  runs this command to define $lambda_install_features
#         then you can do something like this:
#         $ad_adm = get-MsodsAdComputerName some-adm-server-hostname
#         you can choose an ADM and then run the lamba:
#         invoke-command $ad_adm $lambda_install_features 
#
#   But to make this file easier to use, we changed the invoke to happen
#   automatically based on passing in a $ComputerName on the command line...

$lambda_install_features = {
<#

Functions:
    Install-OSFeaturesForMSODSMachine   --- use this to install QMZ Windows Features on a machine, e.g.
    USAGE:
     Install-OSFeaturesForMSODSMachine -Hostname localhost -RoleName QMZ
     Install-OSFeaturesForMSODSMachine -Hostname localhost -RoleName ADM
     Install-OSFeaturesForMSODSMachine -Hostname localhost -RoleName WDS-only some WDS (ones used for licensing)

#>
	function Install-OSFeaturesForMSODSMachine
	{
    <#
      .SYNOPSIS
      Install OS WindowsFeatures for MSOD SMachine make sure we install windows features for a role
      .DESCRIPTION
      Install OS WindowsFeatures for MSOD SMachine make sure we install windows features for a role

      .EXAMPLE
      First example
      Install-OSFeaturesForMSODSMachine -Hostname localhost -RoleName QMZ

      .EXAMPLE
      Second example
      Install-OSFeaturesForMSODSMachine -Hostname localhost -RoleName ADM
	
	  RETURNS: output from Install-WindowsFeature, to indicate if a reboot is needed.
    #>
		
		[CmdletBinding()]
		param
		(
			# Parameter description
			[Parameter(Mandatory = $true)]
			[string]$Hostname,
			# Parameter description

			[Parameter(Mandatory = $true)]
			[string]$RoleName
		)
		
		
		# Note below we add -IncludeManagementTools
		#   ...  -IncludeManagementTools -ComputerName "$hostname"
		# so that any and all management tools are installed as well
		
		$rolesToInstall = (Get-WindowsFeaturesNeededReturnAsStringArray -MachineRole $RoleName) # RoleName is qmz|adm|...
		
		$out = (Install-WindowsFeature -name $rolesToInstall -IncludeManagementTools -ComputerName "$Hostname")
		
		$out
		
		
	}
	
	
	
	function Get-WindowsFeaturesNeededReturnAsStringArray
	{
    <#
      .SYNOPSIS
      Get the WindowsFeatures that are needed (Return as StringArray) based on kind of machine.
      .DESCRIPTION
      Get the WindowsFeatures that are needed (Return as StringArray) based on kind of machine, to
      make sure they are on the machine.
      We use this to make sure a viable "run set" is on each kind of machine that users
      use to debug the environment.

      .EXAMPLE
      First example for QMZ
      Get-WindowsFeaturesNeededReturnAsStringArray  -MachineRole QMZ
      
      .EXAMPLE
      Second example for ADM
      Get-WindowsFeaturesNeededReturnAsStringArray  -MachineRole ADM

      The features returned might be different, e.g.
      
      PS C:\> (Get-WindowsFeaturesNeededReturnAsStringArray -MachineRole adm).count
      29

      PS C:\> (Get-WindowsFeaturesNeededReturnAsStringArray -MachineRole qmz).count
      31

    #>
		
		[CmdletBinding()]
		param
		(
			# Parameter description
			[Parameter(ParameterSetName = 'ParameterSet1', Mandatory = $true)]
			[ValidateSet('QMZ', 'ADM', 'DFS', 'WDS')]
			[string]$MachineRole
		)
		
		
		switch ($MachineRole)
		{
			{ @('QMZ', 'ADM') -contains $_ } {
				# right now most QMZ and ADM are similar , ADM often does not have REMOTE DESKTOP
				(("RSAT-ADDS-Tools"))
				(("RSAT-ADDS"))
				(("RSAT-AD-Tools"))
				(("RSAT-ADLDS"))
				(("RSAT-AD-AdminCenter"))
				(("RSAT-AD-PowerShell"))
				(("RSAT-DFS-Mgmt-Con"))
				(("FS-DFS-Namespace"))
				(("FS-DFS-Replication"))
				(("RSAT-DNS-Server"))
				(("FS-Data-Deduplication"))
				(("FS-FileServer"))
				(("RSAT-File-Services"))
				(("File-Services"))
				(("GPMC"))
				(("Hyper-V-Tools"))
				(("RSAT-Hyper-V-Tools"))
				(("Hyper-V-PowerShell"))
				
				(("Server-Media-Foundation")) # Server Media Foundation
				(("Remote-Desktop-Services")) # Remote Desktop Services
				(("RSAT-RDS-Tools")) #  Remote Desktop Services Tools
				
				$b_QmzHasRDSAndAdmDoesnt = $false # iff $true, only QMZ gets RDS, $false means ADM also gets
				if ($b_QmzHasRDSAndAdmDoesnt)
				{
					if (@('QMZ') -contains $_)
					{
						(("RSAT-RDS-Licensing-Diagnosis-UI")) # Remote Desktop Licensing Diagnoser Tools
					}
					if (@('QMZ') -contains $_)
					{
						(("RDS-RD-Server")) # Remote Desktop Session Host , makes machine able to run more than 2 mstsc sessions
					}
				}
				else
				{
					## all these server roles get RDS
					(("RSAT-RDS-Licensing-Diagnosis-UI")) # Remote Desktop Licensing Diagnoser Tools
					(("RDS-RD-Server")) # Remote Desktop Session Host , makes machine able to run more than 2 mstsc sessions
				}
				
				(("RSAT")) # Remote Server Administration Tools
				(("RSAT-Role-Tools")) # Role Administration Tools
				if ($null -ne (Get-WindowsFeature Server-Gui-Shell))
				{
					# server 2016/2019 does not have Server-Gui-Shell so we test if it is a feature first 
					(("Server-Gui-Shell")) # Server Graphical Shell
				}
				(("RSAT-DHCP"))
				(("FS-Resource-Manager"))
				(("RSAT-FSRM-Mgmt"))
				(("RDS-Licensing"))
				(("RDS-Licensing-UI"))
			}
			
			"DFS" { }
			"WDS" {
				(("RSAT-RDS-Tools")) #  Remote Desktop Services Tools
				(("RSAT-RDS-Licensing-Diagnosis-UI")) # Remote Desktop Licensing Diagnoser Tools
				(("RDS-Licensing"))
				(("RDS-Licensing-UI"))
			}
			default
			{
				Write-Error "MachineRole $($MachineRole) is not supported by Get-WindowsFeaturesNeededReturnAsStringArray"
				break
			}
		}
		
	}
	
	Install-OSFeaturesForMSODSMachine -Hostname localhost -RoleName QMZ
}

$ComputerName = "$ComputerName".Trim()

if (("$ComputerName" -eq "-") -or ("$ComputerName" -eq "dotsource"))
{
	# Here we do not install, just define a lambda function.
	Write-Output ' we created a lambda that you can run $lambda_install_features Make sure it has the proper RoleName'
	Write-Output ' but this file is designed to invoke on a machine or run locally'
}
else
{
	# Here we install, locally or remotely based on $ComputerName
	if (("$ComputerName" -eq "") -or ("$ComputerName" -eq (HOSTNAME)) -or ("$ComputerName" -eq "localhost"))
	{
		# run locally
		& $lambda_install_features
	}
	else
	{
		invoke-command $ComputerName $lambda_install_features
	}
}

