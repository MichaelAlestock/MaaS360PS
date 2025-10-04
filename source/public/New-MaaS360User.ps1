function New-MaaS360User
{

  [CmdletBinding()]

  param(
    [string]$AuthType,
    [string]$Domain,
    [Parameter(
      HelpMessage = 'Email user a link to reset their password. Yes | No (Default)'
    )]
    [string]$Email,
    [ValidateSet('Yes', 'No')]
    [string]$EmailSetPwdLink,
    [string]$FullName,
    [string]$Location,
    [string]$ManagedAppleId,
    [string]$Password,
    [string]$PhoneNumber,
    [string]$PhoneNumberCountry,
    [string]$Username,
    [string]$WorkplacePolicy
  )

  $Uri = $MaaS360Session.baseUrl + 'user-apis/user/1.0/addUser/customer/' + $MaaS360Session.BillingID

  $Body = @{}

  # User object related
  if ($PSBoundParameters.ContainsKey('EmailAddress')) { $Body.Add('email', $EmailAddress) }
  if ($PSBoundParameters.ContainsKey('Domain')) { $Body.Add('domain', $Domain) }
  if ($PSBoundParameters.ContainsKey('FullName')) { $Body.Add('fullName', $FullName) }
  if ($PSBoundParameters.ContainsKey('Username')) { $Body.Add('userName', $Username ) }
  if ($PSBoundParameters.ContainsKey('Credential')) { $Body.Add('password', $Credential.Password ) }
  #  if ($NewPassword.IsPresent) { $Body.Add('emailSetPwdLink', $NewPassword) }

  Write-Debug -Message ( "Running $($MyInvocation.MyCommand)`n" +
    "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
    "Get-GNMaaS360User parameters:`n$($Body | Format-List | Out-String)" )

  try 
  {
    $Request = Invoke-MaaS360Method -Method 'Post' -Body $Body -Uri $Uri -Authentication 'BEARER' -Token $MaaS360Session.apiKey -Headers $MaaS360Session.tempHeaders

    if (($null -eq $Request))
    {
      Write-Output -InputObject 'User not found. Please check the name and try again.'
    }
    else
    {
      $Request
    }
    
  }
  catch
  {
    $_.Exception.Message
  }
  
}