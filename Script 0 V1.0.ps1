#Made by Wessel Rouw 
#Version 1.0 aanmaken en eerste configuratie script 
#Version 1.1 Document aangepast met duidelijke uitleg van de functies. Aan het begin een clear command neergezet, zodat hij altijd leeg begint. 
#Version 1.2 Script getest en kreeg een foutmelding terug bij het disabelen van DHCP voor de WAN verbinding. 
 
  ######################### 
#    Script 0   v1     # 
######################### 
# Dit script kun je pas draaien na script 1
# In script 2 worden de rollen geinstalleerd, DHCP ingesteld, de printer toegevoed en wordt de DC toegevoegd aan het domein.
##################################### 
# Auteur: Wessel Rouw (c), 10-2022 # 
##################################### 
 
################## 
#  Versiebeheer  # 
 #Version 1.0 aanmaken en eerste configuratie script 
#Version 1.1 Document aangepast met duidelijke uitleg van de functies. Aan het begin een clear command neergezet, zodat hij altijd leeg begint. 
#Version 1.2 Script getest en kreeg een foutmelding terug bij het disabelen van DHCP voor de WAN verbinding.
##################


#Command to clear the screen. 
Clear-Host
 
 
#All the command aliasses 
$host.UI.RawUI.ForegroundColor = "green"
$HostName = "DC174376"
$IPLAN = "172.16.2.10"
$DNS1LAN = $IPLAN
$DomainName = ""
$DomainNetBiosName = ""
$SafemodePW = convertTo-securestring -string “Halo25” -asplaintext -force
 
#Command to adjust the timezone to Amsterdam 
Set-TimeZone -Id "W. Europe Standard Time"
 
#Command to list the available network interfaces. 
Get-NetAdapter
 
#Commands to rename the two adapters 
Rename-NetAdapter -Name Ethernet0 -NewName WAN
Rename-NetAdapter -Name Ethernet1 -NewName LAN
 
#Command to set the network adapters ip adressing 
New-NetIPAddress -InterfaceAlias LAN -IPAddress $IPLAN -PrefixLength 24
Set-NetIPinterface -InterfaceAlias LAN -Dhcp disabled
Set-DnsClientServerAddress -InterfaceAlias LAN -ServerAddresses $IPLAN
Set-NetIPInterface -InterfaceAlias WAN -Dhcp Enabled
Disable-NetAdapterBinding -InterfaceAlias * -ComponentID ms_tcpip6
 
 
#Command to rename the computer 
Rename-Computer -NewName $HostName
 
#Command to restart the computer and getting a message 
Write-Warning -Message "De computer zal na 60 seconden herstarten. Start hierna scrips 2!"
Start-Sleep -Seconds 60
Restart-Computer
