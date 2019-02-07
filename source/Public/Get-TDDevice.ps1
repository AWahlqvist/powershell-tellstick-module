function Get-TDDevice
{
    <#
    .SYNOPSIS
    Retrieves all devices associated with a Telldus Live! account.

    .DESCRIPTION
    This command will list all devices associated with an Telldus Live!-account and their current status and other information.

    .EXAMPLE
    Get-TDDevice

    .EXAMPLE
    Get-TDDevice | Format-Table

    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [string] $DeviceID
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        if ($DeviceID) {
            $response = InvokeTelldusAction -URI "device/info?id=$DeviceID&supportedMethods=19&extras=coordinate,metadata,timezone,transport,tzoffset"
            $DeviceList = $response
        }
        else {
            $response = InvokeTelldusAction -URI 'devices/list?supportedMethods=19'
            $DeviceList = $response.device
        }

        foreach ($Device in $DeviceList) {

            $PropertiesToOutput = [ordered] @{
                                 'Name' = $Device.name
                                 'DeviceID' = $Device.id
                                 'State' = switch ($Device.state)
                                           {
                                                 1 { "On" }
                                                 2 { "Off" }
                                                16 { "Dimmed" }
                                                default { "Unknown" }
                                           }
                                 'Statevalue' = $Device.statevalue
                                 'Methods' = switch ($Device.methods)
                                             {
                                                 3 { "On/Off" }
                                                19 { "On/Off/Dim" }
                                                default { "Unknown" }
                                             }
                                 'Type' = $Device.type
                                 'Client' = $Device.client
                                 'Online' = switch ($Device.online)
                                            {
                                                0 { $false }
                                                1 { $true }
                                            }
                                 }

            if ($Device.longitude) {
                $PropertiesToOutput.Add('Longitude', $Device.longitude)
            }

            if ($Device.latitude) {
                $PropertiesToOutput.Add('Latitude', $Device.latitude)
            }

            if ($Device.clientName) {
                $PropertiesToOutput.Add('ClientName', $Device.clientName)
            }

            if ($Device.metadata) {
                $PropertiesToOutput.Add('Metadata', $Device.metadata)
            }

            if ($Device.timezone) {
                $PropertiesToOutput.Add('TimeZone', $Device.timezone)
            }

            if ($Device.transport) {
                $PropertiesToOutput.Add('Transport', $Device.transport)
            }

            if ($Device.tzoffset) {
                $PropertiesToOutput.Add('TimeOffset', $Device.tzoffset)
            }

            $returnObject = New-Object -TypeName PSObject -Property $PropertiesToOutput

            $returnObject
        }
    }

    END { }
}