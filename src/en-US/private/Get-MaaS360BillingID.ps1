function Get-MaaS360BillingID
{
    $Config = ''

    if (-not (Test-Path -Path $PSScriptRoot\config.json))
    {
        Write-Host -Object 'No configuration file was found. A new one must be generated.'
        Write-Output -InputObject ''
        $Config = New-GNMaaS360Config
    }
    else
    {
        $Config = Get-Content -Path $PSScriptRoot\config.json -Raw | ConvertFrom-Json -Depth 5
    }

    # $RootPath = (Get-Item -Path "$PSScriptRoot").FullName
    $Config.authRequest.maaS360AdminAuth.billingID
}