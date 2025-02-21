function Get-BetterError
{
    [OutputType([System.Management.Automation.ErrorRecord])]
    [CmdletBinding()]
    Param(
        [string]$ErrorID,
        [string]$ErrorCategory,
        [string]$ExceptionMessage,
        [object]$ErrorObject
    )

    $FindErrorReason = Get-Error -Newest 1

    $ErrorObject = $FindErrorReason
    $ExceptionMessage = $FindErrorReason.Exception.Message
    $ErrorID = $FindErrorReason.InvocationInfo.ScriptLineNumber
    $ErrorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation

    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
        [Exception]::new($ExceptionMessage),
        $ErrorID,
        [System.Management.Automation.ErrorCategory]::$ErrorCategory,
        $ErrorObject
    )

    if (($null -eq $FindErrorReason.ErrorDetails) -or ($FindErrorReason.ErrorDetails.Message -eq [System.String]::Empty))
    {
        switch ($ExceptionMessage)
        {
            'This operation is not supported for a relative URI.'
            {
                Write-Warning -Message "URI issue. Please make sure 'MaaS360Session' is properly loaded. If issue persists, please re-import the module.'"
                throw $ErrorRecord
            }
            Default
            {
                throw $ErrorRecord
            }
        }
    }

    $ErrorDetailsJson = $FindErrorReason.ErrorDetails.Message | ConvertFrom-Json -Depth '5'
    $ErrorDetailsErrorCode = $ErrorDetailsJson.authResponse.errorCode
    $ErrorDetailsErrorDescription = $ErrorDetailsJson.authResponse.errorDesc
    $StatusCode = $FindErrorReason.Exception.StatusCode
    $Script:ExpressReason = ''

    switch ($StatusCode)
    {
        'Unauthorized'
        {
            switch ($ErrorDetailsErrorCode)
            {
                '1007'
                {
                    Write-Warning -Message 'Token has expired. Please run Connect-MaaS360PS with the [POST] method to generate a new one.'
                    $MaaS360Session.apiKey = [System.String]::Empty
                    break
                }
                '1008'
                {
                    Write-Warning -Message 'BillingID is possibly incorrect. Please check the supplied BillingID to verify and try again.'
                    $MaaS360Session.apiKey = [System.String]::Empty
                    break
                }
                Default
                {
                    Write-Debug -Message @"
Failure Error Description: $($ErrorDetailsErrorDescription)
Failure Error Status Code: $($ErrorDetailsErrorCode)
"@
                }
            }
            break
        }
    }
    $ErrorRecord
}