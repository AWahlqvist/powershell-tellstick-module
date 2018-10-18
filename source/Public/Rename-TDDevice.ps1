function Rename-TDDevice
{

    <#
    .SYNOPSIS
    Renames a device in Telldus Live!

    .DESCRIPTION
    Renames a device in Telldus Live!

    .EXAMPLE
    Rename-TDDevice -DeviceID 123456 -NewName MyNewDeviceName

    .PARAMETER DeviceID
    The DeviceID of the device to rename

    .PARAMETER NewName
    The new name for that device

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('id')]
      [string] $DeviceID,

      [Parameter(Mandatory=$True)]
      [string] $NewName)


    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $Response = InvokeTelldusAction -URI "device/setName`?id=$DeviceID&name=$([uri]::EscapeDataString($NewName))"

        Write-Verbose "Renamed device with id $DeviceID. Result: $($Response.status)."
    }
}