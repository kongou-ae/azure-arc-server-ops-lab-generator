Param( 
    [parameter(mandatory=$true)][string]$name, 
    [parameter(mandatory=$true)][string]$LocalAdministratorPassword,
    [parameter(mandatory=$true)][string]$location,
    [parameter(mandatory=$true)][string]$resourceGroup
)

$ErrorActionPreference = "stop"

Start-Transcript -Path 'c:\arcsvlab-eval\enableArcServerToVm.log'

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "10.0.0.100"  -Force

$securestring = ConvertTo-SecureString -AsPlainText $LocalAdministratorPassword
$Cred = New-Object System.Management.Automation.PSCredential("administrator",$securestring)
$pssession = New-PSSession 10.0.0.100 -Credential $cred

Install-module Az.ConnectedMachine -Force
Login-AzAccount -Identity
Connect-AzConnectedMachine -ResourceGroupName $resourceGroup -Name $name -Location $location -PSSession $pssession

Stop-Transcript
