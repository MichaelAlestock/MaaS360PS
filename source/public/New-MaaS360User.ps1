function New-MaaS360User
{

  [CmdletBinding()]

  Param(
    [string]$Username,
    [string]$EmailAddress,
    [string]$FullName,
    [string]$Domain
  )

  $BillingID = Get-GNMaaS360BillingID
  $Endpoint = "user-apis/user/1.0/addUser/customer/$BillingID"

  $Headers = @{
    'accept' = 'application/json'
  }

  $Body = @{
    # Removing default entries and placing them in the switch
    # 'includeAllUsers' = 0
    # 'pageNumber'      = 1
    # 'pageSize'        = 250
    # 'match'           = 0
  }

  # User object related
  if ($PSBoundParameters.ContainsKey('EmailAddress')) { $Body.Add('email', $EmailAddress) }
  if ($PSBoundParameters.ContainsKey('Domain')) { $Body.Add('domain', $Domain) }
  if ($PSBoundParameters.ContainsKey('FullName')) { $Body.Add('fullName', $FullName) }
  if ($PSBoundParameters.ContainsKey('Username')) { $Body.Add('userName', $Username ) }
  #  if ($SetPassword.IsPresent) { $Body.Add('emailSetPwdLink', $SetPassword) }

  <#
  # Write debug to show not only what params were used when invoking the command but
  # also to show what params are a part of the overall body that is sent in the request
  #>

  Write-Debug -Message ( "Running $($MyInvocation.MyCommand)`n" +
    "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" +
    "Get-GNMaaS360User parameters:`n$($Body | Format-List | Out-String)" )

  try 
  {
    $Response = Invoke-GNMaaS360APIRequest -Method 'Post' -Body $Body -Endpoint $Endpoint -Headers $Headers -ContentType 'application/x-www-form-urlencoded'
    # $ResponseArray = @($Response.users.user)

    # $Object = ForEach ($obj in $ResponseArray)
    # {
    #   [pscustomobject]@{
    #     'FullName'        = $Obj.FullName
    #     'Username'        = $Obj.userName
    #     'EmailAddress'    = $Obj.emailAddress
    #     'Group'           = $Obj.groups.group.name
    #     'Created'         = $Obj.createDate
    #     'AuthType'        = $Obj.authType
    #     'Domain'          = $Obj.domain
    #     'PasswordExpDate' = $Obj.passwordexpirydate
    #     'Source'          = $Obj.source
    #     'Status'          = $Obj.status
    #     'LastUpdated'     = $Obj.updatedate
    #     'UserID'          = $Obj.useridentifier
    #     'Alias'           = $Obj.usernamealias
    #   }
    # }

    # # Create our custom object with the User.Information type
    # $Object.PSObject.TypeNames.Insert(0, 'User.Information')
    # $DefaultDisplaySet = @('Status', 'FullName', 'Username', 'EmailAddress', 'Group')
    # $DefaultDisplayPropertySet = [System.Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet', [string[]]$DefaultDisplaySet)
    # $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)
    # $Object | Add-Member -MemberType 'MemberSet' -Name 'PSStandardMembers' -Value $PSStandardMembers

    # Can this be improved to stop the error from showing even if it's just New-GNMaaS360AuthToken running?
    if (($null -eq $Response))
    {
      Write-Output -InputObject 'User not found. Please check the name and try again.'
    }
    else
    {
      $Response | Get-Member
    }
    
  }
  catch
  {
    $_.Exception.Message
  }
  
}