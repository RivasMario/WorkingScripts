#/This guy couldn't connect via AAD and downloaded the cert and installed directly on the box to authenticate to Fabric /#

$ConnectArgs = @{ ConnectionEndpoint = 'asi-sf-usgov-uga.usgovarizona.cloudapp.usgovcloudapi.net:19000'; AzureActiveDirectory = $True; ServerCertThumbprint = "D57593F2B0B88E4631077D12F8E0B99859A03CF9"}

Connect-ServiceFabricCluster @ConnectArgs

$ConnectArgs = @{  ConnectionEndpoint = 'asi-sf-usgov-uga.usgovarizona.cloudapp.usgovcloudapi.net:19000';  X509Credential = $True;  StoreLocation = 'CurrentUser';  StoreName = "MY";  ServerCommonName = "sfcluster.uga.gov.sentinel.azure.us";  FindType = 'FindByThumbprint';  FindValue = "D57593F2B0B88E4631077D12F8E0B99859A03CF9" }

Connect-ServiceFabricCluster @ConnectArgs

$nodeType = "primary"
$nodes = Get-ServiceFabricNode
$nodes.NodeName

Write-Host "Disabling nodes..."
foreach($node in $nodes)`
{`
  if ($node.NodeType -eq $nodeType)`
  {`
    $node.NodeName`
`
    #Disable-ServiceFabricNode -Intent RemoveNode -NodeName $node.NodeName -Force`
  }`
}


Write-Host "Disabling nodes..."
foreach($node in $nodes)`
{`
  if ($node.NodeType -eq $nodeType)`
  {`
    $node.NodeName`
`
    Disable-ServiceFabricNode -Intent RemoveNode -NodeName $node.NodeName -Force`
  }`
}
foreach($node in $nodes)`
{`
  if ($node.NodeType -eq $nodeType)`