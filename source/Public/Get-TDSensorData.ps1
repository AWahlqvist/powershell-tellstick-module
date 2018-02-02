function Get-TDSensorData
{
    <#
    .SYNOPSIS
    Retrieves the sensordata of specified sensor.

    .DESCRIPTION
    This command will retrieve the sensordata associated with the specified ID.

    .EXAMPLE
    Get-TDSensorData -DeviceID 123456

    .PARAMETER DeviceID
    The DeviceID of the sensor which data you want to retrieve.

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('id')]
      [string] $DeviceID)

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $SensorData = InvokeTelldusAction -URI "sensor/info?id=$DeviceID"
        
        [datetime] $TelldusDate="1970-01-01 00:00:00"

        $TempData = $SensorData.data | where { $_.name -eq 'temp' }
        $HumidityData = $SensorData.data | where { $_.name -eq 'humidity' }

        if ($TempData) {
            $Temparature = $TempData.value
        }
        else {
            $Temparature = $null
        }

        if ($HumidityData) {
            $Humidity = $HumidityData.value
        }
        else {
            $Humidity = $null
        }

        [PSCustomObject] @{
            DeviceId = $SensorData.id
            Name = $SensorData.name
            ClientName = $SensorData.clientName
            LastUpdated = $TelldusDate.AddSeconds($SensorData.lastUpdated)
            Ignored = [bool] $SensorData.Ignored
            Editable = [bool] $SensorData.editable
            Protocol = $SensorData.protocol
            SensorId = $SensorData.sensorId
            TimeZoneOffset = $SensorData.timezoneoffset
            Battery = $SensorData.battery
            Temperature = $Temparature
            Humidity = $Humidity
            Data = $SensorData.data
            KeepHistory = [bool] $SensorData.keepHistory
        }
    }

    END { }
}