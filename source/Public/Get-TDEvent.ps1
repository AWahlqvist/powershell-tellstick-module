function Get-TDEvent
{

    <#
    .SYNOPSIS
    List all events available in Telldus Live!

    .DESCRIPTION
    List all events available in Telldus Live!

    .EXAMPLE
    Get-TDEvent

    #>

    [CmdletBinding()]
    param()

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $EventHistory = InvokeTelldusAction -URI "events/list"

        $EventHistory.event
    }
}