Clear-Host
Write-Host "Welcome to MakePack! A PowerShell Script powered Minecraft Pack Builder."
Write-Host "Start building your Minecraft addons or resource packs instantly with this quick tool."
Pause

#We make an indefinite loop to give the user an option to go to other options.
#Because of this, we have to have a loop break somewhere in the block.
#Luckily we handles that by exiting the program. We have everything in this loop block.
while ($true) {
    #Starts the task with a clean console
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

    switch($Options) {
        #Project creating
        'c' {}
        'C' {
            #Get pack data
            $PackDir = Read-Host "Pack directory (Required, excludes final backward slash, relative to script's directory)"
            $PackName = Read-Host 'Pack name'
            $PackDesc = Read-Host 'Pack description'
            $PackVer = Read-Host 'Pack version (Default: 1.0.0)'
            $PackMin = Read-Host 'Pack minimum engine version (Minimum: 1.13.0)'

            #Defaults pack version and min engine version if no value inputted to avoid nonsense...
            #Also converts the inputted value to array like text in manifest.json
            if(!$PackVer) {$PackVer = "1.0.0"}
            $PackVer = $PackVer.Split(".") -join ","
            if(!$PackMin) {$PackMin = "1.13.0"}
            $PackMin = $PackMin.Split(".") -join ","

            #Prompts user for pack type
            Write-Host ""
            Write-Host "Pack type (Default: Resource):"
            Write-Host "[B] Behavior"
            Write-Host "[R] Resource"

            #Defaults to resouces if no value inputted, also to avoid nonsense...
            $PackType = Read-Host
            if($PackType -match 'b' -or $PackType -match 'B') {
                $PackTyper = 'data'
            } else {
                $PackTyper = 'resources'
            }

            #Warns user if directory not specified, then creates the pack in root directory of MakePack
            if(!$PackDir) {
                Write-Host "Warning! Pack directory unspecified. Creating manifest in root directory instead."
                $PackDir = $PSScriptRoot;
            }
            
            #Generates UUID for the pack
            $NewUUID1 = New-Guid
            $NewUUID2 = New-Guid

            #Test if directory exist
            #If exist, prompt user to overwrite the manifest
            #Option defaults to abort pack creation
            #Proceed to manifest creation if directory doesn't exist...
            if(Test-Path -Path "$PackDir\manifest.json") {
                Write-Host "Warning! Directory already have manifest file. Do you want to overwrite the manifest?"
                Write-Host "[Y] Yes"
                Write-Host "[N] No"
                $Overwrite = Read-Host
                if($Overwrite -match 'Y' -or $Overwrite -match 'y') {
                    Remove-Item -Path "$PackDir\manifest.json" -Recurse -Force
                    New-Item -Path "$PackDir\manifest.json" -Force
                    Set-Content -Path "$PackDir\manifest.json" -Value "{`n`t`"format_version`": 2, `n`t`t`"header`": {`n`t`t`"description`": `"$PackDesc`",`n`t`t`"name`": `"$PackName`",`n`t`t`"uuid`": `"$NewUUID1`",`n`t`t`"version`": [$PackVer],`n`t`t`"min_engine_version`": [$PackMin]`n`t},`n`t`"modules`": [`n`t`t{`n`t`t`t`"description`": `"`",`n`t`t`t`"type`": `"$PackTyper`",`n`t`t`t`"uuid`": `"$NewUUID2`",`n`t`t`t`"version`": [$PackVer]`n`t`t}`n`t]`n}"
                    $Callback = "Manifest have been successfully overwritten."
                } else {
                    $Callback = "Failed to create manifest. Manifest already exist in target directory."
                }
            } else {
                New-Item -Path "$PackDir\manifest.json" -Force
                Set-Content -Path "$PackDir\manifest.json" -Value "{`n`t`"format_version`": 2, `n`t`t`"header`": {`n`t`t`"description`": `"$PackDesc`",`n`t`t`"name`": `"$PackName`",`n`t`t`"uuid`": `"$NewUUID1`",`n`t`t`"version`": [$PackVer],`n`t`t`"min_engine_version`": [$PackMin]`n`t},`n`t`"modules`": [`n`t`t{`n`t`t`t`"description`": `"`",`n`t`t`t`"type`": `"$PackTyper`",`n`t`t`t`"uuid`": `"$NewUUID2`",`n`t`t`t`"version`": [$PackVer]`n`t`t}`n`t]`n}"
                $Callback = "Manifest have been successfully created."
            }
            break
        }

        #Project exporting
        'x' {}
        'X' {
            #Get the required data before proceeding
            $Source = Read-Host 'Pack location (Directory, excludes final backward slash)'
            $Pack = Read-Host 'Pack name literal (File name excludes extension)'
            $Destination = Read-Host 'Pack destination (Directory, excludes final backward slash)'

            #Test for pack source. Break early with an error message if not supplied.
            if(!$Source) {
                $Callback = "Error! Pack location not specified."
                break
            }
            #test for pack name and destination. Use default configuration if no data supplied
            if(!$Pack) {
                Write-Host "Warning! Pack name not specified. Using generic `"Pack`" name  as a placeholder."
                $Pack = "Pack"
            }
            if(!$Destination) {
                Write-Host "Warning! Destination not specified. Exporting file to root directory instead."
                $Destination = $PSScriptRoot
            } elseif(!(Test-Path -Path $Destination)) {
                New-Item -Path "$Destination" -ItemType Directory
            }

            if(Test-Path -Path "$Destination\$Pack.mcpack") {
                Write-Host "Package exist in target directory. Replace?"
                Write-Host "[Y] Yes"
                Write-Host "[N] No"
                $ReplacePack = Read-Host
                if($ReplacePack -match 'y' -or $ReplacePack -match 'Y') {
                    Remove-Item -Path "$Destination\$Pack.mcpack" -Recurse -Force
                    Compress-Archive -Path "$Source\*" -CompressionLevel Optimal -DestinationPath "$Destination\$Pack.zip"
                    Rename-Item -Path "$Destination\$Pack.zip" -NewName "$Pack.mcpack"
                } else {
                    $Callback = "Failed to create pack: Pack already exist."
                    break
                }
            } else {
                Compress-Archive -Path "$Source\*" -CompressionLevel Optimal -DestinationPath "$Destination\$Pack.zip"
                Rename-Item -Path "$Destination\$Pack.zip" -NewName "$Pack.mcpack"
            }

            #Callbacks as a process indicator.
            #Useful for giving the user feedback on the completed task.
            $Callback = "Pack have been successfully created."
            break
        }

        #Project deploying
        'd' {}
        'D' {
            #Acquire current user's Minecraft Bedrock Edition (Windows 10) directory.
            #Break the operation if directory doesn't exist (aka user doesn't have Minecraft for Windows 10 or running on different version of Windows).
            $MinecraftDir = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\"
            if(!(Get-ChildItem $MinecraftDir)) {
                $Callback = "Minecraft directory doesn't exist. Please install Minecraft from the Windows Store to proceed."
                break
            }

            #Get target pack folder or file.
            #Break the operation if pack file or folder not specified.
            $DeployPack = Read-Host 'Choose target pack file or folder. Folder must be within this root directory.'
            if(!$DeployPack) {
                $Callback = "Error! Pack file or folder Not specified."
                break
            }

            #Get pack type. Default to resource_packs directory
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

            #Get deployment mode. Default to development directory.
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
            if(Test-Path -Path "$MinecraftDir$PackDevelopement$PackFolder$DeployPack\") {
                #If exist, prompts user to either replace the pack in the directory.
                #Break if user input response other than Y (yes).
                Write-Host ''
                Write-Host "Pack folder exist in target location. Replace?"
                Write-Host "[Y] Yes"
                Write-Host "[N] No"
                $DeployReplace = Read-Host
                if($DeployReplace -match 'y' -or $DeployReplace -match 'Y') {
                    #Removes the folder in Minecraft directory to ensure perfect pack updating.
                    Remove-Item -Path "$MinecraftDir$PackDevelopement$PackFolder$DeployPack\" -Recurse -Force
                    Copy-Item -Path "$DeployPack" -Destination "$MinecraftDir$PackDevelopement$PackFolder$DeployPack\" -Recurse -Force
                    $Callback = "Pack have been successfully updated."
                    break
                } else {
                    #Returns an error callback if user choose not to replace it.
                    $Callback = "Pack failed to deployed. Pack folder already exist in target directory."
                    break
                }
            } else {
                #Copies the pack to the directory if it doesn't exist in Minecraft folder
                Copy-Item -Path "$DeployPack" -Destination "$MinecraftDir$PackDevelopement$PackFolder$DeployPack\" -Recurse -Force

                #Finalized with a success callback
                $Callback = "Pack have been successfully deployed."
            }
            break
        }

        #Because this while loop is indefinite, we break it by exiting the script by invoking the 'Exit' command.
        #No need for a break here... The program already close itself.
        'e' {}
        'E' {
            #Clears the console for a nice clean exit
            Clear-Host
            Exit
        }

        #No input provided? Set a callback and proceed with the final request section after this switch block.
        default { $Callback = "Provided option is empty or invalid." }
    }

    #Once all the task completed, we give a final request to check whether the user wants to continue using this script.
    #If answer doesn't match Y (yes), Exit command is skipped, allowing the script to loop again.
    Write-Output $Callback,"Would you like to do more?","[Y] Yes","[N] No"
    $Options = Read-Host
    if($Options -notmatch 'y' -or $Options -notmatch 'Y') {
        #Invoke 'Exit' command so that the script exits after task completion instead of exit option.
        Clear-Host
        Exit
    }
}