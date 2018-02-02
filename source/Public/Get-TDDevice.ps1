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
    Param()

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        $DeviceList = InvokeTelldusAction -URI 'devices/list?supportedMethods=19'

        foreach ($Device in $DeviceList.device) {

            $PropertiesToOutput = @{
                                 'Name' = $Device.name;
                                 'State' = switch ($Device.state)
                                           {
                                                 1 { "On" }
                                                 2 { "Off" }
                                                16 { "Dimmed" }
                                                default { "Unknown" }
                                           }
                                 'DeviceID' = $Device.id;
                             

                                 'Statevalue' = $Device.statevalue
                                 'Methods' = switch ($Device.methods)
                                             {
                                                 3 { "On/Off" }
                                                19 { "On/Off/Dim" }
                                                default { "Unknown" }
                                             }
                                 'Type' = $Device.type;
                                 'Client' = $Device.client;
                                 'ClientName' = $Device.clientName;
                                 'Online' = switch ($Device.online)
                                            {
                                                0 { $false }
                                                1 { $true }
                                            }
                                 }

            $returnObject = New-Object -TypeName PSObject -Property $PropertiesToOutput

            Write-Output $returnObject | Select-Object Name, DeviceID, State, Statevalue, Methods, Type, ClientName, Client, Online
        }
    }

    END { }
}