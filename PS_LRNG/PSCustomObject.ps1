<#
About PsCustomObject:
    https://forums.powershell.org/t/what-is-the-difference-between-pscustomobject-and-psobject/3887/4
    [PSCustomObject] is a type accelerator. It constructs a PSObject, but does so in a way that results in hash table keys becoming properties. 
    PSCustomObject isn’t an object type per se - it’s a process shortcut. 

    The docs are relatively clear about it (https://msdn.microsoft.com/en-us/library/system.management.automation.pscustomobject(v=vs.85).aspx) 
    PSCustomObject is a placeholder that’s used when PSObject is called with no constructor parameters.

    HashTable is like a bag you throw key/value pairs to use later and don't care about order or specificty
    PSCustomObjects are a collection that represents an item and has data types like the object type, methods, and properties

    hashTables are hoes you have to move around and control with other commands
    PSCustomObject have their own will $PSCustomObject | Get-Member
#>

#Creating custom object
$obj =[PsCustomObject]@{
    Name = "Mr Fiber"
    Species = "Domestic Cat"
    Type = "Tabby Cat"
}
$obj
$obj.Name

#Saving a file (JSON)
# We could save CSV, however CSV don't support nested properties, thus why JSOn is preferred
$Path = "$env:TEMP\pstojson.json"
$obj | ConvertTo-json -Depth 99 | Set-Content -Path $Path
$imported = Get-Content -Path $Path
$imported
$imported | ConvertFrom-json

##############
# Properties #

#  Accessing properties
$obj.Species

# Dynamically accessing properties
$prop = "Type"
$obj.$prop

# Adding property
#If youy want to add more properties, need to do add member
# Will complain if you try to add the same member again
$obj | Add-Member -MemberType NoteProperty -Name "Favorite Snack" -Value "Dental Treats"
$obj."Favorite Snack"

# Removing Properties
$obj.psobject.Properties.Remove("Favorite Snack")
$obj."Favorite Snack"

# Listing Properties
$obj.psobject.properties.Name
$obj | Get-Member -MemberType NoteProperty