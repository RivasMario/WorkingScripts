$ExecutionContext.SessionState.LanguageMode

Add-Type -AssemblyName System.Security

# Filtering for cert requirements...
$ValidCerts = [System.Security.Cryptography.X509Certificates.X509Certificate2[]](dir Cert:\CurrentUser\My | where { $_.NotAfter -gt (Get-Date) })

# You could check $ValidCerts, and not do this prompt if it only contains 1...
$Cert = [System.Security.Cryptography.X509Certificates.X509Certificate2UI]::SelectFromCollection(
    $ValidCerts,
    'Choose a certificate',
    'Choose a certificate',
    'SingleSelection'
) | select -First 1

$WebRequestParams = @{
    Uri = $Url       # Uri to file to download
    OutFile = $Path  # Path to where file should be downloaded (include filename)
    Certificate = $Cert
}
Invoke-WebRequest @WebRequestParams