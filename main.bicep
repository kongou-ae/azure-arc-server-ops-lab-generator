targetScope = 'subscription'

param envLocation string
param adminUsername string
@secure()
param adminPassword string

var suffix = '-arcsvlab-eval'

resource rgNet 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-net${suffix}'
  location: envLocation
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-vm${suffix}'
  location: envLocation
}


// Create Vnets and private Endpoint
module vnet 'modules/vnet.bicep' = {
  name: 'DeployVNet'
  scope: rgNet
  params: {
    netLocation: envLocation
    suffix: suffix
  }
}

module vm 'modules/vm.bicep' = {
  name: 'DeployAmaVmAndMmaVm'
  scope: rgVm
  params: {
    vmLocation: envLocation
    adminUserName: adminUsername
    adminPassword: adminPassword
    vnetId: vnet.outputs.vnetId
    suffix: suffix
  }
}

module runCommand 'modules/runcommand.bicep' = {
  name: 'RunCommand'
  scope: rgVm
  params: {
    vmLocation: envLocation
    suffix: suffix
  }
}
