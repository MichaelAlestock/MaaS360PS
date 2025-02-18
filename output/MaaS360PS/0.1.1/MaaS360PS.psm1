#Region '.\en-US\public\Connect-MaaS360PS.ps1' -1

function Connect-MaaS360PS
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

    [CmdletBinding(DefaultParameterSetName = 'Connect with API token')]
    Param(
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$BillingID,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$Url,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$Endpoint,
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
        [PSCredential]$Credentials
    )

    # We need to get an auth token from MaaS360 before we can do anything which means we need to utilize all params and make an API call
    # Once we retrieve our API token we can see $MaaS360Session.ApiToken = whatever the token is but of course secure string and in the format of MaaS360 token="token here"
    # Once we have the token we can then call Test-MaaS360PSConnection to see if we're able to get any response
    # It'll probably entail a good amount of error handling but we shall see what we get
    # Fix this later to be a more dynamic function that'll build the body out
    # convert the password from securestring and convert output to json
    # Used for the POST request to get an API key
    # We'll change things up as we get everything working by adding some logic and error-handling

    # $MaaS360Session.apiToken = $null  # Play with this after we make the call and retrieve the API token
    if ($Method -eq 'Post')
    {
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


        $Headers = @{
            'Accept'       = 'application/json'
            'Content-Type' = 'application/xml'
        }

        $AuthResponse = ''
        $MaaS360Session.url = $Url
        $MaaS360Session.endpoint = $Endpoint
        $MaaS360Session.billingID = $BillingID
        $MaaS360Session.platformID = $PlatformID
        $MaaS360Session.password = $Credentials.Password | ConvertFrom-SecureString -AsPlainText
        $MaaS360Session.userName = $Credentials.UserName
        $MaaS360Session.appID = $AppID
        $MaaS360Session.appVersion = $AppVersion
        $MaaS360Session.appAccessKey = $AppAccessKey

        $Script:Uri = $MaaS360Session.url + $MaaS360Session.endpoint + '/' + $MaaS360Session.billingID

        $AuthResponse = Invoke-RestMethod $Uri -Body $Body -Headers $Headers -Method $Method
        $RawToken = $AuthResponse.authResponse.authToken
        $MaaS360Session.apiKey = ('MaaS token=' + $("""$RawToken""")) | ConvertTo-SecureString -AsPlainText -Force
 
        Write-Debug -Message "URL: $($MaaS360Session.url)"
        Write-Debug -Message "API KEY: $($MaaS360Session.apiKey)"
    }

    if ($Method -eq 'Get')
    {
        if (($null -eq $MaaS360Session.apiKey))
        {
            throw 'Please use Connect-MaaS360PS with the [POST] method before attempting to utilize any commands.'
        }

        $TestUrl = $MaaS360Session.url
        $TestEndpoint = $MaaS360Session.endpoint
        $TestUri = $TestUrl + '/' + $TestEndpoint + '/' + $MaaS360Session.billingID
        $Token = $MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText
       
        Write-Debug -Message "URI: $TestUri"
        Write-Debug -Message "API KEY: $($Token)"
    }

    if (-not (Test-MaaS360PSConnection))
    {
        throw 'Unable to verify connection to MaaS360 instance. Please check your [URL], [API KEY], or re-run command with [POST] method to regenerate a key.'
    }
}
#EndRegion '.\en-US\public\Connect-MaaS360PS.ps1' 116
#Region '.\en-US\public\Get-GNMaaS360Device.ps1' -1

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
#EndRegion '.\en-US\public\Get-GNMaaS360Device.ps1' 122
#Region '.\en-US\public\Get-MaaS360Device.ps1' -1

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
#EndRegion '.\en-US\public\Get-MaaS360Device.ps1' 122
#Region '.\en-US\public\Get-MaaS360DeviceBasic.ps1' -1

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
#EndRegion '.\en-US\public\Get-MaaS360DeviceBasic.ps1' 74
#Region '.\en-US\public\Get-MaaS360User.ps1' -1

function Get-MaaS360User
{

  [CmdletBinding(DefaultParameterSetName = 'PartialMatch')]

  Param(
    [ValidateSet(0, 1, 2)]
    [int]$IncludeAllUsers,
    [int]$PageNumber,
    [ValidateSet(25, 50, 100, 200, 250, ErrorMessage = 'Input provided is not a valid page size.')]
    [int]$PageSize,
    [ValidateSet(1)]
    [Parameter(ParameterSetName = 'ExactMatch')]
    [int]$ExactMatch,
    [ValidateSet(0)]
    [Parameter(ParameterSetName = 'PartialMatch', Position = 0)]
    [int]$PartialMatch,
    [ValidatePattern('^([a-zA-Z]*)(.[a-zA-Z]*)@(gnmhc|healthylifeinmind).org', ErrorMessage = 'Input provided is not a valid email address.')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ExactMatch')]
    [string]$EmailAddress,
    [Parameter(ParameterSetName = 'PartialMatch', Position = 2)]
    [string]$PartialEmailAddress,
    [Alias('PartialFullUserName')]
    [Parameter(ParameterSetName = 'PartialMatch', Position = 3)]
    [Parameter(ParameterSetName = 'ExactMatch')]
    [string]$FullName,
    [Alias('PartialUserName')]
    [Parameter(ValueFromPipeline = $true, ParameterSetName = 'PartialMatch', Position = 2)]
    [Parameter(ParameterSetName = 'ExactMatch')]
    [string]$Username
  )

  $BillingID = Get-GNMaaS360BillingID
  $Endpoint = "user-apis/user/1.0/search/$BillingID"

  $Body = @{
    # Removing default entries and placing them in the switch
    # 'includeAllUsers' = 0
    # 'pageNumber'      = 1
    # 'pageSize'        = 250
    # 'match'           = 0
  }

  # User object related
  if ($PSBoundParameters.ContainsKey('EmailAddress')) { $Body.Add('partialEmailAddress', $EmailAddress) }
  if ($PSBoundParameters.ContainsKey('PartialEmailAddress')) { $Body.Add('partialEmailAddress', $PartialEmailAddress) }
  if ($PSBoundParameters.ContainsKey('FullName')) { $Body.Add('partialFullUserName', $FullName) }
  if ($PSBoundParameters.ContainsKey('Username')) { $Body.Add('partialUserName', $Username ) }

  # Paging related
  if ($PSBoundParameters.ContainsKey('PageSize')) { $Body.Add('pageSize', $PageSize ) }
  if ($PSBoundParameters.ContainsKey('PageNumber')) { $Body.Add('pageNumber', $PageNumber ) }
  if ($PSBoundParameters.ContainsKey('IncludeAllUsers')) { $Body.Add('includeAllUsers', $IncludeAllUsers ) }
  if ($PSBoundParameters.ContainsKey('ExactMatch')) { $Body.Add('match', $ExactMatch ) }
  if ($PSBoundParameters.ContainsKey('PartialMatch')) { $Body.Add('match', $PartialMatch ) }


  <#
  # Write debug to show not only what params were used when invoking the command but
  # also to show what params are a part of the overall body that is sent in the request
  #>

  Write-Debug -Message ( "Running $($MyInvocation.MyCommand)`n" +
    "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
    "Get-GNMaaS360User parameters:`n$($Body | Format-List | Out-String)" )

  try 
  {
    $Response = Invoke-GNMaaS360APIRequest -Method 'Get' -Body $Body -Endpoint $Endpoint
    $ResponseArray = @($Response.users.user)

    $Object = ForEach ($obj in $ResponseArray)
    {
      [pscustomobject]@{
        'FullName'        = $Obj.FullName
        'Username'        = $Obj.userName
        'EmailAddress'    = $Obj.emailAddress
        'Group'           = $Obj.groups.group.name
        'Created'         = $Obj.createDate
        'AuthType'        = $Obj.authType
        'Domain'          = $Obj.domain
        'PasswordExpDate' = $Obj.passwordexpirydate
        'Source'          = $Obj.source
        'Status'          = $Obj.status
        'LastUpdated'     = $Obj.updatedate
        'UserID'          = $Obj.useridentifier
        'Alias'           = $Obj.usernamealias
      }
    }

    # Create our custom object with the User.Information type
    $Object.PSObject.TypeNames.Insert(0, 'User.Information')
    $DefaultDisplaySet = @('Status', 'FullName', 'Username', 'EmailAddress', 'Group')
    $DefaultDisplayPropertySet = [System.Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet', [string[]]$DefaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)
    $Object | Add-Member -MemberType 'MemberSet' -Name 'PSStandardMembers' -Value $PSStandardMembers

    # Can this be improved to stop the error from showing even if it's just New-GNMaaS360AuthToken running?
    if (($null -eq $ResponseArray[0]))
    {
      Write-Output -InputObject 'User not found. Please check the name and try again.'
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
#EndRegion '.\en-US\public\Get-MaaS360User.ps1' 115
#Region '.\en-US\public\New-MaaS360User.ps1' -1

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
#EndRegion '.\en-US\public\New-MaaS360User.ps1' 92
#Region '.\en-US\public\Test-MaaS360PSConnection.ps1' -1

# $Method = 'Get'
function Test-MaaS360PSConnection
{
    # Test-MaaS360PSConnection

    <#
     Description: Test connection to the BASE URI of the MaaS360 API

    #>

    [CmdletBinding()]
    Param(
        [string]$Url,
        [string]$Endpoint = 'user-apis/user/1.0/search/',
        [string]$BillingID,
        [string]$Method = 'Get'
    )

    if (($null -eq $MaaS360Session.apiKey) -or ($null -eq $MaaS360Session.url) -or ($null -eq $MaaS360Session))
    {
        throw 'No connection created to MaaS360 instance. Please run "Connect-MaaS360PS" to create a session.'
    }

    $Uri = $Url + '/' + $Endpoint + $BillingID

    $Parameters = @{
        Uri            = $Uri
        Method         = $Method
        Authentication = 'Bearer'
        Token          = $MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText
    }

    try
    {
        $TestResponse = Invoke-RestMethod @Parameters

        if ($TestResponse -eq '1234567890')
        {
            Write-Output -InputObject "Connection to [$Uri] successful."
            return $true
        }
        else
        {
            $PSCmdlet.ThrowTerminatingError()
        }
    }
    catch
    {
        Get-BetterError -ExceptionMessage "Connection to [$Uri] was unsuccessful." -ErrorID '1234' -ErrorObject $TestResponse -ErrorCategory 'ObjectNotFound'
        return $false
    } 
}

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

    $ErrorRecord
}
#EndRegion '.\en-US\public\Test-MaaS360PSConnection.ps1' 73
#Region '.\en-US\private\Get-MaaS360AuthToken.ps1' -1

function Get-MaaS360AuthToken
{
    
    $Config = Get-Content -Path .\private\config.json -Raw | ConvertFrom-Json -Depth 5
    $MaaS360EnvName = $Config.envVar.varName
    $Maas360EnvScope = $Config.envVar.varScope
        
    try
    {
        $GetEnvVariable = [System.Environment]::GetEnvironmentVariable($MaaS360EnvName, $Maas360EnvScope)

        # Check environment variable to make sure it exists
        if ($Null -eq $GetEnvVariable)
        {
            New-GNMaaS360AuthToken
        }


        try
        {
            ConvertTo-SecureString -AsPlainText -String ('MaaS token=' + $("""$GetEnvVariable"""))
        }
        catch [System.Management.Automation.PSArgumentException]
        {
            throw 'error beep boop'
        }
        
        
    }
    catch [System.InvalidCastException]
    {
        Write-Error -Exception 'InvalidCastException' -Message 'Please check to make sure the "$MaaS360EnvName" and "$MaaS360EnvScope" variables are not empty.'
        Write-Host -Object ''
        Write-Error -Exception 'InvalidCastException' -Message "$($_.Exception.Message)"
    }
    
}
#EndRegion '.\en-US\private\Get-MaaS360AuthToken.ps1' 38
#Region '.\en-US\private\Invoke-MaaS360PSRequest.ps1' -1

function Invoke-MaaS360PSRequest
{
    
    Param(
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers,
        [string]$ContentType
    )

    #region Variables

    # Endpoint Variables
    $BaseUri = 'https://apis.m3.maas360.com/'
    $Uri = $BaseUri += $Endpoint
    #endregion Variables

    #region Headers
    $Headers = @{
        'accept'       = 'application/json'
        'Content-Type' = 'application/json'
    }
    #endregion Headers

    # If Method is Post
    # if ($Method -eq 'Post')
    # {
    #     $Body = $Content
    # }

    #region Helper Function
    function New-GNMaaS360TokenRefresh
    {
        New-GNMaaS360AuthToken
        Write-Output -InputObject 'New auth token has been generated. Please re-run the last command.'
    }
    #endregion Helper Function
    
    try
    {
        # $InvResponse = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -Authentication 'Bearer' -Token $Token -SkipHttpErrorCheck

        # OAUTH Token
        $Token = Get-MaaS360AuthToken

        $InvResponse = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType $ContentType -Authentication 'Bearer' -Token $Token

        if (($InvResponse.authResponse.errorCode -eq '1007') -or $InvResponse.authResponse.errorCode -eq '1009' )
        {
            # New-MaaS360AuthToken

            Write-Host -Object 'New auth token generated. Please re-run the last command.'-ForegroundColor 'Green'
        } 
        elseif ($InvResponse.status -eq '1')
        {
            Write-Error -Message $InvResponse.response.description
        }
        else
        {
            throw 'Boop'
        }
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException]
    {

        $ExceptionStatus = $_.Exception.StatusCode.ToString()
        $ExceptionError = $_.Exception.MessageDetails.Message

        # Will make this a switch... eventually
        if ($ExceptionStatus -eq 'Unauthorized')
        {
            New-GNMaaS360TokenRefresh
            break
        }
        elseif ($ExceptionStatus -like 'Token is expired')
        {
            New-GNMaaS360TokenRefresh
            break
        }
        elseif ($ExceptionStatus -like 'Token is invalid')
        {
            New-GNMaaS360TokenRefresh
            break
        }
        elseif ($ExceptionError -like '*Internal Server Error*')
        {
            throw 'An error has occured on the API providers end.'
        } 
        else
        {
            Write-Error -Message "An error occurred: $ExceptionError"
        }
        
    }
}
#EndRegion '.\en-US\private\Invoke-MaaS360PSRequest.ps1' 96
#Region '.\en-US\private\New-MaaS360AuthToken.ps1' -1

function New-GNMaaS360AuthToken
{


    #region Variables
    # Config Variables
    $Config = Get-Content -Path $PSScriptRoot\config.json -Raw | ConvertFrom-Json -Depth 5
    # $RootPath = (Get-Item -Path "$PSScriptRoot").FullName
    $BillingID = $config.authRequest.maaS360AdminAuth.billingID

    #endregion Body

    try 
    {
        $Response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $Headers -Body $Body
        $RawToken = $Response.authResponse.authToken
        New-GNMaaS360EnvironmentEntry -RawToken $RawToken
    }
    catch 
    {
        $_.Exception.Message
    }

}
#EndRegion '.\en-US\private\New-MaaS360AuthToken.ps1' 25
#Region '.\en-US\private\New-MaaS360Config.ps1' -1

function New-MaaS360Config
{  
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $true)]
        [int]$PlatformID,
        [Parameter(Mandatory = $true)]
        [string]$BillingID,
        [Parameter(Mandatory = $true)]
        [string]$Pass,
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string]$AppID,
        [Parameter(Mandatory = $true)]
        [string]$AppVersion,
        [Parameter(Mandatory = $true)]
        [string]$AppAccessKey,
        [Parameter(Mandatory = $true)]
        [string]$EnvVarName,
        [Parameter(Mandatory = $true)]
        [string]$EnvVarScope
    )

    # Config dictionary
    # Could've probably just did a here string but fuck it
    $ConfigDict = @{
        'authRequest' = @{
            'maaS360AdminAuth' = @{
                'platformID'   = $PlatformID
                'billingID'    = $BillingID
                'password'     = $Pass
                'userName'     = $UserName
                'appID'        = $AppID
                'appVersion'   = $AppVersion
                'appAccessKey' = $AppAccessKey
                'method'       = @(
                    'post',
                    'get',
                    'put',
                    'patch'
                )
            }
        }
        'envVar'      = @{
            'varName'  = $EnvVarName
            'varScope' = $EnvVarScope
        }
        
    }

    Write-Debug -Message ("Params: $PSBoundParameters")

    # Convert to Json
    $ConfigDict = $ConfigDict | ConvertTo-Json -Depth 5

    try 
    {
        Write-Verbose -Message ('Checking if config file exists at: ' + $PSScriptRoot)

        if (-not (Test-Path -Path $PSScriptRoot\private\config.json))
        {
            Write-Verbose -Message 'False'
            Write-Verbose -Message 'Creating config file'
            New-Item -ItemType 'File' -Path $PSScriptRoot\config.json
            Set-Content -Path $PSScriptRoot\config.json -Value $ConfigDict
            Write-Verbose -Message 'Generating config contents'
        }
        else
        {
            Write-Output -InputObject 'Config file already exists.'
        }
            
    }
    catch
    {
        throw $_.Exception.Message
    }

}
#EndRegion '.\en-US\private\New-MaaS360Config.ps1' 82
#Region 'PREFIX' -1

New-Variable -Name 'MaaS360Session' -Value System.Collections.Specialized.OrderedDictionary -Scope 'Global' -Force
#EndRegion 'PREFIX'
