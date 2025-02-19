$TestEndpoint = 'user-apis/user/1.0/search/'

function Get-MaaS360User
{

  [CmdletBinding(DefaultParameterSetName = 'PartialMatch')]

  Param(
    [int]$IncludeAllUsers,
    [int]$PageNumber,
    [int]$PageSize,
    [int]$Match,
    [string]$EmailAddress,
    [string]$FullName,
    [string]$Username,
    [string]$Endpoint
  )

  # Testing purposes
  if ($null -ne $TestEndpoint)
  {
    $Endpoint = $TestEndpoint
  }
 
  $Uri = $MaaS360Session.url + $Endpoint + $MaaS360Session.billingID

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
    $Response = Invoke-MaaS360Method -Uri $Uri -Method $Method -Body $Body -Endpoint $Endpoint

    $Response
    
  }
  catch
  {
    $_.Exception.Message
  }
  
}