# Required modules to install
$Modules = @('ModuleBuilder', 'platyPS')

# Make sure PSGallery is trusted so we don't get stuck
if (-not (Get-PSRepository -Name 'PSGallery').InstallationPolicy -eq 'Trusted')
{
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
}
    
# Install modules
foreach ($Module in $Modules)
{
  
    $FindModule = Get-Module -Name $Module -ListAvailable

    if ($null -eq $FindModule)
    {
        Write-Output -InputObject "Installing module: $Module"
        Install-Module -Name $Module -Force
    }
    else
    {
        Write-Output -InputObject "$Module is installed"
    }

    Import-Module -Name $Module
    Write-Output -InputObject "Importing $Module into session"
}
