function Invoke-MaaS360APIRequest
{
    
    Param(
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers,
        [string]$ContentType
    )

    #region Variables

    # Endpoint Variables
    $BaseUri = 'https://apis.m3.maas360.com/'
    $Uri = $BaseUri += $Endpoint
    #endregion Variables

    #region Headers
    $Headers = @{
        'accept'       = 'application/json'
        'Content-Type' = 'application/json'
    }
    #endregion Headers

    # If Method is Post
    # if ($Method -eq 'Post')
    # {
    #     $Body = $Content
    # }

    #region Helper Function
    function New-GNMaaS360TokenRefresh
    {
        New-GNMaaS360AuthToken
        Write-Output -InputObject 'New auth token has been generated. Please re-run the last command.'
    }
    #endregion Helper Function
    
    try
    {
        # $InvResponse = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -Authentication 'Bearer' -Token $Token -SkipHttpErrorCheck

        # OAUTH Token
        $Token = Get-MaaS360AuthToken

        $InvResponse = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType $ContentType -Authentication 'Bearer' -Token $Token

        if (($InvResponse.authResponse.errorCode -eq '1007') -or $InvResponse.authResponse.errorCode -eq '1009' )
        {
            # New-MaaS360AuthToken

            Write-Host -Object 'New auth token generated. Please re-run the last command.'-ForegroundColor 'Green'
        } 
        elseif ($InvResponse.status -eq '1')
        {
            Write-Error -Message $InvResponse.response.description
        }
        else
        {
            throw 'Boop'
        }
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException]
    {

        $ExceptionStatus = $_.Exception.StatusCode.ToString()
        $ExceptionError = $_.Exception.MessageDetails.Message

        # Will make this a switch... eventually
        if ($ExceptionStatus -eq 'Unauthorized')
        {
            New-GNMaaS360TokenRefresh
            break
        }
        elseif ($ExceptionStatus -like 'Token is expired')
        {
            New-GNMaaS360TokenRefresh
            break
        }
        elseif ($ExceptionStatus -like 'Token is invalid')
        {
            New-GNMaaS360TokenRefresh
            break
        }
        elseif ($ExceptionError -like '*Internal Server Error*')
        {
            throw 'An error has occured on the API providers end.'
        } 
        else
        {
            Write-Error -Message "An error occurred: $ExceptionError"
        }
        
    }
}