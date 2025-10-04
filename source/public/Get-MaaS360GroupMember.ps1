function Get-MaaS360GroupMember
{
  # Removed PSCustomObject output type
  [CmdletBinding()]
  param(
    [Parameter(
      HelpMessage = 'placeholder'
    )]
    [string]$GroupIdentifier,

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
      HelpMessage = 'Number of objects per page. 25 (Default)'
    )]
    [ValidateSet(25, 50, 100, 200, 250)]
    [int]$PageSize = 25
  )

  # Stop any further execution until an API key (session) is created
  if ($MaaS360Session.apiKey -eq '')
  {
    throw 'No API key found. Did you run Connect-MaaS360PS before running this command?'
  }

  $Uri = $MaaS360Session.baseUrl + 'user-apis/user/1.0/searchByGroup/customer/' + $MaaS360Session.billingID + '/groupIdentifier/' + $GroupIdentifier

  Write-Verbose $Uri

  $Body = @{}

  # Takes in PSBoundParameters and converts the key name to the proper format e.g. emailAddress and not EmailAddress
  # then adds it to the body along with the value
  foreach ($Param in $PSBoundParameters.GetEnumerator())
  {
    $Body.Add($Param.Key.Substring(0, 1).ToLower() + $Param.Key.Substring(1), $Param.Value)
  }

  # Next step is to work on some stuff for write-debug to allow the user to see information to narrow down issues
  $Response = Invoke-MaaS360Method -Uri $Uri -Method 'Get' -Body $Body -Authentication 'BEARER' `
    -Token $MaaS360Session.apiKey -Headers $MaaS360Session.tempHeaders

  # Get-ProgressInformation -Count $Response.users.count -Page $Response.users.pageNumber -Size $Response.users.pageSize

  switch ($Response)
  {
    { $Response.users.count -le 0 }
    {
      throw 'No user information returned. Please check your inputs and try again.'
      break
    }
    { ($Response.users.pageNumber -eq [System.String]::Empty) -or ($Response.users.pageSize -eq [System.String]::Empty) }
    {
      throw 'Page number or page size is empty. Please check your parameter values and try again.'
    }
    { $Response.users.count -gt 0 }
    {
      $Response.users.user | ForEach-Object {
        [PSCustomObject]@{
          AuthType               = $_.authType
          CreatedDate            = $_.createDate
          Domain                 = $_.domain
          EmailAddress           = $_.emailAddress
          FullName               = $_.fullName
          Groups                 = $_.groups.group # Not sure what this will look like if they have multiple groups but we'll find out eventually
          PasswordExpirationDate = $_.passwordexpirydate
          Source                 = $_.source
          Status                 = $_.status
          UpdateDate             = $_.updateDate
          UPN                    = $_.upn
          UserIdentifier         = $_.UserIdentifier
          Username               = $_.userName
          UsernameAlias          = $_.usernameAlias
          UserGroupBits          = $_.usrGrpBits
        }
      }
    }
  }
}