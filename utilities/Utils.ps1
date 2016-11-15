function OnApplicationLoad {
	return $true #return true for success or false for failure
                           }
function script:OnApplicationExit {
	$script:ExitCode = 0 #Set the exit code for the Packager
                           }

function Set-RegistryKey {
    
  [CmdletBinding()]
  param
  (
    [Object]$computername,
    [Object]$parentKey,
    [Object]$nameRegistryKey,
    [Object]$valueRegistryKey
  )
try{    
        $remoteBaseKeyObject = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername)     
        $regKey = $remoteBaseKeyObject.OpenSubKey($parentKey,$true)
        $regKey.Setvalue("$nameRegistryKey", "$valueRegistryKey", [Microsoft.Win32.RegistryValueKind]::DWORD) 
        $remoteBaseKeyObject.close()
    }
    catch {
        $_.Exception
    }
}

function Search-LastDrive
{
  <#
    .SYNOPSIS
    Get last drive letter used on local computer.

    .DESCRIPTION
    Get last drive letter used on local computer and write result on $LastDriveLetter variable.

    .EXAMPLE
    Search-LastDrive
    $LastDriveLetter = "X"

    .NOTES
    Do $LastDriveLetter=$LastDriveLetter+":" to get "X:" format

  #>

    $UsedLetters = $(Get-PSDrive).name 
    for($j=90;$j -gt 67;$j--)
    {
        $LastDriveLetter=[char]$j
        if($UsedLetters -notcontains $LastDriveLetter)
        {
            return $LastDriveLetter
}
    }
}

function Disable-UAC {
    
  [CmdletBinding()]
  param
  (
    [Object]$computername
  )
$parentKey = 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System'
    $nameRegistryKey = 'LocalAccountTokenFilterPolicy'
    $valueRegistryKey = '1'

    $objReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computername)
    $objRegKey= $objReg.OpenSubKey($parentKey)
    $test = $objRegkey.GetValue($nameRegistryKey)
    if($test -eq $null){    
        Set-RegistryKey $computername $parentKey $nameRegistryKey $valueRegistryKey     
        Write-Verbose -Message 'Registry key setted, you have to reboot the remote computer'
        Stop-Script
    }
    else {
        if($test -ne 1){
            Set-RegistryKey $computername $parentKey $nameRegistryKey $valueRegistryKey     
            Write-Verbose -Message 'Registry key setted, you have to reboot the remote computer'
            Stop-Script
        }
    }
}

function script:CreateDirectoryIfNeeded {
	
  [CmdletBinding()]
  param
  (
    [string]
    $directory
  )
if (!(Test-Path -Path $directory -PathType 'Container')) {
		New-Item -ItemType directory -Path $directory > $null
	}
}

function Select-FileDialog
{
	[CmdletBinding()]
 param ([string]$Title, [string]$Filter = 'All files *.*|*.*')
	$null = Add-Type -AssemblyName System.Windows.Forms
	$fileDialogBox = New-Object Windows.Forms.OpenFileDialog
	$fileDialogBox.ShowHelp = $false
	$fileDialogBox.initialDirectory = $ScriptDir
	$fileDialogBox.filter = $Filter
	$fileDialogBox.Title = $Title
	$Show = $fileDialogBox.ShowDialog()
	
	If ($Show -eq 'OK')
	{
		Return $fileDialogBox.FileName
	}
	Else
	{
		Write-Error 'Canceled operation'
		[Windows.Forms.MessageBox]::Show('Script is not able to continue. Operation stopped.', 'Operation canceled', 0, [Windows.Forms.MessageBoxIcon]::Error)
		Stop-TranscriptOnLog
		Exit
	}
	
}

function Start-WmiRemoteProcess {
    [CmdletBinding()]
    Param(
        [string]$computername=$env:COMPUTERNAME,
        [string]$cmd=$(Throw 'You must enter the full path to the command which will create the process.'),
        [int]$timeout = 0
    )
 
    Write-Verbose -Message "Process to create on $computername is $cmd"
    [wmiclass]$wmi="\\$computername\root\cimv2:win32_process"
    # Exit if the object didn't get created
    if (!$wmi) {return}
 
    try{
    $remote=$wmi.Create($cmd)
    }
    catch{
        $_.Exception
    }
    $test =$remote.returnvalue
    if ($remote.returnvalue -eq 0) {
        Write-Verbose -Message ("Successfully launched $cmd on $computername with a process id of " + $remote.processid)
    } else {
        Write-Verbose -Message ("Failed to launch $cmd on $computername. ReturnValue is " + $remote.ReturnValue)
    }    
    return
}

function Stop-Script () {   
    Begin{
        Write-Log -streamWriter $global:streamWriter -infoToLog '--- Script terminating ---'
    }
    Process{        
        'Script terminating...' 
        Write-Verbose -Message '================================================================================================'
        End-Log -streamWriter $global:streamWriter       
        Exit
    }
}

function Stop-ScriptMessageBox () {
 # MessageBox who inform of the end of the process
   Add-Type -AssemblyName System.Windows.Forms
[Windows.Forms.MessageBox]::Show(
"Process done.
The log file will be opened when click on 'OK' button.
Please, check the log file for further informations.
" , 'End of process' , 0, [Windows.Forms.MessageBoxIcon]::Information)
}

function Test-InternetConnection {
    if(![Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet){
        Write-Verbose -Message 'The script need an Internet Connection to run'    
        Stop-Script
    }
}

function Test-LocalAdminRights {
    $myComputer = Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty name
    $myUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $amIAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent())
    $adminFlag = $amIAdmin.IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    if($adminFlag -eq $true){
        $adminMessage = ' with administrator rights on ' 
    }
    else {
        $adminMessage = ' without administrator rights on '
    }

    Write-Verbose -Message 'Script runs with user '
    Write-Verbose -Message $myUser.Name
    Write-Verbose -Message $adminMessage
    Write-Verbose -Message $myComputer
    Write-Verbose -Message ' computer'
    return $adminFlag
}

function Import-SomeModules {
    $PrerequisitesModules = @('DnsShell','ActiveDirectory')
    Foreach ($Module in $PrerequisitesModules){
      If (!(Get-module $Module )){
        Import-Module $Module
      }
    }
}

function Show-ProgressBar {
  <#
    .SYNOPSIS
    Sho progressbar on a specific action

    .DESCRIPTION
    Sho progressbar on a specific action, thanks to Write-Progress

    .PARAMETER Array
    Describe parameter -Array.

    .PARAMETER Item
    Describe parameter -Item.

    .EXAMPLE
      Get local services with progressbar
        $Services = get-service
        $Services | ForEach-Object {Show-ProgressBar $Services $_ ; write-host $_.name}

      Get content of SoftwareDistribution log with progressbar
        $Content = Get-Content "$env:windir\SoftwareDistribution\ReportingEvents.log"
        $Content | ForEach-Object {Show-ProgressBar $Content $_ ; write-host $_.name}
  #>


  param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][array]$Array,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] [Object]$Item
  )
  #Find Index of current item in Array
  $Index = [array]::IndexOf($array, $item)
  #Count items in array
  $ocount = $array.count
  
  Write-Progress -activity 'Counter' -Status $([string]$Index + ':'+[string]$ocount) -PercentComplete (($Index/$OCount)*100)
}
