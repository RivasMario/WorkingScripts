#Basics
#if true then do this

if ($true) {"This is true"}

if ($false) { "This is false" }

#if something is true then do this, otherwise do that

if ($true) { "This is true" } else { "This is false" }

if ($false) { "This is true" } else { "This is false" }

#comparison

if ( 5 -gt 3 ) { "This is more" } else { "This is less" }

$random = Get-Random -Minimum 1 -Maximum 11
$random

if ($random -ge 5 ) { "Random is more than 5" } else { "Random is less than 5" }

if (($random = Get-Random -Minimum 1 -Maximum 11) -ge 5) {"Random is more than 5!"} else { "Random is less than 5"}

$number = 5
if (($random = Get-Random -Minimum 1 -Maximum 11) -ge $number) {"Random is more than 5!"} else { "Random is less than 5"}

if ($nonExisting -eq $true) { "That variable exists"} else { "It doesn't exist"}

if ($user) {"User Exists"} else {"User doesn't exist"}
#powershell defaults so that the comparison is checking if statement is true

#hashtable
$user =@{}
$user['Name'] = 'Geralt'
$User['Surname'] = 'of Rivia'
$user
if ($user) {"User Exists"} else {"User doesn't exist"}

#More complex ops
if ($user) {
    #makes an email for user, uses hashtable, replaces spaces with nothing in case they exist
    $email = '{0}.{1}@novigrad.com' -f $user.Name, $user.Surname -replace ' ', ''
    "Found user: $($user.Name) $($user.Surname)"
    "Email for user: {0}" -f $email.ToLower()
}

#like Operator, know part of string but not whole thing
if ($email -like "*Rivia*") { "Email has Rivia in it"}

#We can check if something is not true
if ( -not $user1) {"This iser doesn't exist"}
#exclmamation mark means not
if (!$user1) {"This user doesn't exist"}

#more complex logic
if ($user.Name -eq "Geralt" -AND $user.Surname -eq "of Rivia") {"User exists"}
if ($user.Name -eq "Geralt" -AND $user.Surname -eq "of Rivia" -OR $user1) {"User Exists"}
#breakdown of above
if ($user.Name -eq "Geralt"-OR
    $user.Surname -eq "of Rivia" -OR
    $user1) {
        "User Exists"
    }

$Folder = "C:\Windows"
if (Test-Path -Path $Folder) {"Folder: $Folder Exists!"}

#Nested IF statements
if ($user.Name -eq "Geralt") {
    if ($user.Surname -eq "of Rivia") {
        if ($email) {
            "User created successfully"
        }
        else {
            "User's email is not created"
        }
    }
        else {
            "User's surname is not created"
        }
}
else {
    "User's name is not set"
}

#Mutltiple if else statements
$today = (Get-Date).DayOfWeek

if ($today -eq "Monday" -OR $today -eq "Tuesday" -OR $today -eq "Wednesday" -OR $today -eq "Thursday" -or $today -eq "Friday") {
    "Today is a working day"
}
elseif ($today -eq "Saturday") {
    "Today is the first day of the weekend"
}
elseif ($today -eq "Sunday") {
    "Today is the last day of the week. The work week begins tomorrow"
}
else {
    "Unknown day: $today"
}

#Switch
switch ($today) {
    { $_ -in ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday")} {"Today is a working day"}
    "Saturday" {"Today is the first day of the weekend"}
    "Sunday" {"Today is the last day of the week"}
    default {"Unknown day: $today"}
}