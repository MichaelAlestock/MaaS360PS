function Get-MaaS360User
{

  [CmdletBinding()]
  Param(
    [Parameter(
      HelpMessage = "Email address of the user that's searched for."
    )]
    [string]$PartialEmailAddress,

    [Parameter(
      HelpMessage = "Full name of the user that's searched for."
    )]
    [string]$PartialFullUserName,

    [Parameter(
      HelpMessage = "Username of the user that's searched for."
    )]
    [string]$PartialUsername,

    [Parameter(
      HelpMessage = 'Domain name'
    )]
    [string]$Domain,

    [Parameter(
      HelpMessage = 'Authorization type. 0 = Local directory | 1 = User directory'
    )]
    [string]$AuthType,

    [Parameter(
      HelpMessage = 'Types of users that should be returned. Avoids returning inactive users.
      0 = Users w/ devices | 1 = All users | 2 = Users w/o devices'
    )]
    [ValidateSet(0, 1, 2)]
    [int]$IncludeAllUsers = 0,

    [Parameter(
      HelpMessage = 'Page number returned. 1 (Default)'
    )]
    [int]$PageNumber = 1,

    [Parameter(
      HelpMessage = 'Whether custom attributes should be returned in the response.
      0 = Do not include | 1 = Include'
    )]
    [ValidateSet(0, 1)]
    [int]$IncludeCustomAttributes = 0,

    [Parameter(
      HelpMessage = 'Page number returned. 1 (Default)'
    )]
    [ValidateSet(25, 50, 100, 200, 250)]
    [int]$PageSize = 50,

    [Parameter(
      HelpMessage = 'Level of matching. 0 = Partial | 1 = Exact (Default)'
    )]
    [ValidateSet(0, 1)]
    [int]$Match = 1,

    [Parameter(
      HelpMessage = 'Time in Unix epoch milliseconds, returns users updated after this time'
    )]
    [ValidateSet(0, 1)]
    [int]$UsersUpdatedAfterInEpochms
    
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

  foreach ($Item in $PSBoundParameters.GetEnumerator())
  {
    $Body.Add($Item.Key.Substring(0, 1).ToLower() + $Item.Key.Substring(1), $Item.Value)
  }

  <#
  # Write debug to show not only what params were used when invoking the command but
  # also to show what params are a part of the overall body that is sent in the request
  #>

  # Finding a better way to handle writing to debug instead of this
  # Write-Debug -Message ( "Running $($MyInvocation.MyCommand)`n" +
  #   "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
  #   "Get-GNMaaS360User parameters:`n$($Body | Format-List | Out-String)" )

  $Response = Invoke-MaaS360Method -Uri $Uri -Method 'Get' -Body $Body -Authentication 'BEARER' `
    -Token $MaaS360Session.apiKey -Headers $MaaS360Session.tempHeaders

  $TotalUsers = $Response.users.count
  $ActualUsers = $Response.users.user
  # $ReturnedPageNumber = $Response.users.pageNumber
  # $ReturnedPageSize = $Response.users.pageSize
    
  switch ($Response)
  {
    { $TotalUsers -eq 0 }
    {
      Write-Output -InputObject 'No user information returned. Please check your inputs and try again.'
      break
    }
    Default
    {
      $ActualUsers | ForEach-Object {
        [User]::new($_.emailAddress, $_.fullName, $_.userName, $_.usernameAlias, $_.domain, $_.status, $_.createDate, $_.updateDate)
      }

    }
  }  
}