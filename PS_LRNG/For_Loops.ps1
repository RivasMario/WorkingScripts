#Basic Syntax
# for (Initial Value/statement; Condition; Repeat)  {Run my code}

#Initial value: Set this up before starting the loop
#Condition: For loop ends, when condition evaluates to false or it keeps running as long as condition is true
#Repeat: Do this after every loop

for ($MyVariable = 0; $MyVariable -lt 10; $MyVariable = $MyVariable + 1) {
    '$MyVariable is {0}' -f $MyVariable
    Start-Sleep -Seconds 2
}

for ($MyVariable = 0; $MyVariable -lt $MyVariable++) {
    'MyVariable is {0}' -f $MyVariable
}

#We can also decrease

for ($MyVariable = 10; $MyVariable -gt 5; $MyVariable -1) {
    '$MyVariable is {0}' -f $MyVariable
}

#specify variable outside of if
$outside = 7
for (; $outside -lt 15; $outside++) {
    'Outside is {0}' -f $outside
}

#Looping through array
$pets = @("Cat", "Dog", "Fish", "Turtle")
$pets.Count

$pets[2] 

"My pets in order:"
for ($i = 0; $i -lt $pets.Count; $i++) {
    $pets[$i]
}

#How about if i'd like to add a numbered list

Write-Output "My pets in order:`n"

for ($i = 0; $i -lt $pets.Count; $i++) {
    $Number = $i +1
    "  {0}. {1}" -f $Number, $pets[$i]
}

# Can also be used to count strings

for ($text = ''; $text.Length -lt 10; $text += '@') {
    $text
}

# Nested for, grid situation where they are printed
$row = 1..10
$column = 1..10

for ($i = 0; $i -lt $row.Count; $i++) {
    for ($j = 0; $j -lt $column.Count; $j++) {

        $r = $row[$i]
        $c = $column[$j]
        $result = $r * $c

        $t = "{0} * {1} = {2}" -f $r, $c, $result
        Write-Host $t
    }
}

#never ending script have to do an interrupt CTRL + C
#didn't specify condition so it goes on forever
for ( $i = 0; ; $i++) {
    "Loop number: $i"
}

#We can write a condition inside the loop to break out
for ( $i = 0; ; $i++) {
    "Loop number: $i"
    if ($i -eq 1000) {
        "Break out at: {0}" -f $i 
        break
    }
}

# A real use case with Azure Application Insights

$Headers = @("First Name", "Email", "Phone Number")

$Rows = @(
    @("Kamil", "kamil@kamil.mail", "111-111-111"),
    @("John", "john@john.mail", "222-222-222"),
    @("Abigail", "abigail@abigail.mail", "333-333-333")
)

#List is like an array, however it allows the ability to add new entries to it
#Arrays cannot be expanded by definition, not designed for it
#CSharp Object, Generic List object
$result = New-Object System.Collections.Generic.List[System.Object]

#Work through each one at a time
#foreach local variable on the fly
foreach ($row in $rows) {

    #We need a blank powershell object. 
    #Declarea hash-table and the type is PScustomObject
    $record = [PSCustomObject]@{}

    #Now iteration through each property in the row
    #Gets first header and adds it, then add all the others in array
    #Does it for the first row, then restarts for the next row
    for ($i = 0; $i -lt $Headers.Count; $i++) {

        #Powershell objects can add members
        $record | Add-Member -MemberType NoteProperty -Name[$i] -Value $row[$i]
    }

    #We add completed object to the list
    $result.Add($record)

}

#Display list with all record
$record

$result.Email
$result.'First Name'
