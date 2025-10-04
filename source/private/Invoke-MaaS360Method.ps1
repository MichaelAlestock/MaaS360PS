# Changing name to identify that this function uses Invoke-RestMethod and not Invoke-WebRequest
function Invoke-MaaS360Method
{
    <#
        # Usage
        - Like the bread on a sandwich, without this no API calls will function
        - Able to take in any method and piece of input no matter the function calling it
    #>

    [CmdletBinding()]
    Param(
        [hashtable]$Body,
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers,
        [string]$ContentType,
        [string]$Authentication,
        [securestring]$Token
    )

    # Stop any further execution until an API key (session) is created
    if ($null -eq $MaaS360Session.apiKey)
    {
        throw 'No API key found. Did you run Connect-MaaS360PS before running this command?'
    }

    # Make sure the headers hash is empty before trying to shove more stuff into it
    if ($MaaS360Session.tempHeaders.Count -eq 0)
    {
        switch ($Method)
        {
            'Get'
            {
                $MaaS360Session.tempHeaders.Add('Accept', 'application/json')
                $MaaS360Session.tempHeaders.Add('Content-Type', 'application/json')
                break
            }
            'Post'
            {
                $MaaS360Session.tempHeaders.Add('Accept', 'application/json')
                $MaaS360Session.tempHeaders.Add('Content-Type', 'application/x-www-form-urlencoded')
                break
            }
            { 'Patch', 'Delete' }
            {
                $MaaS360Session.tempHeaders.Add('Accept', 'application/json')
                $MaaS360Session.tempHeaders.Add('Content-Type', 'application/json-patch+json')
                break
            }
        }
    }


    # Maybe we should dynamically build the headers ^^
    $Headers = $MaaS360Session.tempHeaders

    try
    {
        # Not sure if smart to keep it out in the open like this instead of behind a variable
        $InvokeResponse = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType $ContentType -Authentication $Authentication -Token $Token

        $InvokeResponse
        # Clear to avoid potential errors in subsequent calls
        $MaaS360Session.tempHeaders.Clear()
    }
    catch
    {
        Get-BetterError -ErrorObject $InvokeResponse
    }
}