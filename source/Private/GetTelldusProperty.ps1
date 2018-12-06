function GetTelldusProperty
{
    [cmdletbinding()]
    Param(
        $Data
    )

    BEGIN {
        $TextFormat = (Get-Culture).TextInfo
    }

    PROCESS {
        foreach ($dataObj in $Data) {
            $Properties = @{}

            $KeyName = $textFormat.ToTitleCase($dataObj.Name.ToLower())

            # Resolve sensors types to friendly names if they are known
            $KeyName = switch ($KeyName) {
                'Temp'   { 'Temperature' }
                'rrate'  { 'RainRate' }
                'rtot'   { 'RainTotal' }
                'wdir'   { 'WindDirection' }
                'wavg'   { 'WindAverage' }
                'watt'   { 'Watt' }
                'lum'    { 'Luminance' }
                default  { $KeyName }
            }

            if ($Properties.ContainsKey($KeyName)) {
                Write-Warning "Property $KeyName already exists. It will be dropped."
            }
            else {
                $Properties.Add($TextFormat.ToTitleCase($KeyName), $dataObj.value)
            }

            $Properties
        }
    }

    END { }
}
