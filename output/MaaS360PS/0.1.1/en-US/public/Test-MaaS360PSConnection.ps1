# $Method = 'Get'
function Test-MaaS360PSConnection
{
    # Test-MaaS360PSConnection

    <#
     Description: Test connection to the BASE URI of the MaaS360 API

    #>

    [CmdletBinding()]
    Param(
        [string]$Url,
        [string]$Endpoint = 'user-apis/user/1.0/search/',
        [string]$BillingID,
        [string]$Method = 'Get'
    )

    if (($null -eq $MaaS360Session.apiKey) -or ($null -eq $MaaS360Session.url) -or ($null -eq $MaaS360Session))
    {
        throw 'No connection created to MaaS360 instance. Please run "Connect-MaaS360PS" to create a session.'
    }

    $Uri = $Url + '/' + $Endpoint + $BillingID

    $Parameters = @{
        Uri            = $Uri
        Method         = $Method
        Authentication = 'Bearer'
        Token          = $MaaS360Session.apiKey | ConvertFrom-SecureString -AsPlainText
    }

    try
    {
        $TestResponse = Invoke-RestMethod @Parameters

        if ($TestResponse -eq '1234567890')
        {
            Write-Output -InputObject "Connection to [$Uri] successful."
            return $true
        }
        else
        {
            $PSCmdlet.ThrowTerminatingError()
        }
    }
    catch
    {
        Get-BetterError -ExceptionMessage "Connection to [$Uri] was unsuccessful." -ErrorID '1234' -ErrorObject $TestResponse -ErrorCategory 'ObjectNotFound'
        return $false
    } 
}

function Get-BetterError
{
    [CmdletBinding()]
    Param(
        [string]$ErrorID,
        [string]$ErrorCategory,
        [string]$ExceptionMessage,
        [object]$ErrorObject
    )

    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
        [Exception]::new($ExceptionMessage), 
        $ErrorID, 
        [System.Management.Automation.ErrorCategory]::$ErrorCategory, 
        $ErrorObject
    )

    $ErrorRecord
}