function ConvertTo-TDNormalizedOutput
{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $InputObject
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
        $Objects | Select-Object -Property @($Properties)
    }
}