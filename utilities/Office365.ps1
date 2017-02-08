Function Connect-Office365_PSSession {
<#
	.SYNOPSIS
		Connect to Office 365 Cloud Services into active PowerShell shell
	
	.PARAMETER Office365_URL
		URL to Office 365 Cloud Services for PowerShell
	
	.PARAMETER Office365_Credentials
		Capture administrative credential for future connections
	
#>
	[CmdletBinding()]
	param
	(
		[string]$Office365_URL = "https://ps.outlook.com/powershell",
			$Office365_Credentials
	)
	
	#Imports the installed Azure Active Directory module.
	Import-Module MSOnline
	
	#Capture administrative credential for future connections.
	$Office365_Credentials = Get-Credential -Message "Enter your Office 365 admin credentials"
	
	#Establishes Online Services connection to Office 365 Management Layer.
	Connect-MsolService -Credential $Office365_Credentials
	
	#Creates an Exchange Online session using defined credential.
	$EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $Office365_URL -Credential $Office365_Credentials -Authentication Basic -AllowRedirection -Name "Exchange Online"
	
	#This imports the Office 365 session into your active Shell.
	Import-PSSession $EXOSession
}

Function Disconnect-Office365_PSSession {
<#
	.SYNOPSIS
		Disconnect PowerShell session to Office 365 Cloud Services
	
	.PARAMETER PSSession_Name
		Default name is "Exchange Online"

#>
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$PSSession_Name
	)
	
	Remove-PSSession -Name $PSSession_Name
}
