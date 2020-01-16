# MakePack
##### A PowerShell script that helps you create, export and deploy Minecraft packs.

## Downloading And Installing:
1. Download zip method:
i. Click the "Clone or Download" option,
ii. Choose "Download as ZIP",
iii. Extract ZIP content,
iv. Copy/Move "MakePack.ps1" to the root directory of your working folder.

2. Git clone method:
i. Click the "Clone or Download option,
ii. Copy the URL,
iii. Open PowerShell and point to the root directory of your working directory,
v. Type "git clone (copied URL)",
vi. Copy/Move "MakePack.ps1" to the root directory of your working folder.

###### You have completed the installation setup.

## Usage
1. Using Visual Studio Code terminal:
i. Open Visual Studio Code,
ii. Click on "Terminal",
iii. Click "New terminal",
iv. Make sure the terminal created is PowerShell terminal, otherwise;
v. Type "powershell" in the terminal,
vi. Point to the root directory of your working folder,
vii. type ".\MakePack.ps1" to run the script.

2. Using the script directly:
i. Open the script... Just like that...

* **Note:**
For security reasons, PowerShell will not run scripts from untrusted source (like scripts downloaded from the internet). In order to use this script directly, please change the Execution Policy of PowerShell to Unrestricted.
Read more about it [here](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7).

## Documentation:
Options available:
1. Create Minecraft Pack Project
2. Export Minecraft Pack Project
3. Deploy Minecraft Pack Project
4. Exit

---
## Create
Starts a Minecraft pack project by selecting the "Create" option. After that, you will be prompted with a few tasks to complete the creation process.
The prompts are:
1. Pack directory
2. Pack name
3. Pack description
4. Pack type

- Pack directory; Required, Excludes last backward slash
- Pack name; Name of pack, will be written into the pack's manifest.
- Pack description; Description of pack, will be written into the pack's manifest.
- Pack type; Default is "R", Accepted value:
[B] Behavior
[R] Resource

---
# Export
Exports a Minecraft pack project to a MCPACK package.

The prompts are:

1. Pack location
2. Pack name literal
3. Pack destination

- Pack location: The root directory of the pack.
- Pack name literal: The name of the package file.
- Pack destination: The target directory of the export.

---
# Deploy
Select a pack and copy it to your Minecraft's resource packs or behavior packs folder directly.
###### Requires Minecraft for Windows 10 to work, not included...

The prompts are:

1. Choose target pack file or folder
2. Pack type
3. Pack mode

- Target pack file or folder:
    The desired pack for deployment.
- Pack type, defaults to "Resource". Available values:
    [B] Behavior
    [R] Resource
- Pack mode, defaults to "Development". Available values:
    [D] Development
    [R] Release

---
`More information coming soon`