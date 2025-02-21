function Get-ProgressInformation ([int]$Count, [int]$Page, [int]$Size)
{
    Write-Information -MessageData "Total Returned Objects: $Count | Page Number: $Page | Page Size: $Size" -InformationAction 'Continue'
}