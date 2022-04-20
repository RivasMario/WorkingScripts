<#
4/19/2022 Make sure they have the right JIT FABRIC permissions or even a new build form the share won't work
#>

Update-ServiceFabricClusterUpgrade  -UpgradeMode  UnmonitoredAuto
 
$doneUD = $false
do {
	$sfCU = Get-ServiceFabricClusterUpgrade
	 
	if ( $sfCU.UpgradeState -eq "RollingForwardCompleted") {
		Write-Host "Upgrade Completed" -ForegroundColor Green
		 
		$doneUD = $true 
	} else {
	 
		$nodes = ( $sfCU.CurrentUpgradeDomainProgress.NodeProgressList | where-object {$_.UpgradePhase -ne "Upgrading"}).NodeName
        $ud = $sfCU.CurrentUpgradeDomainProgress.UpgradeDomainName
        $nextUd = $sfCU.NextUpgradeDomain #
        Write-Host "I am upgrading UD $ud, next ud is $nextUd" -ForegroundColor Yellow
  
		$nodesCount = $nodes.Count
		Foreach ($node in $nodes) { 
            try {
                Restart-ServiceFabricNode $node
            } catch {
            } 
        }
		 
		if ($nodesCount  -gt 0) {
			Start-Sleep -Second 300
		} else {
			Start-Sleep -Second 30
		}
	}
 
}  while (-not $doneUD)
