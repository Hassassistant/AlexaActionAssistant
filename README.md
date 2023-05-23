# AlexaActionAssistant

☕ Found my content helpful?<br>
All funds will go towards improving and developing future content.

[Buy me a coffee!](https://www.buymeacoffee.com/hassassistant)


## Description

**AlexaActionAssistant** simplifies and automates the setup of Alexa Skills for Home Assistant, allowing for easy creation of actionable notifications. It builds upon the [alexa-actions](https://github.com/keatontaylor/alexa-actions) project, providing additional features such as automatic skill creation and configuration generation using PowerShell scripts. 

## Example Use Cases

**Morning Routine** <br><br>
Alexa: "Good morning! Would you like me to start your morning routine?"
  
You: "Yes"
  
Alexa: "Starting morning routine: turning on kitchen lights, brewing coffee, and playing the news."<br><br>

**Evening Lights**<br><br>
Alexa: "It's getting dark outside. Would you like me to turn on the living room lights?"
  
You: "Yes"
  
Alexa: "Turning on living room lights."<br><br>

**Movie Mode**<br><br>
Alexa: "Are you ready for movie night? Shall I set the living room lights to movie mode?"
  
You: "Yes"
  
Alexa: "Setting living room lights to movie mode."<br><br>

**Radio Station**<br><br>
Alexa: "What radio station would you like to listen to?"

You: "Planet Rock"

Alexa: "Tuning in to Planet Rock."<br><br>

**Temperature Adjustment**<br><br>
Alexa: "The temperature in the living room is 23°C. Would you like me to adjust the thermostat?"
  
You: "Lower it by two degrees."
  
Alexa: "Setting thermostat to 21°C."<br><br>

**Bedtime**<br><br>
Alexa: "It's getting late. Shall I prepare the house for bedtime?"

You: "Yes"

Alexa: "Locking doors, turning off lights, and setting alarm."<br><br>

Remember, these are just examples. With **AlexaActionAssistant**, you can tailor your responses to fit your personal preferences and automate any routine within your smart home setup.



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
