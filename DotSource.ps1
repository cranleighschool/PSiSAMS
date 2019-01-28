Get-ChildItem -Path "$PSScriptRoot\Modules\*\*.ps1" |
ForEach-Object {
    . $_.FullName
}