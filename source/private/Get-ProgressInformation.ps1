function Get-ProgressInformation
{
    [CmdletBinding()] # Just in case we need it for debugging purposes in the future
    param(
        [int]$Count,
        [int]$Page,
        [int]$Size
    )
    
    Write-Information -MessageData "Total Returned Objects: $Count | Page Number: $Page | Page Size: $Size" -InformationAction 'Continue'
}