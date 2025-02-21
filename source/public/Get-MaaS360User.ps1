function Get-MaaS360User
{
  [OutputType(PSCustomObject)]
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
    [string]$PartialUserName,

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
  if ($MaaS360Session.apiKey -eq '')
  {
    throw 'No API key found. Did you run Connect-MaaS360PS before running this command?'
  }

  $Uri = $MaaS360Session.baseUrl + 'user-apis/user/1.0/search/' + $MaaS360Session.billingID

  $Body = @{}

  # Takes in PSBoundParameters and converts the key name to the proper format i.e. emailAddress and not EmailAddress
  # then adds it to the body along with the value
  foreach ($Param in $PSBoundParameters.GetEnumerator())
  {
    $Body.Add($Param.Key.Substring(0, 1).ToLower() + $Param.Key.Substring(1), $Param.Value)
  }

  # Next step is to work on some stuff for write-debug to allow the user to see information to narrow down issues
  $Response = Invoke-MaaS360Method -Uri $Uri -Method 'Get' -Body $Body -Authentication 'BEARER' `
    -Token $MaaS360Session.apiKey -Headers $MaaS360Session.tempHeaders

  $TotalUsers = $Response.users.count
  $ActualUsers = $Response.users.user
  $ReturnedPageNumber = $Response.users.pageNumber
  $ReturnedPageSize = $Response.users.pageSize

  Get-ProgressInformation -Count $TotalUsers -Page $ReturnedPageNumber -Size $ReturnedPageSize

  switch ($Response)
  {
    { $TotalUsers -le 0 }
    {
      throw 'No user information returned. Please check your inputs and try again.'
      break
    }
    { ($ReturnedPageNumber -eq [System.String]::Empty) -or ($ReturnedPageSize -eq [System.String]::Empty) }
    {
      throw 'Page number or page size is empty. Please check your parameter values and try again.'
    }
    { $TotalUsers -gt 0 }
    {
      $ActualUsers | ForEach-Object {
        [PSCustomObject]@{
          AuthType               = $_.authType
          CreatedDate            = $_.createDate
          Department             = $_.department
          Domain                 = $_.domain
          EmailAddress           = $_.emailAddress
          EmployeeID             = $_.employeeID
          FullName               = $_.fullName
          Groups                 = $_.groups.group
          ID                     = $_.id
          JobTitle               = $_.jobTitle
          Location               = $_.location
          LogonHours             = $_.logonHours
          PasswordExpirationDate = $_.passwordexpirydate
          PhoneNumber            = $_.phoneNumber
          Source                 = $_.source
          Status                 = $_.status
          UpdateDate             = $_.updateDate
          UPN                    = $_.upn
          UserDistinguishedName  = $_.userDN
          UserIdentifier         = $_.UserIdentifier
          Username               = $_.userName
          Alias                  = $_.usernameAlias
          UserGroupBits          = $_.usrGrpBits
        }
      }
    }
  }
}