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