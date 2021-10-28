[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

function Get-Config()
{
    [xml]$configFile = Get-Content -Path "\\SVCACCTTRACKER\SvcAcctTracker\Deployment\config.xml"
    return $configFile
}

function Get-DB()
{
   #Creates DB conection
    [xml]$configFile = Get-Config
    $dbConfig = $configFile.ChildNodes.databases
    $accountConfig = $configFile.ChildNodes.accounts

    #Creates DB conection
    $SQLServer = $dbConfig.database.server
    $SQLDatabase = $dbConfig.database.database
    $SQLTable = ($dbConfig.database.table | Where-Object {$_.id -eq "looper"}).innertext
    $SQLUsername = ($accountConfig.account | Where-Object {$_.id -eq "Admin"}).name
    $SQLPassword = ($accountConfig.account | Where-Object {$_.id -eq "Admin"}).value
    $SQLConnectionTimeout = 60
    $SQLConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Encrypt=True;Connect Timeout={4}" -f $SqlServer,$SqlDatabase,$SqlUsername,$SqlPassword,$SqlConnectionTimeout
    $SQLConnection = New-Object System.Data.SQLClient.SQLConnection
    $SQLConnection.ConnectionString = $SqlConnectionString

    return $SQLConnection
}

Add-Type -AssemblyName PresentationFramework
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:SvcAcctDBEdit"
        Title="MainWindow" Height="950.577" Width="1678.783">
    <Grid Margin="0,0,2,1">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="12*"/>
            <ColumnDefinition Width="344*"/>
            <ColumnDefinition Width="384*"/>
            <ColumnDefinition Width="929*"/>
        </Grid.ColumnDefinitions>
        <Button x:Name="btnEdit" Content="Queue" HorizontalAlignment="Left" Margin="243,542,0,0" VerticalAlignment="Top" Width="76" Height="78" Grid.Column="2"/>
        <TextBox x:Name="txt_ID" HorizontalAlignment="Left" Height="23" Margin="50,527,0,0" TextWrapping="Wrap" Text="ID" VerticalAlignment="Top" Width="120" Grid.Column="1"/>
        <TextBox x:Name="txtField" HorizontalAlignment="Left" Height="23" Margin="50,558,0,0" TextWrapping="Wrap" Text="Field" VerticalAlignment="Top" Width="120" Grid.Column="1" RenderTransformOrigin="0.017,-0.899"/>
        <TextBox x:Name="txtChange" Grid.Column="2" HorizontalAlignment="Left" Height="76" Margin="0,544,0,0" TextWrapping="Wrap" Text="Change" VerticalAlignment="Top" Width="238"/>
        <Label x:Name="lbl_ID" Content="ID" HorizontalAlignment="Left" Margin="10,524,0,0" VerticalAlignment="Top" Grid.Column="1"/>
        <Label x:Name="lblField" Content="Field" HorizontalAlignment="Left" Margin="10,555,0,0" VerticalAlignment="Top" Grid.Column="1" RenderTransformOrigin="-2.21,0.513"/>
        <Label x:Name="lblChange" Content="Change" Grid.Column="2" HorizontalAlignment="Left" Margin="0,519,0,0" VerticalAlignment="Top"/>
        <DataGrid x:Name="dgResults" HorizontalAlignment="Left" Height="465" Margin="10,54,0,0" VerticalAlignment="Top" Width="1400" Grid.ColumnSpan="4"/>
        <ListView x:Name="lstQueue" HorizontalAlignment="Left" Height="284" Margin="10,625,0,0" VerticalAlignment="Top" Width="1400" Grid.ColumnSpan="4">
            <ListView.View>
                <GridView>
                    <GridViewColumn/>
                </GridView>
            </ListView.View>
        </ListView>
        <Button x:Name="btnDelete" Content="Delete" Grid.Column="3" HorizontalAlignment="Left" Margin="675,686,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="btnCommit" Content="Commit" Grid.Column="3" HorizontalAlignment="Left" Margin="675,661,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="btnDeleteRow" Content="Delete Row" HorizontalAlignment="Left" Margin="675,107,0,0" VerticalAlignment="Top" Width="75" Grid.Column="3"/>
        <Button x:Name="btnAddRow" Content="Add Row" HorizontalAlignment="Left" Margin="675,82,0,0" VerticalAlignment="Top" Width="75" Grid.Column="3" />
        <ComboBox x:Name="cmbTableSelect" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="346" Grid.ColumnSpan="2"/>

    </Grid>
</Window>


"@

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
