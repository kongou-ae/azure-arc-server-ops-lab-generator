# Ref: https://github.com/microsoft/azure_arc/blob/main/azure_jumpstart_arcbox/artifacts/Bootstrap.ps1

$ErrorActionPreference = "stop"

$result = Get-VMSwitch "InternalNAT" -ErrorAction Ignore

if ( $null -eq $result){
    New-VMSwitch -Name "InternalNAT" -SwitchType Internal
    New-NetIPAddress -IPAddress 10.0.0.254 -PrefixLength 24 -InterfaceAlias "vEthernet (InternalNAT)"
    New-NetNat -Name "ArcNat" -InternalIPInterfaceAddressPrefix 10.0.0.0/24

    Write-Output "Setting DHCP"

    Add-DhcpServerv4Scope -name "internal" -StartRange 10.0.0.100 -EndRange 10.0.0.200 -SubnetMask 255.255.255.0 -State Active
    Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.0.254 -ScopeID 10.0.0.0 
    Set-DhcpServerv4OptionValue -DnsServer 10.0.0.254

    Write-Output "Setting DNS"

    Add-DnsServerForwarder -IPAddress 168.63.129.16
}
