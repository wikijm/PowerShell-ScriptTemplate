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
