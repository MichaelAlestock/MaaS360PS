function New-MaaS360EnvironmentEntry
{
    Param(
        [string]$RawToken
    )

    try
    {
        # Create a new environment variable and store token in it
        # Seems like the best way to hide the token and later implement TTL variable
        # Should just overwrite the current value that is in the environment variable

        $Config = Get-Content -Path $PSScriptRoot\config.json | ConvertFrom-Json -Depth 5
        
        # Adding environment variables for Unix
        # Gotta figure out how to find system shell i.e. Zsh or Bash
        
        [System.Environment]::SetEnvironmentVariable($Config.envVar.varName, $RawToken, $Config.envVar.varScope)
    }
    catch
    {
        throw $_.Exception.Message
    }
}