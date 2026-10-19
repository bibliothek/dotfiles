$env:POSH_SESSION_DEFAULT_USER = [System.Environment]::UserName
oh-my-posh init pwsh --config ~/martin-paradox.omp.json | Invoke-Expression
# Import-Module posh-git
Import-Module z
Import-Module git-aliases -DisableNameChecking
Set-Alias k kubectl
function _ghpr {gh pr checkout $args --force}
function _gco {git checkout ((git branch | fzf).trim())}
Set-PSReadlineOption -PredictionSource None
#g | out-null
atuin init powershell --disable-up-arrow | Out-String | Invoke-Expression
# $env:POSH_GIT_ENABLED = $true

