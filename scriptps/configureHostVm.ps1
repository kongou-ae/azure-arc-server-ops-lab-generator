# Ref: https://github.com/microsoft/azure_arc/blob/main/azure_jumpstart_arcbox/artifacts/Bootstrap.ps1

$ErrorActionPreference = "stop"
Start-Transcript -Path 'c:\Bootstrap.log' -append

# Installing tools
$chocolateyAppList = 'azure-cli,az.powershell,microsoft-edge,azcopy10,vscode,git,7zip'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$appsToInstall = $chocolateyAppList -split "," | ForEach-Object { "$($_.Trim())" }

foreach ($app in $appsToInstall)
{
    Write-Host "Installing $app"
    & choco install $app /y -Force | Write-Output
}

Write-Output "Installing DHCP service"
Install-WindowsFeature -Name "DHCP" -IncludeManagementTools

Write-Host "Installing Hyper-V"
Install-WindowsFeature -Name Hyper-V -IncludeAllSubFeature -IncludeManagementTools -Restart

Write-Output "Installed Hyper-V"
