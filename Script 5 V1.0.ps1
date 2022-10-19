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
# Versie 0.2 : De regels aangemaakt om het domein te joinen
# Versie 0.3 : Onderzoek naar de foutmelding dat het domain niet gejoined kan worden
# Versie 1.0 : Eind versie 
################## 
# Draai dit script na script 3 
#  
# Dit script moet je draaien nadat RRAS is geinstalleerd (via script02.ps1) 
# Ook zorgt dit script ervoor dat AGDLP wordt toegepast met de juiste rechten 

# Variablen
$DomainName = "Aventus174376.local"
$SafemodePW = convertTo-securestring -string “Pa$$w0rd” -asplaintext -force
$CRED = New-Object System.Management.Automation.PSCredential("Aventus174376\Administrator",(ConvertTo-SecureString "Pa$$w0rd" -AsPlainText -Force))


# Commando's om het werkstation aan het domein toe te voegen.
write-host -foregroundColor green -object "Uw werkstation zal nu aan het domein toegevoegd worden."
add-computer -domainname $DomainName -Credential $CRED -OUPath "OU=Computers,OU=Aventus174376,DC=local"

#Command to restart the computer and getting a message 
#Write-Warning -Message "De computer zal na 30 seconden herstarten. Hierna kunt u lekker gebruik maken van uw werkstation!"
#Start-Sleep -Seconds 30
#Restart-Computer
