function Connect-EXOnline {
    $URL = "https://ps.outlook.com/powershell"
    $Credentials = Get-Credential -Message "Enter your Office 365 admin credentials"
    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $Credentials -Authentication Basic -AllowRedirection -Name "Exchange Online"
    Import-PSSession $EXOSession
}

function Disconnect-EXOnline {
    Remove-PSSession -Name "Exchange Online"
}
