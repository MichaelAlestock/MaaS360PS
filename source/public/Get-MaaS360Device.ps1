function Get-MaaS360Device
{
  [CmdletBinding()]
  Param(
    [Parameter(HelpMessage = 'Page number returned. 1 (Default)')]
    [int]$PageNumber = 1,

    [Parameter( HelpMessage = 'Page number returned. 1 (Default)')]
    [ValidateSet(25, 50, 100, 200, 250)]
    [int]$PageSize = 50,

    [Parameter(HelpMessage = 'Level of matching. 0 = Partial | 1 = Exact (Default)')]
    [ValidateSet(0, 1)]
    [int]$Match = 0,

    [Parameter(HelpMessage = 'Name of the device that should be searched for.')]
    [string]$PartialDeviceName,

    [Parameter(HelpMessage = 'Phone number that should be searched for.')]
    [string]$PartialPhoneNumber,

    [Parameter(HelpMessage = 'Username of the user that should be searched for.', ValueFromPipelineByPropertyName = $True, ParameterSetName = 'User information')]
    [string]$PartialUsername,

    [Parameter(HelpMessage = 'Email address of the user that should be searched for.')]
    [string]$Email,

    [Parameter(HelpMessage = 'Status of the device. Active = Device is under MDM control | Inactive = Device is not under MDM control ')]
    [ValidateSet('Active', 'Inactive')]
    [string]$DeviceStatus,

    [string]$Maas360DeviceId,

    [string]$MdmMailboxDeviceId,

    [string]$MailboxDeviceId,

    [string]$PlatformName,

    [ValidateSet('NOTAPPLIED', 'PENDING', 'COMPLETE')]
    [string]$SelectiveWipe,

    [ValidateSet('OOC', 'ALL')]
    [string]$AppCompliance = 'ALL',

    [ValidateSet('OOC', 'ALL')]
    [string]$PlcCompliance = 'ALL',

    [ValidateSet('OOC', 'ALL')]
    [string]$RuleCompliance = 'ALL',

    [ValidateSet('OOC', 'ALL')]
    [string]$PswdCompliance = 'ALL',

    [ValidateSet('lastReported', 'installedDate')]
    [string]$SortAttribute = 'lastReported',

    [ValidateSet('asc', 'dsc')]
    [string]$SortOrder = 'dsc',

    [string]$Udid,

    [string]$UserDomain,

    [string]$WifiMacAddress,

    [Parameter(HelpMessage = 'IMEIesn of the device that should be searched for.')]
    [ValidatePattern('^[0-9]{15}$', ErrorMessage = 'Provided IMEIesn is not valid. Check the length and try again.')]
    [string]$ImeiMeid,

    [Parameter(HelpMessage = 'MDM status of the device.')]
    [ValidateSet('Inactive', 'Activated', 'Control Removed', 'Pending Control Removed', 'User Removed Control', 'Not Enrolled', 'Enrolled')]
    [string]$Maas360ManagedStatus,
    [switch]$All
  )

  # Need to work on creating a function that will contain all the information for the URI, Body definition, and the 
  # body builder to I stop reusing this in everything

  # Stop any further execution until an API key (session) is created
  if ($MaaS360Session.apiKey -eq '')
  {
    throw 'No API key found. Did you run Connect-MaaS360PS before running this command?'
  }
 
  $Uri = $MaaS360Session.baseUrl + 'device-apis/devices/2.0/search/customer/' + $MaaS360Session.billingID
 
  $Body = @{}
 
  # Takes in PSBoundParameters and converts the key name to the proper format i.e. emailAddress and not EmailAddress
  # then adds it to the body along with the value
  foreach ($Param in $PSBoundParameters.GetEnumerator())
  {
    $Body.Add($Param.Key.Substring(0, 1).ToLower() + $Param.Key.Substring(1), $Param.Value)
  }

  $Response = Invoke-MaaS360Method -Uri $Uri -Method 'Get' -Body $Body -Authentication 'BEARER' -Token $MaaS360Session.apiKey -Headers $MaaS360Session.tempHeaders

  Get-ProgressInformation -Count $Response.devices.count -Page $Response.devices.pageNumber -Size $Response.devices.pageSize

  $Response | ForEach-Object {

    $BasicInfo = Get-MaaS360DeviceBasic -DeviceId $Response.devices.device.maas360DeviceID
    # $RemainingStorage = "$($BasicInfo.FreeSpace) GB"
    # $ICCID = ($BasicInfo.ICCID).ToString().Replace(' ', '')
    # $Carrier = $BasicInfo.'Current Carrier'

    $Limited = [PSCustomObject]@{
      'LastReported'       = $_.devices.device.lastReported
      'Name'               = $_.devices.device.deviceName
      'Type'               = $_.devices.device.deviceType
      'Status'             = $_.devices.device.deviceStatus
      'Serial'             = $_.devices.device.platformSerialNumber
      'MdmSerial'          = $_.devices.device.maas360DeviceID
      'IMEI'               = $_.devices.device.imeiEsn
      'Enrollment'         = $_.devices.device.maas360ManagedStatus
      'Owner'              = $_.devices.device.username
      'OwnerEmail'         = $_.devices.device.emailAddress
      'OwnedBy'            = $_.devices.device.ownership
      'ModelId'            = $_.devices.device.modelId
      'iOS'                = $_.devices.device.osName
      'iOS_Version'        = $_.devices.device.osVersion
      'PhoneNumber'        = ($_.devices.device.phoneNumber).Remove(0, 2).Insert(3, '.').Insert(7, '.')
      'AppCompliance'      = $_.devices.device.appComplianceState
      'PasscodeCompliance' = $_.devices.device.passcodeCompliance
      'PolicyCompliance'   = $_.devices.device.policyComplianceState
      'Policy'             = $_.devices.device.mdmPolicy
      'DateRegistered'     = $_.devices.device.installedDate
      'iTunesEnabled'      = $_.devices.device.itunesStoreAccountEnabled
      'WipeStatus'         = $_.devices.device.selectiveWipeStatus
      'UDID'               = $_.devices.device.udid
      'MAC_Address'        = $_.devices.device.wifiMacAddress
    }
    if ($All.IsPresent)
    {
      foreach ($Item in $BasicInfo)
      {
        foreach ($Device in $Item.GetEnumerator())
        {
          $Limited | Add-Member -TypeName 'PSObject' -MemberType 'NoteProperty' -Name $Device.Key -Value $Device.Value
        }
      }
      $Limited
    }
    else
    {
      $Limited
    }
  }
}