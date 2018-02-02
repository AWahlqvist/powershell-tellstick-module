function Set-TDDimmer
{
    <#
    .SYNOPSIS
    Dims a device to a certain level.

    .DESCRIPTION
    This command can set the dimming level of a device to through the Telldus Live! service.

    .EXAMPLE
    Set-TDDimmer -DeviceID 123456 -Level 89

    .EXAMPLE
    Set-TDDimmer -Level 180

    .PARAMETER DeviceID
    The DeviceID of the device to dim. (Pipelining possible)

    .PARAMETER Level
    What level to dim to. Possible values are 0 - 255.

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True,
                 ValueFromPipeline=$true,
                 ValueFromPipelineByPropertyName=$true,
                 HelpMessage="Enter the DeviceID.")] [Alias('id')] [string] $DeviceID,

      [Parameter(Mandatory=$True,
                 HelpMessage="Enter the level to dim to between 0 and 255.")]
      [ValidateRange(0,255)]
      [int] $Level)


    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        $Response = InvokeTelldusAction -URI "device/dim`?id=$DeviceID&level=$Level"

        Write-Verbose "Dimming device $DeviceID to level $Level. Result: $($Response.status)."
    }
}