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

    try
    {
        $FindErrorReason = Get-Error -Newest 1
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
                        break
                    }
                    '1008'
                    {
                        Write-Warning -Message 'BillingID is possibly incorrect. Please check the supplied BillingID to verify and try again.'
                        break
                    }
                    Default
                    {
                        Write-Warning -Message @"
                        Failure Error Description: $($ErrorDetailsErrorDescription)
                        Failure Error Status Code: $($ErrorDetailsErrorCode)
"@
                        break
                    }
                }
                break
            }
        }

        $ErrorRecord
    }
    catch
    {
        throw 'Unable to parse error record.'
    }
    
}