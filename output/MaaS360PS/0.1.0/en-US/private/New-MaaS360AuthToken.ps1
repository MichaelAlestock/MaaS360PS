function New-GNMaaS360AuthToken
{


    #region Variables
    # Config Variables
    $Config = Get-Content -Path $PSScriptRoot\config.json -Raw | ConvertFrom-Json -Depth 5
    # $RootPath = (Get-Item -Path "$PSScriptRoot").FullName
    $BillingID = $config.authRequest.maaS360AdminAuth.billingID

    # Endpoint Variables
    $Method = $config.authRequest.maaS360AdminAuth.method[0]
    $Uri = 'https://apis.m3.maas360.com/auth-apis/auth/1.0/'
    $Endpoint = "authenticate/$BillingID"
    $Url = $Uri += $Endpoint
    #endregion Variables

    #region Headers
    $Headers = @{
        'accept'       = 'application/json'
        'Content-Type' = 'application/xml'
    }
    #endregion Headers

    #region Body
    $Body = @"
<?xml version="1.0" encoding="UTF-8"?>
<authRequest>
	<maaS360AdminAuth>
		<platformID>$($Config.authRequest.maaS360AdminAuth.platformID)</platformID>
		<billingID>$($Config.authRequest.maaS360AdminAuth.billingID)</billingID>
		<password>$($Config.authRequest.maaS360AdminAuth.password)</password>
		<userName>$($Config.authRequest.maaS360AdminAuth.userName)</userName>
		<appID>$($Config.authRequest.maaS360AdminAuth.appID)</appID>
		<appVersion>$($Config.authRequest.maaS360AdminAuth.appVersion)</appVersion>
		<appAccessKey>$($Config.authRequest.maaS360AdminAuth.appAccessKey)</appAccessKey>
	</maaS360AdminAuth>
</authRequest>
"@
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
