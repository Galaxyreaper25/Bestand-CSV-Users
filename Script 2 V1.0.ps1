######################### 
#    Script 2   v1.0    # 
######################### 
# Dit script kun je pas draaien na script 1
# In script 1 wordt de Domain Controller geconfigureerd door middel van Router and Remote Access. Ook wordt DNS ingesteld en wordt de DHCP geauthoriseerd.
# 
##################################### 
# Auteur: Wessel Rouw (c), 11-2022 # 
##################################### 
 
################## 
#  Versiebeheer  # 
# Versie 0.1  Aanmaak document 
# Versie 0.2 Alle laatste aanpassingen gedaan betreft de opmaak
# Versie 1.0  Eind versie 
################## 
#  
# Dit script moet je draaien nadat RRAS is geinstalleerd (via script1.ps1) 
 
#Command to clear the screen. 
Clear-Host
 
# De variablen  
$ExternalInterface = "WAN"
$InternalInterface = "LAN"
$DNSname = "DC174376.Aventus174376.local"
$Netwerkaddress = "172.16.2.0/24"
$IPaddressLAN = "172.16.2.10"
$Printernaam = "Eerste printer"
$HostName = "DC174376"
 
 
# Command om de tools te installeren van RRAS 
Write-Host -ForegroundColor Green -Object "De RRAS services worden geinstalleerd."
Install-WindowsFeature -Name DirectAccess-VPN -computerName $HostName
Install-WindowsFeature -Name Routing -computerName $HostName
Install-WindowsFeature RSAT-RemoteAccess-PowerShell
Install-WindowsFeature RemoteAccess -VpnType RoutingOnly
 
 
# Printer wordt gepubliceerd in de AD
Write-Host -ForegroundColor Green -Object "Printer wordt gepubliceerd in de AD"
Set-Printer -Name "Eerste printer" -Published $True
 
# Command for creating the reverse lookup zone
write-host -foregroundColor green -object "De DNS instellingen worden nu geconfigureerd!"
Add-DnsServerPrimaryZone -NetworkID $Netwerkaddress -ReplicationScope Domain
Add-DnsServerResourceRecordPtr -Name 10 -PtrDomainName DC174376.Aventus174376.local -ZoneName 2.16.172.in-addr.arpa


 
# Autoriseren van DHCP
write-host -foregroundColor green -object "De DHCP server wordt nu geauthoriseerd!"
Add-DhcpServerInDC -DnsName $DNSname -IPAddress $IPaddressLAN
 
# Instellen over welk NIC routing moet worden ingesteld (voor NAT)
write-host -foregroundColor green -object "De Router and Remote Access worden nu geconfigureerd!"
cmd.exe /c "netsh routing ip nat install"
cmd.exe /c "netsh routing ip nat add interface $ExternalInterface"
cmd.exe /c "netsh routing ip nat set interface $ExternalInterface mode=full"
cmd.exe /c "netsh routing ip nat add interface $InternalInterface"
  
