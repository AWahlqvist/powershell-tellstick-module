function ConvertTo-TDNormalizedOutput
{
    <#
    .SYNOPSIS
    Makes sure all objects have the same set of properties

    .DESCRIPTION
    Makes sure all objects have the same set of properties

    Makes exporting to for example CSV-files easiser since all sensors will have
    the same set of "columns" in the file (but blank values for those missing that
    sensor value type).

    .EXAMPLE
    Get-TDSensor | Get-TDSensorData | ConvertTo-TDNormalizedOutput

    Makes sure all objects have the same set of properties

    .EXAMPLE
    Get-TDSensor | Get-TDSensorData | ConvertTo-TDNormalizedOutput -PropertiesToAlwaysInclude CustomSensorData

    Makes sure all objects have the same set of properties, and "CustomSensorData" will always be a property
    of the objects even if it doesn't exist in the results.

    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $InputObject,

        [Parameter(Mandatory=$false)]
        [string[]] $PropertiesToAlwaysInclude
    )

    begin {
        $Properties = New-Object System.Collections.Generic.HashSet[string]
        $Objects = New-Object System.Collections.Generic.List[System.Object]
    }

    process {
        $null = $InputObject.psobject.Properties.Name.foreach({$Properties.Add($_)})
        $Objects.Add($InputObject)
    }

    end {
        if ($PropertiesToAlwaysInclude) {
            foreach ($Property in $PropertiesToAlwaysInclude) {
                if ($Property -notin $Properties) {
                    $null = $Properties.Add($Property)
                }
            }
        }

        $Objects | Select-Object -Property @($Properties)
    }
}