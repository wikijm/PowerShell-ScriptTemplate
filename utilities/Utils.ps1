function OnApplicationLoad {
	return $true #return true for success or false for failure
}
function script:OnApplicationExit {
	$script:ExitCode = 0 #Set the exit code for the Packager
}
function Show-MessageBox {
  <#
    .SYNOPSIS 
      Displays a MessageBox using Windows WinForms
	  
	.Description
	  	This function helps display a custom Message box with the options to set
	  	what Icons and buttons to use. By Default without using any of the optional
	  	parameters you will get a generic message box with the OK button.
	  
	.Parameter Msg
		Mandatory: This item is the message that will be displayed in the body
		of the message box form.
		Alias: M

	.Parameter Title
		Optional: This item is the message that will be displayed in the title
		field. By default this field is blank unless other text is specified.
		Alias: T

	.Parameter OkCancel
		Optional:This switch will display the Ok and Cancel buttons.
		Alias: OC

	.Parameter AbortRetryIgnore
		Optional:This switch will display the Abort Retry and Ignore buttons.
		Alias: ARI

	.Parameter YesNoCancel
		Optional: This switch will display the Yes No and Cancel buttons.
		Alias: YNC

	.Parameter YesNo
		Optional: This switch will display the Yes and No buttons.
		Alias: YN

	.Parameter RetryCancel
		Optional: This switch will display the Retry and Cancel buttons.
		Alias: RC

	.Parameter Critical
		Optional: This switch will display Windows Critical Icon.
		Alias: C

	.Parameter Question
		Optional: This switch will display Windows Question Icon.
		Alias: Q

	.Parameter Warning
		Optional: This switch will display Windows Warning Icon.
		Alias: W

	.Parameter Informational
		Optional: This switch will display Windows Informational Icon.
		Alias: I

	.Parameter TopMost
		Optional: This switch will make the form stay on top until the user answers it.
		Alias: TM	
		
	.Example
		Show-MessageBox -Msg "This is the default message box"
		
		This example creates a generic message box with no title and just the 
		OK button.
	
	.Example
		$A = Show-MessageBox -Msg "This is the default message box" -YN -Q
		
		if ($A -eq "YES") {
			..do something 
		} 
		else { 
		 ..do something else 
		} 

		This example creates a msgbox with the Yes and No button and the
		Question Icon. Once the message box is displayed it creates the A varible
		with the message box selection choosen.Once the message box is done you 
		can use an if statement to finish the script.
		
	.Notes
		Created By Zachary Shupp
		Email zach.shupp@hp.com		

		Version: 1.0
		Date: 9/23/2013
		Purpose/Change:	Initial function development

		Version 1.1
		Date: 12/13/2013
		Purpose/Change: Added Switches for the form Type and Icon to make it easier to use.

		Version 1.2
		Date: 3/4/2015
		Purpose/Change: Added Switches to make the message box the top most form.
				Corrected Examples
		
	.Link
		http://msdn.microsoft.com/en-us/library/system.windows.forms.messagebox.aspx
		
  #>
	Param (
	[Parameter(Mandatory=$True)][Alias('M')][String]$Msg,
	[Parameter(Mandatory=$False)][Alias('T')][String]$Title = "",
	[Parameter(Mandatory=$False)][Alias('OC')][Switch]$OkCancel,
	[Parameter(Mandatory=$False)][Alias('OCI')][Switch]$AbortRetryIgnore,
	[Parameter(Mandatory=$False)][Alias('YNC')][Switch]$YesNoCancel,
	[Parameter(Mandatory=$False)][Alias('YN')][Switch]$YesNo,
	[Parameter(Mandatory=$False)][Alias('RC')][Switch]$RetryCancel,
	[Parameter(Mandatory=$False)][Alias('C')][Switch]$Critical,
	[Parameter(Mandatory=$False)][Alias('Q')][Switch]$Question,
	[Parameter(Mandatory=$False)][Alias('W')][Switch]$Warning,
	[Parameter(Mandatory=$False)][Alias('I')][Switch]$Informational,
    [Parameter(Mandatory=$False)][Alias('TM')][Switch]$TopMost,
	[Parameter(Mandatory=$False)][Alias('AS')][Switch]$AutoSize)

	#Set Message Box Style
	IF($OkCancel){$Type = 1}
	Elseif($AbortRetryIgnore){$Type = 2}
	Elseif($YesNoCancel){$Type = 3}
	Elseif($YesNo){$Type = 4}
	Elseif($RetryCancel){$Type = 5}
	Else{$Type = 0}
	
	#Set Message box Icon
	If($Critical){$Icon = 16}
	ElseIf($Question){$Icon = 32}
	Elseif($Warning){$Icon = 48}
	Elseif($Informational){$Icon = 64}
	Else { $Icon = 0 }
	
	#Loads the WinForm Assembly, Out-Null hides the message while loading.
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	
	If ($TopMost) {
		#Creates a Form to use as a parent
		$FrmMain = New-Object 'System.Windows.Forms.Form'
		$FrmMain.TopMost = $true
		
		#Display the message with input
		$Answer = [System.Windows.Forms.MessageBox]::Show($FrmMain, $MSG, $TITLE, $Type, $Icon)
		
		#Dispose of parent form
		$FrmMain.Close()
		$FrmMain.Dispose()
	}
	Else {
		#Display the message with input
		$Answer = [System.Windows.Forms.MessageBox]::Show($MSG , $TITLE, $Type, $Icon)			
	}
	
	#Return Answer
	Return $Answer
}

function Test-RegistryValue {
  <#
    .SYNOPSIS
    Check specific values within a key.

    .DESCRIPTION
    Check specific values within a key, in the same way than Test-Path cmdlet for the key.

    .EXAMPLE
    Test-RegistryValue -Path 'HKLM:\SOFTWARE\TestSoftware' -Value 'Version'
    This will return 'True' or 'False'
#>
	param (
		[parameter(Mandatory=$true)]
 		[ValidateNotNullOrEmpty()]$Path,
		[parameter(Mandatory=$true)]
 		[ValidateNotNullOrEmpty()]$Value
	)

	try {
		Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
 		return $true
	}

	catch {
		return $false
	}
}

function Set-RegistryKey {
  [CmdletBinding()]
  param (
    [Object]$computername,
    [Object]$parentKey,
    [Object]$nameRegistryKey,
    [Object]$valueRegistryKey
  )
  try {    
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

function New-DirectoryIfNeeded {
	
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

function Select-FolderDialog
{
    [CmdletBinding()]
    param ([string]$InitialDirectory='MyComputer')
    Add-Type -AssemblyName System.Windows.Forms
    $openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $openFolderDialog.ShowNewFolderButton = $true
    $openFolderDialog.RootFolder = $InitialDirectory
    $openFolderDialog.ShowDialog()
    return $openFolderDialog.SelectedPath

	If (!$($openFolderDialog.SelectedPath)) {
	    Write-Error 'Canceled operation'
		[Windows.Forms.MessageBox]::Show('Script is not able to continue. Operation stopped.', 'Operation canceled', 0, [Windows.Forms.MessageBoxIcon]::Error)
		Stop-TranscriptOnLog
		Exit
	}
    Else {
        $SelectedFolder = $openFolderDialog.SelectedPath
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

#Hide the powershell console window without hiding the other child windows that it spawns. (I.E. hide the powershell window, but not the Out-Gridview window)
#https://community.spiceworks.com/topic/1710213-hide-a-powershell-console-window-when-running-a-script
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
function Show-PowershellConsole()
	{ $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10) }
function Hide-PowershellConsole()
	{ $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2) }

	.Parameter Question
		Optional: This switch will display Windows Question Icon.
		Alias: Q

	.Parameter Warning
		Optional: This switch will display Windows Warning Icon.
		Alias: W

	.Parameter Informational
		Optional: This switch will display Windows Informational Icon.
		Alias: I

	.Parameter TopMost
		Optional: This switch will make the form stay on top until the user answers it.
		Alias: TM	
		
	.Example
		Show-MessageBox -Msg "This is the default message box"
		
		This example creates a generic message box with no title and just the 
		OK button.
	
	.Example
		$A = Show-MessageBox -Msg "This is the default message box" -YN -Q
		
		if ($A -eq "YES") {
			..do something 
		} 
		else { 
		 ..do something else 
		} 

		This example creates a msgbox with the Yes and No button and the
		Question Icon. Once the message box is displayed it creates the A varible
		with the message box selection choosen.Once the message box is done you 
		can use an if statement to finish the script.
		
	.Notes
		Created By Zachary Shupp
		Email zach.shupp@hp.com		

		Version: 1.0
		Date: 9/23/2013
		Purpose/Change:	Initial function development

		Version 1.1
		Date: 12/13/2013
		Purpose/Change: Added Switches for the form Type and Icon to make it easier to use.

		Version 1.2
		Date: 3/4/2015
		Purpose/Change: Added Switches to make the message box the top most form.
				Corrected Examples
		
	.Link
		http://msdn.microsoft.com/en-us/library/system.windows.forms.messagebox.aspx
		
  #>
	Param (
	[Parameter(Mandatory=$True)][Alias('M')][String]$Msg,
	[Parameter(Mandatory=$False)][Alias('T')][String]$Title = "",
	[Parameter(Mandatory=$False)][Alias('OC')][Switch]$OkCancel,
	[Parameter(Mandatory=$False)][Alias('OCI')][Switch]$AbortRetryIgnore,
	[Parameter(Mandatory=$False)][Alias('YNC')][Switch]$YesNoCancel,
	[Parameter(Mandatory=$False)][Alias('YN')][Switch]$YesNo,
	[Parameter(Mandatory=$False)][Alias('RC')][Switch]$RetryCancel,
	[Parameter(Mandatory=$False)][Alias('C')][Switch]$Critical,
	[Parameter(Mandatory=$False)][Alias('Q')][Switch]$Question,
	[Parameter(Mandatory=$False)][Alias('W')][Switch]$Warning,
	[Parameter(Mandatory=$False)][Alias('I')][Switch]$Informational,
        [Parameter(Mandatory=$False)][Alias('TM')][Switch]$TopMost)
	[Parameter(Mandatory=$False)][Alias('AS')][Switch]$AutoSize)

	#Set Message Box Style
	IF($OkCancel){$Type = 1}
	Elseif($AbortRetryIgnore){$Type = 2}
	Elseif($YesNoCancel){$Type = 3}
	Elseif($YesNo){$Type = 4}
	Elseif($RetryCancel){$Type = 5}
	Else{$Type = 0}
	
	#Set Message box Icon
	If($Critical){$Icon = 16}
	ElseIf($Question){$Icon = 32}
	Elseif($Warning){$Icon = 48}
	Elseif($Informational){$Icon = 64}
	Else { $Icon = 0 }
	
	#Loads the WinForm Assembly, Out-Null hides the message while loading.
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	
	If ($TopMost) {
		#Creates a Form to use as a parent
		$FrmMain = New-Object 'System.Windows.Forms.Form'
		$FrmMain.TopMost = $true
		
		#Display the message with input
		$Answer = [System.Windows.Forms.MessageBox]::Show($FrmMain, $MSG, $TITLE, $Type, $Icon)
		
		#Dispose of parent form
		$FrmMain.Close()
		$FrmMain.Dispose()
	}
	Else {
		#Display the message with input
		$Answer = [System.Windows.Forms.MessageBox]::Show($MSG , $TITLE, $Type, $Icon)			
	}
	
	#Return Answer
	Return $Answer
}

function Test-RegistryValue {
  <#
    .SYNOPSIS
    Check specific values within a key.

    .DESCRIPTION
    Check specific values within a key, in the same way than Test-Path cmdlet for the key.

    .EXAMPLE
    Test-RegistryValue -Path 'HKLM:\SOFTWARE\TestSoftware' -Value 'Version'
    This will return 'True' or 'False'
#>
	param (
		[parameter(Mandatory=$true)]
 		[ValidateNotNullOrEmpty()]$Path,
		[parameter(Mandatory=$true)]
 		[ValidateNotNullOrEmpty()]$Value
	)

	try {
		Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
 		return $true
	}

	catch {
		return $false
	}
}

function Set-RegistryKey {
  [CmdletBinding()]
  param (
    [Object]$computername,
    [Object]$parentKey,
    [Object]$nameRegistryKey,
    [Object]$valueRegistryKey
  )
  try {    
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

function New-DirectoryIfNeeded {
	
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

#Hide the powershell console window without hiding the other child windows that it spawns. (I.E. hide the powershell window, but not the Out-Gridview window)
#https://community.spiceworks.com/topic/1710213-hide-a-powershell-console-window-when-running-a-script
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
function Show-PowershellConsole()
	{ $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10) }
function Hide-PowershellConsole()
	{ $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2) }
