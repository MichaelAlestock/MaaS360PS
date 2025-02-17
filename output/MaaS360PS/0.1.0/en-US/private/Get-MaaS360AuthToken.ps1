function Get-MaaS360AuthToken
{
    <#
    .NOTES
	===========================================================================
	 Created with: 	Visual Studio Code
	 Created on:   	12/15/2024 12:10 PM
	 Created by:   	Anthony Alestock
	 Organization: 	Greater Nashua Mental Health
	 Department: 	Information Technology
	 Position:		Jr. Network Administrator
	 Filename:     	Get-GNMaaS360AuthToken.ps1

	 To-Do:			
	===========================================================================

    .SYNOPSIS
        Pulls the OAUTH token generated by New-GNMaaS360AuthToken from the environment variable.
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
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