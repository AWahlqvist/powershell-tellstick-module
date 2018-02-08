function GetTelldusAccessToken
{
    [cmdletbinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", Scope="Function", Target="GetTelldusAccessToken")]
    Param(
        $RequestToken
    )

    BEGIN { }

    PROCESS {
        $RequestTokenJson = $RequestToken | ConvertTo-Json
        $TokenResponse = Invoke-RestMethod -Uri https://tl.p0wershell.com/api/GetAccessToken -Method Post -Body $RequestTokenJson   

        [PSCustomObject] @{
            Token = $TokenResponse.Token
            TokenSecret = (ConvertTo-SecureString -String $TokenResponse.TokenSecret -AsPlainText -Force -ErrorAction Stop)
        }

        Remove-Variable TokenResponse -ErrorAction SilentlyContinue
        [GC]::Collect()
    }

    END { }
}
