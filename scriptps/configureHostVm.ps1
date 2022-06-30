# Ref: https://github.com/microsoft/azure_arc/blob/main/azure_jumpstart_arcbox/artifacts/Bootstrap.ps1

$ErrorActionPreference = "stop"

<#
# Installing tools
$chocolateyAppList = 'azure-cli,az.powershell,microsoft-edge,azcopy10,vscode,git,7zip'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$appsToInstall = $chocolateyAppList -split "," | ForEach-Object { "$($_.Trim())" }

foreach ($app in $appsToInstall)
{
    Write-Host "Installing $app"
    & choco install $app /y -Force | Write-Output
}
#>

Start-Transcript -Path 'c:\arcsvlab-eval\002-configureHostVm.log' 

Write-Host "Installing features"

Install-WindowsFeature -Name "DNS" -IncludeManagementTools
Install-WindowsFeature -Name "DHCP" -IncludeManagementTools
Install-WindowsFeature -Name Hyper-V -IncludeAllSubFeature -IncludeManagementTools -Restart

Write-Output "Setting the network of Hyper-V "

New-VMSwitch -Name "InternalNAT" -SwitchType Internal
New-NetIPAddress -IPAddress 10.0.0.254 -PrefixLength 24 -InterfaceAlias "vEthernet (InternalNAT)"
New-NetNat -Name "ArcNat" -InternalIPInterfaceAddressPrefix 10.0.0.0/24

Write-Output "Setting DHCP"

Add-DhcpServerv4Scope -name "internal" -StartRange 10.0.0.100 -EndRange 10.0.0.200 -SubnetMask 255.255.255.0 -State Active
Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.0.254 -ScopeID 10.0.0.0 
Set-DhcpServerv4OptionValue -DnsServer 10.0.0.254

Write-Output "Setting DNS"

Add-DnsServerForwarder -IPAddress 168.63.129.16

Stop-Transcript