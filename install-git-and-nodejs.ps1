# Define path of scripts
$scriptsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$installScriptsPath = Join-Path -Path $scriptsPath -ChildPath 'Install'  # point to the 'Install' subdirectory

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
$installScripts = @("node-install.ps1", "git-install.ps1")
foreach ($script in $installScripts) {
    & "$installScriptsPath\$script"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } # if error occurred in script, stop the process
}
