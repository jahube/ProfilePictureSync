#################################################################################################################################################
# credential Path %UserProfile%\Documents\MyCredential.xml
$Credpath = "$ENV:UserProfile\Documents\MyCredential.xml"
#################################################################################################################################################
# SAVE credential %UserProfile%\Documents\MyCredential.xml
if (!(Test-Path -Path $Credpath -PathType Leaf)) { Get-Credential | Export-Clixml $ENV:UserProfile\Documents\MyCredential.xml }
#################################################################################################################################################
# READ credential %UserProfile%\Documents\MyCredential.xml
$cred = Import-Clixml $ENV:UserProfile\Documents\MyCredential.xml
#################################################################################################################################################
# Exchange PS V2  check
IF(!@(Get-PSSession | where { $_.State -ne "broken" } )) {
IF(!@(Get-InstalledModule ExchangeOnlineManagement -ErrorAction SilentlyContinue)) { install-module exchangeonlinemanagement -Scope CurrentUser }
IF(!@($Credentials)) {$Credentials = Get-credential } ; IF(!@($ADMIN)) {$ADMIN = $Credentials.UserName }
Try { Connect-ExchangeOnline -Credential $Credentials -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $ADMIN } }
#################################################################################################################################################
# AzureAD Version Update check
IF (get-installedmodule AzureAD -EA SilentlyContinue) { Uninstall-Module AzureAD -Force }
IF (!(get-installedmodule AzureADPreview)) {

  Try { Install-Module AzureADPreview -Repository 'PSGallery' -Force -CF:$false -EA stop } 
catch {  Install-Module AzureADPreview -Repository 'PSGallery' -Force -Scope CurrentUser } }
#################################################################################################################################################
Connect-AzureAD -Credential $cred
#################################################################################################################################################
$Users = Get-AzureADUser | Where {$_.UserType -eq 'Member' -and $_.AssignedLicenses -ne $null}
#################################################################################################################################################
$NoPictureUsers = @()

foreach ($user in $Users) 
{
    $Picture = Get-UserPhoto -Identity $user.UserPrincipalName -ErrorAction SilentlyContinue

    if ($Picture -eq $null)
    {
        $NoPictureUsers += $user
    }
}
$NoPictureUsers | Select DisplayName, UserPrincipalName | Export-Csv -Path $ENV:UserProfile\Documents\UsersWithNoPicture.csv –NoTypeInformation
#################################################################################################################################################