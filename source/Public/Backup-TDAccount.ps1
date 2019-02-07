function Backup-TDAccount
{
    <#
    .SYNOPSIS
    Exports information from Telldus Live! to the specified folder

    .DESCRIPTION
    This function will fetch information about Clients (Locations), devices,
    sensors, schedules and events from the Telldus Live! API and export the
    data as XML to the specified folder.

    This backup can potentially be used to restore for example events or 
    schedules if they become broken.

    This backup does NOT include device/sensor history and values!

    .EXAMPLE
    Backup-TDAccount -Verbose

    Exports the backups and logs a verbose message for each type of information that get's exported
    #>

    [CmdletBinding()]
    Param(
        $BackupFolderPath
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        if (-not (Test-Path -Path $BackupFolderPath)) {
            $null = New-Item -Path $BackupFolderPath -ItemType Directory -Force
        }

        Write-Verbose "Backing up client/location information..."
        $ClientBackupPath = Join-Path -Path $BackupFolderPath -ChildPath ClientBackup.xml
        Get-TDClient | Get-TDClient | Export-Clixml -Path $ClientBackupPath -Encoding UTF8 -Depth 10 -Force

        Write-Verbose "Backing up device information..."
        $DeviceBackupPath = Join-Path -Path $BackupFolderPath -ChildPath DeviceBackup.xml
        Get-TDDevice | Export-Clixml -Path $DeviceBackupPath -Encoding UTF8 -Depth 10 -Force

        Write-Verbose "Backing up sensor information..."
        $SensorBackupPath = Join-Path -Path $BackupFolderPath -ChildPath SensorBackup.xml
        Get-TDSensor | Export-Clixml -Path $SensorBackupPath -Encoding UTF8 -Depth 10 -Force

        Write-Verbose "Backing up schedule information..."
        $ScheduleBackupPath = Join-Path -Path $BackupFolderPath -ChildPath ScheduleBackup.xml
        Get-TDSchedule | Export-Clixml -Path $ScheduleBackupPath -Encoding UTF8 -Depth 10 -Force

        Write-Verbose "Backing up trigger event information..."
        $EventBackupPath = Join-Path -Path $BackupFolderPath -ChildPath EventBackup.xml
        Get-TDTriggerEvent | Get-TDTriggerEvent | Export-Clixml -Path $EventBackupPath -Encoding UTF8 -Depth 10 -Force
    }

    END { }
}