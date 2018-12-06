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

            if ($KeyName -eq 'Temp') {
                $KeyName = 'Temperature'
            }
            elseif ($KeyName -eq 'rrate') {
                $KeyName = 'RainRate'
            }
            elseif ($KeyName -eq 'rtot') {
                $KeyName = 'RainTotal'
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
