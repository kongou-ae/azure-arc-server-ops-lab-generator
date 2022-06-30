$ErrorActionPreference = "stop"

$disk = Get-Disk | Where-Object {$_.PartitionStyle -eq "RAW" } 

# If there are disk which is not mounted.
if ($null -ne $disk){
$disk |
    Initialize-Disk -PartitionStyle MBR -PassThru |
    New-Partition -UseMaximumSize -DriveLetter 'G' |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel 'G' -Confirm:$false -Force

}

