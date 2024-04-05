
# Maps domains to paths for FcShell on sovereign clouds.
$sovereignPaths =
@{
  "usme.gbl" = "\\USOE.GBL\Public\Builds\Branches\git_Azure_Compute_master\";
  "cme.gbl" = "\\CAZ.GBL\Builds\Branches\git_Azure_Compute_master\";
  "deme.gbl" = "\\DEOE.GBL\Public\Builds\Branches\git_Azure_Compute_master\"
}

$isSovereignClouds = $sovereignPaths.ContainsKey($Env:USERDNSDOMAIN);

if ($isInstall) {
  $remotePackagePath = Join-Path $PSScriptRoot "\";
}
Elseif (!$remotePackagePath -or ($remotePackagePath -eq "")) {
  $remotePackagePath = "\\reddog\builds\branches\git_azure_compute_master_latest\retail-amd64\Services\Controller\FcShell\";

  if ($isSovereignClouds)
  {
    $remotePackageRoot = $sovereignPaths[$Env:USERDNSDOMAIN]

    # Since we do not have "_latest" on the sovereign shares we must find the latest available build.
    $dirs = Get-ChildItem -Path $remotePackageRoot | sort -Descending
    $latestDir = $dirs[0]

    $remotePackagePath = Join-Path $remotePackageRoot $latestDir
    $remotePackagePath = Join-Path $remotePackagePath "\retail-amd64\Rdtools\FcShell\"
  }
}

$fcShellPackage = (dir "$remotePackagePath\..\..\..\..\packages\FcShell.$sku*")[0];
$retailAmd64 = "$remotePackagePath\..\..\..\..\retail-amd64";
if ($isSovereignClouds) {
  $fcShellPackage = (dir "$remotePackagePath\..\..\..\packages\FcShell.$sku*")[0];
  $retailAmd64 = "$remotePackagePath\..\..\..\retail-amd64";
}