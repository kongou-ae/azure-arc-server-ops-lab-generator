param vmLocation string
param suffix string

resource vmCommand 'Microsoft.ScVmm/virtualMachines@2020-06-05-preview' existing = {
   name: 'vm${suffix}-archost01'
}

resource mountDisk 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
   name: '${vmCommand.name}/mountDisk'
   location: vmLocation
    properties: {
       source: {
         script: ''
       }
    }

}
