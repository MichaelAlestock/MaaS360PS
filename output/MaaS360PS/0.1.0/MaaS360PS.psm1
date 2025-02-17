#Region '.\en-US\public\Connect-MaaS360PS.ps1' -1

function Connect-MaaS360PS
{
	
}
#EndRegion '.\en-US\public\Connect-MaaS360PS.ps1' 5
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
#Region '.\en-US\private\Get-MaaS360AuthToken.ps1' -1

function Get-MaaS360AuthToken
{
    <#
    .NOTES
	===========================================================================
	 Created with: 	Visual Studio Code
	 Created on:   	12/15/2024 12:10 PM
	 Created by:   	Anthony Alestock
	 Organization: 	Greater Nashua Mental Health
	 Department: 	Information Technology
	 Position:		Jr. Network Administrator
	 Filename:     	Get-GNMaaS360AuthToken.ps1

	 To-Do:			
	===========================================================================

    .SYNOPSIS
        Pulls the OAUTH token generated by New-GNMaaS360AuthToken from the environment variable.
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
#EndRegion '.\en-US\private\Get-MaaS360AuthToken.ps1' 64
#Region '.\en-US\private\Get-MaaS360BillingID.ps1' -1

function Get-MaaS360BillingID
{
    $Config = ''

    if (-not (Test-Path -Path $PSScriptRoot\config.json))
    {
        Write-Host -Object 'No configuration file was found. A new one must be generated.'
        Write-Output -InputObject ''
        $Config = New-GNMaaS360Config
    }
    else
    {
        $Config = Get-Content -Path $PSScriptRoot\config.json -Raw | ConvertFrom-Json -Depth 5
    }

    # $RootPath = (Get-Item -Path "$PSScriptRoot").FullName
    $Config.authRequest.maaS360AdminAuth.billingID
}
#EndRegion '.\en-US\private\Get-MaaS360BillingID.ps1' 19
#Region '.\en-US\private\Invoke-MaaS360APIRequest.ps1' -1

function Invoke-MaaS360APIRequest
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
#EndRegion '.\en-US\private\Invoke-MaaS360APIRequest.ps1' 96
#Region '.\en-US\private\New-MaaS360AuthToken.ps1' -1

function New-GNMaaS360AuthToken
{


    #region Variables
    # Config Variables
    $Config = Get-Content -Path $PSScriptRoot\config.json -Raw | ConvertFrom-Json -Depth 5
    # $RootPath = (Get-Item -Path "$PSScriptRoot").FullName
    $BillingID = $config.authRequest.maaS360AdminAuth.billingID

    # Endpoint Variables
    $Method = $config.authRequest.maaS360AdminAuth.method[0]
    $Uri = 'https://apis.m3.maas360.com/auth-apis/auth/1.0/'
    $Endpoint = "authenticate/$BillingID"
    $Url = $Uri += $Endpoint
    #endregion Variables

    #region Headers
    $Headers = @{
        'accept'       = 'application/json'
        'Content-Type' = 'application/xml'
    }
    #endregion Headers

    #region Body
    $Body = @"
<?xml version="1.0" encoding="UTF-8"?>
<authRequest>
	<maaS360AdminAuth>
		<platformID>$($Config.authRequest.maaS360AdminAuth.platformID)</platformID>
		<billingID>$($Config.authRequest.maaS360AdminAuth.billingID)</billingID>
		<password>$($Config.authRequest.maaS360AdminAuth.password)</password>
		<userName>$($Config.authRequest.maaS360AdminAuth.userName)</userName>
		<appID>$($Config.authRequest.maaS360AdminAuth.appID)</appID>
		<appVersion>$($Config.authRequest.maaS360AdminAuth.appVersion)</appVersion>
		<appAccessKey>$($Config.authRequest.maaS360AdminAuth.appAccessKey)</appAccessKey>
	</maaS360AdminAuth>
</authRequest>
"@
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
#EndRegion '.\en-US\private\New-MaaS360AuthToken.ps1' 54
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
#Region '.\en-US\private\New-MaaS360EnvironmentEntry.ps1' -1

function New-MaaS360EnvironmentEntry
{
    Param(
        [string]$RawToken
    )

    try
    {
        # Create a new environment variable and store token in it
        # Seems like the best way to hide the token and later implement TTL variable
        # Should just overwrite the current value that is in the environment variable

        $Config = Get-Content -Path $PSScriptRoot\config.json | ConvertFrom-Json -Depth 5
        
        # Adding environment variables for Unix
        # Gotta figure out how to find system shell i.e. Zsh or Bash
        
        [System.Environment]::SetEnvironmentVariable($Config.envVar.varName, $RawToken, $Config.envVar.varScope)
    }
    catch
    {
        throw $_.Exception.Message
    }
}
#EndRegion '.\en-US\private\New-MaaS360EnvironmentEntry.ps1' 25
#Region '.\en-US\private\Test-MaaS360PSConnection.ps1' -1

function Test-MaaS30PSConnection
{
	
}
#EndRegion '.\en-US\private\Test-MaaS360PSConnection.ps1' 5
