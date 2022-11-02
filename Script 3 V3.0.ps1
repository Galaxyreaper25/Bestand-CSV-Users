######################### 
#    Script 3   v1     # 
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
# Versie 2.0 : Versie met de loop eruit voor NTFS maar nu een csv bestand in de plaats
# Versie 3.0 : Versie met het csv ntfs rechten bestand eruit, maar gewoon met de hand alles ingevuld 
# Versie 3.1 : Printer netwerksharing commando toegevoegd
################## 
# Draai dit script na script 3 
#  
# Dit script moet je draaien nadat RRAS is geinstalleerd (via script02.ps1) 
# Ook zorgt dit script ervoor dat AGDLP wordt toegepast met de juiste rechten 

# Command to clear the screen. 
Clear-Host 

# Lijst met variablen
$Datadisk = "1"
$Driveletter = "E"
$Drivenaam = "Bedrijfsdata"
$ShareMapAanmaak = "E:\Shares"
$UserFolderShare = "E:\Shares\UserFolders"
$UserProfilesShare = "E:\Shares\UserProfiles"
$BedrijfsDataShare = "E:\Shares\BedrijfsData"
$DomainAdmins = "Aventus174376.local\Domain Admins"
$DomainUsers = "Aventus174376.local\Domain Users"
$URLUsers = "https://raw.githubusercontent.com/Galaxyreaper25/Bestand-CSV-Users/main/bulk_users_rumb_v5.csv"
$DestCSVUsers = "C:\Users\Administrator\Documents\gebruikers.csv"



# Commando's om de OU's aan te maken
write-host -foregroundColor green -object "Het OU schema wordt aangemaakt!"
New-ADOrganizationalUnit -Name "Afdelingen" -Path "DC=Aventus174376,DC=local"
New-ADOrganizationalUnit -name "Directie" -path "OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADOrganizationalUnit -name "Staf" -path "OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADOrganizationalUnit -name "Verkoop" -path "OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADOrganizationalUnit -name "Administratie" -path "OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADOrganizationalUnit -name "Productie" -path "OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADOrganizationalUnit -name "FabricageBudel" -path "OU=Productie,OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADOrganizationalUnit -name "Automatisering" -path "OU=Afdelingen,DC=Aventus174376,DC=local"

# Commando's om de security groups aan te maken in AD oftwel de GlobalGroups GG
write-host -foregroundColor green -object "De GG groups worden aangemaakt!"
New-ADGroup -Name GG_Directie -GroupScope Global -Path "OU=Directie,OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADGroup -Name GG_Staf -GroupScope Global -Path "OU=Staf,OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADGroup -Name GG_Verkoop -GroupScope Global -Path "OU=Verkoop,OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADGroup -Name GG_Administratie -GroupScope Global -Path "OU=Administratie,OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADGroup -Name GG_Productie -GroupScope Global -Path "OU=Productie,OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADGroup -Name GG_FabricageBudel -GroupScope Global -Path "OU=FabricageBudel,OU=Productie,OU=Afdelingen,DC=Aventus174376,DC=local"
New-ADGroup -Name GG_Automatisering -GroupScope Global -Path "OU=Automatisering,OU=Afdelingen,DC=Aventus174376,DC=local"

# Commando's om de Domain Local oftwel de DL groups aan te maken 1 met lees en schrijf rechten de ander alleen met lees rechten ze worden in de default users groups gezet, zodat je ze niet direct in je bedrijfs OU schema ziet.
write-host -foregroundColor green -object "De DL groups worden aangemaakt!"
New-ADGroup -Name DL_Directie-Share_RW -GroupScope DomainLocal
New-ADGroup -Name DL_Directie-Share_R -GroupScope DomainLocal
New-ADGroup -Name DL_Staf-Share_RW -GroupScope DomainLocal
New-ADGroup -Name DL_Staf-Share_R -GroupScope DomainLocal
New-ADGroup -Name DL_Verkoop-Share_RW -GroupScope DomainLocal
New-ADGroup -Name DL_Verkoop-Share_R -GroupScope DomainLocal
New-ADGroup -Name DL_Administratie-Share_RW -GroupScope DomainLocal
New-ADGroup -Name DL_Administratie-Share_R -GroupScope DomainLocal
New-ADGroup -Name DL_Productie-Share_RW -GroupScope DomainLocal
New-ADGroup -Name DL_Productie-Share_R -GroupScope DomainLocal
New-ADGroup -Name DL_FabricageBudel-Share_RW -GroupScope DomainLocal
New-ADGroup -Name DL_FabricageBudel-Share_R -GroupScope DomainLocal
New-ADGroup -Name DL_Automatisering-Share_RW -GroupScope DomainLocal
New-ADGroup -Name DL_Automatisering-Share_R -GroupScope DomainLocal

# Het toevoegen van de betreffende groups in de DL groups
write-host -foregroundColor green -object "De DL groups worden aan de GG groups toegevoegd!"
Add-ADGroupMember -Identity DL_Directie-Share_RW -Members GG_Directie
Add-ADGroupMember -Identity DL_Directie-Share_R -Members GG_Staf, GG_Verkoop, GG_Administratie, GG_Productie, GG_FabricageBudel, GG_Automatisering
Add-ADGroupMember -Identity DL_Staf-Share_RW -Members GG_Staf
Add-ADGroupMember -Identity DL_Staf-Share_R -Members GG_Directie, GG_Verkoop, GG_Administratie, GG_Productie, GG_FabricageBudel, GG_Automatisering
Add-ADGroupMember -Identity DL_Verkoop-Share_RW -Members GG_Verkoop
Add-ADGroupMember -Identity DL_Verkoop-Share_R -Members GG_Staf, GG_Directie, GG_Administratie, GG_Productie, GG_FabricageBudel, GG_Automatisering
Add-ADGroupMember -Identity DL_Administratie-Share_RW -Members GG_Administratie
Add-ADGroupMember -Identity DL_Administratie-Share_R -Members GG_Staf, GG_Verkoop, GG_Directie, GG_Productie, GG_FabricageBudel, GG_Automatisering
Add-ADGroupMember -Identity DL_Productie-Share_RW -Members GG_Productie
Add-ADGroupMember -Identity DL_Productie-Share_R -Members GG_Staf, GG_Verkoop, GG_Administratie, GG_Directie, GG_FabricageBudel, GG_Automatisering
Add-ADGroupMember -Identity DL_FabricageBudel-Share_RW -Members GG_FabricageBudel
Add-ADGroupMember -Identity DL_FabricageBudel-Share_R -Members GG_Staf, GG_Verkoop, GG_Administratie, GG_Productie, GG_Directie, GG_Automatisering
Add-ADGroupMember -Identity DL_Automatisering-Share_RW -Members GG_Automatisering
Add-ADGroupMember -Identity DL_Automatisering-Share_R -Members GG_Staf, GG_Verkoop, GG_Administratie, GG_Productie, GG_FabricageBudel, GG_Directie

# Commando's om de E: schrijf te partieoneren.
# Clear-Disk -Number $Datadisk -RemoveData
write-host -foregroundColor green -object "De schrijf wordt geinitializeerd, partiogioneerd en geformateerd naar de E:\ schrijf met de naam BedrijfsData!"
Initialize-Disk $Datadisk -PartitionStyle GPT
New-Partition -DiskNumber $Datadisk -DriveLetter $Driveletter -UseMaximumSize
Format-Volume -DriveLetter $Driveletter -FileSystem NTFS -NewFileSystemLabel $Drivenaam

# Commando's om de Share HomeFolders$ aan te maken 
write-host -foregroundColor green -object "De Share folders worden aangemaakt dit betreft de user, home en bedrijfsdata share!"
mkdir -Path $UserFolderShare
New-SmbShare -Name "UserFolders$" -Path $UserFolderShare -FullAccess $DomainAdmins -ChangeAccess $DomainUsers

# Commando's om de Share UserProfiles$ aan te maken
mkdir -Path $UserProfilesShare
New-SmbShare -Name "UserProfiles$" -Path $UserProfilesShare -FullAccess $DomainAdmins -ChangeAccess $DomainUsers

# Commando's om de Share BedrijfsData$ aan te maken
mkdir -Path $BedrijfsDataShare
New-SmbShare -Name "BedrijfsData" -Path $BedrijfsDataShare -FullAccess $DomainAdmins -ChangeAccess $DomainUsers

# Commando's om het CSV bestand van GitHub af te halen en op de lokale machine te zetten.
write-host -foregroundColor green -object "Het CSV bestand wordt van Github gehaald om in de betreffende locatie geplaatst te worden!"
Invoke-WebRequest -Uri $URLUsers -OutFile $DestCSVUsers

# De NTFS module om meer mogelijkheden te krijgen
write-host -foregroundColor green -object "De NTFS module wordt geinstaleerd!"
Install-Module -Name NTFSSecurity -RequiredVersion 4.2.6 -Force

# De Afdeling Shares maken
write-host -foregroundColor green -object "De afdeling shares worden aangemaakt!"
mkdir -Path E:\Shares\BedrijfsData\DIRshare
mkdir -Path E:\Shares\BedrijfsData\STAshare
mkdir -Path E:\Shares\BedrijfsData\VERshare
mkdir -Path E:\Shares\BedrijfsData\ADMshare
mkdir -Path E:\Shares\BedrijfsData\PROshare
mkdir -Path E:\Shares\BedrijfsData\FABshare
mkdir -Path E:\Shares\BedrijfsData\AUTshare

# Commando's om de NTFS rechten van de map BedrijfsData aan te passen
write-host -foregroundColor green -object "De loop om de NTFS rechten worden geregeld!"
$ACL = Get-Acl E:\Shares\BedrijfsData
$acl.SetAccessRuleProtection($true,$true)
$everyone = New-Object System.Security.Principal.NTAccount("Everyone")
$acl.PurgeAccessRules($everyone)
$acl | set-Acl E:\Shares\BedrijfsData

# Commando's om de NTFS rechten van de Share mappen in te stellen
$acl = Get-Acl E:\Shares\BedrijfsData\DIRshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("Domain Admins","FullControl","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\DIRshare

$acl = Get-Acl E:\Shares\BedrijfsData\DIRshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Directie-Share_R","Readandexecute","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\DIRshare
	
$acl = Get-Acl E:\Shares\BedrijfsData\DIRshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Directie-Share_RW","Readandexecute,write","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\DIRshare



# Commando's om de NTFS rechten van de Share mappen in te stellen
$acl = Get-Acl E:\Shares\BedrijfsData\STAshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("Domain Admins","FullControl","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\STAshare

$acl = Get-Acl E:\Shares\BedrijfsData\STAshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Staf-Share_R","Readandexecute","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\STAshare
	
$acl = Get-Acl E:\Shares\BedrijfsData\STAshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Staf-Share_RW","Readandexecute,write","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\STAshare


# Commando's om de NTFS rechten van de Share mappen in te stellen
$acl = Get-Acl E:\Shares\BedrijfsData\VERshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("Domain Admins","FullControl","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\VERshare

$acl = Get-Acl E:\Shares\BedrijfsData\VERshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Verkoop-Share_R","Readandexecute","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\VERshare
	
$acl = Get-Acl E:\Shares\BedrijfsData\VERshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Verkoop-Share_RW","Readandexecute,write","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\VERshare


# Commando's om de NTFS rechten van de Share mappen in te stellen
$acl = Get-Acl E:\Shares\BedrijfsData\ADMshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("Domain Admins","FullControl","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\ADMshare

$acl = Get-Acl E:\Shares\BedrijfsData\ADMshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Administratie-Share_R","Readandexecute","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\ADMshare
	
$acl = Get-Acl E:\Shares\BedrijfsData\ADMshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Administratie-Share_RW","Readandexecute,write","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\ADMshare

# Commando's om de NTFS rechten van de Share mappen in te stellen
$acl = Get-Acl E:\Shares\BedrijfsData\ADMshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("Domain Admins","FullControl","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\ADMshare

$acl = Get-Acl E:\Shares\BedrijfsData\ADMshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Productie-Share_R","Readandexecute","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\ADMshare
	
$acl = Get-Acl E:\Shares\BedrijfsData\ADMshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Productie-Share_RW","Readandexecute,write","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\ADMshare


# Commando's om de NTFS rechten van de Share mappen in te stellen
$acl = Get-Acl E:\Shares\BedrijfsData\PROshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("Domain Admins","FullControl","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\PROshare

$acl = Get-Acl E:\Shares\BedrijfsData\PROshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Productie-Share_R","Readandexecute","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\PROshare
	
$acl = Get-Acl E:\Shares\BedrijfsData\PROshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Productie-Share_RW","Readandexecute,write","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\PROshare


# Commando's om de NTFS rechten van de Share mappen in te stellen
$acl = Get-Acl E:\Shares\BedrijfsData\FABshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("Domain Admins","FullControl","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\FABshare

$acl = Get-Acl E:\Shares\BedrijfsData\FABshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_FabricageBudel-Share_R","Readandexecute","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\FABshare
	
$acl = Get-Acl E:\Shares\BedrijfsData\FABshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_FabricageBudel-Share_RW","Readandexecute,write","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\FABshare

# Commando's om de NTFS rechten van de Share mappen in te stellen
$acl = Get-Acl E:\Shares\BedrijfsData\AUTshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("Domain Admins","FullControl","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\AUTshare

$acl = Get-Acl E:\Shares\BedrijfsData\AUTshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Automatisering-Share_R","Readandexecute","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\AUTshare
	
$acl = Get-Acl E:\Shares\BedrijfsData\AUTshare
$acl.SetAccessRuleProtection($true,$true)
$AccessRules = New-Object system.security.AccessControl.FileSystemAccessRule("DL_Automatisering-Share_RW","Readandexecute,write","Allow")
$acl.SetAccessRule($AccessRules)
$acl | Set-Acl E:\Shares\BedrijfsData\AUTshare


# Commando om de activedirectory module te downloaden
write-host -foregroundColor green -object "De activedirectory module wordt geinstaleerd!"
Import-Module activedirectory
    
#Store the data from ADUsers.csv in the $ADUsers variable 
write-host -foregroundColor green -object "Het CSV bestand wordt aan een variable gekoppeld!"
$ADUsers = Import-csv C:\Users\Administrator\Documents\gebruikers.csv
  
#Loop through each row containing user details in the CSV file 
write-host -foregroundColor green -object "De automatische loop die kijkt zorgt dat alle gebruikers worden aangemaakt aan de hand van het CSV bestand en kijkt of de gebruiker niet al bestaat!"
foreach ($User in $ADUsers)
{  
#Read user data from each field in each row and assign the data to a variable as below  
  
  $Username = $User.username
  $Password = $User.password
  $Firstname = $User.firstname
  $Lastname = $User.lastname
  $OU = $User.ou #This field refers to the OU the user account is to be created in  
  $email = $User.email
  $streetaddress = $User.streetaddress
  $city = $User.city
  $zipcode = $User.zipcode
  $state = $User.state
  $country = $User.country
  $telephone = $User.telephone
  $jobtitle = $User.jobtitle
  $company = $User.company
  $department = $User.department
  $Password = $User.Password
  $Office = $User.Office
  $FullName = $User.Name
  $UserProfiles = “\\DC174376\UserProfiles$\$Username”
  $UserHome = “\\DC174376\UserFolders$\$Username”
  $UserDrive = $User.HomeDrive
  
#Check to see if the user already exists in AD  
if (Get-ADUser -F {SamAccountName -eq $Username})
{
 #If user does exist, give a warning
 Write-Warning "A user account with username $Username already exist in Active Directory."
}
else
{
  
        #Account will be created in the OU provided by the $OU variable read from the CSV file
New-ADUser `
	-SamAccountName $Username `
	-UserPrincipalName "$Username@Aventus174376.local" `
	-Name $FullName `
	-GivenName $Firstname `
 	-Surname $Lastname `
	-Enabled $True `
	-DisplayName "$Lastname, $Firstname" `
	-Path $OU `
 	-City $city `
	-Company $company `
	-State $state `
	-StreetAddress $streetaddress `
 	-OfficePhone $telephone `
 	-EmailAddress $email `
	-Title $jobtitle `
 	-Department $department `
	Office $Office `
	-Profilepath $UserProfiles `
	-HomeDrive $UserDrive `
	-HomeDirectory $UserHome `
	-AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
# Commando om de Userprofile toe te voegen
Set-ADUser -Identity $Username -HomeDirectory ("\\DC174376\UserFolders$\" + $Username) }}
mkdir $UserHome

#De gebruikers in de OU's worden toegevoegd aan de juiste Globale groep
write-host -foregroundColor green -object "De users worden aan de betreffende GG group toegevoegd, zodat het AGDLP princiepe compleet is!"
Get-ADUser -SearchBase ‘OU=Directie,OU=Afdelingen,DC=Aventus174376,DC=local’ -Filter * | ForEach-Object {Add-ADGroupMember -Identity ‘GG_Directie’ -Members $_ }
Get-ADUser -SearchBase ‘OU=Automatisering,OU=Afdelingen,DC=Aventus174376,DC=local’ -Filter * | ForEach-Object {Add-ADGroupMember -Identity ‘GG_Automatisering’ -Members $_ }
Get-ADUser -SearchBase ‘OU=Verkoop,OU=Afdelingen,DC=Aventus174376,DC=local’ -Filter * | ForEach-Object {Add-ADGroupMember -Identity ‘GG_Verkoop’ -Members $_ }
Get-ADUser -SearchBase ‘OU=FabricageBudel,OU=Productie,OU=Afdelingen,DC=Aventus174376,DC=local’ -Filter * | ForEach-Object {Add-ADGroupMember -Identity ‘GG_FabricageBudel’ -Members $_ }
Get-ADUser -SearchBase ‘OU=Staf,OU=Afdelingen,DC=Aventus174376,DC=local’ -Filter * | ForEach-Object {Add-ADGroupMember -Identity ‘GG_Staf’ -Members $_ }
Get-ADUser -SearchBase ‘OU=Productie,OU=Afdelingen,DC=Aventus174376,DC=local’ -Filter * | ForEach-Object {Add-ADGroupMember -Identity ‘GG_Productie’ -Members $_ }
Get-ADUser -SearchBase ‘OU=Administratie,OU=Afdelingen,DC=Aventus174376,DC=local’ -Filter * | ForEach-Object {Add-ADGroupMember -Identity ‘GG_Administratie’ -Members $_ }

#UserFolders worden aangemaakt
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
Cls
  Write-warning "This script needs to be run As Admin go back and Run as admin"
Start-Sleep -Seconds 5
Exit
}
$users= get-ADUser -filter *
Foreach($user in $users)
{
$user=$user.samaccountname
$HomeDir ="\\DC174376\UserFolders$\$($user)" -f $user; <#change it with your servername with actual server I am using the local computer itself in this example #>
Set-ADUser $user -HomeDirectory $HomeDir -HomeDrive z;
if (-not (Test-Path "$homedir"))
        {
    $acl = Get-Acl (New-Item -Path $homedir -ItemType Directory)



    # Make sure access rules inherited from parent folders.
    $acl.SetAccessRuleProtection($false, $true)



   $ace = "$domain\$user","FullControl", "ContainerInherit,ObjectInherit","None","Allow"
    $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($ace)
    $acl.AddAccessRule($objACE)
Set-ACL -Path "$homedir" -AclObject $acl
}}

