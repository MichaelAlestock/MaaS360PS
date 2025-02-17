#region Build Module
[CmdletBinding()]
Param(
    [version]$Version,
    [ValidateSet('Major', 'Minor', 'Patch')]
    [string]$BumpVersion,
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$Output
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

$Parameters = @{
    SourcePath        = [System.IO.Path]::Combine($PSScriptRoot, 'src', 'build.psd1')
    OutputDirectory   = '../output'
    SourceDirectories = @('en-US/public', 'en-US/private')
    CopyPaths         = @('en-US')
    Version           = $Version
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
    Write-Output -InputObject "Unable to import $VersionSpecificManifest"
}

if ((!(Test-Path -Path $Path)) -or ((Get-ChildItem -Path $Path).count -le 0))
{
    New-MarkdownHelp -Module $VersionSpecificManifest -OutputFolder $Path
    New-ExternalHelp $Path -OutputPath $Output
}

Update-MarkdownHelp -Path $Path
Build-Module @Parameters
#endregion Build Module