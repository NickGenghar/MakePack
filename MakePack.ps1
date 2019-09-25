Clear-Host
Write-Host "Welcome to MakePack! A PowerShell Script powered Minecraft Pack Builder."
Write-Host "Start building your Minecraft addons or resource packs instantly with this quick tool."
Pause

#We make an indefinite loop to give the user an option to go to other options.
#Because of this, we have to have a loop break somewhere in the block.
#Luckily we handles that by exiting the program. We have everything in this loop block.
while ($true) {
    Clear-Host

    #Prompts the user with options
    Write-Host "Select task you want this script to do:"
    Write-Host "[C] Create a Minecraft pack project"
    Write-Host "[X] Export a Minecraft pack project"
    Write-Host "[D] Deploy a Minecraft pack project"
    Write-Host "[E] Exit"
    #Get user input, assign to a variable.
    #We will be using this variable to go to different options.
    $Options = Read-Host

    #Project creating
    if ($Options -match 'c' -or $Options -match 'C') {
        #Checks if template exist
        if(Get-Content -Path "$PSScriptRoot\template\manifest.json") {

            #Generates UUID for the pack
            $NewUUID1 = New-Guid
            $NewUUID2 = New-Guid

            #Get pack data
            $PackDir = Read-Host "Pack directory (Required, excludes final backward slash, relative to script's directory)"
            $PackName = Read-Host 'Pack name'
            $PackDesc = Read-Host 'Pack description'
            Write-Host ""
            Write-Host "Pack type (Default: Resource):"
            Write-Host "[B] Behavior"
            Write-Host "[R] Resource"
            $PackType = Read-Host
            if($PackType -match 'b' -or $PackType -match 'B') {
                $PackTyper = 'data'
            } else {
                $PackTyper = 'resources'
            }

            #Create the pack manifest from temmplate
            New-Item -Path "$PackDir\manifest.json" -Force
            Copy-Item -Path "$PSScriptRoot\template\manifest.json" -Destination "$PackDir\manifest.json" -Recurse -Force

            #Starts mapping the values to manifest
            (Get-Content -Path "$PackDir\manifest.json") | ForEach-Object {$_.Replace('UUID1', $NewUUID1).Replace('UUID2', $NewUUID2).Replace('NAME', $PackName).Replace('DESCRIPTION', $PackDesc).Replace('TYPE', $PackTyper)} | Set-Content -Path "$PackDir\manifest.json"

            $Callback = "Manifest have been successfully build."
        } else {
            #If we don't have the manifest template, we give an error message callback to the user.
            $Callback = "Pack manifest template is missing. Script cannot proceed if template does not exist."
        }
    }

    #Pack exporting
    elseif($Options -match 'x' -or $Options -match 'X') {
        $Source = Read-Host 'Pack location (Directory, excludes final backward slash)'
        $Pack = Read-Host 'Pack name literal (File name excludes extension)'
        $Destination = Read-Host 'Pack destination (Directory, excludes final backward slash)'

        #Test for empty destination
        try{
            if(!(Test-Path -Path "$Destination")) {
                New-Item -Path "$Destination" -ItemType Directory
            }
        } catch {
            $Destination = $PSScriptRoot
        }

        Compress-Archive -Path "$Source\*" -CompressionLevel Optimal -DestinationPath "$Destination\$Pack.zip"
        Rename-Item -Path "$Destination\$Pack.zip" -NewName "$Pack.mcpack"

        #Callbacks as a process indicator.
        #Useful for giving the user feedback on the completed task.
        $Callback = "Pack have been successfully created."
    }

    #Project deploying
    elseif($Options -match 'd' -or $Options -match 'D') {
        #Acquire current user's Minecraft Bedrock Edition (Windows 10) directory
        $MinecraftDir = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\"

        if(!(Get-ChildItem $MinecraftDir)) {
            return $Callback = "Minecraft directory doesn't exist. Please install Minecraft from the Windows Store to proceed."
        }

        $DeployPack = Read-Host 'Choose target pack directory'

        Write-Host ''
        Write-Host "Pack type? (Default: Resource)"
        Write-Host "[B] Behavior"
        Write-Host "[R] Resource"
        $DeployType = Read-Host
        
        if($DeployType -match 'b' -or $DeployType -match 'B') {
            $PackFolder = 'behavior_packs\'
        } else {
            $PackFolder = 'resource_packs\'
        }

        Write-Host ''
        Write-Host "Pack mode? (Default: Developement)"
        Write-Host "[D] Developement"
        Write-Host "[R] Release"
        $DeployMode = Read-Host

        if($DeployMode -match 'r' -or $DeployMode -match 'R') {
            $PackDevelopement = ''
        } else {
            $PackDevelopement = 'developement_'
        }

        #Test for directory existence
        if(!(Test-Path -Path "$MinecraftDir$PackDevelopement$PackFolder$DeployPack\")) {
            #Copies the pack to the directory if it doesn't exist in Minecraft folder
            Copy-Item -Path "$DeployPack" -Destination "$MinecraftDir$PackDevelopement$PackFolder$DeployPack\" -Recurse -Force

            #Finalized with a success callback
            $Callback = "Pack have been successfully deployed."
        } else {
            #Prompts user to either replace the pack in the directory. Works best if user choose to replace.
            Write-Host ''
            Write-Host "Pack folder exist in target location. Replace?"
            Write-Host "[Y] Yes"
            Write-Host "[N] No"
            $DeployReplace = Read-Host
            if($DeployReplace -match 'y' -or $DeployReplace -match 'Y') {
                #Removes the folder in Minecraft directory to ensure perfect pack updating.
                Remove-Item -Path "$MinecraftDir$PackDevelopement$PackFolder$DeployPack\" -Recurse -Force
                return Copy-Item -Path "$DeployPack" -Destination "$MinecraftDir$PackDevelopement$PackFolder$DeployPack\" -Recurse -Force
            } else {
                #Returns an error callback if user choose not to replace it.
                return $Callback = "Pack failed to deployed. Pack folder already exist in target directory."
            }
        }
    }

    #Because this while loop is indefinite, we break it by exiting the script by invoking the 'Exit' command
    elseif($Options -match 'e' -or $Options -match 'E') {
        #Clears the console for a nice clean exit
        Clear-Host
        Exit
    }

    #Once all the task completed, we give a final request to check whether the user wants to continue using this script.
    Write-Output $Callback,"Would you like to do more?","[Y] Yes","[N] No"
    $Options = Read-Host
    if($Options -notmatch 'y' -or $Options -notmatch 'Y') {
        #Invoke 'Exit' command so that the script exits after task completion instead of exit option.
        Clear-Host
        Exit
    }
}