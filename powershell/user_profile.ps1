# Oh My Posh (Prompt theme engine)
oh-my-posh init pwsh --config "$env:USERPROFILE\scoop\apps\oh-my-posh\current\themes\pure.omp.json" | Invoke-Expression

# PowerShell Modules
Import-Module Terminal-Icons
Import-Module z
Import-Module PSFzf

# PSFzf Keybindings
Set-PsFzfOption -TabExpansion -PSReadlineChordProvider 'Ctrl+f'

# PSReadLine Configurations (Autocompletion & Navigation)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Aliases
Set-Alias g git
function ll { Get-ChildItem -Force }

# Clear screen on startup
Clear-Host
