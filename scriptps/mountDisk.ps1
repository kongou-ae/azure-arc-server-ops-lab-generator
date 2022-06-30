$ErrorActionPreference = "stop"

Start-Transcript -Path 'c:\arcsvlab-eval\001-mountDisk.log'

$disk = Get-Disk | Where-Object {$_.PartitionStyle -eq "RAW" } 
$disk |
    Initialize-Disk -PartitionStyle MBR -PassThru |
    New-Partition -UseMaximumSize -DriveLetter 'G' |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel 'G' -Confirm:$false -Force

Stop-Transcript
