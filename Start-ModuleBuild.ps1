#region Build Module
[CmdletBinding(DefaultParameterSetName = 'Markdown help files')]
Param(
    [Parameter(ParameterSetName = 'Control version')]
    [version]$Version,
    [Parameter(ParameterSetName = 'Control version')]
    [ValidateSet('Major', 'Minor', 'Patch')]
    [string]$BumpVersion,
    [Parameter(Mandatory = $false)]
    [Parameter(ParameterSetName = 'Markdown help files')]
    [string]$Path,
    [Parameter(ParameterSetName = 'Markdown help files')]
    [string]$Output,
    [Parameter(ParameterSetName = 'Markdown help files')]
    [switch]$Update
)

$ManifestPath = [System.IO.Path]::Combine($PSScriptRoot, 'source', 'MaaS360PS.psd1')

[version]$ModuleVersion = (Import-PowerShellDataFile -Path $ManifestPath).ModuleVersion
$Version = $ModuleVersion

$Major = $ModuleVersion.Major
$Minor = $ModuleVersion.Minor
$Patch = $ModuleVersion.Build

if ($BumpVersion)
{
    switch ($BumpVersion)
    {
        'Major'
        {
            $Major ++
            $Minor = 0
            $Patch = 0
            break;
        }
        'Minor'
        {
            $Major
            $Minor ++
            $Patch = 0
            break;
        }
        'Patch'
        {
            $Major
            $Minor
            $Patch ++
            break;
        }
    }

    $NewVersion = [version]::new($Major, $Minor, $Patch)
    Write-Verbose -Message "Bumping module version to [$NewVersion]"
    Update-ModuleManifest -Path $ManifestPath -ModuleVersion $NewVersion
    $Version = $NewVersion
}

$MaaS360Session = @{
    'url'          = $null
    'endpoint'     = $null
    'platformID'   = $null
    'billingID'    = $null
    'userName'     = $null
    'password'     = $null
    'appID'        = $null
    'appVersion'   = $null
    'appAccessKey' = $null 
    'apiKey'       = $null
}

$VersionSpecificManifest = [System.IO.Path]::Combine($PSScriptRoot, 'output', 'MaaS360PS', $Version, 'MaaS360PS.psm1')

$Parameters = @{
    SourcePath        = [System.IO.Path]::Combine($PSScriptRoot, 'source', 'build.psd1')
    SourceDirectories = @('public', 'private')
    OutputDirectory   = '../output'
    Version           = $Version
    Suffix            = New-Variable -Name 'MaaS360Session' -Value $MaaS360Session -Scope 'Script' -Force
    Target            = 'CleanBuild'
    # UnversionedOutputDirectory = $false
}

Build-Module @Parameters

Import-Module -Name $VersionSpecificManifest

switch ($PSBoundParameters.Keys)
{
    { $_ -eq 'Output' }
    {
        New-MarkdownHelp -Module 'MaaS360PS' -OutputFolder $Path
        New-ExternalHelp $Path -OutputPath $Output
        break
    }
    { $_ -eq 'Update' }
    {
        Update-MarkdownHelp -Path $Path
        break
    }
}
#endregion Build Module