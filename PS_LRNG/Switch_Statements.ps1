#Basic version

<#
switch (test-valuer) {
    condition {do stuff}
    another condition {do-stuff}
}
#>

#This will print out Green
#no conditions on this one

switch (2) {
        0 {"Blue"}
        1 {"Yellow"}
        2 {"Green"}
        3 {"Red"}
}

#Working with a variable
$number = 1
switch ($number) {
        0 {"Blue"}
        1 {"Yellow"}
        2 {"Green"}
        3 {"Red"}
}

#Assigning variables with scriptblock
$number = 3
switch ($number) {
    0 {$result = "Blue"}
    1 {$result = "Yellow"}
    2 {$result = "Green"}
    3 {$result = "Red"}
}
Write-Host "The result is: $result" -ForegroundColor $result

#We can also assign statement to a variable
#Kinda ends up being a cheap version of a function, not really one tho
# I fucked up earlier because I copied the above assigning the result in the block
$number = 0
$result = switch ($number) {
    0 { "Blue" }
    1 { "Yellow"}
    2 { "Green"}
    3 { "Red"}
}
Write-Host "The result is: $result" -ForegroundColor $result

#Using default when there is not match
$number = 8
$result = switch ($number) {
    0 { "Blue" }
    1 { "Yellow"}
    2 { "Green"}
    3 { "Red"}
    default {
        #Write-Warning doesn't give a value, system knows its alerting you
        Write-Warning "Unknown value, defaulting to White"
        "White"
    }
}
Write-Host "The result is: $result" -ForegroundColor $result

#Strings can also be matched
#This also shows working on expressions

switch ((Get-Host).Name) {
    "Visual Studio Code Host" {"You are using VS CODE"}
    "ConsoleHost" {"You are using Console!"}
    default {"Unknown host $_"}
}

#Arrays
#Runs through the list, leaves out one where it doesnt match a value in the array
$employees = @("Developer", "Project Manager", "Devops Engineer", "Developer", "Sysadmin")

switch ($employees) {
    "Developer" {"We need a Developer!"}
    "Project Manager" {"We need a Project Manager"}
    "DevOps Engineer" {"We need a DevOps Engineer"}
    "Sysadmin" {"We need a Sysadmin"}
}

#using a script block when comparing value
#conditions to push otu a value
#Other ones it just compare values natively

$age = 25

switch ($age) {
    {$_ -ge 18} {
        "An Adult"
    }

    {$_ -lt 18} {
        "Not an adult"
    }
}
#powershell is usually not case sensitive
#Powershell will match multiple times
#all of them get pumped out
switch ("something") {
    "something" {"This is lowercase"}
    "SOMETHING" {"This is uppercase"}
    "SomeThinG" {"This is mixed"}
}

#Stop execution with break, break stops that event itself

switch ("something") {
    "something" {"This is lowercase"}
    "SOMETHING" {"This is uppercase"; break}
    "SomeThinG" {"This is mixed"}
}


#Make text case sensitive with a switch
#A few switches exist for switch
#Remember parenthesis then Curly brackets
switch -CaseSensitive ("something") {
    "something" {"This is lowercase"}
    "SOMETHING" {"This is uppercase"; break}
    "SomeThinG" {"This is mixed"}
}

#enable wildcard
#activates wildcard in the block
switch -Wildcard ("mix") {
    "*lower*" {"This is lowercase"}
    "*upper*" {"This is uppercase"; break}
    "*mix*" {"This is mixed"}
    default {"Unknown"}
}

#regex version
#also inside
switch -Regex ("mix") {
    "^lower" {"This is lowercase"}
    "^upper" {"This is uppercase"}
    "^mix" {"This is mixed"}
    default {"Unknown"}
}

#Switch is best for more than a complicated if else statement
#More human readable