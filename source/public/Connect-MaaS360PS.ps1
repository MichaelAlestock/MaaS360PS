function Connect-MaaS360PS
{
    [CmdletBinding(DefaultParameterSetName = 'New API token')]
    param(
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [string]$BillingID,
        [Parameter(ParameterSetName = 'New API token', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Retrieve info', Mandatory = $true)]
        [ValidateSet('Post')]
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
        [PSCredential]$Credentials,
        [Parameter(ParameterSetName = 'Retrieve info')]
        [switch]$Validate,
        [Parameter(ParameterSetName = 'Retrieve info')]
        [switch]$Result
    )

    # We need to get an auth token from MaaS360 before we can do anything which means we need to utilize all params and make an API call
    # Once we retrieve our API token we can see $MaaS360Session.ApiToken = whatever the token is but of course secure string and in the format of MaaS360 token="token here"
    # Once we have the token we can then call Test-MaaS360PSConnection to see if we're able to get any response
    # It'll probably entail a good amount of error handling but we shall see what we get
    # Fix this later to be a more dynamic function that'll build the body out
    # convert the password from securestring and convert output to json
    # Used for the POST request to get an API key
    # We'll change things up as we get everything working by adding some logic and error-handling

    if (-not ((Get-ChildItem -Path 'Variable:').Name -contains 'MaaS360Session'))
    {
        throw 'Unable to find the session variable [$MaaS360Session]. Try re-importing the module with the `-Force` parameter if you continue to have issues.'
    }
    elseif ($PSBoundParameters.Count -eq 0) # We need the command to be ran with at least something
    {
        throw 'Account information not provided. Please run the command again with the appropriate parameters.'
    }

    # $MaaS360Session.apiToken = $null  # Play with this after we make the call and retrieve the API token
    if ($Method -eq 'Post')
    {
        $Headers = @{
            'Accept'       = 'application/json'
            'Content-Type' = 'application/xml'
        }

        $AuthResponse = ''
        # $MaaS360Session.url = $Url # Getting rid of this and just gonna place it in the script var since it's global
        # $MaaS360Session.endpoint = $Endpoint # Getting rid of this too for the same reasons as ^^
        $MaaS360Session.billingID = $BillingID

        # Stop if BillingID doesn't exist before anything can even continue
        # 
        if ($MaaS360Session.billingID -eq [System.String]::Empty)
        {
            throw 'Billing ID is missing. Please check all inputs and run [Connect-MaaS360PS] again.'
        }

        $MaaS360Session.platformID = $PlatformID
        $MaaS360Session.password = $Credentials.Password | ConvertFrom-SecureString -AsPlainText
        $MaaS360Session.userName = $Credentials.UserName
        $MaaS360Session.appID = $AppID
        $MaaS360Session.appVersion = $AppVersion
        $MaaS360Session.appAccessKey = $AppAccessKey

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

        $Uri = $MaaS360Session.baseUrl + $MaaS360Session.authEndpoint + '/' + $MaaS360Session.billingID

        $AuthResponse = Invoke-RestMethod -Uri $Uri -Body $Body -Headers $Headers -Method $Method
        $RawToken = $AuthResponse.authResponse.authToken
        Write-Debug -Message "RAW API KEY: $RawToken"
        $MaaS360Session.apiKey = ('MaaS token=' + $("""$RawToken""")) | ConvertTo-SecureString -AsPlainText -Force

        Write-Debug -Message "URI: $($Uri)"
        Write-Debug -Message "SECURE API KEY: $($MaaS360Session.apiKey)"

        if (($MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText) -eq 'MaaS token=""')
        {
            Write-Debug -Message "RAW API KEY FIELD IS EMPTY: [$($MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText)] instead of [MaaS token='your_token_here']"

            throw 'Something went wrong, [API KEY] was not retrieved. Please check parameter values to be sure all info is correct or run the command with the -Debug parameter to get more info.'
        }

        Write-Output -InputObject 'Successfully obtained API KEY. '
        Write-Output -InputObject ''
        Write-Output -InputObject 'Confirming API key and connection to your MaaS360 account.'
        Write-Output -InputObject ''

        if (-not (Test-MaaS360PSConnection -BillingID $MaaS360Session.billingID -Method 'Get'))
        {
            throw 'Unable to verify connection to MaaS360 instance. Please check your [URL], [API KEY], or re-run command with [POST] method to regenerate a key.'
        }
        else
        {
            Write-Output -InputObject 'Connection confirmed. Feel free to use all commands.'
        }
    }

    if ($Validate.IsPresent)
    {
        Write-Verbose -Message 'Checking if the authEndpoint exists. '
        Write-Verbose -Message 'Checking if an API key exists.'
        
        if (($MaaS360Session.authEndpoint -eq [System.String]::Empty) -or ($MaaS360Session.apiKey -eq [System.String]::Empty))
        {
            throw 'Please use Connect-MaaS360PS with the [POST] method before attempting to utilize any commands.'
        }

        $Token = $MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText

        if ($Result.IsPresent)
        {
            Write-Output -InputObject "URI: $($MaaS360Session.baseUrl + $MaaS360Session.authEndpoint + '/' + $MaaS360Session.billingID)"
            Write-Output -InputObject "API KEY: $Token"
        }

        Write-Output -InputObject 'Connection to MaaS360 instance assumed successful. Run Test-MaaS360PSConnection for confirmation.'

        Write-Verbose -Message "Clearing [$($MaaS360Session.authEndpoint)] from 'MaaS360Session'."
        $MaaS360Session.authEndpoint = ''
        Write-Verbose -Message "AuthEndpoint is now '[System.String]::Empty'."
    }
}