function Get-TDSensor
{
    <#
    .SYNOPSIS
    Retrieves all sensors associated with a Telldus Live! account.

    .DESCRIPTION
    This command will list all sensors associated with an Telldus Live!-account and their current status and other information.

    .PARAMETER IncludeIgnored
    Returns hidden/ignored sensors as well

    .EXAMPLE
    Get-TDSensor

    .EXAMPLE
    Get-TDSensor | Format-Table

    #>
    [cmdletbinding()]
    Param(
        [switch] $IncludeIgnored
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        $Response = InvokeTelldusAction -URI "sensors/list?includeValues=1"

        $Sensors = $Response.sensor
        [datetime] $TelldusDate="1970-01-01 00:00:00"

        foreach ($Sensor in $Sensors) {
            $Sensor.lastUpdated = $TelldusDate.AddSeconds($Sensor.lastUpdated)
            $Sensor.Ignored = [bool] $Sensor.Ignored
            $Sensor.keepHistory = [bool] $Sensor.keepHistory
            $Sensor.Editable = [bool] $Sensor.Editable
            $Sensor.Online = [bool] $Sensor.Online
            Write-Output $Sensor
        }
    }

    END { }
}