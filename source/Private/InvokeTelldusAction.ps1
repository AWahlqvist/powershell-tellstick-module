function InvokeTelldusAction
{
    Param($URI)

    BEGIN {
        $ApiUri = 'https://tl.p0wershell.com/api/InvokeAction'

        if (-not [Net.ServicePointManager]::SecurityProtocol.HasFlag([Net.SecurityProtocolType]::Tls12) -AND $EnableTls12) {
            [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
        }
    }

    PROCESS {
        $Payload = @{
            Token = $Global:TelldusLiveAccessToken.Token
            TokenSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($Global:TelldusLiveAccessToken.TokenSecret))
            URI = $URI
        } | ConvertTo-Json

        $Response = try {
            Invoke-RestMethod -Uri $ApiUri -Method Post -Body $Payload -ErrorAction Stop
        }
        catch {
            throw "Request failed with error: $($_.Exception.Message)"
        }

        if ($Response.error) {
            throw $Response.error
        }
        else {
            $Response
        }
    }

    END {
        Remove-Variable Payload -ErrorAction SilentlyContinue
        [GC]::Collect()
    }
}
