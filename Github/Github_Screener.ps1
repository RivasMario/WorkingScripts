$url = "https://esescreener.azurewebsites.net/api/screener/submit/39f26a498befe029f3436cf2db6583c2"

$body = @{
    "name" = "Mario Rivas"
    "favorite" = "ls -a"
    "code"= "Nzk0ODc4N2I4NjYzZjhiNDViMjFiMWJmMjUxODNlMDcxODY5OTZhMz1leHBpcmVzLTE2MTg1MDU5MjI4MDM7RXhwaXJlcz1UaHUsIDE1IEFwciAyMDIxIDE2OjU4OjQyIEdNVDtMYW5nPUVO"
}

Invoke-RestMethod -Method 'POST' -Uri $url -Body ($body|ConvertTo-Json) -ContentType "application/json"