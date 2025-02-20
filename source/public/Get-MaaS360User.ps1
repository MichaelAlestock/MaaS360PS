function Get-MaaS360User
{
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
 
  # Stop any further execution until an API key (session) is created
  # Will most likely need to turn this into an external function since this will be used in nearly every single function
  # gotta live by that DRY
  if ($MaaS360Session.apiKey -eq '')
  {
    throw 'No API key found. Did you run Connect-MaaS360PS before running this command?'
  }
  
  $Uri = $MaaS360Session.url + 'user-apis/user/1.0/search/' + $MaaS360Session.billingID

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