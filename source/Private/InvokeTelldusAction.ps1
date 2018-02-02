function InvokeTelldusAction
{
    Param($URI)

    BEGIN {
        $ApiUri = 'https://tl.p0wershell.com/api/InvokeAction'
    }

    PROCESS {
        $Payload = @{
            Token = $Global:TelldusLiveAccessToken.Token
            TokenSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($Global:TelldusLiveAccessToken.TokenSecret))
            URI = $URI
        } | ConvertTo-Json

        Invoke-RestMethod -Uri $ApiUri -Method Post -Body $Payload
    }

    END { }
}