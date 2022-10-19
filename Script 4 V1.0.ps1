######################### 
#    Script 4   v1     # 
######################### 
# Dit script kun je pas draaien na script 4 
# In script 4 gaat de configuratie en invulling van het AD geregeld worden. 
# 
##################################### 
# Auteur: Wessel Rouw (c), 09-2022 # 
##################################### 
 
################## 
#  Versiebeheer  # 
# Versie 0.1 : Aanmaak document
# Versie 0.1 : Eerste veriablen maken en OU aangemaakt
# Versie 0.2 : De AGDLP princiepes begonnen
# Versie 0.3 : De loop overgenomen en aangepast naar mijn wensen voor de NTFS rechten
# Verise 0.4 : De Users CSV bestand toegevoerd en de loop aangepast
# Versie 0.5 : De gebruikers aan de juiste OU koppelen
# Versie 0.6 : Zorgen dat het UserProfiles path HomeFolers path en de schrijf path worden aangemaakt
# Versie 0.7 : Zorgen dat uit de share mappen de default users verwijderd worden, zodat het agdlp princiepe werkt
# Versie 1.0 : Eind versie 
################## 
# Draai dit script na script 3 
#  
# Dit script moet je draaien nadat RRAS is geinstalleerd (via script02.ps1) 
# Ook zorgt dit script ervoor dat AGDLP wordt toegepast met de juiste rechten 

# Command to clear the screen. 
Clear-Host 
 
#All the command aliasses 
#$host.UI.RawUI.ForegroundColor = "white"  
$IPLAN = "172.16.2.10" 
$DNS1LAN = $IPLAN 
$ComputerName = "WS174376" 
$DomainName = "Aventus174376.local"
$Tijdzone = "W. Europe Standard Time"
$SafemodePW = convertTo-securestring -string “Pa$$w0rd” -asplaintext -force 
$NewNetwerkadapterName = "LAN"

 
 
#Command to adjust the timezone to Amsterdam 
write-host -foregroundColor green -object "Uw tijdzone wordt nu juist ingevoerd"
Set-TimeZone -Id $Tijdzone
 
#Command to list the available network interfaces. 
write-host -foregroundColor green -object "Dit zijn uw beschikbare netwerk-kaarten"
Get-NetAdapter 
 
#Commands to rename the two adapters 
write-host -foregroundColor green -object "De naam van de netwerkaart is geweizigd"
Rename-NetAdapter -Name Ethernet0 -NewName $NewNetwerkadapterName
 
# Hier ga ik de LAN interface configureren en hem toeweizen aan DHCP
write-host -foregroundColor green -object "De netwerkinterface is ingesteld op DHCP en zal dus automatisch een IP adres toegewezen krijgen."
Set-NetIPInterface -InterfaceAlias $NewNetwerkadapterName -Dhcp Enabled 
Disable-NetAdapterBinding -InterfaceAlias * -ComponentID ms_tcpip6 

Rename-Computer -NewName $ComputerName

#Command to rename the computer 
write-host -foregroundColor green -object "Hier wordt uw werkstation hernaamd naar de betreffende naam."
Rename-Computer -NewName $ComputerName -LocalCredential 174376\Administrator -PassThru

#Command to restart the computer and getting a message 
Write-Warning -Message "De computer zal na 30 seconden herstarten. Hierna kunt u lekker gebruik maken van uw werkstation!"
Start-Sleep -Seconds 30
Restart-Computer
