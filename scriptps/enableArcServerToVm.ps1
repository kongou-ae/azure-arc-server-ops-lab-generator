Param( 
    [parameter(mandatory=$true)][string]$name, 
    [parameter(mandatory=$true)][string]$LocalAdministratorPassword,
    [parameter(mandatory=$true)][string]$location,
    [parameter(mandatory=$true)][string]$resourceGroup
)

$ErrorActionPreference = "stop"

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "10.0.0.100" -Force

$result = Get-VM -Name arcWin2019sv01 -ErrorAction Ignore
if ( $null -ne $result){
    $securestring = ConvertTo-SecureString -AsPlainText $LocalAdministratorPassword -Force
    $Cred = New-Object System.Management.Automation.PSCredential(".\administrator",$securestring)
    $pssession = New-PSSession 10.0.0.100 -Credential $cred

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-module Az.ConnectedMachine -Force
    Login-AzAccount -Identity
    Connect-AzConnectedMachine -ResourceGroupName $resourceGroup -Name $name -Location $location -PSSession $pssession
}
