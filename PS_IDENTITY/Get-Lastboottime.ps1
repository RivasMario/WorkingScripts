Remove-Variable * -ErrorAction SilentlyContinue

$boxes =(

"BN1AGR3ADR011",
"BN1AGR3ADR021",
"BN1AGR3ADR211",
"BN1RGR3ADR011",
"BN1RGR3ADR021",
"BN1RGR3ADR211",
"DM2AGR3ADR011",
"DM2AGR3ADR021",
"DM2AGR3ADR211",
"DM2RGR3ADR011",
"DM2RGR3ADR021",
"DM2RGR3ADR211"  

)
$scriptBlock = {
Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime
}

foreach ($one in $boxes){
$host.ui.RawUI.WindowTitle =  "$one "   
 Invoke-Command -ComputerName $one -ScriptBlock $scriptBlock -credential $credential 
}