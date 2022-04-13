Set-Location "H:\Randomsftp\TESTING"
$files = Get-ChildItem -Path ".\*.txt"
ForEach ($file in $files) {
    (Get-Content $file) -Replace "~","~`r`n" | Out-File -FilePath ("H:\Randomsftp\TESTING-MORE\" + $file.Name)
    Remove-Item $file
}