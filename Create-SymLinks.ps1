$sourceDir = $PSScriptRoot

Get-ChildItem "$sourceDir/crossplatform" |
ForEach-Object {
	$scriptName = $_.Name
	New-Item -Type SymbolicLink -Path "$env:USERPROFILE/$scriptName" -Value "$sourceDir/crossplatform/$scriptName"
}

