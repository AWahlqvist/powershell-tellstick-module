function Invoke-TDAction
{
    <#
    .SYNOPSIS
    Generic function that can trigger any endpoint in the Telldus Live! API

    .DESCRIPTION
    Generic function that can trigger any endpoint in the Telldus Live! API

    Just specify the URL you want to call with all the parameters.

    .EXAMPLE
    Invoke-TDAction -URI "events/list"

    Lists all events

    #>

    [CmdletBinding()]
    Param(
        [string] $URI
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        InvokeTelldusAction -URI $URI
    }

    END { }
}