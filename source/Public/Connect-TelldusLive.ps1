function Connect-TelldusLive
{
    <#
    .SYNOPSIS
    Connects to Telldus Live!

    .DESCRIPTION
    This function connects to Telldus Live! by either using a saved access token or
    by creating a new one.

    .EXAMPLE
    Connect-TelldusLive

    .EXAMPLE
    Connect-TelldusLive -SaveCredential

    Will return a link which you need to authorize and then save that access token for later use.

    .PARAMETER Profile
    The name of the profile you use to connect. You can leave this to "Default" (default value)
    if you don't have more than one Telldus Live! account.

    .PARAMETER Credential
    If you have a known access token, you can specify it as a PSCredential object.

    Username should be the AccessToken
    Password Should be the AccessTokenSecret

    .PARAMETER AccessToken
    If you have a known access token, you can specify it here (not the AccessTokenSecret)

    .PARAMETER AccessTokenSecret
    If you have a known access TokenSecret, you can specify it here (as a secure string)

    .PARAMETER SaveCredential
    Will save and store the access token after it has been retieved so it can be reused later
    
    You can then connect by simply using the -UseSavedCredential switch. The credential is saved using your logon session.

    .PARAMETER UseSavedCredential
    Specify this switch to use a saved credential instead of specifying one.

    #>

    [cmdletbinding(DefaultParameterSetName='SpecifyCredential')]
    Param (
        [Parameter(Mandatory=$false)]
        $Profile = 'Default',

        [Parameter(Mandatory=$true, ParameterSetName='SpecifyAccessTokenAsCredential')]
        [PSCredential] $Credential,

        [Parameter(Mandatory=$true, ParameterSetName='SpecifyAccessToken')]
        $AccessToken,

        [Parameter(Mandatory=$true, ParameterSetName='SpecifyAccessToken')]
        [System.Security.SecureString] $AccessTokenSecret,

        [Parameter(Mandatory=$false)]
        [Switch] $SaveCredential,

        [Parameter(Mandatory=$false, ParameterSetName='SavedCredential')]
        [Switch] $UseSavedCredential
    )

    BEGIN { }

    PROCESS {
        $AccessTokenFolder = Join-Path -Path $($env:APPDATA) -ChildPath AutomaTD

        if ( -not (Test-Path -Path $AccessTokenFolder)) {
            $null = New-Item -Path $AccessTokenFolder -ItemType Directory -Force
        }

        $AccessTokenFilename = "TelldusAccessToken-$($Profile).json"
        $AccessTokenFilePath = Join-Path -Path $AccessTokenFolder -ChildPath $AccessTokenFilename

        if ($PSCmdlet.ParameterSetName -eq 'SavedCredential') {
            if (Test-Path -Path $AccessTokenFilePath) {
                $AccessTokenFromDisk = Get-Content $AccessTokenFilePath -Raw -Encoding UTF8 | ConvertFrom-Json

                $Token = $AccessTokenFromDisk.Token
                $TokenSecret = $AccessTokenFromDisk.TokenSecret | ConvertTo-SecureString

                # Build the token
                $AccessToken = [PSCustomObject] @{
                    Token = $Token
                    TokenSecret = $TokenSecret
                }
            }
            else {
                throw "Didn't locate any saved access tokens. Please run this command with the 'SaveCredential' switch first to store the credentials or verify which profile you choose."
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'SpecifyAccessToken') {
            # Build the credential
            $AccessToken = [PSCustomObject] @{
                Token = $AccessToken
                TokenSecret = $AccessTokenSecret
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'SpecifyAccessTokenAsCredential') {
            # Build the credential
            $AccessToken = [PSCustomObject] @{
                Token = $Credential.UserName
                TokenSecret = $Credential.Password
            }
        }
        else {
            $RequestToken = GetTelldusRequestToken
            Write-Output "Please go to the following URL to authenticate this module:`n$($RequestToken.AuthURL)"

            $PollingAttempts = 20
            Do {
                $PollingAttempts--
                $AuthFailed = $false

                try {
                    $AccessToken = GetTelldusAccessToken -RequestToken $RequestToken -ErrorAction Stop
                }
                catch {
                    $AuthFailed = $true

                    Start-Sleep -Seconds 15
                }
            }
            while ($AuthFailed -and $PollingAttempts -gt 0)

            if (-not $AccessToken) {
                throw "Authorization failed or timed out. Please try again."
            }

            if ($SaveCredential.IsPresent) {
                $ExportToken = @{
                    Token = $AccessToken.Token
                    TokenSecret = ConvertFrom-SecureString -SecureString $AccessToken.TokenSecret
                }

                $ExportToken | ConvertTo-Json -Compress | Out-File -FilePath $AccessTokenFilePath -Encoding utf8 -Force
            }
        }

        $Global:TelldusLiveAccessToken = $AccessToken

        try {
            $null = Get-TDClient -ErrorAction Stop
        }
        catch {
            throw "Failed to connect to Telldus Live! The error was: $($_.Exception.Message)"
        }
    }

    END {
    
    }
}