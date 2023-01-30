
#Gets the time in correct format for the bios call / alarm
$ALARM = (get-date).AddMinutes(5).ToString("HH:mm:ss")

#Write-Output "Time to set the wakeup alarm for $ALARM"
# Setting the alarm to the correct time sample command
(gwmi -Class Lenovo_SetBiosSetting -Namespace root\wmi).SetBiosSetting("AlarmTime,[$ALARM]").return

# Seeting the configuration to use a wake on alarm
(gwmi -Class Lenovo_SetBiosSetting -Namespace root\wmi).SetBiosSetting("WakeUponAlarm,Daily Event").return

#Save the Bios settings
(gwmi -Class Lenovo_SaveBiosSettings -Namespace root\wmi).SaveBiosSettings().return
