$ChassisManagers = @(
"P20AGR5CMCA104B",
"P20AGR5CMCA104M",
"P20AGR5CMCA104T",
"P20AGR5CMCA105B",
"P20AGR5CMCA105M",
"P20AGR5CMCA105T",
"P20AGR5CMCA106B",
"P20AGR5CMCA106M",
"P20AGR5CMCA106T",
"P20AGR5CMCA108B",
"P20AGR5CMCA108M",
"P20AGR5CMCA108T",
"P20AGR5CMCA109B",
"P20AGR5CMCA109M",
"P20AGR5CMCA109T"
)

foreach ($ChassisManager in $ChassisManagers) {

24..13 | ForEach-Object{
    Set-BladeNextBoot -ChassisManager $ChassisManager -BladeID $_ -BootType ForceDefaultHdd -Persistent:$true -UEFI:$true -Confirm:$false
    
    Write-Host "Completed set-bladenextboot for $ChassisManager and Blade $_"  

    }

Write-Host "CM $ChassisManager complete"

}
