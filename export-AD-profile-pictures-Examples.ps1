##################################################################################################################################################
# https://devblogs.microsoft.com/scripting/weekend-scripter-exporting-and-importing-photos-in-active-directory/
##################################################################################################################################################

$Picture=[System.IO.File]::ReadAllBytes('C:\Photos\sean.jpg')

SET-ADUser SeanK –add @{thumbnailphoto=$Picture}

##################################################################################################################################################
# "If you had this information in Active Directory and you need to export it (for any reason at all), we can do that too."
# "First we grab the User object from Active Directory:"
##################################################################################################################################################

$User=GET-ADUser SeanK –properties thumbnailphoto
##################################################################################################################################################
# "Then we export the information with a little more .NET magic:"
##################################################################################################################################################

$Filename='C:\Photos\Export.jpg'

[System.Io.File]::WriteAllBytes($Filename, $User.Thumbnailphoto)

##################################################################################################################################################
# "We could even go so far as to export all the photos in Active Directory to the file system:"
##################################################################################################################################################

$list=GET-ADuser –filter * -properties thumbnailphoto

Foreach ($User in $list)

{

$Directory='C:\Photos\'

If ($User.thumbnailphoto)

  {

  $Filename=$Directory+$User.samaccountname+'.jpg'

  [System.Io.File]::WriteAllBytes($Filename, $User.Thumbnailphoto)

  }

}

##################################################################################################################################################
# https://www.reddit.com/r/PowerShell/comments/5u0imh/check_if_ad_users_have_a_thumbnailphoto/
##################################################################################################################################################

Import-Module ActiveDirectory
$AllUsers = get-aduser -filter { objectClass -eq "User" -and Enabled -eq "True"} -Properties SamAccountName | select SamAccountName
$WithPhotos = get-aduser -filter { objectClass -eq "User" -and Enabled -eq "True" -and thumbnailPhoto -ne "NULL" } -Properties SamAccountName | select SamAccountName
$WithoutPhotos = Compare-Object -ReferenceObject $WithPhotos -DifferenceObject $AllUsers -PassThru  

##################################################################################################################################################
$WithoutPhotos = Get-ADUser -Filter {ObjectClass -eq "User" -and Enabled -eq $True -and thumbnailPhoto -notlike "*"} | select SamAccountName
##################################################################################################################################################
# https://clan8blog.wordpress.com/2018/02/28/extracting-photos-from-ad/
##################################################################################################################################################
cls
$ldapFilter = "(&(employeeID=*)(sAMAccountType=805306368)(thumbnailPhoto=*)(!(|(userAccountControl:1.2.840.113556.1.4.803:=2))))"
$searchRoot = "OU=User Accounts,DC=MyADDomain,DC=com"
$useADCommandlets = $false
$sizelimit = 0
$OutputPath = 'c:\Temp\Photos'
Function ConvertTo-Jpeg {
 param ($userName,$photoAsBytes,$path='c:\temp')
 if ( ! ( Test-Path $path ) ) { New-Item $path -ItemType Directory }
 $Filename="$($path)\$($userName).jpg"
 [System.Io.File]::WriteAllBytes( $Filename,$photoAsBytes )
}
 
if ( $useADCommandlets ) {
 #Import-Module ActiveDirectory
 $Users = GET-ADUser -LDAPFilter $ldapFilter  -Properties thumbnailPhoto # | select -First $sizelimit # remove the select to get all users 
 ForEach ( $User in $Users ) {
  ConvertTo-Jpeg -userName $user.SamAccountName -photoAsBytes $user.thumbnailPhoto -path $OutputPath
 }
}
else {
 $Users = get-qaduser  -LdapFilter $ldapFilter -SearchRoot $searchRoot -DontUseDefaultIncludedProperties -DontConvertValuesToFriendlyRepresentation  -IncludedProperties thumbnailphoto -SizeLimit $sizelimit   # set sizelimit to 0 to get all users
 ForEach ( $User in $Users ) {
  #ConvertTo-Jpeg -userName $user.SamAccountName -photoAsBytes $user.DirectoryEntry.thumbnailPhoto.Value -path $OutputPath # if you didn't use the -DontConvertValuesToFriendlyRepresentation switch 
  ConvertTo-Jpeg -userName $user.SamAccountName -photoAsBytes $user.thumbnailPhoto -path $OutputPath
 }
}
##################################################################################################################################################

<# Source https://devblogs.microsoft.com/scripting/weekend-scripter-exporting-and-importing-photos-in-active-directory/
# https://social.technet.microsoft.com/Forums/en-US/b5a6d825-c3ef-43b8-bf17-19b87b583507/windows-8-account-picture
# https://jocha.se/blog/tech/ad-user-pictures-in-windows-10
# https://msitpros.com/?p=1036
http://www.cjwdev.co.uk/Software/ADPhotoEdit/Info.html
# https://blog.cjwdev.co.uk/2010/11/03/the-thumbnailphoto-attribute-explained/
http://deployment.xtremeconsulting.com/2010/06/23/usertile-automation-part-1/
https://www.sevenforums.com/tutorials/5187-user-account-picture-change.html
https://docs.microsoft.com/en-us/archive/blogs/ilvancri/upload-picture-in-outlook-2010-using-the-exchange-management-shell-exchange-2010
https://www.allabout365.com/2010/12/enabling-outlook-2003-and-2007-to-display-exchange-gal-photos/

Sharepoint
https://www.arricc.net/active-directory-photos-sharepoint.php
https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/primary-tile-apis
https://richardjgreen.net/programmatically-set-windows-7-user-account-picture/
http://networksteve.com/forum/topic.php/Add_photos_to_AD/?TopicId=71731&Posts=8
https://social.technet.microsoft.com/Forums/en-US/d6e7b2c3-c343-4900-a01d-24bfb30357b6/is-there-a-solution-to-set-user-account-picture-from-active-directory-thumbnailphoto-attribute-in?forum=w8itproinstall
https://www.reddit.com/r/PowerShell/comments/5u0imh/check_if_ad_users_have_a_thumbnailphoto/
https://theezitguy.wordpress.com/2014/08/14/getset-active-directory-photos-by-using-powershell/
https://clan8blog.wordpress.com/2018/02/28/extracting-photos-from-ad/ #>