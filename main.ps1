# Define path of scripts
$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$installScriptsPath = Join-Path -Path $scriptsPath -ChildPath 'Install'  # point to the 'Install' subdirectory
$configScriptsPath = Join-Path -Path $scriptsPath -ChildPath 'Config'  # point to the 'Config' subdirectory

# Check if scripts exist
$installScriptPath = Join-Path -Path $installScriptsPath -ChildPath 'ask-install.ps1'
$configScriptPath = Join-Path -Path $configScriptsPath -ChildPath 'ask.ps1'
if (-not (Test-Path -Path $installScriptPath)) {
    Write-Error "Install script does not exist at path: $installScriptPath"
    exit 1
}
if (-not (Test-Path -Path $configScriptPath)) {
    Write-Error "Config script does not exist at path: $configScriptPath"
    exit 1
}

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole)) {
    # We are running "as Administrator"
    Write-Host -NoNewline -ForegroundColor Red "`nRunning as Administrator"
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host
} else {
    # We are not running "as Administrator" - so relaunch as administrator
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

# Run install scripts
try {
    & $installScriptPath
    if (-not $?) { throw "Install script failed" }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

# Run ask.ps1
try {
    & $configScriptPath
    if (-not $?) { throw "Config script failed" }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

# Pause before commiting new changes
Write-Host "Please wait while skill is being built..."
Start-Sleep -Seconds 20
Write-Host "Finishing up..."
