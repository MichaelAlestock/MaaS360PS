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
    [switch]$Update,
    [Parameter(ParameterSetName = 'Build')]
    [switch]$Build
)

$ManifestPath = [System.IO.Path]::Combine($PSScriptRoot, 'source', 'MaaS360PS.psd1')

[version]$ModuleVersion = (Import-PowerShellDataFile -Path $ManifestPath).ModuleVersion
$Version = $ModuleVersion

$Major = $Version.Major
$Minor = $Version.Minor
$Patch = $Version.Build

if ($PSBoundParameters.ContainsKey('BumpVersion'))
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
    Update-ModuleManifest -Path '.\source\MaaS360PS.psd1' -ModuleVersion $NewVersion
    $Version = $NewVersion
}

$VersionSpecificManifest = [System.IO.Path]::Combine($PSScriptRoot, 'output', 'MaaS360PS', $Version, 'MaaS360PS.psd1')

$Parameters = @{
    SourcePath        = [System.IO.Path]::Combine($PSScriptRoot, 'source', 'build.psd1')
    SourceDirectories = @('public', 'private')
    OutputDirectory   = '../output'
    Version           = $Version
    Prefix            = "New-Variable -Name 'MaaS360Session' -Value @{
    'url' = ''; 'endpoint' = ''; 'platformID' = ''; 'billingID' = ''; 'userName' = ''; 'password' = ''; 'appID' = ''; 'appVersion' = '' ; 'appAccessKey' = '' ; 'apiKey' = '' ; 'tempHeaders' = @{} ; 'baseUrl' = 'https://apis.m3.maas360.com/' ; 'authEndpoint' = 'auth-apis/auth/1.0/authenticate'
} -Scope 'Global' -Force"
    Target            = 'CleanBuild'
    # UnversionedOutputDirectory = $false
}

switch ($PSBoundParameters.Keys)
{
    'Build'
    {
        Build-Module @Parameters
        break
    }
    'Output'
    {
        Import-Module -Name $VersionSpecificManifest
        New-MarkdownHelp -Module 'MaaS360PS' -OutputFolder $Path
        New-MarkdownAboutHelp -OutputFolder $Output -AboutName 'about_MaaS360PS'
        New-ExternalHelp $Path -OutputPath $Output
        break
    }
    'Update'
    {
        Import-Module -Name $VersionSpecificManifest
        Update-MarkdownHelp -Path $Path
        break
    }
    'Default'
    {
        Write-Warning 'Skipping module build. If you want to build the module, please supply the [-BUILD] parameter.'
    }
}
#endregion Build Module