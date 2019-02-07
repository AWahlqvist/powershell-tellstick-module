function Get-TDClient
{
    <#
    .SYNOPSIS
    Retrieves all clients/locations associated with a Telldus Live! account.

    .DESCRIPTION
    Retrieves all clients/locations associated with a Telldus Live! account.

    .EXAMPLE
    Get-TDClient

    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [string] $ClientID
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        if ($ClientID) {
            $response = InvokeTelldusAction -URI "client/info?id=$ClientID&extras=coordinate,suntime,timezone,tzoffset"
            $Clients = $response
        }
        else {
            $response = InvokeTelldusAction -URI "clients/list"
            $Clients = $response.client
        }

        foreach ($Client in $Clients) {
            $Client.online = [bool] $Client.online
            $Client.editable = [bool] $Client.editable

            if ($Client.sunrise) {
                $Client.sunrise = (Get-Date "1970-01-01 00:00:00").AddSeconds($Client.sunrise)
            }

            if ($Client.sunset) {
                $Client.sunset = (Get-Date "1970-01-01 00:00:00").AddSeconds($Client.sunset)
            }
            
            $Client
        }
    }

    END { }
}