# Disable Administrative / Hidden Shares

# Restore the value of the LocalAccountTokenFilterPolicy to 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name AutoShareServer -Value 0

# Restore UAC
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy -Value 0

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name FilterAdministratorToken -Value 1

# Remove SMB1 Feature
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 1

# Disable SMB1 protocol
Remove-WindowsFeature -name fs-smb1

# Remove WindowsDefender
Set-SmbServerConfiguration -EnableSMB1Protocol $False -Force

Remove-WindowsFeature -name Windows-Defender-Features