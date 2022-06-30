Param( 
    [parameter(mandatory=$true)][string]$name, 
    [parameter(mandatory=$true)][string]$LocalAdministratorPassword
)

$ErrorActionPreference = "stop"

Start-Transcript -Path 'c:\arcsvlab-eval\createWin2019Vm.log'

if ((Test-Path 'G:\arcsvlab-eval') -eq $false){
    New-Item "G:\arcsvlab-eval" -ItemType Directory 
}

$result = Get-VM -Name arcWin2019sv01 -ErrorAction Ignore
if ( $null -eq $result){

    if ((Test-Path 'G:\arcsvlab-eval\win2019dcCore.iso') -eq $false){
        Start-BitsTransfer -Source "https://software-static.download.prss.microsoft.com/pr/download/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso" `
            -Destination "G:\arcsvlab-eval\win2019dcCore.iso"
    }

    Start-BitsTransfer -Source "https://raw.githubusercontent.com/Azure/AzureStackHCI-EvalGuide/main/deployment/dsc/azshcihost/WindowsDeploymentHelper/0.0.1/WindowsDeploymentHelper.psm1" `
        -Destination "G:\arcsvlab-eval\WindowsDeploymentHelper.psm1"

    Import-module "G:\arcsvlab-eval\WindowsDeploymentHelper.psm1"

    Start-BitsTransfer -Source "https://raw.githubusercontent.com/MicrosoftDocs/Virtualization-Documentation/main/hyperv-tools/Convert-WindowsImage/Convert-WindowsImage.ps1" `
        -Destination "G:\arcsvlab-eval\Convert-WindowsImage.ps1"

    Import-module "G:\arcsvlab-eval\Convert-WindowsImage.ps1"

    $LocalAdministratorPassword = ConvertTo-SecureString -AsPlainText $LocalAdministratorPassword -Force

    New-BasicUnattendXML -ComputerName $name `
        -LocalAdministratorPassword $LocalAdministratorPassword `
        -AutoLogonCount 1 -OutputPath "G:\arcsvlab-eval\" -Force `
        -ErrorAction Stop
        
    Convert-WindowsImage -SourcePath "G:\arcsvlab-eval\win2019dcCore.iso" -SizeBytes 32GB -VHDPath "G:\arcsvlab-eval\VHD\win2019dcCore.vhdx" `
        -VHDFormat VHDX -DiskLayout UEFI -Verbose -UnattendPath 'G:\arcsvlab-eval\Unattend.xml' -Edition "Windows Server 2019 Datacenter Evaluation"
    
    New-VM -Name arcWin2019sv01 -MemoryStartupBytes 4GB -BootDevice VHD -VHDPath "G:\arcsvlab-eval\VHD\win2019dcCore.vhdx" -Path "G:\arcsvlab-eval\VM\" `
        -Generation 2 -Switch "InternalNAT"

    Start-vm arcWin2019sv01
}

Stop-Transcript