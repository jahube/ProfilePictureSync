#################################################################################################################################################
# Picture sync - Mustread - https://support.microsoft.com/en-us/office/information-about-profile-picture-synchronization-in-microsoft-365-20594d76-d054-4af4-a660-401133e3d48a
#################################################################################################################################################
# Issue descr. - Mustread - https://docs.microsoft.com/en-us/exchange/troubleshoot/administration/user-photos-not-synced-to-exchange-online
#################################### References #################################################################################################
# resize image https://gist.github.com/someshinyobject/617bf00556bc43af87cd
# https://social.technet.microsoft.com/Forums/ie/en-US/033b1a17-dec3-41bd-b0e1-a13bbdf4484b/how-to-resize-an-image-using-powershell?forum=winserverpowershell
# https://techcommunity.microsoft.com/t5/sharepoint/syncing-profile-pictures-with-office-365-and-active-directory/m-p/644726
# https://techcommunity.microsoft.com/t5/microsoft-teams/profile-pictures-not-updating-syncing-in-teams/m-p/1361273
# https://techcommunity.microsoft.com/t5/microsoft-teams/microsoft-teams-profile-picture-is-not-fully-syncing/m-p/1822179
# https://techcommunity.microsoft.com/t5/microsoft-teams/teams-profile-photos-replaced-by-placeholder/m-p/1359301
###################################### credential Path %UserProfile%\Documents\MyCredential.xml ################################################
$Credpath = "$ENV:UserProfile\Documents\MyCredential.xml"
#################################### SAVE credential %UserProfile%\Documents\MyCredential.xml ##################################################
if (!(Test-Path -Path $Credpath -PathType Leaf)) { Get-Credential | Export-Clixml $ENV:UserProfile\Documents\MyCredential.xml }
#################################### READ credential %UserProfile%\Documents\MyCredential.xml ##################################################
$cred = Import-Clixml $ENV:UserProfile\Documents\MyCredential.xml
################################################################################################################################################
# Exchange PS V2  check
IF(!@(Get-PSSession | where { $_.State -ne "broken" } )) {
IF(!@(Get-InstalledModule ExchangeOnlineManagement -ErrorAction SilentlyContinue)) { install-module exchangeonlinemanagement -Scope CurrentUser}
IF(!@($Credentials)) {$Credentials = Get-credential } ; IF(!@($ADMIN)) {$ADMIN = $Credentials.UserName }
Try { Connect-ExchangeOnline -Credential $Credentials -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $ADMIN } }
################################################################################################################################################

$path= $path\UsersWithNoPicture2.csv 

$UserPicCSV = Import-csv $path

foreach ($User in $UserPicCSV) {

Set-UserPhoto –Identity $User.UserPrincipalName -PictureData ([System.IO.File]::ReadAllBytes($_.picture)) -Confirm:$false

Set-UserPhoto -Identity $User.UserPrincipalName -Save -Confirm:$False
}
#################################################################################################################################################
# Version 3
#################################################################################################################################################
$path= "C:\Users\YOUR_PATH "
$CSV = Import-csv $path\UsersWithNoPicture2.csv 
$CSV | %{
Set-UserPhoto –Identity $_.UserPrincipalName -PictureData ([Byte[]] $(Get-Content -Path "$path\($_.picture)" -Encoding Byte -ReadCount 0)) -Preview -Confirm:$false |
Set-UserPhoto -Identity $_.UserPrincipalName -Save -Confirm:$False
}

#################################################################################################################################################
# SOURCE  https://community.spiceworks.com/topic/2186604-create-loop-to-try-set-userphoto
#################################################################################################################################################

$timer = [diagnostics.stopwatch]::startnew()
while ($timer.elapsed.totalseconds -lt 60)
{
Try
{
	$prevErrorActionPreference = $global:ErrorActionPreference
	$global:ErrorActionPreference = 'Stop'
	Set-UserPhoto -Identity $script:newuser.SamAccountName -PictureData $photo -Preview -Confirm:$False -DomainController $ADServer -ErrorAction Stop
	Set-UserPhoto -Identity $script:newuser.SamAccountName -Save -Confirm:$False -DomainController $ADServer -ErrorAction Stop
	Break
}
									
	Catch
{
	start-sleep -seconds 5
}
Finally
{
	$timer.stop()
	$global:ErrorActionPreference = $prevErrorActionPreference
}
#################################################################################################################################################