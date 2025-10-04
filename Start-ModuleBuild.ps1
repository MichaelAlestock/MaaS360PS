#region Build Module
[CmdletBinding(DefaultParameterSetName = 'Markdown help files')]
param(
    [Parameter(ParameterSetName = 'Control version')]
    [version]$Version,
    [Parameter(ParameterSetName = 'Control version')]
    [ValidateSet('Major', 'Minor', 'Patch')]
    [string]$BumpVersion,
    [Parameter(ParameterSetName = 'Markdown help files')]
    [switch]$Create,
    [Parameter(ParameterSetName = 'Markdown help files')]
    [switch]$Update,
    [Parameter(ParameterSetName = 'Markdown help files')]
    [switch]$External,
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
    SourceDirectories = @('public', 'private', 'classes')
    OutputDirectory   = '../output'
    Version           = $Version
    Prefix            = "New-Variable -Name 'MaaS360Session' -Value @{
    'url' = ''; 'endpoint' = ''; 'platformID' = ''; 'billingID' = ''; 'userName' = ''; 'password' = ''; 'appID' = ''; 'appVersion' = '' ; 'appAccessKey' = '' ; 'apiKey' = '' ; 'tempHeaders' = @{} ; 'baseUrl' = 'https://apis.m3.maas360.com/' ; 'authEndpoint' = 'auth-apis/auth/1.0/authenticate'
} -Scope 'Global' -Force"
    Target            = 'CleanBuild'
    # UnversionedOutputDirectory = $false
}

$DocsPath = '.\docs'
$ExternalHelpPath = '.\docs\en-us'

switch ($PSBoundParameters.Keys)
{
    'Build' # Build the entire PSM1 and output it into the output/MaaS360PS directory in the matching version folder
    {
        Build-Module @Parameters
        break
    }
    'Create' # Create entirely new markdown help files
    {
        Import-Module -Name $VersionSpecificManifest
        New-MarkdownHelp -Module 'MaaS360PS' -OutputFolder $DocsPath
        New-MarkdownAboutHelp -OutputFolder $ExternalHelpPath -AboutName 'about_MaaS360PS'
        break
    }
    'External' # Create entirely new external (XML) help files
    {
        New-ExternalHelp $DocsPath -OutputPath $ExternalHelpPath -Force
        break
    }
    'Update' # Update the current version of documentation 
    {
        Import-Module -Name $VersionSpecificManifest
        Update-MarkdownHelp -Path $DocsPath
        break
    }
    'Default' # Do nothing except warn that you're about to do nothing because you ran the command without input
    {
        Write-Warning 'Skipping module build. If you want to build the module, please supply the [-BUILD] switch.'
        break
    }
}
#endregion Build Module