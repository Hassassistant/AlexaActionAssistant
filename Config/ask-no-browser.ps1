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
$askPath = "C:/Users/$env:USERNAME/AppData/Roaming/npm/ask.cmd"
$workingDirectory = Split-Path -Path $myInvocation.MyCommand.Definition -Parent
$rootDirectory = Split-Path -Path $workingDirectory -Parent

Start-Process -NoNewWindow -Wait -WorkingDirectory $workingDirectory -FilePath $askPath -ArgumentList "configure --no-browser"
Start-Process -NoNewWindow -Wait -WorkingDirectory $workingDirectory -FilePath $askPath -ArgumentList "new"

# Get the list of directories after running the command and select the most recently created
$newDir = Get-ChildItem -Path $workingDirectory -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Now you can use the $newDir variable as your destination
$destination = Join-Path -Path $workingDirectory -ChildPath $newDir.Name

# Define source folder
$source = "$rootDirectory\skill-data"

# Copy 'lambda' and 'skill-package' folders
Copy-Item -Path "$source\lambda" -Destination "$destination" -Recurse -Force
Copy-Item -Path "$source\skill-package\interactionModels" -Destination "$destination\skill-package" -Recurse -Force


################################################################################################################
################################################################################################################


# Get the user's HA URL
$haURL = Read-Host -Prompt 'Input your Home Assistant URL'

# Replace the HA URL in lambda_function.py
(Get-Content "$destination\lambda\lambda_function.py") |
Foreach-Object {
    $_ -replace 'https://yourhomeassistanturl.com', $haURL
} | Set-Content "$destination\lambda\lambda_function.py"



# Get the user's HA Token
$haToken = Read-Host -Prompt 'Input your Home Assistant Long Lived Token'

# Replace the HA Token in lambda_function.py
(Get-Content "$destination\lambda\lambda_function.py") |
Foreach-Object {
    $_ -replace 'YourHALongToken', $haToken
} | Set-Content "$destination\lambda\lambda_function.py"




# Ask the user if the site has valid SSL certs
$sslValid = Read-Host -Prompt 'Does your site have valid SSL certs? (Y/N)'
if ($sslValid -eq 'Y' -or $sslValid -eq 'y') {
    $sslOption = 'True'
}
else {
    $sslOption = 'False'
}

# Replace the VERIFY_SSL option in lambda_function.py
(Get-Content "$destination\lambda\lambda_function.py") |
Foreach-Object {
    $_ -replace 'TrueorFalse', "$sslOption"
} | Set-Content "$destination\lambda\lambda_function.py"



################################################################################################################
################################################################################################################



# Define the locales
$locales = @(
    @{Code='ar-SA';Description='Arabic (SA)'},
    @{Code='de-DE';Description='German (DE)'},
    @{Code='en-AU';Description='English (AU)'},
    @{Code='en-CA';Description='English (CA)'},
    @{Code='en-GB';Description='English (UK)'},
    @{Code='en-IN';Description='English (IN)'},
    @{Code='en-US';Description='English (US)'},
    @{Code='es-ES';Description='Spanish (ES)'},
    @{Code='es-MX';Description='Spanish (MX)'},
    @{Code='es-US';Description='Spanish (US)'},
    @{Code='fr-CA';Description='French (CA)'},
    @{Code='fr-FR';Description='French (FR)'},
    @{Code='hi-IN';Description='Hindi (IN)'},
    @{Code='it-IT';Description='Italian (IT)'},
    @{Code='ja-JP';Description='Japanese (JP)'},
    @{Code='pt-BR';Description='Portuguese (BR)'}
)

# Present the options to the user
Write-Host "Please choose a locale:"
for ($i=0; $i -lt $locales.Length; $i++) {
    Write-Host "$($i+1). $($locales[$i].Description)"
}

# Get the user's choice
[int]$choice = 0
do {
    $choice = [int](Read-Host "Enter the number of your choice")
} until ($choice -ge 1 -and $choice -le $locales.Length)

# Get the selected locale code
$selectedLocaleCode = $locales[$choice-1].Code

# Add locale code to Env Variable for use with intent-addition.ps1
[Environment]::SetEnvironmentVariable("SelectedLocaleCode", $selectedLocaleCode, "User")


# Load the skill.json content
$skillJsonPath = "$destination\skill-package\skill.json"
$skillJsonContent = Get-Content $skillJsonPath | ConvertFrom-Json

# Modify the properties
$localeName = $skillJsonContent.manifest.publishingInformation.locales.'en-US'.name

# Remove 'en-US' and add selected locale with same name
$skillJsonContent.manifest.publishingInformation.locales.PSObject.Properties.Remove('en-US')
$skillJsonContent.manifest.publishingInformation.locales | Add-Member -Type NoteProperty -Name $selectedLocaleCode -Value @{ 'name' = $localeName }

$skillJsonContent.manifest | Add-Member -Type NoteProperty -Name 'manifestVersion' -Value '1.0'
$skillJsonContent.manifest.publishingInformation | Add-Member -Type NoteProperty -Name 'isAvailableWorldwide' -Value $true
$skillJsonContent.manifest.publishingInformation | Add-Member -Type NoteProperty -Name 'category' -Value 'KNOWLEDGE_AND_TRIVIA'

# Save the updated JSON content
$skillJsonContent | ConvertTo-Json -Depth 20 | Set-Content $skillJsonPath


################################################################################################################
################################################################################################################


# Load the ask-states.json content
$askStatesPath = "$destination\.ask\ask-states.json"
$askStatesContent = Get-Content $askStatesPath | ConvertFrom-Json

# Extract the skillId
$skillId = $askStatesContent.profiles.default.skillId

# Define the path of the new text file
$newFilePath = "$destination\Scripts.txt"

# Define the text content
$textContent = @"
activate_alexa_actionable_notification:
  alias: activate_alexa_actionable_notification
  description: Activates an actionable notification on a specific echo device
  fields:
    text:
      description: The text you would like alexa to speak.
    event_id:
      description: Correlation ID for event responses
    alexa_device:
      description: Alexa device you want to trigger
  sequence:
  - service: input_text.set_value
    data_template:
      entity_id: input_text.alexa_actionable_notification
      value: '{"text": "{{ text }}", "event": "{{ event_id }}"}'
  - service: media_player.play_media
    data_template:
      entity_id: '{{ alexa_device }}'
      media_content_type: skill
      media_content_id: $skillId
  mode: single
"@

# Save the text content to the new text file
$textContent | Out-File -FilePath $newFilePath


# Copy 'lambda' and 'skill-package' folders
Move-Item -Path $newFilePath -Destination $rootDirectory -Force




# Define the path of the new text file
$newFilePath2 = "$destination\Configuration.txt"

# Define the text content
$textContent = @"
input_text: ## Do Not Include This Line If You Already Have input_text: In You Configuration.yaml
  alexa_actionable_notification:
    name: Alexa Actionable Notification Holder
    max: 255
    initial: '{"text": "This is a test of the alexa actionable notifications skill. Did it work?", "event": "actionable.skill.test"}'
"@

# Save the text content to the new text file
$textContent | Out-File -FilePath $newFilePath2


# Copy 'lambda' and 'skill-package' folders
Move-Item -Path $newFilePath2 -Destination $rootDirectory -Force


################################################################################################################
################################################################################################################

# Pause before commiting new changes
Write-Host "Please wait..."
Start-Sleep -Seconds 5
Write-Host "Resuming script execution..."

################################################################################################################
################################################################################################################

# Initialize and configure git in the destination directory
Set-Location $destination

git init
git config --global --add safe.directory $destination
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

# If there are any conflicts, you need to resolve them manually

# After resolving conflicts, commit the changes
git commit -am "Resolved merge conflicts"

# Push changes
git push origin dev

# Switch to 'master' branch
git checkout master

# Merge 'dev' into 'master'
git merge dev

# Push changes to the remote 'master' branch
git push origin master




################################################################################################################
################################################################################################################


# Create a WScript Shell to create the shortcut
$WshShell = New-Object -ComObject WScript.Shell

# Set the path to the shortcut
$Shortcut = $WshShell.CreateShortcut("$rootDirectory\intent-addition.lnk")

# Set the target path for the shortcut
$Shortcut.TargetPath = "$destination\skill-package\interactionModels\custom\intent-additon.ps1"

# Set the window style
$Shortcut.WindowStyle = 1

# Set hotkey
$Shortcut.Hotkey = "CTRL+SHIFT+F"

# Set the description of the shortcut
$Shortcut.Description = "Shortcut for intent-addition.ps1"

# Save the shortcut
$Shortcut.Save()
