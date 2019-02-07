function Get-TDTriggerEvent
{

    <#
    .SYNOPSIS
    Lists trigger events available in Telldus Live!

    .DESCRIPTION
    Lists trigger events available in Telldus Live!

    If you specify an EventId, you'll also get all the events properties back

    .EXAMPLE
    Get-TDTriggerEvent

    List all Trigger events in the associated Telldus Live! account

    .EXAMPLE
    Get-TDTriggerEvent -EventId 123456

    Get information about the event with id 123456 from Telldus Live! (including all properties)

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [string] $EventId
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        if ($EventId) {
            $URI = "event/info`?id=$EventId"
        }
        else {
            $URI = "events/list`?listOnly=1"
        }

        $Response = InvokeTelldusAction -URI $URI

        if ($Response.event) {
            $Response.event
        }
        else {
            $Response
        }
    }
}