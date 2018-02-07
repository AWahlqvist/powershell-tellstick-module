function Get-TDAccessToken
{
    <#
    .SYNOPSIS
    Used to export the access token as a PSCredential or as plain text

    .DESCRIPTION
    Used to export the access token as a PSCredential or as plain text

    Useful if you want to set it up on a new computer where you wont be able to
    interact with the login command interactively or store the token.

    Be aware that exporting the access token as plain-text is a security risk!

    Only do this on systems that you trust.

    .EXAMPLE
    Get-TDAccessToken -ExportAsPSCredential

    #>

    [CmdletBinding(DefaultParameterSetName='AsPSCredential')]
    Param(
        [Parameter(Mandatory=$false, ParameterSetName='AsPSCredential')]
        [switch] $ExportAsPSCredential,

        [Parameter(Mandatory=$true, ParameterSetName='AsPlainText')]
        [switch] $ExportAsPlainText,

        [Parameter(Mandatory=$false, ParameterSetName='AsPlainText')]
        [switch] $Force
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet to load the access token"
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'AsPSCredential') {
            New-Object System.Management.Automation.PSCredential ($Global:TelldusLiveAccessToken.Token, $Global:TelldusLiveAccessToken.TokenSecret)
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'AsPlainText') {
            if ($Force.IsPresent) {
                [PSCustomObject] @{
                    Token = $Global:TelldusLiveAccessToken.Token
                    TokenSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($Global:TelldusLiveAccessToken.TokenSecret))
                }
            }
            else {
                throw "The system cannot protect plain text output. To suppress this warning and output the access token as plain text anyway, reissue the command specifying the Force parameter."
            }
        }
    }

    END { }
}