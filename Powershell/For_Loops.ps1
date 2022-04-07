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
$pets - @("Cat", "Dog", "Fish", "Turtle")
$pets.Count

$pets[2]

"My pets in order:"
for ($i = 0; $i -lt $pets.Count; $i++) {
    $pets[$i]
}