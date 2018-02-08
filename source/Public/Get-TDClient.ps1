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
    Param()

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $Clients = InvokeTelldusAction -URI "clients/list"

        foreach ($Client in $Clients.client) {
            $Client.online = [bool] $Client.online
            $Client.editable = [bool] $Client.editable
            $Client
        }
    }

    END { }
}