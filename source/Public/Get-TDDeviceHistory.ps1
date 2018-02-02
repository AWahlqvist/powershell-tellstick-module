function Get-TDDeviceHistory
{
    <#
    .SYNOPSIS
    Retrieves all events associated with the specified device.
    .DESCRIPTION
    This command will list all events associated with the specified device
    .EXAMPLE
    Get-TDDeviceHistory
    .EXAMPLE
    Get-TDDeviceHistory | Format-Table
    #>

    [cmdletbinding()]
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
        $HistoryEvents = InvokeTelldusAction -URI "device/history`?id=$DeviceID"
        
        foreach ($HistoryEvent in $HistoryEvents.history)
        {
            $PropertiesToOutput = @{
                                 'DeviceID' = $DeviceID
                                 'State' = switch ($HistoryEvent.state)
                                           {
                                                 1 { "On" }
                                                 2 { "Off" }
                                                16 { "Dimmed" }
                                                default { "Unknown" }
                                           }
                                 'Statevalue' = $HistoryEvent.statevalue
                                 'Origin' = $HistoryEvent.Origin;
                                 'EventDate' = (Get-Date "1970-01-01 00:00:00").AddSeconds($HistoryEvent.ts)
                                 }

            $returnObject = New-Object -TypeName PSObject -Property $PropertiesToOutput

            Write-Output $returnObject | Select-Object DeviceID, EventDate, State, Statevalue, Origin
        }
    }

    END { }
}