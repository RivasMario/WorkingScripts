<#

    Updates
		2/21/18 - v-coprel 	- 	Script created
		4/4/18	- v-coprel	-	Decreased update frequency
        5/19/18 - v-coprel  -   Adding error checking when IP address of host changes
                                Increased update frequency due to VPN issues
        5/30/18 - v-coprel  -   Moved connection info into config.xml
	
#>
$version = "1.0.4"

$host.ui.RawUI.WindowTitle = "ServiceAccounts - Version: $version"
function Get-Accounts(){
	
	#Creates DB connection
    [xml]$configFile = Get-Content -Path "\\SVCACCTTRACKER\SvcAcctTracker\Deployment\config.xml"
    $dbConfig = $configFile.ChildNodes.databases
    $accountConfig = $configFile.ChildNodes.accounts

    #Creates DB connection
    $SQLServer = $dbConfig.database.server
    $SQLDatabase = $dbConfig.database.database
    $SQLTable = ($dbConfig.database.table | Where-Object {$_.id -eq "Admin"}).innertext
    $SQLUsername = ($accountConfig.account | Where-Object {$_.id -eq "Admin"}).name
    $SQLPassword = ($accountConfig.account | Where-Object {$_.id -eq "Admin"}).value
	$SQLConnectionTimeout = 60
	$SQLConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Encrypt=True;Connect Timeout={4}" -f $SqlServer,$SqlDatabase,$SqlUsername,$SqlPassword,$SqlConnectionTimeout
	
	$SQLQuery = "SELECT TOP 30 AccountName, ExpirationDate FROM svcacct_looper ORDER BY ExpirationDate"
			
	#Create data table
	$Data = New-Object System.Data.DataTable

	#Connect to the DB
	$SqlConnection = New-Object System.Data.SQLClient.SQLConnection
	$SqlConnection.ConnectionString = $SqlConnectionString
	$SqlConnection.Open()

	#Run the query and load the data to the data table
	$QueryCmd = New-Object System.Data.SQLClient.SQLCommand
	$QueryCmd.Connection  = $SqlConnection
	$QueryCmd.CommandText = $SQLQuery
	$Reader = $QueryCmd.ExecuteReader()
	$Data.Load($Reader)
	$SqlConnection.Close()		

    $AccountsList = $Data.GetList()

	return $AccountsList
}

function DisplayHud() {

    #$quiet = $error.Clear()
    $today = Get-Date
   	$OutputData = @()
    $connectionState = $true
    try
    { 
        $error.clear()
        $accounts = Get-Accounts
    }
    catch [System.Data.SqlClient.SqlException]
    {
        $connectionState = $false
        $Error[0].Exception -match "'(\d{1,3}\.){3}\d{1,3}'"
    }

    foreach ($a in $accounts)
    {
        $account = [pscustomobject][ordered]@{
            AccountName = $a.AccountName
            ExpirationDate = $a.ExpirationDate.ToShortDateString()
            DaysToExpiration = ($a.ExpirationDate - $today).Days
        }
        $OutputData += $account
    }
	
    $accountlist = $OutputData | sort-object DaysToExpiration

	$Bckgrndclr = "Black"
	
	
	$Host.UI.RawUI.BackgroundColor = $Bckgrndclr
	Clear-Host
    

" _____ _____ _____    _____ _____ _____ _____ _____ 
|   __|  |  |     |  |  _  |     |     |_   _|   __|
|__   |  |  |   --|  |     |   --|   --| | | |__   |
|_____|\___/|_____|  |__|__|_____|_____| |_| |_____|
                                                    "	
    Write-Host "Last Execution: " (Get-Date)
    if(!$connectionState) {Write-host "Access to SQL Server sql-svcacct-tracker.database.usgovcloudapi.net is denied.`nAdd IP address to the server firewall." -ForegroundColor Yellow}
    "{0,-30}  {1,12}  {2,4}" -f ("Account", "Exp Date", "DTE")
    "{0,-30}  {1,12}  {2,4}" -f ("--------", "--------", "----")        
	$notifyDate = 30
    $warnDate = 20
    $critDate = 10
    $accountlist | %{
            $writeline = "{0,-30}  {1,12}  {2,4}" -f ($_.AccountName, $_.ExpirationDate, $_.DaysToExpiration)
			if($_.DaysToExpiration -le $critDate)
			{
				Write-Host $writeline -ForegroundColor Red
			}
			elseif ($_.DaysToExpiration -le $warnDate)
			{
				Write-Host $writeline -ForegroundColor Yellow
			}
            elseif ($_.DaysToExpiration -le $notifyDate)
            {
                Write-Host $writeline -ForegroundColor White
            }
            else 
            {
                $null
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

$ScriptDirectory = split-path $MyInvocation.MyCommand.path

while(1)
{
    DisplayHud
    Start-Sleep -Seconds (60)
}

