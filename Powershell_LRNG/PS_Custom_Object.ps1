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


#############
# Hashtable #
#############

# Converting hashtable to psobject:
$ht = @{
    Name    = "Mr Fiber"
    Species = "Domestic cat"
    Type    = "Tabby cat"
}
$ht
$htobj = [pscustomobject]$ht
$htobj

# Converting psobject to hashtable
$newHt = @{}
foreach ($property in $htobj.psobject.Properties.name) {
    $newHt[$property] = $htobj.$property
}
$newHt

###########
# Methods #
###########

# We can actually have some action!
# $this is a automatic variable, like $_
$method = {
    "Hi, my name is $($this.name) and I like to sleep."
}

$params = @{
    MemberType = "ScriptMethod"
    Name       = "SayHi"
    Value      = $method
}
$obj | Add-Member @params
$obj.SayHi()

# How about, converting Object to Hashtable, as the actual method?
$params = @{
    MemberType = "ScriptMethod"
    Name       = "OutHashtable"
    Value      = {
        $hash = @{}
        $this.psobject.properties.name.foreach({
                $hash[$_] = $this.$_
            })
        return $hash
    }
}
$obj | Add-Member @params
$obj.OutHashtable()

#########
# Types #
#########

#PSTYPENAME is a specific class in .net

$obj | Get-Member # now it is PSCustomObject, duh

$obj.psobject.TypeNames # this looks familiar
$obj.psobject.TypeNames.Insert(0, "Kp.CatsAreAwesome")
$obj | Get-Member

function Invoke-CAA {
    param ( 
        # We only accept parameter of type Kp.CatsAreAwesome
        [PSTypeName('Kp.CatsAreAwesome')]
        [Parameter(ValueFromPipeline)]
        $Cat 
        )
        
        # If $Cat has been passed, we call method SayHi(), otherwise we just say that cats are awesome (generally)
        if ($PSBoundParameters.ContainsKey('Cat')) {
            "Here's an awesome cat:"
            return $Cat.SayHi()
        } else {
            "Cats are awesome!"
        }
}
Invoke-CAA
Invoke-Caa -Cat $obj
Invoke-Caa -Cat "BLA"

# We can also specify type name at creation
$obj2 = [pscustomobject]@{
    PSTypeName = 'Kp.CatsAreAwesome'
    Name = 'Whiskers'
    Species = "Domestic cat"
    Type    = "Persian"
}

$method = {
    "Hi, my name is $($this.name) and I like to sleep."
}

$params = @{
    MemberType = "ScriptMethod"
    Name       = "SayHi"
    Value      = $method
}
$obj2 | Add-Member @params
$obj2 | Invoke-CAA

# Specify default output
Update-TypeData -TypeName kp.CatsAreAwesome -DefaultDisplayPropertySet Name,Type
$obj # list is now limited to only Name and Type properties
$obj2
$obj | Format-List -Property * #displays all

# Let's see arrays and pscustomobjects working together
$list = [System.Collections.Generic.List[pscustomobject]]::new()
$locations = @("London", "Sligo", "Barcelona", "Paphos", "Ubud", "Valdemosa")
$baseUri = "wttr.in/"

foreach ($location in $locations) {
    "Currently retrieving weather for: $location"
    $Uri = "{0}{1}?format=j1" -f $baseUri, $location
    $Uri
    $data = Invoke-RestMethod $Uri
    $result = [pscustomobject]@{
        City = $Location
        Temperature = $data.current_condition.temp_C
        Pressure =  $data.current_condition.pressure
    }
    $list.Add($result)
}
$list