#link to the video:

#Documentation

#What is an array and why is it needed?

<#
Array is a data structure that allows you to collect multiple item under one collection
so the items can be accessed at will, iterated over, and updated as need be

Arrays allow you to work with a bunch of variables in a more human readable form
#>

#Create an empty array
$stuff = @()
$stuff
"Numbering it out: $($stuff.Count)"

#fill an array
$stuff = @("Fork", "Knife", "Spoon")
$stuff
"Numbering it out: $($stuff.Count)"

#comma separating also works
$stuff = "Fork", "Knife", "Spoon"
$stuff
"Numbering it out: $($stuff.Count)"

##########

#Accessing items in the array#
# Arrays always start at 0

$stuff[0]
$stuff[-1]
$stuff[2,1,2,1]
$stuff[0..2]
$stuff[2..0]

#accessing items outside of an array is silent
$stuff[20]
[bool]$stuff[20]

#you can mix different types in an array

$mix = @("Hi",74,(Get-Date), "Bye")
$mix

#More often we can store objects

$people = @(
    [PSCustomObject]@{Name = "John"; Email = "john@john.com"}
    [PSCustomObject]@{Name = "Tony"; Email = "tony@tony.com"}
    [PSCustomObject]@{Name = "Fiber"; Email = "fiber@optics.com"}
) 
$people
$people[-1]
$people.Email
$people | Where-Object {$_.Name -eq "John"} #returns the object
$people.Where({$_.Name -eq "John"}).Email

#null will throw an error
$NotaRealArray[3]

###########
#Looping#

$domains = @("bbc.com", "github.com", "youtube.com", "bellingcat.com")

#Env variable neccessary
$ProgressPreference = "SilentlyContinue"

foreach ($domain in $domains) {
    $Result = Test-Connection -ComputerName $domain -Quiet
    "$domain is pinging: $Result"
}

#Different than the later one, does one each by each then pumps out
$domains | ForEach-Object {
    $Result = Test-Connection -ComputerName $_ -Quiet
    "$_ is pinging: $Result"
}

#For Each method
#Does them all then pumps them out to you
$domains.ForEach{
    $Result = Test-Connection -ComputerName $_ -Quiet
    "$_ is pinging: $Result"
}

#Doesnt use the period because it's an array not an object
for ($i =0; $i -LT $domains.Count; $i++) {
    $Result = Test-Connection -ComputerName $domain -Quiet
    "$($domains[$i]) is pinging $Result"
}

######################
# Updating Values #

$Week = @("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
$Week[2]  #Currently Wednesday
$Week[2] = "Boo"
$Week[2]
$Week

#Updating non existent member of array throws error
$Week[8] ="Hi"

#Join
$Week
$Week -join "|"
$Week -join "," #essentially making a csv file
$Week -join $null

#In or in other words search
"Tuesday" -in $Week

#match
$Week -match "es"

###################
# Adding to array #

#Arrays are typically fixed memory, updates are not allowed
#Powershell a
llows you to do that. 
#Powershell in essence created new array, copies content from old array, and removes old one
#If you plan to add items to array, use ArrayList and List

#Adding elements to an array
$Week
$Week.Add("January") #This is an error
$Week += "January"
$Week

#Adding arrays together
$ArrayA = 1..10
$ArrayB = 11..20
$ArrayA + $ArrayB

##############
# Array List #

$alist = [System.Collections.ArrayList]::new() #This is .Net framework
#pops out 0 or 1 depending on if it runs successfully
$alist.Add("January")
#Prevents performance hit like regular add does
#Void stops prevents writing to console
[void]$alist.Add("February")
$alist

# removing from ArrayList

$alist.Remove($alist[1])
$alist