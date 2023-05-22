# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
{
    # We are running "as Administrator" - so change the title and background color to indicate this
    Write-Host -NoNewline -ForegroundColor Red "`nRunning as Administrator"
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host
}
else {
    # We are not running "as Administrator" - so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    exit
}

# Run your code that needs to be elevated here
Write-Host -NoNewline -ForegroundColor Red "`nPlease wait..."


# Determine the script directory
$scriptDir = $PSScriptRoot



#############################################################

$selectedLocaleCode = [Environment]::GetEnvironmentVariable("SelectedLocaleCode", "User")
$jsonPath = Join-Path -Path $scriptDir -ChildPath "$selectedLocaleCode.json"

# OLD - Set the JSON file path
#$jsonPath = Join-Path -Path $scriptDir -ChildPath 'en-GB.json'


#############################################################


# Read the JSON file and convert it to a PowerShell object
$jsonContent = Get-Content -Path $jsonPath -Raw | ConvertFrom-Json

# Keep adding new selections until the user is done
do {
    # Prompt the user for a new selection value
    $newSelectionValue = Read-Host -Prompt 'Enter the new selection value'

    # Create a new selection object
    $newSelection = @{
        name = @{
            value = $newSelectionValue
            synonyms = @()
        }
    }

    # Add the new selection to the selections in the JSON data
    $jsonContent.interactionModel.languageModel.types[0].values += $newSelection

    # Ask the user if they want to add another selection
    $anotherSelection = Read-Host -Prompt 'Would you like to add another selection? (Y/n)'
} while ($anotherSelection -eq 'y')

# Convert the updated object back to JSON and overwrite the original file
$jsonContent | ConvertTo-Json -Depth 20 | Set-Content -Path $jsonPath


#############################################################

# Move up three directories
$newDir = $PSScriptRoot
for ($i=0; $i -lt 3; $i++) {
    $newDir = Split-Path -Path $newDir
}

# Now, $newDir should be the directory you want to navigate to
Set-Location -Path $newDir

git init
git config --global --add safe.directory $newDir
git config --global user.email "Hassassistant@Hassassistant.com"
git config --global user.name "Hassassistant"

# Check if 'dev' branch exists and create if it doesn't
$branchExists = git show-ref --verify --quiet refs/heads/dev
if (-not $branchExists) {
    git checkout -b dev
} else {
    git checkout dev
}

# Commit changes
git add .
git commit -m "Included Actionable Notification Files"

# Merge master into dev to sync them
git merge master

# If any conflicts occurred, handle them here

# Checkout to master and merge dev into master to apply changes
git checkout master
git merge dev

# Push changes
git push origin master

# Confirm completion
Write-Host "`nChanges successfully committed and pushed to 'master' branch."

Write-Host -NoNewline -ForegroundColor Red "`nPlease allow a couple of minutes for changes to be made to your Alexa skill`n"
pause
