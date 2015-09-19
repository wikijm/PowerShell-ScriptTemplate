#requires -version 2
<#
.SYNOPSIS
  <None>

.DESCRIPTION
  <None>

.INPUTS
  <None>

.OUTPUTS
  Create transcript log file similar to $ScriptDir\[SCRIPTNAME]_[YYYY_MM_DD]_[HHhMMmSSs].log
  Create a list of AD Objects, similar to $ScriptDir\[SCRIPTNAME]_FoundADObjects_[YYYY_MM_DD]_[HHhMMmSSs].csv
   
   
.NOTES
  Version:        0.1
  Author:         ALBERT Jean-Marc
  Creation Date:  DD/MM/YYYY (DD/MM/YYYY
  Purpose/Change: 1.0 - YYYY.MM.DD - ALBERT Jean-Marc - Initial script development
                    
                                                  
.SOURCES
  <None>
  
  
.EXAMPLE
  <None>

#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
Set-StrictMode -version Latest

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptFile = $MyInvocation.MyCommand.Definition
$launchDate = get-date -f "yyyy.MM.dd-HH:mm:ss"
$logDirectoryPath = $scriptPath + "\" + $launchDate
$buffer = "$scriptPath\bufferCommand.txt"
$fullScriptPath = (Resolve-Path -Path $buffer).Path

$loggingFunctions = "$scriptPath\logging\Logging.ps1"
$utilsFunctions = "$scriptPath\utilities\Utils.ps1"
$addsFunctions = "$scriptPath\utilities\ADDS.ps1"


#----------------------------------------------------------[Declarations]----------------------------------------------------------

$scriptName = [System.IO.Path]::GetFileName($scriptFile)
$scriptVersion = "0.1"

if(!(Test-Path $logDirectoryPath)) {
    New-Item $logDirectoryPath -type directory | Out-Null
}

$logFileName = "Log_" + $launchDate + ".log"
$logPathName = "$logDirectoryPath\$logFileName"

$global:streamWriter = New-Object System.IO.StreamWriter $logPathName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

. $loggingFunctions
. $utilsFunctions
. $
#----------------------------------------------------------[Execution]----------------------------------------------------------

Start-Log -scriptName $scriptName -scriptVersion $scriptVersion -streamWriter $global:streamWriter
cls
Write-Host "================================================================================================"

# Prerequisites
Test-InternetConnection

if($adminFlag -eq $false){
    Write-Host "You have to launch this script with " -nonewline; Write-Host "local Administrator rights!" -f Red    
    $scriptPath = Split-Path $MyInvocation.InvocationName    
    $RWMC = $scriptPath + "\$scriptName.ps1"
    $ArgumentList = 'Start-Process -FilePath powershell.exe -ArgumentList \"-ExecutionPolicy Bypass -File "{0}"\" -Verb Runas' -f $RWMC;
    Start-Process -FilePath powershell.exe -ArgumentList $ArgumentList -Wait -NoNewWindow;    
    Stop-Script
}

Write-Host "================================================================================================"

#Execute action with a progressbar
Write-Progress -Activity "HelloWorld!" -status "Running..." -id 1 
#Write-Host HelloWorld!

#Writing informations in the log file
Write-Progress -Activity "Write informations in the log file" -status "Running..." -id 1
End-Log -streamWriter $global:streamWriter
notepad $logPathName
cls