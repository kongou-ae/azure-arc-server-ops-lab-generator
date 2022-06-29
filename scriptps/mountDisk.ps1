$ErrorActionPreference = "stop"

$disk = Get-Disk | Where-Object {$_.PartitionStyle -eq "RAW" } 
$disk |
    Initialize-Disk -PartitionStyle MBR -PassThru |
    New-Partition -UseMaximumSize -DriveLetter 'G' |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel 'G' -Confirm:$false -Force


