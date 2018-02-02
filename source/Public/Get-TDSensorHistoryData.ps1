function Get-TDSensorHistoryData
{
    <#
    .SYNOPSIS
    Retrieves sensor data history from Telldus Live!
    
    .DESCRIPTION
    This command will retrieve the sensor history data of the specified sensor.
    
    .PARAMETER DeviceID
    The DeviceID of the sensor which data you want to retrieve.

    .PARAMETER After
    Specify from which date you would like to retrieve sensor history.

    Always use UTC time.

    .PARAMETER Before
    Specify the "end date" of the data samples.
    Default value is current date.

    Always use UTC time.

    .EXAMPLE
    Get-TDSensorHistoryData -DeviceID 123456

    .EXAMPLE
    Get-TDSensorHistoryData -DeviceID 123456 | Format-Table

    .EXAMPLE
    Get-TDSensorHistoryData -DeviceID 123456 -After (get-date).AddDays(-1)
    
    Get's the history from yesterday until today

    #>

    [cmdletbinding(DefaultParameterSetName='AllData')]
    param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='AllData')]
        [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='DateRange')]
        [Alias('id')]
        [string] $DeviceID,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='DateRange')]
        [DateTime] $After,

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ParameterSetName='DateRange')]
        [DateTime] $Before
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $ApiEndpoint = "sensor/history`?id=$DeviceID"

        if ($PSCmdlet.ParameterSetName -eq 'DateRange') {
            if (-not $Before) {
                $Before = (Get-Date).ToUniversalTime()
            }

            if ($Before -gt $After) {
                $FromDateToPost = [Math]::Floor((New-TimeSpan -Start '1970-01-01' -End $After).TotalSeconds)
                $ToDateToPost = [Math]::Floor((New-TimeSpan -Start '1970-01-01' -End $Before).TotalSeconds)

                $ApiEndpoint = $ApiEndpoint + "&from=$FromDateToPost" + "&to=$ToDateToPost"
            }
            else {
                throw 'The value for Before must be greater than the value for After.'
            }
        }

        $HistoryDataPoints = InvokeTelldusAction -URI $ApiEndpoint


        foreach ($HistoryDataPoint in $HistoryDataPoints.history)
        {
            $PropertiesToOutput = @{
                                 'DeviceID' = $DeviceID
                                 'Humidity' = ($HistoryDataPoint.data | Where-Object { $_.Name -eq 'humidity' }).value
                                 'Temperature' = ($HistoryDataPoint.data | Where-Object { $_.Name -eq 'temp' }).value
                                 'Date' = (Get-Date "1970-01-01 00:00:00").AddSeconds($HistoryDataPoint.ts)
                                 }

            $returnObject = New-Object -TypeName PSObject -Property $PropertiesToOutput

            Write-Output $returnObject | Select-Object DeviceID, Humidity, Temperature, Date
        }
    }

    END { }
}