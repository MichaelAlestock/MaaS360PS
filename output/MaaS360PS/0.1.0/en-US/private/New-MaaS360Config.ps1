function New-MaaS360Config
{  
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $true)]
        [int]$PlatformID,
        [Parameter(Mandatory = $true)]
        [string]$BillingID,
        [Parameter(Mandatory = $true)]
        [string]$Pass,
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string]$AppID,
        [Parameter(Mandatory = $true)]
        [string]$AppVersion,
        [Parameter(Mandatory = $true)]
        [string]$AppAccessKey,
        [Parameter(Mandatory = $true)]
        [string]$EnvVarName,
        [Parameter(Mandatory = $true)]
        [string]$EnvVarScope
    )

    # Config dictionary
    # Could've probably just did a here string but fuck it
    $ConfigDict = @{
        'authRequest' = @{
            'maaS360AdminAuth' = @{
                'platformID'   = $PlatformID
                'billingID'    = $BillingID
                'password'     = $Pass
                'userName'     = $UserName
                'appID'        = $AppID
                'appVersion'   = $AppVersion
                'appAccessKey' = $AppAccessKey
                'method'       = @(
                    'post',
                    'get',
                    'put',
                    'patch'
                )
            }
        }
        'envVar'      = @{
            'varName'  = $EnvVarName
            'varScope' = $EnvVarScope
        }
        
    }

    Write-Debug -Message ("Params: $PSBoundParameters")

    # Convert to Json
    $ConfigDict = $ConfigDict | ConvertTo-Json -Depth 5

    try 
    {
        Write-Verbose -Message ('Checking if config file exists at: ' + $PSScriptRoot)

        if (-not (Test-Path -Path $PSScriptRoot\private\config.json))
        {
            Write-Verbose -Message 'False'
            Write-Verbose -Message 'Creating config file'
            New-Item -ItemType 'File' -Path $PSScriptRoot\config.json
            Set-Content -Path $PSScriptRoot\config.json -Value $ConfigDict
            Write-Verbose -Message 'Generating config contents'
        }
        else
        {
            Write-Output -InputObject 'Config file already exists.'
        }
            
    }
    catch
    {
        throw $_.Exception.Message
    }

}