# AlexaActionAssistant

## Description

**AlexaActionAssistant** simplifies and automates the setup of Alexa Skills for Home Assistant, allowing for easy creation of actionable notifications. It builds upon the [alexa-actions](https://github.com/keatontaylor/alexa-actions) project, providing additional features such as automatic skill creation and configuration generation using PowerShell scripts. 

## Prerequisites

Before starting with **AlexaActionAssistant**, ensure you have the following:

- An Alexa developer account. Register [here](https://developer.amazon.com/alexa/console/ask)
- A Windows PC with PowerShell enabled
- A long-lived access token from Home Assistant
- [Alexa Media Player](https://github.com/custom-components/alexa_media_player) custom component installed via HACS and set up properly
- A solution for accessing your Home Assistant from the Alexa Skill. There are different approaches to this, including the services of Nabucasa, Cloudflare, Duckdns, and Let’s Encrypt. For guidance, you may refer to this [video on setting up Cloudflare](https://youtu.be/Qsz1OjlGidU) with your local Home Assistant URL.

>Note: You don't need to register for an AWS developer account, as long as your skill doesn't exceed the limits of typical personal usage of AWS resources. More details can be found [here](https://developer.amazon.com/en-US/docs/alexa/hosted-skills/usage-limits.html).

## Setup & Usage

1. Download the [AlexaActionAssistant](https://github.com/Hassassistant/AlexaActionAssistant) repository and extract the ZIP file to your Windows PC.
2. In the root directory, you'll find two `.ps1` files. Right-click on each and select "Run with PowerShell".
   - Note: You may be prompted to change the execution policy to run these scripts. Type "A" for "Yes to All" and press enter. This allows the scripts to run as administrator.
3. Run the **`install-git-and-nodejs.ps1`** script. This will check if NodeJS and Git are installed, if not, they will be downloaded and installed.
4. Next, run the **`main.ps1`** script. This will guide you through the setup process, which includes:
   - Installing the ASK-CLI module
   - Creating the ASK-CLI configuration by authenticating your Amazon Alexa Developer account
   - Selecting the modeling stack for the skill **(choose 'Interaction Model')**
   - Choosing the programming language for your skill **(choose 'Python')**
   - Selecting the hosting environment for your Alexa skill **(choose 'Alexa-hosted skill')**
   - Picking a default region for your skill
   - Naming your skill
   - Providing your Home Assistant URL
   - Entering your Home Assistant long-lived access token
   - Confirming if your Home Assistant site has valid SSL certificates
   - Choosing the language for your skill
5. After the script execution, three new files will be generated:
   - **`Configuration.txt`** - Paste the YAML code from this file into your Home Assistant `configuration.yaml` file
   - **`scripts.txt`** - Paste the YAML code from this file into your Home Assistant `scripts.yaml` file
   - **`intent-addition.ps1`** - An optional script that allows you to include additional response options for your Alexa actionable notification setup.

To use the **`intent-addition.ps1`** script, right-click the file and select "Run with PowerShell". When prompted for your intent addition, type in the intent you want to include and press enter. You will then be asked if you want to add further intents. Type **'Y'** for yes or **'N'** for no and press enter. The script will push the changes to your skill.
