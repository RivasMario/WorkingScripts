<#

    Updates
		2/21/18 - v-coprel 	- 	Script created
		4/4/18	- v-coprel	-	Decreased update frequency
		5/19/21 - v-copede	-   Removed SQLPassword value until cleared by compliance for cross boundary use
#>

$version = "1.0.1"

$host.ui.RawUI.WindowTitle = "ServiceAccounts - Version: $version"
function Get-Accounts(){
	
	#Creates DB conection
	$SQLServer   = "sql-svcacct-tracker.database.usgovcloudapi.net"
    $SQLDatabase = "db_svcacct_tracker"
    $SQLTable    = "svcacct_looper"
    $SQLUsername = "svcacctLooper"
    $SQLPassword = ""   #password removed until cleared by compliance
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
    $accounts = Get-Accounts
	$OutputData = @()

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
    Start-Sleep -Seconds (5*60)
}
