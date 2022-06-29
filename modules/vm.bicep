param vmLocation string
param adminUserName string
@secure()
param adminPassword string
param vnetId string
param numberOfVms int = 1
param suffix string

resource pipVm 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: 'pip-${suffix}'
  location: vmLocation
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nicForVm 'Microsoft.Network/networkInterfaces@2021-08-01' = [for i in range(1, numberOfVms): {
  name: 'nic${suffix}-0${i}'
  location: vmLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.4.10${i}'
          subnet: {
            id: '${vnetId}/subnets/iaasSubnet'
          }
          publicIPAddress: {
             id: pipVm.id
          }
        }
      }
    ]
  }
}]

resource amaUbVm01 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'vm${suffix}-archost01'
  location: vmLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osProfile: {
      computerName: 'mmaWinVm01'
      adminUsername: adminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        patchSettings: {
          patchMode: 'AutomaticByOS'
        }
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 64
          lun: 0
          createOption: 'Empty'
          caching: 'ReadOnly'
        }
      ]
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-core-smalldisk-g2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicForVm[0].id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}
