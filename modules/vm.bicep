param vmLocation string
param adminUserName string
@secure()
param adminPassword string
param vnetId string
param numberOfVms int = 1
param suffix string

resource pipVm 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: 'pip${suffix}'
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

resource bootDiagStorage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  kind: 'StorageV2'
  location: vmLocation
  name: 'archostdiagsta${take(guid(subscription().subscriptionId), 4)}'
  sku: {
    name: 'Standard_LRS'
  }
}

resource dataDisk 'Microsoft.Compute/disks@2022-03-02' = {
  name: 'vm${suffix}-archost01-data01'
  location: vmLocation
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    diskSizeGB: 64
    creationData: {
      createOption: 'Empty'
    }
  }
}

resource archost01 'Microsoft.Compute/virtualMachines@2021-11-01' = {
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
      vmSize: 'Standard_D4s_v4'
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
          lun: 0
          caching: 'ReadOnly'
          createOption: 'Attach'
          managedDisk: {
            id: dataDisk.id
          }
        }
      ]
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-core-smalldisk-g2'
        version: 'latest'
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'https://${bootDiagStorage.name}.blob.${environment().suffixes.storage}'
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

resource ownerRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(subscription().subscriptionId)
  properties: {
    principalType: 'ServicePrincipal'
    principalId: archost01.identity.principalId
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    
  }
}

resource mountDisk 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'mountDisk'
  parent: archost01
  location: vmLocation
  properties: {
    source: {
      scriptUri: 'https://raw.githubusercontent.com/kongou-ae/azure-arc-server-ops-lab-generator/dev/scriptps/mountDisk.ps1'
    }
  }
}

resource configureHostVm 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'configureHostVm'
  parent: archost01
  dependsOn: [
    mountDisk
  ]
  location: vmLocation
  properties: {
    source: {
      scriptUri: 'https://raw.githubusercontent.com/kongou-ae/azure-arc-server-ops-lab-generator/dev/scriptps/configureHostVm.ps1'
    }
    timeoutInSeconds: 600
  }
}

resource createWin2019Vm 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'createWin2019Vm'
  parent: archost01
  dependsOn: [
    configureHostVm
  ]
  location: vmLocation
  properties: {
    source: {
      scriptUri: 'https://raw.githubusercontent.com/kongou-ae/azure-arc-server-ops-lab-generator/dev/scriptps/createWin2019Vm.ps1'
    }
    parameters: [
      {
        name: 'name'
        value: archost01.properties.osProfile.computerName
      }
    ]
    protectedParameters: [
      {
        name: 'LocalAdministratorPassword'
        value: adminPassword
      }
    ]
    timeoutInSeconds: 3600
  }
}



resource enableArcServerToVm 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  name: 'enableArcServerToVm'
  parent: archost01
  dependsOn: [
    createWin2019Vm
  ]
  location: vmLocation
  properties: {
    source: {
      scriptUri: 'https://raw.githubusercontent.com/kongou-ae/azure-arc-server-ops-lab-generator/dev/scriptps/enableArcServerToVm.ps1'
    }
    parameters: [
      {
        name: 'name'
        value: archost01.properties.osProfile.computerName
      }
      {
        name: 'location'
        value: vmLocation
      }
      {
        name: 'resouceGroup'
        value: resourceGroup().name
      }

    ]
    protectedParameters: [
      {
        name: 'LocalAdministratorPassword'
        value: adminPassword
      }
    ]
    timeoutInSeconds: 300
  }
}
