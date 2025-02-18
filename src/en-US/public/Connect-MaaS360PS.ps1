function Connect-MaaS360PS
{
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    [CmdletBinding(DefaultParameterSetName = 'Connect with API token')]
    Param(
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$BillingID,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$Url,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$Endpoint,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Connect with API token', Mandatory = $true)]
        [ValidateSet('Get', 'Post')]
        [string]$Method,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$PlatformID,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$AppID,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$AppVersion,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$AppAccessKey,
        [Parameter(HelpMessage = 'Enter same credentials utilized to log into MaaS360 web portal.',
            ParameterSetName = 'New API token', Mandatory = $true)]
        [PSCredential]$Credentials
    )

    # We need to get an auth token from MaaS360 before we can do anything which means we need to utilize all params and make an API call
    # Once we retrieve our API token we can see $MaaS360Session.ApiToken = whatever the token is but of course secure string and in the format of MaaS360 token="token here"
    # Once we have the token we can then call Test-MaaS360PSConnection to see if we're able to get any response
    # It'll probably entail a good amount of error handling but we shall see what we get
    # Fix this later to be a more dynamic function that'll build the body out
    # convert the password from securestring and convert output to json
    # Used for the POST request to get an API key
    # We'll change things up as we get everything working by adding some logic and error-handling

    # $MaaS360Session.apiToken = $null  # Play with this after we make the call and retrieve the API token
    if ($Method -eq 'Post')
    {
        $Body = @"
        <authRequest>
          <maaS360AdminAuth>
              <platformID>$($MaaS360Session.platformID)</platformID>
              <billingID>$($MaaS360Session.billingID)</billingID>
              <password>$($MaaS360Session.password)</password>
              <userName>$($MaaS360Session.userName)</userName>
              <appID>$($MaaS360Session.appID)</appID>
              <appVersion>$($MaaS360Session.appVersion)</appVersion>
              <appAccessKey>$($MaaS360Session.appAccessKey)</appAccessKey>
          </maaS360AdminAuth>
        </authRequest>
"@

        $Headers = @{
            'Accept'       = 'application/json'
            'Content-Type' = 'application/xml'
        }

        $AuthResponse = ''
        $MaaS360Session.url = $Url
        $MaaS360Session.endpoint = $Endpoint
        $MaaS360Session.billingID = $BillingID
        $MaaS360Session.platformID = $PlatformID
        $MaaS360Session.password = $Credentials.Password | ConvertFrom-SecureString -AsPlainText
        $MaaS360Session.userName = $Credentials.UserName
        $MaaS360Session.appID = $AppID
        $MaaS360Session.appVersion = $AppVersion
        $MaaS360Session.appAccessKey = $AppAccessKey

        $Script:Uri = $MaaS360Session.url + $MaaS360Session.endpoint + '/' + $MaaS360Session.billingID

        $AuthResponse = Invoke-RestMethod -Uri $Uri -Body $Body -Headers $Headers -Method $Method
        $RawToken = $AuthResponse.authResponse.authToken
        Write-Debug -Message "API KEY: $RawToken"
        $MaaS360Session.apiKey = ('MaaS token=' + $("""$RawToken""")) | ConvertTo-SecureString -AsPlainText -Force
 
        Write-Debug -Message "URL: $($MaaS360Session.url)"
        Write-Debug -Message "API KEY: $($MaaS360Session.apiKey)"
    }

    if ($Method -eq 'Get')
    {
        if (($null -eq $MaaS360Session.apiKey) -or ($null -eq $MaaS360Session.url))
        {
            throw 'Please use Connect-MaaS360PS with the [POST] method before attempting to utilize any commands.'
        }

        $TestUrl = $MaaS360Session.url
        $TestEndpoint = $MaaS360Session.endpoint
        $TestUri = $TestUrl + $TestEndpoint + '/' + $MaaS360Session.billingID
        $Token = $MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText
       
        Write-Debug -Message "URI: $TestUri"
        Write-Debug -Message "API KEY: $Token"
    }

    if (-not (Test-MaaS360PSConnection))
    {
        throw 'Unable to verify connection to MaaS360 instance. Please check your [URL], [API KEY], or re-run command with [POST] method to regenerate a key.'
    }
}