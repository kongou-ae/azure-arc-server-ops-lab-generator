# Ref: https://github.com/microsoft/azure_arc/blob/main/azure_jumpstart_arcbox/artifacts/Bootstrap.ps1

$ErrorActionPreference = "stop"

# Installing tools
$chocolateyAppList = 'azure-cli,az.powershell'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$appsToInstall = $chocolateyAppList -split "," | ForEach-Object { "$($_.Trim())" }

foreach ($app in $appsToInstall)
{
    Write-Host "Installing $app"
    & choco install $app /y -Force | Write-Output
}

Start-Transcript -Path 'c:\arcsvlab-eval\configureHostVm.log' 

Write-Host "Installing features"

$hyperV = Get-WindowsFeature -Name Hyper-V
if($false -eq $hyperV.Installed){
    Install-WindowsFeature -Name DNS -IncludeManagementTools
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
    Install-WindowsFeature -Name Hyper-V -IncludeAllSubFeature -IncludeManagementTools -Restart
}

Stop-Transcript
