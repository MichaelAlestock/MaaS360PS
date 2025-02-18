function New-GNMaaS360AuthToken
{


    #region Variables
    # Config Variables
    $Config = Get-Content -Path $PSScriptRoot\config.json -Raw | ConvertFrom-Json -Depth 5
    # $RootPath = (Get-Item -Path "$PSScriptRoot").FullName
    $BillingID = $config.authRequest.maaS360AdminAuth.billingID

    #endregion Body

    try 
    {
        $Response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $Headers -Body $Body
        $RawToken = $Response.authResponse.authToken
        New-GNMaaS360EnvironmentEntry -RawToken $RawToken
    }
    catch 
    {
        $_.Exception.Message
    }

}
