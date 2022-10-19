 ######################### 
#    Script 2   v1     # 
######################### 
# Dit script kun je pas draaien na script 1
# In script 2 worden de rollen geinstalleerd, DHCP ingesteld, de printer toegevoed en wordt de DC toegevoegd aan het domein.
##################################### 
# Auteur: Wessel Rouw (c), 10-2022 # 
##################################### 
 
################## 
#  Versiebeheer  # 
# Version 0.1 aanmaken en eerste configuratie script. Hier heb ik de benodigde install roles bijgevoegd. 
# Version 0.2 DHCP configuratie ingesteld.
# Version 0.3 De rollen toegevoegd
# Version 0.4 De DC aan het forest toegevoegd en vervolgens aan het domein.
# Version 0.5 De commando's toegevoegd om de printer toe te voegen en benaderbaar is.
# Version 0.6 De betreffende variablen toegevoegd en de write-host commmando's bijgevoegd.
# Version 1.0 eindversie 
################## 
 
#Command to clear the screen. 
Clear-Host 
 
#All the command aliasses 
$SafemodePW = convertTo-securestring -string “Halo25” -asplaintext -force 
$ScopeName = "172.16.2.10" 
$PrinterIP = "172.16.2.110" 
$DNSscope = "172.16.2.10" 
$Routerscope = "172.16.2.10" 
$PrinerMAC = "B0-1C-38-0A-FB-24"  
$Printernaam = "HP Laserjet m118dw" 
$netwerkIP = "172.16.2.0" 
$Printersource = "https://ftp.hp.com/pub/softlib/software13/COL40842/ds-99374-24/upd-pcl6-x64-7.0.1.24923.exe" 
$Printerdest = "C:\\Users\\Administrator\\Documents\\upd-pcl6-x64-7.0.1.24923.exe" 
$PrinterdestZip = "C:\\Users\\Administrator\\Documents\\upd-pcl6-x64-7.0.1.24923.zip" 
$PNP_Bestand = "c:\HP Universal Print Driver\hpcu255u.inf" 
$TijdelijkeBestandLocatie = "c:\\HP Universal Print Driver"  
$Netlogin_Locatie = "c:\windows\Netlogon\" 
$Domainname = "Aventus174376.local" 
$inf_path = “c:\HP Universal Print Driver\hpcu255u.inf" 
$PrinterDriver = "HP Universal Printing PCL 6"
$NieuweNaam = "Eerste Printer"
 
 
#Command to install all roles (ADDS, DNS, DHCP, RRAS and print services). 
Install-WindowsFeature AD-domain-Services -includemanagementtools 
Install-WindowsFeature dns -IncludeManagementTools 
Install-WindowsFeature dhcp -IncludeManagementTools 
Install-WindowsFeature RemoteAccess -IncludeManagementTools 
Install-WindowsFeature Print-services -IncludeManagementTools 
 
# Commando om de DHCP server in te stellen
Write-Host -ForegroundColor purple -Object "Uw DHCP server wordt ingesteld!"
Add-DhcpServerv4Scope -name $ScopeName -StartRange 172.16.2.100 -EndRange 172.16.2.151 -SubnetMask 255.255.255.0 
Set-DhcpServerv4OptionValue -DnsServer $DNSscope -Router $Routerscope 
add-DhcpServerv4Reservation -IPAddress $PrinterIP -ClientId "$PrinerMAC" -ScopeId $netwerkIP  
 
# Commando's om de printer aan het domein toe te voegen
Write-Host -ForegroundColor purple -Object "De printer wordt ingesteld en aan het domein toegevoegd!"
Invoke-WebRequest -Uri $Printersource -OutFile $Printerdest 
Rename-Item -Path $Printerdest -NewName $PrinterdestZip 
Expand-Archive $PrinterdestZip -Force -DestinationPath $TijdelijkeBestandLocatie
pnputil.exe -i -a $PNP_Bestand
mkdir -Path C:\Windows\Netlogon 
Copy-Item -Path $inf_path -Destination $Netlogin_Locatie
Add-PrinterPort -Name $Printernaam -PrinterHostAddress $PrinterIP 
Add-PrinterDriver -Name $PrinterDriver
Add-Printer -DriverName $PrinterDriver -Name $NieuweNaam -PortName $Printernaam 

# Commando om het betreffende zip bestand weer te verwijderen
Write-Host -ForegroundColor purple -Object "De tijdelijke pirnter bestanden zijn er weer uitgehaald scheelt u weer werk!"
Remove-Item -Path $PrinterdestZip -Recurse 
 
# Active Directoy installeren en de DC aan het domein toevoegen
Write-Host -ForegroundColor purple -Object "De DC wordt aan het domein toegevoegd!"
Install-ADDSForest -DomainName $Domainname -SafeModeAdministratorPassword $SafemodePW -Force 
