$TestMethod = 'Get'
$TestEndpoint = 'user-apis/user/1.0/search/'

function Test-MaaS360PSConnection
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
    
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'User instances MaaS360 API base url.')]
        [ValidateSet(
            'https://apis.m3.maas360.com/'
        )]
        [string]$Url,
        [Parameter(HelpMessage = "Endpoint you'd like to interact with")]
        [ValidateSet(
            'user-apis/user/1.0/search/'
        )]
        [string]$Endpoint,
        [string]$BillingID,
        [string]$Method
    )

    if (($null -eq $MaaS360Session.apiKey) -or ($null -eq $MaaS360Session.url) -or (-not (Get-ChildItem -Path 'Variable:').Name -contains 'MaaS360Session'))
    {
        throw 'No connection created to MaaS360 instance. Please run "Connect-MaaS360PS" to create a session.'
    }

    $Headers = @{
        'Accept'       = 'application/json'
        'Content-Type' = 'application/json'
    }

    $Uri = $Url + $Endpoint + $BillingID

    Write-Debug -Message "URI: $Uri"
    Write-Debug -Message "TOKENIZED API KEY: $(($MaaS360Session.apiKey) | ConvertFrom-SecureString -AsPlainText)"

    $Parameters = @{
        Uri            = $Uri
        Method         = $Method
        Headers        = $Headers
        Authentication = 'Bearer'
        Token          = $MaaS360Session.apiKey # Forgot this needs to actually send secured.. wow
    }

    try
    {
        $TestResponse = Invoke-RestMethod @Parameters
        
        Write-Debug -Message "Debug response: $TestResponse"

        if ($TestResponse)
        {
            Write-Output -InputObject "Connection to [$Uri] successful."
            return $true | Out-Null
        }
        else
        {
            $PSCmdlet.ThrowTerminatingError()
        }
    }
    catch
    {   
        Get-BetterError -ExceptionMessage "Connection to [$Uri] was unsuccessful. Find reasoning below to correct the issue." -ErrorID "$BillingID" -ErrorObject $TestResponse -ErrorCategory 'ConnectionError'
        return $false | Out-Null
    } 
}