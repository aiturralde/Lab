# Disable Administrative / Hidden Shares
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name AutoShareServer -Value 0# Restore the value of the LocalAccountTokenFilterPolicy to 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy -Value 0# Restore UAC
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name FilterAdministratorToken -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 1# Remove SMB1 Feature
Remove-WindowsFeature -name fs-smb1# Disable SMB1 protocol
Set-SmbServerConfiguration -EnableSMB1Protocol $False -Force# Remove WindowsDefender
Remove-WindowsFeature -name Windows-Defender-Features