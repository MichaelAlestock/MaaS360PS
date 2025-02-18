function Get-MaaS360AuthToken
{
    
    $Config = Get-Content -Path .\private\config.json -Raw | ConvertFrom-Json -Depth 5
    $MaaS360EnvName = $Config.envVar.varName
    $Maas360EnvScope = $Config.envVar.varScope
        
    try
    {
        $GetEnvVariable = [System.Environment]::GetEnvironmentVariable($MaaS360EnvName, $Maas360EnvScope)

        # Check environment variable to make sure it exists
        if ($Null -eq $GetEnvVariable)
        {
            New-GNMaaS360AuthToken
        }


        try
        {
            ConvertTo-SecureString -AsPlainText -String ('MaaS token=' + $("""$GetEnvVariable"""))
        }
        catch [System.Management.Automation.PSArgumentException]
        {
            throw 'error beep boop'
        }
        
        
    }
    catch [System.InvalidCastException]
    {
        Write-Error -Exception 'InvalidCastException' -Message 'Please check to make sure the "$MaaS360EnvName" and "$MaaS360EnvScope" variables are not empty.'
        Write-Host -Object ''
        Write-Error -Exception 'InvalidCastException' -Message "$($_.Exception.Message)"
    }
    
}