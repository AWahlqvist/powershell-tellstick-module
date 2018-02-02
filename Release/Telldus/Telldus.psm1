function GetTelldusAccessToken
{
    Param(
        $RequestToken
    )

    $RequestTokenJson = $RequestToken | ConvertTo-Json
    $TokenResponse = Invoke-RestMethod -Uri https://tl.p0wershell.com/api/GetAccessToken -Method Post -Body $RequestTokenJson   

    [PSCustomObject] @{
        Token = $TokenResponse.Token
        TokenSecret = (ConvertTo-SecureString -String $TokenResponse.TokenSecret -AsPlainText -Force -ErrorAction Stop)
    }
}
function GetTelldusRequestToken
{
    Invoke-RestMethod -Uri https://tl.p0wershell.com/api/GetRequestToken
}
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
        $AccessTokenFolder = Join-Path -Path $($env:APPDATA) -ChildPath TelldusPowerShellModule
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
        else {
            $RequestToken = GetTelldusRequestToken
            Write-Output "Please go to the following URL to authenticate this module:`n$($RequestToken.AuthURL)"

            while ($UserResponse -notin 'y','n') {
                $UserResponse = Read-Host "Is the module authenticated? (Y/N)"
            }

            if ($UserResponse -eq 'y') {
                $AccessToken = GetTelldusAccessToken -RequestToken $RequestToken
            }
            else {
                return
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
    }

    END {
    
    }
}
function Get-TDDevice
{
    <#
    .SYNOPSIS
    Retrieves all devices associated with a Telldus Live! account.

    .DESCRIPTION
    This command will list all devices associated with an Telldus Live!-account and their current status and other information.

    .EXAMPLE
    Get-TDDevice

    .EXAMPLE
    Get-TDDevice | Format-Table

    #>

    [CmdletBinding()]
    Param()

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        $DeviceList = InvokeTelldusAction -URI 'devices/list?supportedMethods=19'

        foreach ($Device in $DeviceList.device) {

            $PropertiesToOutput = @{
                                 'Name' = $Device.name;
                                 'State' = switch ($Device.state)
                                           {
                                                 1 { "On" }
                                                 2 { "Off" }
                                                16 { "Dimmed" }
                                                default { "Unknown" }
                                           }
                                 'DeviceID' = $Device.id;
                             

                                 'Statevalue' = $Device.statevalue
                                 'Methods' = switch ($Device.methods)
                                             {
                                                 3 { "On/Off" }
                                                19 { "On/Off/Dim" }
                                                default { "Unknown" }
                                             }
                                 'Type' = $Device.type;
                                 'Client' = $Device.client;
                                 'ClientName' = $Device.clientName;
                                 'Online' = switch ($Device.online)
                                            {
                                                0 { $false }
                                                1 { $true }
                                            }
                                 }

            $returnObject = New-Object -TypeName PSObject -Property $PropertiesToOutput

            Write-Output $returnObject | Select-Object Name, DeviceID, State, Statevalue, Methods, Type, ClientName, Client, Online
        }
    }

    END { }
}
function Get-TDDeviceHistory
{
    <#
    .SYNOPSIS
    Retrieves all events associated with the specified device.
    .DESCRIPTION
    This command will list all events associated with the specified device
    .EXAMPLE
    Get-TDDeviceHistory
    .EXAMPLE
    Get-TDDeviceHistory | Format-Table
    #>

    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('id')]
    [string] $DeviceID)

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $HistoryEvents = InvokeTelldusAction -URI "device/history`?id=$DeviceID"
        
        foreach ($HistoryEvent in $HistoryEvents.history)
        {
            $PropertiesToOutput = @{
                                 'DeviceID' = $DeviceID
                                 'State' = switch ($HistoryEvent.state)
                                           {
                                                 1 { "On" }
                                                 2 { "Off" }
                                                16 { "Dimmed" }
                                                default { "Unknown" }
                                           }
                                 'Statevalue' = $HistoryEvent.statevalue
                                 'Origin' = $HistoryEvent.Origin;
                                 'EventDate' = (Get-Date "1970-01-01 00:00:00").AddSeconds($HistoryEvent.ts)
                                 }

            $returnObject = New-Object -TypeName PSObject -Property $PropertiesToOutput

            Write-Output $returnObject | Select-Object DeviceID, EventDate, State, Statevalue, Origin
        }
    }

    END { }
}
function Get-TDEvent
{

    <#
    .SYNOPSIS
    List all events available in Telldus Live!

    .DESCRIPTION
    List all events available in Telldus Live!

    .EXAMPLE
    Get-TDEvent

    #>

    [CmdletBinding()]
    param()

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $EventHistory = InvokeTelldusAction -URI "events/list"

        $EventHistory.event
    }
}
function Get-TDSensor
{
    <#
    .SYNOPSIS
    Retrieves all sensors associated with a Telldus Live! account.

    .DESCRIPTION
    This command will list all sensors associated with an Telldus Live!-account and their current status and other information.

    .EXAMPLE
    Get-TDSensor

    .EXAMPLE
    Get-TDSensor | Format-Table

    #>
    [cmdletbinding()]
    Param()

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        $Response = InvokeTelldusAction -URI "sensors/list"

        $Sensors = $Response.sensor
        [datetime] $TelldusDate="1970-01-01 00:00:00"

        foreach ($Sensor in $Sensors) {
            $Sensor.lastUpdated = $TelldusDate.AddSeconds($Sensor.lastUpdated)
            $Sensor.Ignored = [bool] $Sensor.Ignored
            $Sensor.keepHistory = [bool] $Sensor.keepHistory
            $Sensor.Editable = [bool] $Sensor.Editable
            $Sensor.Online = [bool] $Sensor.Online
            Write-Output $Sensor
        }
    }

    END { }
}
function Get-TDSensorData
{
    <#
    .SYNOPSIS
    Retrieves the sensordata of specified sensor.

    .DESCRIPTION
    This command will retrieve the sensordata associated with the specified ID.

    .EXAMPLE
    Get-TDSensorData -DeviceID 123456

    .PARAMETER DeviceID
    The DeviceID of the sensor which data you want to retrieve.

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('id')]
      [string] $DeviceID)

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $SensorData = InvokeTelldusAction -URI "sensor/info?id=$DeviceID"
        
        [datetime] $TelldusDate="1970-01-01 00:00:00"

        $TempData = $SensorData.data | where { $_.name -eq 'temp' }
        $HumidityData = $SensorData.data | where { $_.name -eq 'humidity' }

        if ($TempData) {
            $Temparature = $TempData.value
        }
        else {
            $Temparature = $null
        }

        if ($HumidityData) {
            $Humidity = $HumidityData.value
        }
        else {
            $Humidity = $null
        }

        [PSCustomObject] @{
            DeviceId = $SensorData.id
            Name = $SensorData.name
            ClientName = $SensorData.clientName
            LastUpdated = $TelldusDate.AddSeconds($SensorData.lastUpdated)
            Ignored = [bool] $SensorData.Ignored
            Editable = [bool] $SensorData.editable
            Protocol = $SensorData.protocol
            SensorId = $SensorData.sensorId
            TimeZoneOffset = $SensorData.timezoneoffset
            Battery = $SensorData.battery
            Temperature = $Temparature
            Humidity = $Humidity
            Data = $SensorData.data
            KeepHistory = [bool] $SensorData.keepHistory
        }
    }

    END { }
}
function Get-TDSensorHistoryData
{
    <#
    .SYNOPSIS
    Retrieves sensor data history from Telldus Live!
    
    .DESCRIPTION
    This command will retrieve the sensor history data of the specified sensor.
    
    .PARAMETER DeviceID
    The DeviceID of the sensor which data you want to retrieve.

    .PARAMETER After
    Specify from which date you would like to retrieve sensor history.

    Always use UTC time.

    .PARAMETER Before
    Specify the "end date" of the data samples.
    Default value is current date.

    Always use UTC time.

    .EXAMPLE
    Get-TDSensorHistoryData -DeviceID 123456

    .EXAMPLE
    Get-TDSensorHistoryData -DeviceID 123456 | Format-Table

    .EXAMPLE
    Get-TDSensorHistoryData -DeviceID 123456 -After (get-date).AddDays(-1)
    
    Get's the history from yesterday until today

    #>

    [cmdletbinding(DefaultParameterSetName='AllData')]
    param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='AllData')]
        [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='DateRange')]
        [Alias('id')]
        [string] $DeviceID,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='DateRange')]
        [DateTime] $After,

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ParameterSetName='DateRange')]
        [DateTime] $Before
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {
        $ApiEndpoint = "sensor/history`?id=$DeviceID"

        if ($PSCmdlet.ParameterSetName -eq 'DateRange') {
            if (-not $Before) {
                $Before = (Get-Date).ToUniversalTime()
            }

            if ($Before -gt $After) {
                $FromDateToPost = [Math]::Floor((New-TimeSpan -Start '1970-01-01' -End $After).TotalSeconds)
                $ToDateToPost = [Math]::Floor((New-TimeSpan -Start '1970-01-01' -End $Before).TotalSeconds)

                $ApiEndpoint = $ApiEndpoint + "&from=$FromDateToPost" + "&to=$ToDateToPost"
            }
            else {
                throw 'The value for Before must be greater than the value for After.'
            }
        }

        $HistoryDataPoints = InvokeTelldusAction -URI $ApiEndpoint


        foreach ($HistoryDataPoint in $HistoryDataPoints.history)
        {
            $PropertiesToOutput = @{
                                 'DeviceID' = $DeviceID
                                 'Humidity' = ($HistoryDataPoint.data | Where-Object { $_.Name -eq 'humidity' }).value
                                 'Temperature' = ($HistoryDataPoint.data | Where-Object { $_.Name -eq 'temp' }).value
                                 'Date' = (Get-Date "1970-01-01 00:00:00").AddSeconds($HistoryDataPoint.ts)
                                 }

            $returnObject = New-Object -TypeName PSObject -Property $PropertiesToOutput

            Write-Output $returnObject | Select-Object DeviceID, Humidity, Temperature, Date
        }
    }

    END { }
}
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
        $Response = InvokeTelldusAction -URI "device/setName`?id=$DeviceID&name=$NewName"

        Write-Verbose "Renamed device with id $DeviceID. Result: $($Response.status)."
    }
}

function Set-TDDevice
{

    <#
    .SYNOPSIS
    Turns a device on or off.

    .DESCRIPTION
    This command can set the state of a device to on or off through the Telldus Live! service.

    .EXAMPLE
    Set-TDDevice -DeviceID 123456 -Action turnOff

    .EXAMPLE
    Set-TDDevice -DeviceID 123456 -Action turnOn

    .EXAMPLE
    SET-TDDevice -DeviceID 123456 -Action bell

    .PARAMETER DeviceID
    The DeviceID of the device to turn off or on. (Pipelining possible)

    .PARAMETER Action
    What to do with that device. Possible values are "turnOff", "turnOn" and "bell".

    .NOTES
    Thank you Ispep (automatiserar.se) for fixing "bell" support!

    #>

    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('id')]
      [string] $DeviceID,
      [Parameter(Mandatory=$True)]
      [ValidateSet("turnOff","turnOn", "bell", "down", "up")]
      [string] $Action)


    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        $Response = InvokeTelldusAction -URI "device/$Action`?id=$DeviceID"

        Write-Verbose "Doing action $Action on device $DeviceID. Result: $($Response.status)."
    }
}
function Set-TDDimmer
{
    <#
    .SYNOPSIS
    Dims a device to a certain level.

    .DESCRIPTION
    This command can set the dimming level of a device to through the Telldus Live! service.

    .EXAMPLE
    Set-TDDimmer -DeviceID 123456 -Level 89

    .EXAMPLE
    Set-TDDimmer -Level 180

    .PARAMETER DeviceID
    The DeviceID of the device to dim. (Pipelining possible)

    .PARAMETER Level
    What level to dim to. Possible values are 0 - 255.

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True,
                 ValueFromPipeline=$true,
                 ValueFromPipelineByPropertyName=$true,
                 HelpMessage="Enter the DeviceID.")] [Alias('id')] [string] $DeviceID,

      [Parameter(Mandatory=$True,
                 HelpMessage="Enter the level to dim to between 0 and 255.")]
      [ValidateRange(0,255)]
      [int] $Level)


    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        $Response = InvokeTelldusAction -URI "device/dim`?id=$DeviceID&level=$Level"

        Write-Verbose "Dimming device $DeviceID to level $Level. Result: $($Response.status)."
    }
}
