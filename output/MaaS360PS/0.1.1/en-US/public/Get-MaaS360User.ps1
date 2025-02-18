function Get-MaaS360User
{

  [CmdletBinding(DefaultParameterSetName = 'PartialMatch')]

  Param(
    [ValidateSet(0, 1, 2)]
    [int]$IncludeAllUsers,
    [int]$PageNumber,
    [ValidateSet(25, 50, 100, 200, 250, ErrorMessage = 'Input provided is not a valid page size.')]
    [int]$PageSize,
    [ValidateSet(1)]
    [Parameter(ParameterSetName = 'ExactMatch')]
    [int]$ExactMatch,
    [ValidateSet(0)]
    [Parameter(ParameterSetName = 'PartialMatch', Position = 0)]
    [int]$PartialMatch,
    [ValidatePattern('^([a-zA-Z]*)(.[a-zA-Z]*)@(gnmhc|healthylifeinmind).org', ErrorMessage = 'Input provided is not a valid email address.')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ExactMatch')]
    [string]$EmailAddress,
    [Parameter(ParameterSetName = 'PartialMatch', Position = 2)]
    [string]$PartialEmailAddress,
    [Alias('PartialFullUserName')]
    [Parameter(ParameterSetName = 'PartialMatch', Position = 3)]
    [Parameter(ParameterSetName = 'ExactMatch')]
    [string]$FullName,
    [Alias('PartialUserName')]
    [Parameter(ValueFromPipeline = $true, ParameterSetName = 'PartialMatch', Position = 2)]
    [Parameter(ParameterSetName = 'ExactMatch')]
    [string]$Username
  )

  $BillingID = Get-GNMaaS360BillingID
  $Endpoint = "user-apis/user/1.0/search/$BillingID"

  $Body = @{
    # Removing default entries and placing them in the switch
    # 'includeAllUsers' = 0
    # 'pageNumber'      = 1
    # 'pageSize'        = 250
    # 'match'           = 0
  }

  # User object related
  if ($PSBoundParameters.ContainsKey('EmailAddress')) { $Body.Add('partialEmailAddress', $EmailAddress) }
  if ($PSBoundParameters.ContainsKey('PartialEmailAddress')) { $Body.Add('partialEmailAddress', $PartialEmailAddress) }
  if ($PSBoundParameters.ContainsKey('FullName')) { $Body.Add('partialFullUserName', $FullName) }
  if ($PSBoundParameters.ContainsKey('Username')) { $Body.Add('partialUserName', $Username ) }

  # Paging related
  if ($PSBoundParameters.ContainsKey('PageSize')) { $Body.Add('pageSize', $PageSize ) }
  if ($PSBoundParameters.ContainsKey('PageNumber')) { $Body.Add('pageNumber', $PageNumber ) }
  if ($PSBoundParameters.ContainsKey('IncludeAllUsers')) { $Body.Add('includeAllUsers', $IncludeAllUsers ) }
  if ($PSBoundParameters.ContainsKey('ExactMatch')) { $Body.Add('match', $ExactMatch ) }
  if ($PSBoundParameters.ContainsKey('PartialMatch')) { $Body.Add('match', $PartialMatch ) }


  <#
  # Write debug to show not only what params were used when invoking the command but
  # also to show what params are a part of the overall body that is sent in the request
  #>

  Write-Debug -Message ( "Running $($MyInvocation.MyCommand)`n" +
    "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
    "Get-GNMaaS360User parameters:`n$($Body | Format-List | Out-String)" )

  try 
  {
    $Response = Invoke-GNMaaS360APIRequest -Method 'Get' -Body $Body -Endpoint $Endpoint
    $ResponseArray = @($Response.users.user)

    $Object = ForEach ($obj in $ResponseArray)
    {
      [pscustomobject]@{
        'FullName'        = $Obj.FullName
        'Username'        = $Obj.userName
        'EmailAddress'    = $Obj.emailAddress
        'Group'           = $Obj.groups.group.name
        'Created'         = $Obj.createDate
        'AuthType'        = $Obj.authType
        'Domain'          = $Obj.domain
        'PasswordExpDate' = $Obj.passwordexpirydate
        'Source'          = $Obj.source
        'Status'          = $Obj.status
        'LastUpdated'     = $Obj.updatedate
        'UserID'          = $Obj.useridentifier
        'Alias'           = $Obj.usernamealias
      }
    }

    # Create our custom object with the User.Information type
    $Object.PSObject.TypeNames.Insert(0, 'User.Information')
    $DefaultDisplaySet = @('Status', 'FullName', 'Username', 'EmailAddress', 'Group')
    $DefaultDisplayPropertySet = [System.Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet', [string[]]$DefaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)
    $Object | Add-Member -MemberType 'MemberSet' -Name 'PSStandardMembers' -Value $PSStandardMembers

    # Can this be improved to stop the error from showing even if it's just New-GNMaaS360AuthToken running?
    if (($null -eq $ResponseArray[0]))
    {
      Write-Output -InputObject 'User not found. Please check the name and try again.'
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