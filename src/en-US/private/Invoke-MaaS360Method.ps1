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
        [string]$Url,
        [string]$Endpoint,
        [hashtable]$Headers,
        [string]$ContentType
    )

    $ApiToken = $null

    # Maybe we should dynamically build the headers
    $Headers = [ordered]@{}

    # Stop any further execution until an API key (session) is created
    if ($null -eq $MaaS360Session.apiKey)
    {
        throw 'No API key found. Did you run Connect-MaaS360PS before running this command?'
    }

    switch ($Method)
    {
        'Get'
        {
            $Headers.Add('Accept', 'application/json')
            $Headers.Add('Content-Type', 'application/json')
            $ApiToken = $MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText
            break
        }
        'Post'
        {
            $Headers.Add('Accept', 'application/json')
            $Headers.Add('Content-Type', 'application/x-www-form-urlencoded')
            $ApiToken = $MaaS360Session.apiKey
            break
        }
        { 'Patch', 'Delete' }
        {
            $Headers.Add('Accept', 'application/json')
            $Headers.Add('Content-Type', 'application/json-patch+json')
            $ApiToken = $MaaS360Session.apiKey
            break
        }
    }
    
    try
    {
        $InvokeResponse = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType $ContentType -Authentication 'Bearer' -Token $ApiToken

        $InvokeResponse
    }
    catch
    {
        $_.ErrorDetails.Message
        $_.Exception.Message
    }
}