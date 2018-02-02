
function Set-TDDevice
{

    <#
    .SYNOPSIS
    Turns a device on or off.

    .DESCRIPTION
    This command can set the state of a device to on or off through the Telldus Live! service.

    .EXAMPLE
    Set-TDDevice -DeviceID 123456 -Action turnOff

    .EXAMPLE
    Set-TDDevice -DeviceID 123456 -Action turnOn

    .EXAMPLE
    SET-TDDevice -DeviceID 123456 -Action bell

    .PARAMETER DeviceID
    The DeviceID of the device to turn off or on. (Pipelining possible)

    .PARAMETER Action
    What to do with that device. Possible values are "turnOff", "turnOn" and "bell".

    .NOTES
    Thank you Ispep (automatiserar.se) for fixing "bell" support!

    #>

    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('id')]
      [string] $DeviceID,
      [Parameter(Mandatory=$True)]
      [ValidateSet("turnOff","turnOn", "bell", "down", "up")]
      [string] $Action)


    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        $Response = InvokeTelldusAction -URI "device/$Action`?id=$DeviceID"

        Write-Verbose "Doing action $Action on device $DeviceID. Result: $($Response.status)."
    }
}
