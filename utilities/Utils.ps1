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


1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
	
function ConvertFrom-IniFile {
<#
.Synopsis
Convert an INI file to an object
.Description
Use this command to convert a legacy INI file into a PowerShell custom object. Each INI section will become a property name. Then each section setting will become a nested object. Blank lines and comments starting with ; will be ignored. 
 
It is assumed that your ini file follows a typical layout like this:
 
;This is a sample ini
[General]
Action = Start
Directory = c:\work
ID = 123ABC
 
 ;this is another comment
[Application]
Name = foo.exe
Version = 1.0
 
[User]
Name = Jeff
Company = Globomantics
 
.Parameter Path
The path to the INI file.
.Example
PS C:\> $sample = ConvertFrom-IniFile c:\scripts\sample.ini
PS C:\> $sample
 
General                           Application                      User                            
-------                           -----------                      ----                            
@{Directory=c:\work; ID=123ABC... @{Version=1.0; Name=foo.exe}     @{Name=Jeff; Company=Globoman...
 
PS C:\> $sample.general.action
Start
 
In this example, a sample ini file is converted to an object with each section a separate property.
.Example
PS C:\> ConvertFrom-IniFile c:\windows\system.ini | export-clixml c:\work\system.ini
 
Convert the System.ini file and export results to an XML format.
.Notes
Last Updated: June 5, 2015
Version     : 1.0
 
Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/
 
  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
.Link
Get-Content
.Inputs
[string]
.Outputs
[pscustomobject]
#>
 
[cmdletbinding()]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter the path to an INI file",
ValueFromPipeline, ValueFromPipelineByPropertyName)]
[Alias("fullname","pspath")]
[ValidateScript({
if (Test-Path $_) {
   $True
}
else {
  Throw "Cannot validate path $_"
}
})]     
[string]$Path
)
 
 
Begin {
    Write-Verbose "Starting $($MyInvocation.Mycommand)"  
} #begin
 
Process {
    Write-Verbose "Getting content from $(Resolve-Path $path)"
    #strip out comments that start with ; and blank lines
    $all = Get-content -Path $path | Where {$_ -notmatch "^(\s+)?;|^\s*$"}
 
    $obj = New-Object -TypeName PSObject -Property @{}
    $hash = [ordered]@{}
 
    foreach ($line in $all) {
 
        Write-Verbose "Processing $line"
 
        if ($line -match "^\[.*\]$" -AND $hash.count -gt 0) {
            #has a hash count and is the next setting
            #add the section as a property
            write-Verbose "Creating section $section"
            Write-verbose ([pscustomobject]$hash | out-string)
            $obj | Add-Member -MemberType Noteproperty -Name $Section -Value $([pscustomobject]$Hash) -Force
            #reset hash
            Write-Verbose "Resetting hashtable"
            $hash=[ordered]@{}
            #define the next section
            $section = $line -replace "\[|\]",""
            Write-Verbose "Next section $section"
        }
        elseif ($line -match "^\[.*\]$") {
            #Get section name. This will only run for the first section heading
            $section = $line -replace "\[|\]",""
            Write-Verbose "New section $section"
        }
        elseif ($line -match "=") {
            #parse data
            $data = $line.split("=").trim()
            $hash.add($data[0],$data[1])    
        }
        else {
            #this should probably never happen
            Write-Warning "Unexpected line $line"
        }
 
    } #foreach
 
    #get last section
    If ($hash.count -gt 0) {
      Write-Verbose "Creating final section $section"
      Write-Verbose ([pscustomobject]$hash | Out-String)
     #add the section as a property
     $obj | Add-Member -MemberType Noteproperty -Name $Section -Value $([pscustomobject]$Hash) -Force
    }
 
    #write the result to the pipeline
    $obj
} #process
 
End {
    Write-Verbose "Ending $($MyInvocation.Mycommand)"
} #end
 
} #end function


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

function Select-FolderDialog($SelectFolderDialogMessage = 'Select a folder', $SelectFolderDialogPath = 0) {
	$SelectFolderDialogObject = New-Object -comObject Shell.Application
	$SelectFolderDialogFolder = $SelectFolderDialogObject.BrowseForFolder(0, $SelectFolderDialogMessage, 0, $SelectFolderDialogPath)
	If (!$SelectFolderDialogFolder.self.Path) {
		Write-Error 'Canceled operation'
		[Windows.Forms.MessageBox]::Show('Script is not able to continue. Operation stopped.', 'Operation canceled', 0, [Windows.Forms.MessageBoxIcon]::Error)
		Stop-TranscriptOnLog
		Exit
	}
	Else {
		$SelectedFolder = $SelectFolderDialogFolder.self.Path
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

Function Test-IsAdmin   
{  
<#     
.SYNOPSIS     
   Function used to detect if current user is an Administrator.  
     
.DESCRIPTION   
   Function used to detect if current user is an Administrator. Presents a menu if not an Administrator  
      
.NOTES     
    Name: Test-IsAdmin  
    Author: Boe Prox   
    DateCreated: 30April2011    
      
.EXAMPLE     
    $admincheck = Test-IsAdmin
    If ($admincheck -is [System.Management.Automation.PSCredential]) {
        Start-Process -FilePath PowerShell.exe -Credential $admincheck -ArgumentList $myinvocation.mycommand.definition
        Break
    }  
      
   
Description   
-----------       
Command will check the current user to see if an Administrator. If not, a menu is presented to the user to either  
continue as the current user context or enter alternate credentials to use. If alternate credentials are used, then  
the [System.Management.Automation.PSCredential] object is returned by the function.  
#>  
    [cmdletbinding()]  
    Param()  
      
    Write-Verbose "Checking to see if current user context is Administrator"  
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
    {  
        Write-Warning "You are not currently running this under an Administrator account! `nThere is potential that this command could fail if not running under an Administrator account."  
        Write-Verbose "Presenting option for user to pick whether to continue as current user or use alternate credentials"  
        #Determine Values for Choice  
        $choice = [System.Management.Automation.Host.ChoiceDescription[]] @("Use &Alternate Credentials","&Continue with current Credentials")  
  
        #Determine Default Selection  
        [int]$default = 0  
  
        #Present choice option to user  
        $userchoice = $host.ui.PromptforChoice("Warning","Please select to use Alternate Credentials or current credentials to run command",$choice,$default)  
  
        Write-Debug "Selection: $userchoice"  
  
        #Determine action to take  
        Switch ($Userchoice)  
        {  
            0  
            {  
                #Prompt for alternate credentials  
                Write-Verbose "Prompting for Alternate Credentials"  
                $Credential = Get-Credential  
                Write-Output $Credential      
            }  
            1  
            {  
                #Continue using current credentials  
                Write-Verbose "Using current credentials"  
                Write-Output "CurrentUser"  
            }  
        }          
          
    }  
    Else   
    {  
        Write-Verbose "Passed Administrator check"  
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

function MonitorJobs {
    #Sources: https://gallery.technet.microsoft.com/scriptcenter/Monitor-and-display-808ce573
    $JobsLaunch = Get-Date
    Do { 
        Clear-Host
        $myjobs = get-job  
        $myjobs | Out-File $env:TEMP\scrapjobs.txt 
        Get-Content $env:TEMP\scrapjobs.txt 
        $jobscount = $myjobs.Count 
        "$jobscount jobs running" 
        $done = 0 

        ForEach ($job in $myjobs) {
            $mystate = $job.State 
            If ($mystate -eq "Completed") {$done = $done + 1}
        } 
        "$done jobs done"
        " 
        " 
        $currentTime = Get-Date
        "Jobs started at $JobsLaunch" 
        "Current time $currentTime  " 
 
        $timecount = $JobsLaunch - $currentTime 
        $timecount = $timecount.TotalMinutes 
        "Elapsed time in minutes $timecount" 
        Start-Sleep 5 
        Clear-Host 
    }
    
    While ( $done -lt $jobscount ) 
        Get-Job | Remove-Job 
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
