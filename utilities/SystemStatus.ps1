#Function Ping-Host
Function Ping-Host
{
    #Parameter Definition
    Param
    (
    [Parameter(position = 0)] $Hosts,
    [Parameter] $ToCsv
    )
        #Funtion to make space so that formatting looks good
        Function Make-Space($l,$Maximum)
        {
        $space =""
        $s = [int]($Maximum - $l) + 1
        1..$s | %{$space+=" "}

        return [String]$space
        }
    #Array Variable to store length of all hostnames
    $LengthArray = @() 
    $Hosts | %{$LengthArray += $_.length}

    #Find Maximum length of hostname to adjust column witdth accordingly
    $Maximum = ($LengthArray | Measure-object -Maximum).maximum
    $Count = $hosts.Count

    #Initializing Array objects 
    $Success = New-Object int[] $Count
    $Failure = New-Object int[] $Count
    $Total = New-Object int[] $Count
    cls
    #Running a never ending loop
    while($true){

    $i = 0 #Index number of the host stored in the array
    $out = "| HOST$(Make-Space 4 $Maximum)| STATUS | SUCCESS  | FAILURE  | ATTEMPTS  |" 
    $Firstline=""
    1..$out.length|%{$firstline+="_"}

    #output the Header Row on the screen
    Write-Host $Firstline 
    Write-host $out -ForegroundColor White -BackgroundColor Black

    $Hosts|%{
    $total[$i]++
    If(Test-Connection $_ -Count 1 -Quiet -ErrorAction SilentlyContinue)
    {
    $success[$i]+=1
    #Percent calclated on basis of number of attempts made
    $SuccessPercent = $("{0:N2}" -f (($success[$i]/$total[$i])*100))
    $FailurePercent = $("{0:N2}" -f (($Failure[$i]/$total[$i])*100))

    #Print status UP in GREEN if above condition is met
    Write-Host "| $_$(Make-Space $_.Length $Maximum)| UP$(Make-Space 2 4)  | $SuccessPercent`%$(Make-Space ([string]$SuccessPercent).length 6) | $FailurePercent`%$(Make-Space ([string]$FailurePercent).length 6) | $($Total[$i])$(Make-Space ([string]$Total[$i]).length 9)|" -BackgroundColor Green
    }
    else
    {
    $Failure[$i]+=1

    #Percent calclated on basis of number of attempts made
    $SuccessPercent = $("{0:N2}" -f (($success[$i]/$total[$i])*100))
     $FailurePercent = $("{0:N2}" -f (($Failure[$i]/$total[$i])*100))

    #Print status DOWN in RED if above condition is met
    Write-Host "| $_$(Make-Space $_.Length $Maximum)| DOWN$(Make-Space 4 4)  | $SuccessPercent`%$(Make-Space ([string]$SuccessPercent).length 6) | $FailurePercent`%$(Make-Space ([string]$FailurePercent).length 6) | $($Total[$i])$(Make-Space ([string]$Total[$i]).length 9)|" -BackgroundColor Red
    }
    $i++

    }

    #Pause the loop for few seconds so that output 
    #stays on screen for a while and doesn't refreshes

    Start-Sleep -Seconds 4
    cls
    }
}

Function Get-MyPublicIP {
(Invoke-WebRequest -Uri ifconfig.me).RawContent -match "b(?:d{1,3}.){3}d{1,3}b" | Out-Null
$matches | select -ExpandProperty Values
}

# This function gets your System Uptime
Function Get-Uptime
{
    $wmio = Get-WmiObject -Class Win32_OperatingSystem 
    $LocalTime = [management.managementDateTimeConverter]::ToDateTime($wmio.localdatetime)
    $LastBootUptime = [management.managementDateTimeConverter]::ToDateTime($wmio.lastbootuptime)
                        
    # Calculating timespan between current server time and last reboot time, i.e Uptime
    $timespan = $localTime - $lastBootUptime   
    
    
    if($timespan.Days -eq 0 -and $timespan.Hours -gt 0)
    {
    $Uptime = "Your System is up from $($Timespan.hours) Hours and $($timespan.Minutes)  Minutes"                 
    }
    elseif($timespan.Days -eq 0 -and $timespan.Hours -eq 0)
    {
    $Uptime = "Your System is up from $($timespan.Minutes) Minutes"  
    }
    else
    {
    $Uptime = "Your System is up from $($Timespan.days) Days $($Timespan.hours) Hours and $($timespan.Minutes) Minutes"  
    }
Return $Uptime
}

# This Function check Battery status and charge percentage
Function Get-BatteryStatus
{
    $wmio = Get-WmiObject Win32_battery
    If($wmio.Status –eq ‘ok’)
    {
        $BatteryString = “Your systems battery is in Good health and $($wmio.EstimatedChargeRemaining) % charged. “
    }
    else
    {
        $BatteryString = “Your systems battery is not in good health and  $($wmio.EstimatedChargeRemaining) % charged. “
    }


    Return $BatteryString
}

# This function gets your System Disk Information
Function Get-DiskInfo
{
    $wmio= Get-WmiObject -class win32_logicaldisk
    $Drives = $wmio|?{$_.size -ne $null} | Select Deviceid , @{name='Free Space';Expression ={($_.freespace/1gb)}}
    $DrivesString = 0..$($drives.count-1) | %{ " $(($drives[$_]).Deviceid.Replace(':',' Drive')) has $("{0:N2}" -f $(($Drives[$_]).'free space')) GB of free space.     `n"}
    $DrivesString = "Loading system disk free space information.." +$DrivesString
    return $DrivesString
}

# This function identifies all services that are configured to auto start with system but are in stopped state
Function Check-Services
{
    $Services = $(Get-WmiObject -Class win32_service |?{$_.startmode -eq 'Auto' -and $_.State -eq 'Stopped'} | select displayname -ExpandProperty displayname)
    $count=$Services.count
    $ServicesString = "Checking System Service status...   Total $count services identified that have startup type configured to Auto start, but are in stopped state."
    $ServicesString = $ServicesString + $(1..$count | %{"`n $_. $($services[$($_)-1]) ."})
    return $ServicesString
}

# This function collects and groups warning and error logs
Function Check-Eventlogs
{
   $ErrorEvents = Get-EventLog -LogName System -EntryType Error | ?{$_.TimeGenerated -ge (get-date).AddDays(-7) } | Group-Object source | sort count -Descending | Select Count, Name -First 3 
   $EventsString = "Collecting System Error events, occured in last one week . `n" +  ($ErrorEvents |%{"$($_.count) error messages logged related to $(($_.name).Replace('-',' ')) ."})
   $WarningEvents = Get-EventLog -LogName System -EntryType Warning | ?{$_.TimeGenerated -ge (get-date).AddDays(-7) } | Group-Object source | sort count -Descending | Select Count, Name -First 3 
   $EventsString += "`n Collecting System Warning events, occured in last one week . `n" +  ($WarningEvents |%{"$($_.count) Warning messages logged related to $(($_.name).Replace('-',' ')) ."})
   return $EventsString
}

# This function check CPU and RAM utilization by the system
Function Check-HardwarePerformance
{
 $CPU = Get-WmiObject win32_processor | select LoadPercentage -ExpandProperty Loadpercentage
 
 If($CPU -le 30)
 {
     $CPUString = " Your system is on Optimum C P U utilization of  $CPU percent.. "          
 }
 else
 {
     $CPUString = " Your systems CPU utilization is about $CPU percent, which is above defined 30% threshold. Identifying Top 3 processes with highest C P U utlization"
     $Process = Get-Process| Sort CPU -desc | select name -ExpandProperty name -first 3
     $ProcessString = 1..3 | %{ "Process $_ . $($process[$_ - 1]) . `n "}
     $CPUString += $ProcessString            
 }
 
    $Memory = (Get-WmiObject -Class win32_operatingsystem |
    Select-Object @{Name = 'Memory' ; Expression = { “{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }}).memory
    $MemoryString = "`n You system is consuming Total of $Memory % of Physical memory. "

    Return $CPUString + $MemoryString

}
