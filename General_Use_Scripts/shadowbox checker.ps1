Function Get-LoggedInuser {

[cmdletbinding()]
   $Computer =  
   "ffshadowa01",
   "ffshadowa02",
   "ffshadow101",
   "ffshadow102",
   "ffshadow103",
   "ffshadow01",
   "ffshadow02",
   "ffshadow03",
   "ffshadow04",
   "ffshadow05",
   "ffshadow06",
   "ffshadow07",
   "ffshadow08",
   "ffshadow09",
   "ffshadow10",
   "ffshadow11",
   "ffshadow12",
   "ffshadow13",
   "ffshadow14",
   "ffshadow15",
   "ffshadow16",
   "ffshadow17",
   "ffshadow18",
   "ffshadow19", 
   "ffshadow20",
   "ffshadow21",
   "ffshadow22",
   "ffshadow23",
   "ffshadow24",
   "ffshadow25",
   "ffshadow26",
   "ffshadow27",
   "ffshadow28",
   "ffshadow29",
   "ffshadow30",
   "ffshadow31",
   "ffshadow32",
   "ffshadow33"
   
   $Repeat = $True
   While ($Repeat)
   {
     cls
    ForEach ($Comp in $Computer) 
    { 
    If (-not (Test-Connection -ComputerName $comp -Quiet -Count 1 -ea silentlycontinue)) 
    {
    Write-Warning "$comp is Offline"; continue 
    } 
    $stringOutput = quser /server:$Comp 2>$null
          If (!$stringOutput)
         {
         Write "No one is currently logged in to $Comp"
         }
         ForEach ($line in $stringOutput){
           If ($line -match "logon time") 
          {Continue}

          [PSCustomObject]@{
           ComputerName    = $Comp
              Username        = $line.SubString(1, 20).Trim()
             }
          
        } 
     } 
    $Again = Read-Host "Run shadow check again?"

    If ($Again -eq "Yes" -Or $Again -eq "yes" -Or $Again -eq "y" -Or $Again -eq "Y" -Or $Again -eq "R" -Or $Again -eq "r")
    {
    $Repeat = $True
    } else {
        $Repeat = $False
        }
    }
    
}
Get-LoggedInUser
Read-Host -Prompt "Press Enter to exit"
