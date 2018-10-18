function Set-TDSensor
{

    <#
    .SYNOPSIS
    Sets/updates settings for sensors

    .DESCRIPTION
    Sets/updates settings for sensors

    It can for example enable history on the sensor, ignore/hide a sensor or
    rename a sensor

    .EXAMPLE
    Set-TDSensor -DeviceID 123456 -NewName Garage

    Changes the name of the sensor with id 123456 to Garage

    .EXAMPLE
    Set-TDSensor -DeviceID 123456 -KeepHistory $true -IgnoreSensor $false

    Enables history on sensor with id 123456 and unhides it

    .PARAMETER DeviceID
    The ID of the sensor which settings you wish to update

    #>

    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('id')]
      [string] $DeviceID,
      [Parameter(Mandatory=$false)]
      [bool] $KeepHistory,
      [Parameter(Mandatory=$false)]
      [bool] $IgnoreSensor,
      [Parameter(Mandatory=$false)]
      [string] $NewName
    )


    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        if ($PSBoundParameters.ContainsKey('KeepHistory')) {
            if ($KeepHistory) {
                $HistorySetting = 1
            }
            else {
                $HistorySetting = 0
            }

            $Response = InvokeTelldusAction -URI "sensor/setKeepHistory?id=$DeviceID&keepHistory=$HistorySetting"
        }

        if ($PSBoundParameters.ContainsKey('IgnoreSensor')) {
            if ($IgnoreSensor) {
                $IgnoreSetting = 1
            }
            else {
                $IgnoreSetting = 0
            }

            $Response = InvokeTelldusAction -URI "sensor/setIgnore?id=$DeviceID&ignore=$IgnoreSetting"
        }

        if ($NewName) {
            $Response = InvokeTelldusAction -URI "sensor/setName?id=$DeviceID&name=$([uri]::EscapeDataString($NewName))"
        }
    }
}
