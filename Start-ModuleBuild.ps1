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

$ManifestPath = [System.IO.Path]::Combine($PSScriptRoot, 'src', 'MaaS360PS.psd1')

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

$Parameters = @{
    SourcePath        = [System.IO.Path]::Combine($PSScriptRoot, 'src', 'build.psd1')
    OutputDirectory   = '../output'
    SourceDirectories = @('en-US/public', 'en-US/private')
    CopyPaths         = @('en-US')
    Version           = $Version
    Suffix            = "New-Variable -Name 'MaaS360Session' -Value $MaaS360Session -Scope 'Script' -Force"
    Target            = 'CleanBuild'
    # UnversionedOutputDirectory = $false
}

$VersionSpecificManifest = [System.IO.Path]::Combine($PSScriptRoot, 'output', 'MaaS360PS', $Version, 'MaaS360PS.psm1')

Write-Verbose -Message 'Importing $VersionSpecificManifest'

try
{
    Import-Module -Name $VersionSpecificManifest -ErrorAction 'Stop'
}
catch
{
    throw "Unable to import $VersionSpecificManifest"
}

if ($PSBoundParameters.ContainsKey('Path'))
{
    if ((!(Test-Path -Path $Path)) -or ((Get-ChildItem -Path $Path).count -le 0))
    {
        New-MarkdownHelp -Module $VersionSpecificManifest -OutputFolder $Path
        New-ExternalHelp $Path -OutputPath $Output
    }

    if ($Update.IsPresent)
    {
        Update-MarkdownHelp -Path $Path
    }
}
Build-Module @Parameters
#endregion Build Module