param netLocation string
param suffix string

resource routetable 'Microsoft.Network/routeTables@2021-08-01' = {
  name: 'rt${suffix}'
  location: netLocation
  properties: {
    routes: [
    ] 
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'nsg${suffix}'
  location: netLocation
  properties: {
    securityRules: [
    ]
  }
}



resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: 'net${suffix}'
  location: netLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '192.168.2.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '192.168.3.0/24'
        }
      }
      {
        name: 'IaasSubnet'
        properties: {
          addressPrefix: '192.168.4.0/24'
          routeTable: {
             id: routetable.id
          }
          networkSecurityGroup: {
             id: nsg.id
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
