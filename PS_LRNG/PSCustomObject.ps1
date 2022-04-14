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

