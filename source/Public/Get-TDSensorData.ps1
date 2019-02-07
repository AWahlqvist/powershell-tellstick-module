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

    .PARAMETER HideRawData
    Specify this switch to hide the raw data response from Telldus Live!

    #>

    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('id')]
      [string] $DeviceID,
      
      [Parameter(Mandatory=$false)]
      [switch] $HideRawData
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $SensorData = InvokeTelldusAction -URI "sensor/info?id=$DeviceID"
        
        [datetime] $TelldusDate="1970-01-01 00:00:00"

        $PropertiesToOutput = @{
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
            KeepHistory = [bool] $SensorData.keepHistory
        }

        if (-not $HideRawData.IsPresent) {
            $PropertiesToOutput += @{ 'Data' = $SensorData.data }
        }

        $expandedProperties = GetTelldusProperty -Data $SensorData.data

        foreach ($expandedProperty in $expandedProperties) {
            $PropertiesToOutput += $expandedProperty
        }
        
        New-Object -TypeName PSObject -Property $PropertiesToOutput
    }

    END { }
}