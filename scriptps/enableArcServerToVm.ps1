$ErrorActionPreference = "stop"

Param( 
    [parameter(mandatory=$true)][string]$name, 
    [parameter(mandatory=$true)][securestring]$LocalAdministratorPassword,
    [parameter(mandatory=$true)][string]$location,
    [parameter(mandatory=$true)][string]$resourceGroup

)

Start-Transcript -Path 'c:\arcsvlab-eval\Bootstrap.log' -Append

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "10.0.0.100"  -Force

$Cred = New-Object System.Management.Automation.PSCredential("administrator",$LocalAdministratorPassword)
$pssession = New-PSSession 10.0.0.100 -Credential $cred

Install-module Az.ConnectedMachine -Force
Connect-AzConnectedMachine -ResourceGroupName $resourceGroup -Name $name -Location $location -PSSession $pssession

Stop-Transcript
