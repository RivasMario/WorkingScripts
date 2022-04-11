# Context
# A common scenario for our team is automation of processes on build machines and/or user tooling.Assume you have an executable that takes two words, a noun (ball, car, dog) and an adjective (big, small,red) and returns a sentence in JSON format.

# Input:Sentence.exe red ball
# Output:{ “sentence”: “The ball is red.” }
# Input:Sentence.exe big truck
# Output:{ “sentence”: “The truck is big.” }

# Problem Statement
# Write-Output a PowerShell script that wraps this exe, with auto completion, discoverability, help, and error handling.

# Input: Sentence.ps1 -Noun Ball -Adjective Red
# Output: “The Ball is Red.”

$MyVariable =@{}
$MyVariable['Noun'] = 'Ball'
$MyVariable['Adjective'] = 'Red'

#$BatItself = ./sentence.bat

if ($MyVariable) {
    #$BatInput = '{0} {1}' -f $MyVariable.Noun, $MyVariable.Adjective
    $JsonOut= ./sentence.bat $MyVariable.Noun $MyVariable.Adjective
    $MyOutput = $JsonOut | ConvertFrom-Json
    $MyOutput.Sentence
}

function sentenceMaker($Noun, $Adjective) {
    $JsonOut = ./sentence.bat $Noun $Adjective
    $Out = $JsonOut | ConvertFrom-Json
    $Out.Sentence
}

sentenceMaker($MyVariable.Noun, $MyVariable.Adjective)

#4/10/2022 Need to add command line argumenst for the script, auto completion, discoverability, help and error handling