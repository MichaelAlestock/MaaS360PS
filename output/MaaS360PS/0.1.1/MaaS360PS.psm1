#Region 'PREFIX' -1

New-Variable -Name 'MaaS360Session' -Value @{
    'url' = ''; 'endpoint' = ''; 'platformID' = ''; 'billingID' = ''; 'userName' = ''; 'password' = ''; 'appID' = ''; 'appVersion' = '' ; 'appAccessKey' = '' ; 'apiKey' = '' ; 'tempHeaders' = @{} ; 'baseUrl' = 'https://apis.m3.maas360.com/' ; 'authEndpoint' = 'auth-apis/auth/1.0/authenticate'
} -Scope 'Global' -Force
#EndRegion 'PREFIX'
#Region '.\public\Connect-MaaS360PS.ps1' -1

function Connect-MaaS360PS
{
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Bugs to fix:
            - Receive a success message when getting trying to receive a token even when using incorrect info
            - Always fails the first auth attempt even when info is correct and succeeds on the next attempt
                - Annoyance for now
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    [CmdletBinding(DefaultParameterSetName = 'Connect with API token')]
    Param(
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$BillingID,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Connect with API token', Mandatory = $true)]
        [ValidateSet('Get', 'Post')]
        [string]$Method,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$PlatformID,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$AppID,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$AppVersion,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$AppAccessKey,
        [Parameter(HelpMessage = 'Enter same credentials utilized to log into MaaS360 web portal.',
            ParameterSetName = 'New API token', Mandatory = $true)]
        [PSCredential]$Credentials,
        [switch]$Result
    )

    # We need to get an auth token from MaaS360 before we can do anything which means we need to utilize all params and make an API call
    # Once we retrieve our API token we can see $MaaS360Session.ApiToken = whatever the token is but of course secure string and in the format of MaaS360 token="token here"
    # Once we have the token we can then call Test-MaaS360PSConnection to see if we're able to get any response
    # It'll probably entail a good amount of error handling but we shall see what we get
    # Fix this later to be a more dynamic function that'll build the body out
    # convert the password from securestring and convert output to json
    # Used for the POST request to get an API key
    # We'll change things up as we get everything working by adding some logic and error-handling

    if (-not ((Get-ChildItem -Path 'Variable:').Name -contains 'MaaS360Session'))
    {
        throw 'Unable to find the session variable [$MaaS360Session]. Try re-importing the module with the `-Force` parameter if you continue to have issues.'
    }
        
    # $MaaS360Session.apiToken = $null  # Play with this after we make the call and retrieve the API token
    if ($Method -eq 'Post')
    {
        $Headers = @{
            'Accept'       = 'application/json'
            'Content-Type' = 'application/xml'
        }

        $AuthResponse = ''
        # $MaaS360Session.url = $Url # Getting rid of this and just gonna place it in the script var since it's global
        # $MaaS360Session.endpoint = $Endpoint # Getting rid of this too for the same reasons as ^^
        $MaaS360Session.billingID = $BillingID
        $MaaS360Session.platformID = $PlatformID
        $MaaS360Session.password = $Credentials.Password | ConvertFrom-SecureString -AsPlainText
        $MaaS360Session.userName = $Credentials.UserName
        $MaaS360Session.appID = $AppID
        $MaaS360Session.appVersion = $AppVersion
        $MaaS360Session.appAccessKey = $AppAccessKey

        $Body = @"
        <authRequest>
          <maaS360AdminAuth>
              <platformID>$($MaaS360Session.platformID)</platformID>
              <billingID>$($MaaS360Session.billingID)</billingID>
              <password>$($MaaS360Session.password)</password>
              <userName>$($MaaS360Session.userName)</userName>
              <appID>$($MaaS360Session.appID)</appID>
              <appVersion>$($MaaS360Session.appVersion)</appVersion>
              <appAccessKey>$($MaaS360Session.appAccessKey)</appAccessKey>
          </maaS360AdminAuth>
        </authRequest>
"@

        $Uri = $MaaS360Session.baseUrl + $MaaS360Session.authEndpoint + '/' + $MaaS360Session.billingID

        $AuthResponse = Invoke-RestMethod -Uri $Uri -Body $Body -Headers $Headers -Method $Method
        $RawToken = $AuthResponse.authResponse.authToken
        Write-Debug -Message "RAW API KEY: $RawToken"
        $MaaS360Session.apiKey = ('MaaS token=' + $("""$RawToken""")) | ConvertTo-SecureString -AsPlainText -Force
 
        Write-Debug -Message "URI: $($Uri)"
        Write-Debug -Message "SECURE API KEY: $($MaaS360Session.apiKey)"

        if (($MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText) -eq 'MaaS token=""')
        {
            Write-Debug -Message "RAW API KEY FIELD IS EMPTY: [$($MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText)] instead of [MaaS token='your_token_here']"

            throw 'Something went wrong, [API KEY] was not retrieved. Please check parameter values to be sure all info is correct or run the command with the -Debug parameter to get more info.'
        }
        
        Write-Output -InputObject 'Successfully obtained API KEY. '
    }

    if ($Method -eq 'Get')
    {
        if (($MaaS360Session.apiKey -eq '') -or ($MaaS360Session.authEndpoint -eq ''))
        {
            throw 'Please use Connect-MaaS360PS with the [POST] method before attempting to utilize any commands.'
        }

        $Token = $MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText

        if ($Result.IsPresent)
        {
            Write-Output -InputObject "URI: $($MaaS360Session.baseUrl + $MaaS360Session.authEndpoint + '/' + $MaaS360Session.billingID)"
            Write-Output -InputObject "API KEY: $Token"
        }
       
        Write-Output -InputObject 'Connection to MaaS360 instance assumed successful. Run Test-MaaS360PSConnection for confirmation.'
    }

    if (-not (Test-MaaS360PSConnection -BillingID $BillingID -Method 'Get'))
    {
        throw 'Unable to verify connection to MaaS360 instance. Please check your [URL], [API KEY], or re-run command with [POST] method to regenerate a key.'
    }
    else
    {
        Write-Output -InputObject 'Connection to your MaaS360 instance is fully confirmed. Feel free to use all commands.'
    }
}
#EndRegion '.\public\Connect-MaaS360PS.ps1' 136
#Region '.\public\Get-GNMaaS360Device.ps1' -1

function Get-MaaS360Device
{
  # Need to add a default parameter set
  [CmdletBinding()]

  # Need to add parameter set names
  Param(
    [int]$PageNumber,
    [ValidateSet('25', '50', '100', '200', '250')]
    [int]$PageSize,
    [ValidateSet(0, 1)]
    [int]$Match,
    [string]$DeviceName,
    [string]$PhoneNumber,
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]$Username,
    [string]$EmailAddress,
    [ValidateSet('Active', 'Inactive')]
    [string]$DeviceStatus,
    [ValidatePattern('^[0-9]{15}$', ErrorMessage = 'IMEI provided is not valid.')]
    [string]$IMEI,
    [ValidateSet('Inactive', 'Activated', 'Control Removed', 'Pending Control Removed', 'User Removed Control', 'Not Enrolled', 'Enrolled')]
    [string]$ManagedStatus
  )

  $BillingID = Get-PSMaaS360BillingID
  $Endpoint = "device-apis/devices/2.0/search/customer/$BillingID"

  $Body = @{}
  
  # FAT if statements but not sure how to turn into a switch without getting in the weeds
  if ($PSBoundParameters.ContainsKey('DeviceName')) { $Body.Add('partialDeviceName', $DeviceName) }
  if ($PSBoundParameters.ContainsKey('Username')) { $Body.Add('partialUsername', $Username) }
  if ($PSBoundParameters.ContainsKey('PhoneNumber')) { $Body.Add('partialPhoneNumber', $PhoneNumber) }
  if ($PSBoundParameters.ContainsKey('PageSize')) { $Body.Add('pageSize', $PageSize) }
  if ($PSBoundParameters.ContainsKey('PageNumber')) { $Body.Add('pageNumber', $PageNumber) }
  if ($PSBoundParameters.ContainsKey('Match')) { $Body.Add('match', $Match) }
  if ($PSBoundParameters.ContainsKey('EmailAddress')) { $Body.Add('email', $EmailAddress) }
  if ($PSBoundParameters.ContainsKey('DeviceStatus')) { $Body.Add('deviceStatus', $DeviceStatus) }
  if ($PSBoundParameters.ContainsKey('IMEI')) { $Body.Add('imeiMeid', $IMEI) }
  if ($PSBoundParameters.ContainsKey('ManagedStatus')) { $Body.Add('maas360ManagedStatus', $ManagedStatus) }

  <#
  # Write debug to show not only what params were used when invoking the command but
  # also to show what params are a part of the overall body that is sent in the request
  #>

  Write-Debug -Message `
  ( "Running $($MyInvocation.MyCommand)`n" +
    "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
    "Get-PSMaaS360Device parameters:`n$($Body | Format-List | Out-String)" )

  try 
  {
    $Response = Invoke-PSMaaS360APIRequest -Method 'Get' -Body $Body -Endpoint $Endpoint
    $ResponseArray = @($Response.devices.device)

    $Object = Foreach ($Obj in $ResponseArray)
    {

      $BasicInfo = Get-PSMaaS360DeviceBasic -SerialNumber $Obj.maas360DeviceID
      $RemainingStorage = "$($BasicInfo.FreeSpace) GB"
      $ICCID = ($BasicInfo.ICCID).ToString().Replace(' ', '')
      $Carrier = $BasicInfo.Carrier

      [PSCustomObject]@{
        'LastReported'       = $Obj.lastReported
        'Name'               = $Obj.deviceName
        'Type'               = $Obj.deviceType
        'Status'             = $Obj.deviceStatus
        'Serial'             = $Obj.platformSerialNumber
        'MdmSerial'          = $Obj.maas360DeviceID
        'IMEI'               = $Obj.imeiEsn
        'ICCID'              = $ICCID
        'Carrier'            = $Carrier
        'RemainingStorage'   = $RemainingStorage
        'Enrollment'         = $Obj.maas360ManagedStatus
        'Owner'              = $Obj.username
        'OwnerEmail'         = $Obj.emailAddress
        'OwnedBy'            = $Obj.ownership
        'Manufacturer'       = $Obj.manufacturer
        'Model'              = $Obj.model
        'ModelId'            = $Obj.modelId
        'iOS'                = $Obj.osName
        'iOS_Version'        = $Obj.osVersion
        'PhoneNumber'        = ($Obj.phoneNumber).Remove(0, 2).Insert(3, '.').Insert(7, '.')
        'AppCompliance'      = $Obj.appComplianceState
        'PasscodeCompliance' = $Obj.passcodeCompliance
        'PolicyCompliance'   = $Obj.policyComplianceState
        'Policy'             = $Obj.mdmPolicy
        'DateRegistered'     = $Obj.installedDate
        'iTunesEnabled'      = $Obj.itunesStoreAccountEnabled
        'WipeStatus'         = $Obj.selectiveWipeStatus
        'UDID'               = $Obj.udid
        'MAC_Address'        = $Obj.wifiMacAddress
      }
   
    }
    
    # Create our custom object with the Device.Information type
    $Object.PSObject.TypeNames.Insert(0, 'Device.Information')
    $DefaultDisplaySet = @('Status', 'Enrollment', 'Owner', 'PhoneNumber', 'IMEI', 'ICCID', 'Serial', 'LastReported')
    $DefaultDisplayPropertySet = [System.Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet', [string[]]$DefaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)
    $Object | Add-Member -MemberType 'MemberSet' -Name 'PSStandardMembers' -Value $PSStandardMembers

    if ($null -eq $ResponseArray[0])
    {
      Write-Output -InputObject 'Device not found. Please check the name and try again.'
    }
    else
    {
      $Object
    }
  }
  catch
  {
    $_.Exception.Message
  }
  
}
#EndRegion '.\public\Get-GNMaaS360Device.ps1' 122
#Region '.\public\Get-MaaS360Device.ps1' -1

function Get-MaaS360Device
{
  # Need to add a default parameter set
  [CmdletBinding()]

  # Need to add parameter set names
  Param(
    [int]$PageNumber,
    [ValidateSet('25', '50', '100', '200', '250')]
    [int]$PageSize,
    [ValidateSet(0, 1)]
    [int]$Match,
    [string]$DeviceName,
    [string]$PhoneNumber,
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]$Username,
    [string]$EmailAddress,
    [ValidateSet('Active', 'Inactive')]
    [string]$DeviceStatus,
    [ValidatePattern('^[0-9]{15}$', ErrorMessage = 'IMEI provided is not valid.')]
    [string]$IMEI,
    [ValidateSet('Inactive', 'Activated', 'Control Removed', 'Pending Control Removed', 'User Removed Control', 'Not Enrolled', 'Enrolled')]
    [string]$ManagedStatus
  )

  $BillingID = Get-PSMaaS360BillingID
  $Endpoint = "device-apis/devices/2.0/search/customer/$BillingID"

  $Body = @{}
  
  # FAT if statements but not sure how to turn into a switch without getting in the weeds
  if ($PSBoundParameters.ContainsKey('DeviceName')) { $Body.Add('partialDeviceName', $DeviceName) }
  if ($PSBoundParameters.ContainsKey('Username')) { $Body.Add('partialUsername', $Username) }
  if ($PSBoundParameters.ContainsKey('PhoneNumber')) { $Body.Add('partialPhoneNumber', $PhoneNumber) }
  if ($PSBoundParameters.ContainsKey('PageSize')) { $Body.Add('pageSize', $PageSize) }
  if ($PSBoundParameters.ContainsKey('PageNumber')) { $Body.Add('pageNumber', $PageNumber) }
  if ($PSBoundParameters.ContainsKey('Match')) { $Body.Add('match', $Match) }
  if ($PSBoundParameters.ContainsKey('EmailAddress')) { $Body.Add('email', $EmailAddress) }
  if ($PSBoundParameters.ContainsKey('DeviceStatus')) { $Body.Add('deviceStatus', $DeviceStatus) }
  if ($PSBoundParameters.ContainsKey('IMEI')) { $Body.Add('imeiMeid', $IMEI) }
  if ($PSBoundParameters.ContainsKey('ManagedStatus')) { $Body.Add('maas360ManagedStatus', $ManagedStatus) }

  <#
  # Write debug to show not only what params were used when invoking the command but
  # also to show what params are a part of the overall body that is sent in the request
  #>

  Write-Debug -Message `
  ( "Running $($MyInvocation.MyCommand)`n" +
    "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
    "Get-PSMaaS360Device parameters:`n$($Body | Format-List | Out-String)" )

  try 
  {
    $Response = Invoke-PSMaaS360APIRequest -Method 'Get' -Body $Body -Endpoint $Endpoint
    $ResponseArray = @($Response.devices.device)

    $Object = Foreach ($Obj in $ResponseArray)
    {

      $BasicInfo = Get-PSMaaS360DeviceBasic -SerialNumber $Obj.maas360DeviceID
      $RemainingStorage = "$($BasicInfo.FreeSpace) GB"
      $ICCID = ($BasicInfo.ICCID).ToString().Replace(' ', '')
      $Carrier = $BasicInfo.Carrier

      [PSCustomObject]@{
        'LastReported'       = $Obj.lastReported
        'Name'               = $Obj.deviceName
        'Type'               = $Obj.deviceType
        'Status'             = $Obj.deviceStatus
        'Serial'             = $Obj.platformSerialNumber
        'MdmSerial'          = $Obj.maas360DeviceID
        'IMEI'               = $Obj.imeiEsn
        'ICCID'              = $ICCID
        'Carrier'            = $Carrier
        'RemainingStorage'   = $RemainingStorage
        'Enrollment'         = $Obj.maas360ManagedStatus
        'Owner'              = $Obj.username
        'OwnerEmail'         = $Obj.emailAddress
        'OwnedBy'            = $Obj.ownership
        'Manufacturer'       = $Obj.manufacturer
        'Model'              = $Obj.model
        'ModelId'            = $Obj.modelId
        'iOS'                = $Obj.osName
        'iOS_Version'        = $Obj.osVersion
        'PhoneNumber'        = ($Obj.phoneNumber).Remove(0, 2).Insert(3, '.').Insert(7, '.')
        'AppCompliance'      = $Obj.appComplianceState
        'PasscodeCompliance' = $Obj.passcodeCompliance
        'PolicyCompliance'   = $Obj.policyComplianceState
        'Policy'             = $Obj.mdmPolicy
        'DateRegistered'     = $Obj.installedDate
        'iTunesEnabled'      = $Obj.itunesStoreAccountEnabled
        'WipeStatus'         = $Obj.selectiveWipeStatus
        'UDID'               = $Obj.udid
        'MAC_Address'        = $Obj.wifiMacAddress
      }
   
    }
    
    # Create our custom object with the Device.Information type
    $Object.PSObject.TypeNames.Insert(0, 'Device.Information')
    $DefaultDisplaySet = @('Status', 'Enrollment', 'Owner', 'PhoneNumber', 'IMEI', 'ICCID', 'Serial', 'LastReported')
    $DefaultDisplayPropertySet = [System.Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet', [string[]]$DefaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)
    $Object | Add-Member -MemberType 'MemberSet' -Name 'PSStandardMembers' -Value $PSStandardMembers

    if ($null -eq $ResponseArray[0])
    {
      Write-Output -InputObject 'Device not found. Please check the name and try again.'
    }
    else
    {
      $Object
    }
  }
  catch
  {
    $_.Exception.Message
  }
  
}
#EndRegion '.\public\Get-MaaS360Device.ps1' 122
#Region '.\public\Get-MaaS360DeviceBasic.ps1' -1

function Get-MaaS360DeviceBasic
{

  # Need to add a default parameter set
  [CmdletBinding()]

  # Need to add parameter set names
  Param(
    [Parameter(ValueFromPipeline = $true)]
    [string]$SerialNumber
  )

  $BillingID = Get-GNMaaS360BillingID
  $Endpoint = "/device-apis/devices/1.0/summary/$BillingID"

  $Body = @{}
  
  # FAT if statements but not sure how to turn into a switch without getting in the weeds
  if ($PSBoundParameters.ContainsKey('SerialNumber')) { $Body.Add('deviceId', $SerialNumber) }

  <#
  # Write debug to show not only what params were used when invoking the command but+
  # also to show what params are a part of the overall body that is sent in the request
  #>

  Write-Debug -Message `
  ( "Running $($MyInvocation.MyCommand)`n" +
    "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
    "Get-GNMaaS360DeviceBasic parameters:`n$($Body | Format-List | Out-String)" )

  try 
  {
    $Response = Invoke-GNMaaS360APIRequest -Method 'Get' -Body $Body -Endpoint $Endpoint
    $ResponseArray = @($Response.devicesSummary.deviceAttributes.deviceAttribute)

    # this took me way too long to figure out
    $Keys = @($ResponseArray.key)
    $Values = @($ResponseArray.value)

    if ($null -eq $Keys[0])
    {
      throw 'No device found.'
    }

    $Obj = for ($i = 0 ; $i -lt $Keys.Length ; $i++)
    {
      @{
        $Keys[$i] = $Values[$i]
      }
    }

    $Object = [PSCustomObject]@{
      'SerialNumber' = $Obj.'Apple Serial Number'
      'Carrier'      = $Obj.'Current Carrier'
      'FreeSpace'    = $Obj.'Free Internal Storage (GB)'
      'ICCID'        = $Obj.ICCID
    }

    $Object.PSObject.TypeNames.Insert(0, 'Device.Basic.Information')
    $DefaultDisplaySet = @('SerialNumber', 'Carrier', 'FreeSpace', 'ICCID')
    $DefaultDisplayPropertySet = [System.Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet', [string[]]$DefaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)
    $Object | Add-Member -MemberType 'MemberSet' -Name 'PSStandardMembers' -Value $PSStandardMembers

    $Object

  }
  catch
  {
    $_.Exception.Message
  }
  
}
#EndRegion '.\public\Get-MaaS360DeviceBasic.ps1' 74
#Region '.\public\Get-MaaS360User.ps1' -1

function Get-MaaS360User
{
  Param(
    [int]$IncludeAllUsers,
    [int]$PageNumber,
    [int]$PageSize,
    [int]$Match,
    [string]$EmailAddress,
    [string]$FullName,
    [string]$Username
  )
 
  # Stop any further execution until an API key (session) is created
  # Will most likely need to turn this into an external function since this will be used in nearly every single function
  # gotta live by that DRY
  if ($MaaS360Session.apiKey -eq '')
  {
    throw 'No API key found. Did you run Connect-MaaS360PS before running this command?'
  }

  $Uri = $MaaS360Session.baseUrl + 'user-apis/user/1.0/search/' + $MaaS360Session.billingID

  $Body = @{}

  # User object related
  # Removed the majority of what was there to slowly build up to the best way to handle dynamically adding these keys to the body
  if ($PSBoundParameters.ContainsKey('EmailAddress')) { $Body.Add('partialEmailAddress', $EmailAddress) }

  <#
  # Write debug to show not only what params were used when invoking the command but
  # also to show what params are a part of the overall body that is sent in the request
  #>

  # Finding a better way to handle writing to debug instead of this
  # Write-Debug -Message ( "Running $($MyInvocation.MyCommand)`n" +
  #   "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
  #   "Get-GNMaaS360User parameters:`n$($Body | Format-List | Out-String)" )

  try 
  {
    $Response = Invoke-MaaS360Method -Uri $Uri -Method 'Get' -Body $Body -Authentication 'BEARER' `
      -Token $MaaS360Session.apiKey -Headers $MaaS360Session.tempHeaders

    $Response.users.user
  }
  catch
  {
    $_.Exception.Message
  }
  
}
#EndRegion '.\public\Get-MaaS360User.ps1' 52
#Region '.\public\New-MaaS360User.ps1' -1

function New-MaaS360User
{

  [CmdletBinding()]

  Param(
    [string]$Username,
    [string]$EmailAddress,
    [string]$FullName,
    [string]$Domain
  )

  $BillingID = Get-GNMaaS360BillingID
  $Endpoint = "user-apis/user/1.0/addUser/customer/$BillingID"

  $Headers = @{
    'accept' = 'application/json'
  }

  $Body = @{
    # Removing default entries and placing them in the switch
    # 'includeAllUsers' = 0
    # 'pageNumber'      = 1
    # 'pageSize'        = 250
    # 'match'           = 0
  }

  # User object related
  if ($PSBoundParameters.ContainsKey('EmailAddress')) { $Body.Add('email', $EmailAddress) }
  if ($PSBoundParameters.ContainsKey('Domain')) { $Body.Add('domain', $Domain) }
  if ($PSBoundParameters.ContainsKey('FullName')) { $Body.Add('fullName', $FullName) }
  if ($PSBoundParameters.ContainsKey('Username')) { $Body.Add('userName', $Username ) }
  #  if ($SetPassword.IsPresent) { $Body.Add('emailSetPwdLink', $SetPassword) }

  <#
  # Write debug to show not only what params were used when invoking the command but
  # also to show what params are a part of the overall body that is sent in the request
  #>

  Write-Debug -Message ( "Running $($MyInvocation.MyCommand)`n" +
    "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
    "Get-GNMaaS360User parameters:`n$($Body | Format-List | Out-String)" )

  try 
  {
    $Response = Invoke-GNMaaS360APIRequest -Method 'Post' -Body $Body -Endpoint $Endpoint -Headers $Headers -ContentType 'application/x-www-form-urlencoded'
    # $ResponseArray = @($Response.users.user)

    # $Object = ForEach ($obj in $ResponseArray)
    # {
    #   [pscustomobject]@{
    #     'FullName'        = $Obj.FullName
    #     'Username'        = $Obj.userName
    #     'EmailAddress'    = $Obj.emailAddress
    #     'Group'           = $Obj.groups.group.name
    #     'Created'         = $Obj.createDate
    #     'AuthType'        = $Obj.authType
    #     'Domain'          = $Obj.domain
    #     'PasswordExpDate' = $Obj.passwordexpirydate
    #     'Source'          = $Obj.source
    #     'Status'          = $Obj.status
    #     'LastUpdated'     = $Obj.updatedate
    #     'UserID'          = $Obj.useridentifier
    #     'Alias'           = $Obj.usernamealias
    #   }
    # }

    # # Create our custom object with the User.Information type
    # $Object.PSObject.TypeNames.Insert(0, 'User.Information')
    # $DefaultDisplaySet = @('Status', 'FullName', 'Username', 'EmailAddress', 'Group')
    # $DefaultDisplayPropertySet = [System.Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet', [string[]]$DefaultDisplaySet)
    # $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)
    # $Object | Add-Member -MemberType 'MemberSet' -Name 'PSStandardMembers' -Value $PSStandardMembers

    # Can this be improved to stop the error from showing even if it's just New-GNMaaS360AuthToken running?
    if (($null -eq $Response))
    {
      Write-Output -InputObject 'User not found. Please check the name and try again.'
    }
    else
    {
      $Response | Get-Member
    }
    
  }
  catch
  {
    $_.Exception.Message
  }
  
}
#EndRegion '.\public\New-MaaS360User.ps1' 92
#Region '.\public\Test-MaaS360PSConnection.ps1' -1

# $TestMethod = 'Get'
# $TestEndpoint = 'user-apis/user/1.0/search/'

function Test-MaaS360PSConnection
{
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    [CmdletBinding()]
    Param(
        [string]$BillingID,
        [string]$Method
    )

    if (($null -eq $MaaS360Session.apiKey) -or ($null -eq $MaaS360Session.baseUrl) -or (-not (Get-ChildItem -Path 'Variable:').Name -contains 'MaaS360Session'))
    {
        throw 'No connection created to MaaS360 instance. Please run "Connect-MaaS360PS" to create a session.'
    }

    $Headers = @{
        'Accept'       = 'application/json'
        'Content-Type' = 'application/json'
    }

    $Uri = $MaaS360Session.baseUrl + 'user-apis/user/1.0/search/' + $BillingID

    # Both of these are needed to give the user the ability to see if their URI or API KEY could be reasons behind errors they're experiencing.
    Write-Debug -Message "URI: $Uri"
    Write-Debug -Message "TOKENIZED API KEY: $(($MaaS360Session.apiKey) | ConvertFrom-SecureString -AsPlainText)"

    $Parameters = @{
        Uri            = $Uri
        Method         = $Method
        Headers        = $Headers
        Authentication = 'Bearer'
        Token          = $MaaS360Session.apiKey 
        # Forgot token needs to actually be sent as a securestring and is only sent as plain text when used getting a new token.. wow
    }

    try
    {
        $TestResponse = Invoke-MaaS360Method @Parameters
        
        Write-Debug -Message "Debug response: $($TestResponse)"

        # Not sure how else to check for content in the response other than checking if it's a PSCustomObject since it wouldn't be if it were an error.
        if ((($TestResponse).GetType()).Name -eq 'PSCustomObject')
        {
            Write-Debug -Message "Connection to [$Uri] successful."
            return $true
        }
        else
        {
            # API isn't going to return a terminating error no matter what I do so this is the best way I can think of to handle the error and provide the user with useful information.
            Write-Debug -Message $(Get-BetterError -ExceptionMessage "Connection to [$Uri] was unsuccessful. Find reasoning below to correct the issue." -ErrorID "$BillingID" -ErrorObject $TestResponse -ErrorCategory 'ConnectionError')
            return $false
        }
    }
    catch
    {   
        throw $_
    } 
}
#EndRegion '.\public\Test-MaaS360PSConnection.ps1' 75
#Region '.\private\Get-BetterError.ps1' -1

function Get-BetterError
{
    [CmdletBinding()]
    Param(
        [string]$ErrorID,
        [string]$ErrorCategory,
        [string]$ExceptionMessage,
        [object]$ErrorObject
    )

    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
        [Exception]::new($ExceptionMessage), 
        $ErrorID, 
        [System.Management.Automation.ErrorCategory]::$ErrorCategory, 
        $ErrorObject
    )

    try
    {
        $FindErrorReason = Get-Error -Newest 1
        $ErrorDetailsJson = $FindErrorReason.ErrorDetails.Message | ConvertFrom-Json -Depth '5'
        $ErrorDetailsErrorCode = $ErrorDetailsJson.authResponse.errorCode
        $ErrorDetailsErrorDescription = $ErrorDetailsJson.authResponse.errorDesc
        $StatusCode = $FindErrorReason.Exception.StatusCode
        $Script:ExpressReason = ''
            
        switch ($StatusCode)
        {
            'Unauthorized'
            {
                switch ($ErrorDetailsErrorCode)
                {
                    '1007'
                    {
                        Write-Warning -Message 'Token has expired. Please run Connect-MaaS360PS with the [POST] method to generate a new one.'
                        break
                    }
                    '1008'
                    {
                        Write-Warning -Message 'BillingID is possibly incorrect. Please check the supplied BillingID to verify and try again.'
                        break
                    }
                    Default
                    {
                        Write-Debug -Message @"
Failure Error Description: $($ErrorDetailsErrorDescription)
Failure Error Status Code: $($ErrorDetailsErrorCode)
"@
                    }
                }
                break
            }
        }

        $ErrorRecord
    }
    catch
    {
        throw 'Unable to parse error record.'
    }
    
}
#EndRegion '.\private\Get-BetterError.ps1' 63
#Region '.\private\Invoke-MaaS360Method.ps1' -1

# Changing name to identify that this function uses Invoke-RestMethod and not Invoke-WebRequest
function Invoke-MaaS360Method
{
    <#
        # Usage
        - Like the bread on a sandwich, without this no API calls will function
        - Able to take in any method and piece of input no matter the function calling it
    #>

    [CmdletBinding()]
    Param(
        [hashtable]$Body,
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers,
        [string]$ContentType,
        [string]$Authentication,
        [securestring]$Token
    )

    # Stop any further execution until an API key (session) is created
    if ($null -eq $MaaS360Session.apiKey)
    {
        throw 'No API key found. Did you run Connect-MaaS360PS before running this command?'
    }

    # Make sure the headers hash is empty before trying to shove more stuff into it
    if ($MaaS360Session.tempHeaders.Count -eq 0)
    {
        switch ($Method)
        {
            'Get'
            {
                $MaaS360Session.tempHeaders.Add('Accept', 'application/json')
                $MaaS360Session.tempHeaders.Add('Content-Type', 'application/json')
                break
            }
            'Post'
            {
                $MaaS360Session.tempHeaders.Add('Accept', 'application/json')
                $MaaS360Session.tempHeaders.Add('Content-Type', 'application/x-www-form-urlencoded')
                break
            }
            { 'Patch', 'Delete' }
            {
                $MaaS360Session.tempHeaders.Add('Accept', 'application/json')
                $MaaS360Session.tempHeaders.Add('Content-Type', 'application/json-patch+json')
                break
            }
        }
    }
   

    # Maybe we should dynamically build the headers ^^
    $Headers = $MaaS360Session.tempHeaders
    
    try
    {
        # Not sure if smart to keep it out in the open like this instead of behind a variable
        $InvokeResponse = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType $ContentType -Authentication $Authentication -Token $Token

        $InvokeResponse
        # Clear to avoid potential errors in subsequent calls
        $MaaS360Session.tempHeaders.Clear()
    }
    catch
    {
        # Just the basics for right now
        $_.ErrorDetails.Message
        $_.Exception.Message
    }
}
#EndRegion '.\private\Invoke-MaaS360Method.ps1' 73
