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