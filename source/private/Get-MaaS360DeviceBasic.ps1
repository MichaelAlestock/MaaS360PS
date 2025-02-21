function Get-MaaS360DeviceBasic
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DeviceId
  )

  if ($MaaS360Session.apiKey -eq '')
  {
    throw 'No API key found. Did you run Connect-MaaS360PS before running this command?'
  }

  $Uri = $MaaS360Session.baseUrl + 'device-apis/devices/1.0/summary/' + $MaaS360Session.billingID

  $Body = @{}
  
  foreach ($Param in $PSBoundParameters.GetEnumerator())
  {
    $Body.Add($Param.Key.Substring(0, 1).ToLower() + $Param.Key.Substring(1), $Param.Value)
  }

  try 
  {
    $Response = Invoke-MaaS360Method -Uri $Uri -Method 'Get' -Body $Body -Authentication 'BEARER' `
      -Token $MaaS360Session.apiKey -Headers $MaaS360Session.tempHeaders

    $ResponseArray = @($Response.devicesSummary.deviceAttributes.deviceAttribute)

    # this took me way too long to figure out
    $Keys = @($ResponseArray.key)
    $Values = @($ResponseArray.value)

    if ($null -eq $Keys[0])
    {
      throw "Device not found with the DeviceId: [$DeviceId]"
    }

    $Obj = for ($i = 0 ; $i -lt $Keys.Length ; $i++)
    {
      @{
        $Keys[$i] = $Values[$i]
      }
    }

    $Obj
  }
  catch
  {
    $_.Exception.Message
  }
  
}