<#
HashTables:

A hash table is a compact data structure that stores one or more key/value pairs.
Example: A series of IP addresses and computer names
#>

# Creating a Hashtable
$hash = @{}

#########################
# Adding to a hashtable #
# Hash tables are not expected to be in order, will pull randomly

$hash.Add("Person", "John")
$hash.Add("Email", "John@john.com")
$hash.Add("Pet", "Cat")
$hash.Add("Surname", "Smith")
$hash

# Removing key from hashtable
$hash.Remove("Surname")

#Pre-populating hashtables
$details = @{
    Person = "Mike"
    Email = "Mike@Mike.com"
    Pet = "Dog"
}
$details

# Adding key thgat already exists throws error
$details.Add("Pet", "Snake")

###################
# Accessing Items #

#Gets name of Key wanted
$details["Pet"] #explicity tells this is a hash table
$details.Pet

# We can use a variable instead, much more useful for dynamic
$property = "Email"
$details[$property]

#Accessing multiple properties at the same time
$details["Email", "Person"]

#Non-existent value don't throw errors
$details.["Surname"]
$details.Surname

#Although it doesn't throw we can check it with true/false [bool]
[bool]$details["Surname"]

###################
# Updating Values #

#We can update and add new values
$details.["Pet"] = "Snake"
$details["Drink"] = "Flat White"
$details

$details.Pet = "Dog"
$details.Food = "Lamb Gyro"
$details

###########
# Looping #

foreach ($key in details.Key) {
    "{0} is {1}" -f $key, $details[$key]
}

# Piping to ForEach-Object
$details.Key | Foreach-Object {
    "{0} is {1}" -f $_, $details[$_]
}

#GetEnumerator allows us to work with properties/ work like an object
$details.GetEnumerator() | ForEach-Object {
    "{0} is {1}" -f $_.Key, $_.value
}

#Values can't be updated while enumerated
Foreach ($key in $details.Key) {
    $details[$key] = "Blah"
}

#Keys must be cloned before updating
$details.Keys.Clone() | ForEach-Object {
    $details[$_] = "Sanitized"
}
$details

######
# IF #

# Checking if hashtable exists
if $details {"It's There"}

$empty = @{}
if ($empty) {"It's empty but there"}

if ($details.Person) {"There's some info about a person"}

#Details with false
$details.add("Empty", "")
$details.Add("Null",$Null)
$details.Add("False", $false)
$details

#The Values are there but it returns as negative
#It's using the .net methods instead of finding the value
if ($details.Empty) {"It's there"}
if ($details.Null) {"It's there"}
if ($details.False) {"It's there"}

# COntainsKey is a special method  in hashtable
if ($Details.ContainsKey("Null")) {"It's there"}

$PSBoundParameters

#####################
# Custom Expression #

$employee = @{
    Name = "Beth"
    HourlyWage = 10
    HoursWorked = 7.5
}
#Opening new hashtable, N is Name & E is Expression
$employee | Select-Object -Property *,@{N = "Wage"; E = {$_.HourlyWage * $_.HoursWorked}}

#############
# Splatting #

Invoke-RestMethod -Uri catfact.ninja/facts -Method GET | Select-Object Data -ExpandProperty Data

#A way of passing params to function via hashtable, try to make more readable
$params = @{
    Uri = "catfact.ninja/facts"
    Method = "GET"
}

Invoke-RestMethod @params | Select-Object Data -ExpandProperty Data

# Adding parameters

$Verbose = $true
if ($Verbose) {
    $params["Verbose"] = $true
}

Invoke-RestMethod @params

#####################
# Nested Hashtables #

$Environments = @{

    Development = @{
        Server = "Server1"
        Admin = "Rachel Green"
        Credentials = @{
            Username = "Serv1"
            Password = "Secret"
        }
    }

    Test = @{
        Server = "Server2"
        Admin = "Joe Triviani"
        Credentials = @{
            Username = "Serv2"
            Password = "Letmein"
        }
    }

}

#Accessing nested properties
$Environments
$Environments.Keys
$Environments.Values

#You want more specificity
$Environments.Test
$Environments.Test.Credentials
$Environments["Test"]["Credentials"]

# Updating nested properties
$Environments.Test.Credentials.Username = "admin"
$Environments.Test.Credentials

# Quickly unwrapping all properties
$Environments | ConvertTo-Json -Depth 99

# Adding nested properties
$Environments['Production'] = @{}
$Environments.Production.Server = "Server3"
$Environments.Production.Admin = "Ross Geller"
$Environments.Production['Credentials'] = @{}
$Environments.Production.Credentials.Username = "Serv3"
$Environments.Production.Credentials.Password = "Nosuchplace"

#####################
# Working with JSON #
#####################

$Environments | ConvertTo-Json | Out-File C:\temp\envs.json
Get-Content C:\Temp\envs.json | ConvertFrom-Json #This will create pscustomobject

##################
# PSCustomObject #
##################

# Creating a new object
# Powershell says it's all  an object
$EnvironmentsObject = [pscustomobject]@{

    Development = @{
        Server = "Server1"
        Admin = "Rachel Green"
        Credentials = @{
            Username = "Serv1"
            Password = "Secret"
        }
    }

    Test = @{
        Server = "Server2"
        Admin = "Joe Triviani"
        Credentials = @{
            Username = "Serv2"
            Password = "Letmein"
        }
    }
}

# Casting hashtable to object
# You can convert it to a customobjec if already made
[PSCustomObject]$Environments