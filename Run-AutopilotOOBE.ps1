<#
    .SYNOPSIS
    Installs the required modules and launches the AutopilotOOBE module with the parameters defined in this script

    .DESCRIPTION
    This is a wrapper around the AutopilotOOBE module that allows specifying the parameters used to configure it
    without having to dump a json to $env:ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json that would get left
    on the PC after provisioning.

    Info about the AutopilotOOBE module can be found here: https://autopilotoobe.osdeploy.com/parameters/reference
  
    .INPUTS
    None

    .OUTPUTS
    .None

    .EXAMPLE
    The below URL will launch this script on the PC without having to do anything else. It loads the raw github
    of this script from: https://github.com/AU-Mark/Autopilot/blob/main/Run-AutopilotOOBE.ps1

    irm https://tinyurl.com/AU-Autopilot | iex

    .NOTES
    Version:        1.0
    Author:         Mark Newton
    Creation Date:  07/02/2024
    Purpose/Change: Initial script development
    
    #>


##############################################################################################################
#                                                Functions                                                   #
##############################################################################################################

function Write-Color {
    <#
    .SYNOPSIS
    Write-Color is a wrapper around Write-Host delivering a lot of additional features for easier color options.

    .DESCRIPTION
    Write-Color is a wrapper around Write-Host delivering a lot of additional features for easier color options.

    It provides:
    - Easy manipulation of colors,
    - Logging output to file (log)
    - Nice formatting options out of the box.
    - Ability to use aliases for parameters

    .PARAMETER Text
    Text to display on screen and write to log file if specified.
    Accepts an array of strings.

    .PARAMETER Color
    Color of the text. Accepts an array of colors. If more than one color is specified it will loop through colors for each string.
    If there are more strings than colors it will start from the beginning.
    Available colors are: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, DarkBlue, Green, Cyan, Red, Magenta, Yellow, White

    .PARAMETER BackGroundColor
    Color of the background. Accepts an array of colors. If more than one color is specified it will loop through colors for each string.
    If there are more strings than colors it will start from the beginning.
    Available colors are: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, DarkBlue, Green, Cyan, Red, Magenta, Yellow, White

    .PARAMETER Center
    Calculates the window width and inserts spaces to make the text center according to the present width of the powershell window. Default is false.

    .PARAMETER StartTab
    Number of tabs to add before text. Default is 0.

    .PARAMETER LinesBefore
    Number of empty lines before text. Default is 0.

    .PARAMETER LinesAfter
    Number of empty lines after text. Default is 0.

    .PARAMETER StartSpaces
    Number of spaces to add before text. Default is 0.

    .PARAMETER LogFile
    Path to log file. If not specified no log file will be created.

    .PARAMETER DateTimeFormat
    Custom date and time format string. Default is yyyy-MM-dd HH:mm:ss

    .PARAMETER LogTime
    If set to $true it will add time to log file. Default is $true.

    .PARAMETER LogRetry
    Number of retries to write to log file, in case it can't write to it for some reason, before skipping. Default is 2.

    .PARAMETER Encoding
    Encoding of the log file. Default is Unicode.

    .PARAMETER ShowTime
    Switch to add time to console output. Default is not set.

    .PARAMETER NoNewLine
    Switch to not add new line at the end of the output. Default is not set.

    .PARAMETER NoConsoleOutput
    Switch to not output to console. Default all output goes to console.

    .EXAMPLE
    Write-Color -Text "Red ", "Green ", "Yellow " -Color Red,Green,Yellow

    .EXAMPLE
    Write-Color -Text "This is text in Green ",
                      "followed by red ",
                      "and then we have Magenta... ",
                      "isn't it fun? ",
                      "Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan

    .EXAMPLE
    Write-Color -Text "This is text in Green ",
                      "followed by red ",
                      "and then we have Magenta... ",
                      "isn't it fun? ",
                      "Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan -StartTab 3 -LinesBefore 1 -LinesAfter 1

    .EXAMPLE
    Write-Color "1. ", "Option 1" -Color Yellow, Green
    Write-Color "2. ", "Option 2" -Color Yellow, Green
    Write-Color "3. ", "Option 3" -Color Yellow, Green
    Write-Color "4. ", "Option 4" -Color Yellow, Green
    Write-Color "9. ", "Press 9 to exit" -Color Yellow, Gray -LinesBefore 1

    .EXAMPLE
    Write-Color -LinesBefore 2 -Text "This little ","message is ", "written to log ", "file as well." `
                -Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt" -TimeFormat "yyyy-MM-dd HH:mm:ss"
    Write-Color -Text "This can get ","handy if ", "want to display things, and log actions to file ", "at the same time." `
                -Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt"

    .EXAMPLE
    Write-Color -T "My text", " is ", "all colorful" -C Yellow, Red, Green -B Green, Green, Yellow
    Write-Color -t "my text" -c yellow -b green
    Write-Color -text "my text" -c red

    .EXAMPLE
    Write-Color -Text "Testuję czy się ładnie zapisze, czy będą problemy" -Encoding unicode -LogFile 'C:\temp\testinggg.txt' -Color Red -NoConsoleOutput

    .NOTES
    Understanding Custom date and time format strings: https://learn.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
    Project support: https://github.com/EvotecIT/PSWriteColor
    Original idea: Josh (https://stackoverflow.com/users/81769/josh)

    #>
    [Alias('Write-Colour')]
    [CmdletBinding()]
    param(
        [Alias('T')] [String[]]$Text,
        [Alias('C','ForegroundColor','FGC')] [ConsoleColor[]]$Color = [ConsoleColor]::White,
        [Alias('B','BGC')] [ConsoleColor[]]$BackGroundColor = $null,
        [bool]$Center = $False,
        [Alias('Indent')] [int]$StartTab = 0,
        [int]$LinesBefore = 0,
        [int]$LinesAfter = 0,
        [int]$StartSpaces = 0,
        [Alias('L')] [string]$LogFile = '',
        [Alias('DateFormat','TimeFormat')] [string]$DateTimeFormat = 'yyyy-MM-dd HH:mm:ss',
        [Alias('LogTimeStamp')] [bool]$LogTime = $true,
        [int]$LogRetry = 2,
        [ValidateSet('unknown','string','unicode','bigendianunicode','utf8','utf7','utf32','ascii','default','oem')] [string]$Encoding = 'Unicode',
        [switch]$ShowTime,
        [switch]$NoNewLine,
        [Alias('HideConsole')] [switch]$NoConsoleOutput
    )
    if (-not $NoConsoleOutput) {
        $DefaultColor = $Color[0]
        if ($null -ne $BackGroundColor -and $BackGroundColor.Count -ne $Color.Count) {
            Write-Error "Colors, BackGroundColors parameters count doesn't match. Terminated."
            return
        }
        if ($LinesBefore -ne 0) {
            for ($i = 0; $i -lt $LinesBefore; $i++) {
                Write-Host -Object "`n" -NoNewline
            }
        } # Add empty line before
        if ($Center) {
            $MessageLength = 0
            foreach ($Value in $Text) {
                $MessageLength += $Value.Length
            }
            Write-Host ("{0}" -f (' ' * ([math]::Max(0,$Host.UI.RawUI.BufferSize.Width / 2) - [math]::Floor($MessageLength / 2)))) -NoNewline
        } # Center the line horizontally according to the powershell window size
        if ($StartTab -ne 0) {
            for ($i = 0; $i -lt $StartTab; $i++) {
                Write-Host -Object "`t" -NoNewline
            }
        } # Add TABS before text

        if ($StartSpaces -ne 0) {
            for ($i = 0; $i -lt $StartSpaces; $i++) {
                Write-Host -Object ' ' -NoNewline
            }
        } # Add SPACES before text
        if ($ShowTime) {
            Write-Host -Object "[$([datetime]::Now.ToString($DateTimeFormat))] " -NoNewline -ForegroundColor DarkGray
        } # Add Time before output
        if ($Text.Count -ne 0) {
            if ($Color.Count -ge $Text.Count) {
                # the real deal coloring
                if ($null -eq $BackGroundColor) {
                    for ($i = 0; $i -lt $Text.Length; $i++) {
                        Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewline

                    }
                } else {
                    for ($i = 0; $i -lt $Text.Length; $i++) {
                        Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewline

                    }
                }
            } else {
                if ($null -eq $BackGroundColor) {
                    for ($i = 0; $i -lt $Color.Length; $i++) {
                        Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewline

                    }
                    for ($i = $Color.Length; $i -lt $Text.Length; $i++) {
                        Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -NoNewline

                    }
                }
                else {
                    for ($i = 0; $i -lt $Color.Length; $i++) {
                        Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewline

                    }
                    for ($i = $Color.Length; $i -lt $Text.Length; $i++) {
                        Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -BackgroundColor $BackGroundColor[0] -NoNewline

                    }
                }
            }
        }
        if ($NoNewLine -eq $true) {
            Write-Host -NoNewline
        }
        else {
            Write-Host
        } # Support for no new line
        if ($LinesAfter -ne 0) {
            for ($i = 0; $i -lt $LinesAfter; $i++) {
                Write-Host -Object "`n" -NoNewline
            }
        } # Add empty line after
    }
    if ($Text.Count -and $LogFile) {
        # Save to file
        $TextToFile = ""
        for ($i = 0; $i -lt $Text.Length; $i++) {
            $TextToFile += $Text[$i]
        }
        $Saved = $false
        $Retry = 0
        do {
            $Retry++
            try {
                if ($LogTime) {
                    "[$([datetime]::Now.ToString($DateTimeFormat))] $TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append -ErrorAction Stop -WhatIf:$false
                }
                else {
                    "$TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append -ErrorAction Stop -WhatIf:$false
                }
                $Saved = $true
            }
            catch {
                if ($Saved -eq $false -and $Retry -eq $LogRetry) {
                    Write-Warning "Write-Color - Couldn't write to log file $($_.Exception.Message). Tried ($Retry/$LogRetry))"
                }
                else {
                    Write-Warning "Write-Color - Couldn't write to log file $($_.Exception.Message). Retrying... ($Retry/$LogRetry)"
                }
            }
        } until ($Saved -eq $true -or $Retry -ge $LogRetry)
    }
}

##############################################################################################################
#                                                   Main                                                     #
##############################################################################################################
try {
    Clear-Host
    Write-Color -Text "__________________________________________________________________________________________" -Color White -BackgroundColor Black -Center $True
    Write-Color -Text "|                                                                                          |" -Color White -BackgroundColor Black -Center $True
    Write-Color -Text "|","                                            .-.                                           ","|" -Color White,DarkBlue,White -BackgroundColor Black,Black,Black -Center $True
    Write-Color -Text "|","                                            -#-              -.    -+                     ","|" -Color White,DarkBlue,White -BackgroundColor Black,Black,Black -Center $True
    Write-Color -Text "|","    ....           .       ...      ...     -#-  .          =#:..  .:      ...      ..    ","|" -Color White,DarkBlue,White -BackgroundColor Black,Black,Black -Center $True
    Write-Color -Text "|","   +===*#-  ",".:","     #*  *#++==*#:   +===**:  -#- .#*    -#- =*#+++. +#.  -*+==+*. .*+-=*.  ","|" -Color White,DarkBlue,Cyan,DarkBlue,White -BackgroundColor Black,Black,Black,Black,Black -Center $True
    Write-Color -Text "|","    .::.+#  ",".:","     #*  *#    .#+   .::..**  -#-  .#+  -#=   =#:    +#. =#:       :#+:     ","|" -Color White,DarkBlue,Cyan,DarkBlue,White -BackgroundColor Black,Black,Black,Black,Black -Center $True
    Write-Color -Text "|","  =#=--=##. ",".:","     #*  *#     #+  **---=##  -#-   .#+-#=    =#:    +#. **          :=**.  ","|" -Color White,DarkBlue,Cyan,DarkBlue,White -BackgroundColor Black,Black,Black,Black,Black -Center $True
    Write-Color -Text "|","  **.  .*#. ",".:.","   =#=  *#     #+ :#=   :##  -#-    :##=     -#-    +#. :#*:  .:  ::  .#=  ","|" -Color White,DarkBlue,Cyan,DarkBlue,White -BackgroundColor Black,Black,Black,Black,Black -Center $True
    Write-Color -Text "|","   -+++--=      .==:   ==     =-  .=++=-==  :=:    .#=       -++=  -=    :=+++-. :=++=-   ","|" -Color White,DarkBlue,White -BackgroundColor Black,Black,Black -Center $True
    Write-Color -Text "|","                                                  .#+                                     ","|" -Color White,DarkBlue,White -BackgroundColor Black,Black,Black -Center $True
    Write-Color -Text "|","                                                  *+                                      ","|" -Color White,DarkBlue,White -BackgroundColor Black,Black,Black -Center $True
    Write-Color -Text "|__________________________________________________________________________________________|" -Color White -BackgroundColor Black -Center $True
    Write-Color -Text "Script: ","AutopilotOOBE Prep" -Color Yellow,White -Center $True -LinesBefore 1
    Write-Color -Text "Author: " ,"Mark Newton" -Color Yellow,White -Center $True -LinesAfter 1
    Write-Color -Text "Note: " ,"You can use Alt+Tab to switch to windows that get hidden behind OOBE" -Color Red,White -Center $True -LinesAfter 1

    Write-Color -Text "Preparing device for AutopilotOOBE" -Color White -ShowTime

    # Set execution policy to Unrestricted for this script to run. It will be reverted back to RemoteSigned when the script exits
    Set-ExecutionPolicy Unrestricted -Force

    # Set the PSGallery to trusted to automate installing modules
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

    if ((Get-PackageProvider).Name -notcontains 'NuGet') {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    }

    Write-Color -Text "Installing required PowerShell modules" -Color White -ShowTime
    Install-Module -Name 'Microsoft.Graph.Groups' -Force
    Install-Module -Name 'Microsoft.Graph.Identity.DirectoryManagement' -Force
    Install-Module -Name 'AutopilotOOBE' -Force
    Import-Module 'Microsoft.Graph.Groups'
    Import-Module 'Microsoft.Graph.Identity.DirectoryManagement'
    Import-Module 'AutopilotOOBE'

    # Parameters to run AutopilotOOBE GUI with pre-filled fields
    $Params = [ordered]@{
        Title = 'Aunalytics Autopilot Registration'
        AssignedUserExample = 'username@aunalytics.com'
        AddToGroup = 'AzPC - ENR - Enterprise'
        AddToGroupOptions = 'AzPC - ENR - Enterprise','AzPC - ENR - Kiosk','AzPC - ENR - Shared'
        GroupTag = 'Enterprise'
        GroupTagOptions = 'Enterprise','Kiosk','Shared'
        AssignedComputerNameExample = 'NB-W11P-####'
        PostAction = 'Restart'
        Assign = $true
        Run = 'WindowsSettings'
        Docs = 'https://autopilotoobe.osdeploy.com/'
    }

    Write-Color -Text "Starting AutopilotOOBE with configured parameters:" -Color White -ShowTime
    # Print the configured parameters to the screen
    ForEach ($Param in $Params.Keys) {
        If ($Params[$Param].Count -gt 1) {
            Write-Color -Text "$($Param): ","$($Params[$Param] -join ', ')" -Color Yellow,White -ShowTime
        } Else {
            Write-Color -Text "$($Param): ","$($Params[$Param])" -Color Yellow,White -ShowTime
        }
    }

    Write-Color -Text " "

    # Sleep for 1 second so the parameters can actually be seen
    Start-Sleep 1

    # Run the AutopilotOOBE module with the configured parameters
    AutopilotOOBE @Params
} catch {
    Write-Color -Text "Err Line: ","$($_.InvocationInfo.ScriptLineNumber)"," Err Name: ","$($_.Exception.GetType().FullName) "," Err Msg: ","$($_.Exception.Message)" -Color Red,Magenta,Red,Magenta,Red,Magenta -ShowTime
} finally {
    try {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted -ErrorAction SilentlyContinue | Out-Null
        Set-ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue | Out-Null
    } catch {
        # Do nothing
    }
}
