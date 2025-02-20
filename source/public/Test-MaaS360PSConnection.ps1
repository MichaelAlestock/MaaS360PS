# $TestMethod = 'Get'
# $TestEndpoint = 'user-apis/user/1.0/search/'

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
        [string]$BillingID,
        [string]$Method
    )

    if (($null -eq $MaaS360Session.apiKey) -or ($null -eq $MaaS360Session.baseUrl) -or (-not (Get-ChildItem -Path 'Variable:').Name -contains 'MaaS360Session'))
    {
        throw 'No connection created to MaaS360 instance. Please run "Connect-MaaS360PS" to create a session.'
    }

    $Headers = @{
        'Accept'       = 'application/json'
        'Content-Type' = 'application/json'
    }

    $Uri = $MaaS360Session.baseUrl + 'user-apis/user/1.0/search/' + $BillingID

    # Both of these are needed to give the user the ability to see if their URI or API KEY could be reasons behind errors they're experiencing.
    Write-Debug -Message "URI: $Uri"
    Write-Debug -Message "TOKENIZED API KEY: $(($MaaS360Session.apiKey) | ConvertFrom-SecureString -AsPlainText)"

    $Parameters = @{
        Uri            = $Uri
        Method         = $Method
        Headers        = $Headers
        Authentication = 'Bearer'
        Token          = $MaaS360Session.apiKey 
        # Forgot token needs to actually be sent as a securestring and is only sent as plain text when used getting a new token.. wow
    }

    try
    {
        $TestResponse = Invoke-MaaS360Method @Parameters
        
        Write-Debug -Message "Debug response: $($TestResponse)"

        # Not sure how else to check for content in the response other than checking if it's a PSCustomObject since it wouldn't be if it were an error.
        if ((($TestResponse).GetType()).Name -eq 'PSCustomObject')
        {
            Write-Debug -Message "Connection to [$Uri] successful."
            return $true
        }
        else
        {
            # API isn't going to return a terminating error no matter what I do so this is the best way I can think of to handle the error and provide the user with useful information.
            Write-Debug -Message $(Get-BetterError -ExceptionMessage "Connection to [$Uri] was unsuccessful. Find reasoning below to correct the issue." -ErrorID "$BillingID" -ErrorObject $TestResponse -ErrorCategory 'ConnectionError')
            return $false
        }
    }
    catch
    {   
        throw $_
    } 
}