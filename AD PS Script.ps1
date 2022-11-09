#New Project PS script to get all information from AD and set it as a HTML Report
#
.SYNOPSIS
    Generate graphed report for all Active Directory objects.

.DESCRIPTION
    Generate graphed report for all Active Directory objects.

.PARAMETER CompanyLogo
    Enter URL or UNC path to your desired Company Logo for generated report.

    -CompanyLogo "\\Server01\Admin\Files\CompanyLogo.png"

.PARAMETER RightLogo
    Enter URL or UNC path to your desired right-side logo for generated report.

    -RightLogo "https://www.psmpartners.com/wp-content/uploads/2017/10/porcaro-stolarek-mete.png"

.PARAMETER ReportTitle
    Enter desired title for generated report.

    -ReportTitle "Active Directory Report"

.PARAMETER Days
    Users that have not logged in [X] amount of days or more.

    -Days "30"

.PARAMETER UserCreatedDays
    Users that have been created within [X] amount of days.

    -UserCreatedDays "7"

.PARAMETER DaysUntilPWExpireINT
    Users password expires within [X] amount of days

    -DaysUntilPWExpireINT "7"

.PARAMETER ADModNumber
    Active Directory Objects that have been modified within [X] amount of days.

    -ADModNumber "3"

.NOTES
    Version: 1.0.3
    Author: Bradley Wyatt
    Date: 12/4/2018
    Modified: JBear 12/5/2018
    Bradley Wyatt 12/8/2018
    jporgand 12/6/2018
#>

param (
	
	#Company logo that will be displayed on the left, can be URL or UNC
	[Parameter(ValueFromPipeline = $true, HelpMessage = "Enter URL or UNC path to Company Logo")]
	[String]$CompanyLogo = "",
	#Logo that will be on the right side, UNC or URL

	[Parameter(ValueFromPipeline = $true, HelpMessage = "Enter URL or UNC path for Side Logo")]
	[String]$RightLogo = "https://www.psmpartners.com/wp-content/uploads/2017/10/porcaro-stolarek-mete.png",
	#Title of generated report

	[Parameter(ValueFromPipeline = $true, HelpMessage = "Enter desired title for report")]
	[String]$ReportTitle = "Active Directory Report",
	#Location the report will be saved to

	[Parameter(ValueFromPipeline = $true, HelpMessage = "Enter desired directory path to save; Default: C:\Automation\")]
	[String]$ReportSavePath = "C:\Automation\",
	#Find users that have not logged in X Amount of days, this sets the days

	[Parameter(ValueFromPipeline = $true, HelpMessage = "Users that have not logged on in more than [X] days. amount of days; Default: 30")]
	$Days = 30,
	#Get users who have been created in X amount of days and less

	[Parameter(ValueFromPipeline = $true, HelpMessage = "Users that have been created within [X] amount of days; Default: 7")]
	$UserCreatedDays = 7,
	#Get users whos passwords expire in less than X amount of days

	[Parameter(ValueFromPipeline = $true, HelpMessage = "Users password expires within [X] amount of days; Default: 7")]
	$DaysUntilPWExpireINT = 7,
	#Get AD Objects that have been modified in X days and newer

	[Parameter(ValueFromPipeline = $true, HelpMessage = "AD Objects that have been modified within [X] amount of days; Default: 3")]
	$ADModNumber = 3
	
	#CSS template located C:\Program Files\WindowsPowerShell\Modules\ReportHTML\1.4.1.1\
	#Default template is orange and named "Sample"
)

Write-Host "Gathering Report Customization..." -ForegroundColor White
Write-Host "__________________________________" -ForegroundColor White
(Write-Host -NoNewline "Company Logo (left): " -ForegroundColor Yellow), (Write-Host  $CompanyLogo -ForegroundColor White)
(Write-Host -NoNewline "Company Logo (right): " -ForegroundColor Yellow), (Write-Host  $RightLogo -ForegroundColor White)
(Write-Host -NoNewline "Report Title: " -ForegroundColor Yellow), (Write-Host  $ReportTitle -ForegroundColor White)
(Write-Host -NoNewline "Report Save Path: " -ForegroundColor Yellow), (Write-Host  $ReportSavePath -ForegroundColor White)
(Write-Host -NoNewline "Amount of Days from Last User Logon Report: " -ForegroundColor Yellow), (Write-Host  $Days -ForegroundColor White)
(Write-Host -NoNewline "Amount of Days for New User Creation Report: " -ForegroundColor Yellow), (Write-Host  $UserCreatedDays -ForegroundColor White)
(Write-Host -NoNewline "Amount of Days for User Password Expiration Report: " -ForegroundColor Yellow), (Write-Host  $DaysUntilPWExpireINT -ForegroundColor White)
(Write-Host -NoNewline "Amount of Days for Newly Modified AD Objects Report: " -ForegroundColor Yellow), (Write-Host  $ADModNumber -ForegroundColor White)
Write-Host "__________________________________" -ForegroundColor White

function LastLogonConvert ($ftDate)
{
	
	$Date = [DateTime]::FromFileTime($ftDate)
	
	if ($Date -lt (Get-Date '1/1/1900') -or $date -eq 0 -or $date -eq $null)
	{
		
		"Never"
	}
	
	else
	{
		
		$Date
	}
	
} #End function LastLogonConvert

#Check for ReportHTML Module
$Mod = Get-Module -ListAvailable -Name "ReportHTML"

If ($null -eq $Mod)
{
	
	Write-Host "ReportHTML Module is not present, attempting to install it"
	
	Install-Module -Name ReportHTML -Force
	Import-Module ReportHTML -ErrorAction SilentlyContinue
}

#Array of default Security Groups
$DefaultSGs = @(
	
	"Access Control Assistance Operators"
	"Account Operators"
	"Administrators"
	"Allowed RODC Password Replication Group"
	"Backup Operators"
	"Certificate Service DCOM Access"
	"Cert Publishers"
	"Cloneable Domain Controllers"
	"Cryptographic Operators"
	"Denied RODC Password Replication Group"
	"Distributed COM Users"
	"DnsUpdateProxy"
	"DnsAdmins"
	"Domain Admins"
	"Domain Computers"
	"Domain Controllers"
	"Domain Guests"
	"Domain Users"
	"Enterprise Admins"
	"Enterprise Key Admins"
	"Enterprise Read-only Domain Controllers"
	"Event Log Readers"
	"Group Policy Creator Owners"
	"Guests"
	"Hyper-V Administrators"
	"IIS_IUSRS"
	"Incoming Forest Trust Builders"
	"Key Admins"
	"Network Configuration Operators"
	"Performance Log Users"
	"Performance Monitor Users"
	"Print Operators"
	"Pre-Windows 2000 Compatible Access"
	"Protected Users"
	"RAS and IAS Servers"
	"RDS Endpoint Servers"
	"RDS Management Servers"
	"RDS Remote Access Servers"
	"Read-only Domain Controllers"
	"Remote Desktop Users"
	"Remote Management Users"
	"Replicator"
	"Schema Admins"
	"Server Operators"
	"Storage Replica Administrators"
	"System Managed Accounts Group"
	"Terminal Server License Servers"
	"Users"
	"Windows Authorization Access Group"
	"WinRMRemoteWMIUsers"
)

$Table = New-Object 'System.Collections.Generic.List[System.Object]'
$OUTable = New-Object 'System.Collections.Generic.List[System.Object]'
$UserTable = New-Object 'System.Collections.Generic.List[System.Object]'
$GroupTypetable = New-Object 'System.Collections.Generic.List[System.Object]'
$DefaultGrouptable = New-Object 'System.Collections.Generic.List[System.Object]'
$EnabledDisabledUsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$DomainAdminTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ExpiringAccountsTable = New-Object 'System.Collections.Generic.List[System.Object]'
$CompanyInfoTable = New-Object 'System.Collections.Generic.List[System.Object]'
$securityeventtable = New-Object 'System.Collections.Generic.List[System.Object]'
$DomainTable = New-Object 'System.Collections.Generic.List[System.Object]'
$OUGPOTable = New-Object 'System.Collections.Generic.List[System.Object]'
$GroupMembershipTable = New-Object 'System.Collections.Generic.List[System.Object]'
$PasswordExpirationTable = New-Object 'System.Collections.Generic.List[System.Object]'
$PasswordExpireSoonTable = New-Object 'System.Collections.Generic.List[System.Object]'
$userphaventloggedonrecentlytable = New-Object 'System.Collections.Generic.List[System.Object]'
$EnterpriseAdminTable = New-Object 'System.Collections.Generic.List[System.Object]'
$NewCreatedUsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$GroupProtectionTable = New-Object 'System.Collections.Generic.List[System.Object]'
$OUProtectionTable = New-Object 'System.Collections.Generic.List[System.Object]'
$GPOTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ADObjectTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ProtectedUsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ComputersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ComputerProtectedTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ComputersEnabledTable = New-Object 'System.Collections.Generic.List[System.Object]'
$DefaultComputersinDefaultOUTable = New-Object 'System.Collections.Generic.List[System.Object]'
$DefaultUsersinDefaultOUTable = New-Object 'System.Collections.Generic.List[System.Object]'
$TOPUserTable = New-Object 'System.Collections.Generic.List[System.Object]'
$TOPGroupsTable = New-Object 'System.Collections.Generic.List[System.Object]'
$TOPComputersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$GraphComputerOS = New-Object 'System.Collections.Generic.List[System.Object]'

#Get all users right away. Instead of doing several lookups, we will use this object to look up all the information needed.
$AllUsers = Get-ADUser -Filter * -Properties *

$GPOs = Get-GPO -All | Select-Object DisplayName, GPOStatus, ModificationTime, @{ Label = "ComputerVersion"; Expression = { $_.computer.dsversion } }, @{ Label = "UserVersion"; Expression = { $_.user.dsversion } }

<###########################
         Dashboard
############################>

Write-Host "Working on Dashboard Report..." -ForegroundColor Green

$dte = (Get-Date).AddDays(- $ADModNumber)

$ADObjs = Get-ADObject -Filter { whenchanged -gt $dte -and ObjectClass -ne "domainDNS" -and ObjectClass -ne "rIDManager" -and ObjectClass -ne "rIDSet" } -Properties *

foreach ($ADObj in $ADObjs)
{
	
	if ($ADObj.ObjectClass -eq "GroupPolicyContainer")
	{
		
		$Name = $ADObj.DisplayName
	}
	
	else
	{
		
		$Name = $ADObj.Name
	}
	
	$obj = [PSCustomObject]@{
		
		'Name'	      = $Name
		'Object Type' = $ADObj.ObjectClass
		'When Changed' = $ADObj.WhenChanged
	}
	
	$ADObjectTable.Add($obj)
}
if (($ADObjectTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No AD Objects have been modified recently'
	}
	
	$ADObjectTable.Add($obj)
}


$ADRecycleBinStatus = (Get-ADOptionalFeature -Filter 'name -like "Recycle Bin Feature"').EnabledScopes

if ($ADRecycleBinStatus.Count -lt 1)
{
	
	$ADRecycleBin = "Disabled"
}

else
{
	
	$ADRecycleBin = "Enabled"
}

#Company Information
$ADInfo = Get-ADDomain
$ForestObj = Get-ADForest
$DomainControllerobj = Get-ADDomain
$Forest = $ADInfo.Forest
$InfrastructureMaster = $DomainControllerobj.InfrastructureMaster
$RIDMaster = $DomainControllerobj.RIDMaster
$PDCEmulator = $DomainControllerobj.PDCEmulator
$DomainNamingMaster = $ForestObj.DomainNamingMaster
$SchemaMaster = $ForestObj.SchemaMaster

$obj = [PSCustomObject]@{
	
	'Domain'			    = $Forest
	'AD Recycle Bin'	    = $ADRecycleBin
	'Infrastructure Master' = $InfrastructureMaster
	'RID Master'		    = $RIDMaster
	'PDC Emulator'		    = $PDCEmulator
	'Domain Naming Master'  = $DomainNamingMaster
	'Schema Master'		    = $SchemaMaster
}

$CompanyInfoTable.Add($obj)

if (($CompanyInfoTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: Could not get items for table'
	}
	$CompanyInfoTable.Add($obj)
}

#Get newly created users
$When = ((Get-Date).AddDays(- $UserCreatedDays)).Date
$NewUsers = $AllUsers | Where-Object { $_.whenCreated -ge $When }

foreach ($Newuser in $Newusers)
{
	
	$obj = [PSCustomObject]@{
		
		'Name' = $Newuser.Name
		'Enabled' = $Newuser.Enabled
		'Creation Date' = $Newuser.whenCreated
	}
	
	$NewCreatedUsersTable.Add($obj)
}
if (($NewCreatedUsersTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No new users have been recently created'
	}
	$NewCreatedUsersTable.Add($obj)
}



#Get Domain Admins
$DomainAdminMembers = Get-ADGroupMember "Domain Admins"

foreach ($DomainAdminMember in $DomainAdminMembers)
{
	
	$Name = $DomainAdminMember.Name
	$Type = $DomainAdminMember.ObjectClass
	$Enabled = ($AllUsers | Where-Object { $_.Name -eq $Name }).Enabled
	
	$obj = [PSCustomObject]@{
		
		'Name'    = $Name
		'Enabled' = $Enabled
		'Type'    = $Type
	}
	
	$DomainAdminTable.Add($obj)
}

if (($DomainAdminTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No Domain Admin Members were found'
	}
	$DomainAdminTable.Add($obj)
}


#Get Enterprise Admins
$EnterpriseAdminsMembers = Get-ADGroupMember "Enterprise Admins" -Server $SchemaMaster

foreach ($EnterpriseAdminsMember in $EnterpriseAdminsMembers)
{
	
	$Name = $EnterpriseAdminsMember.Name
	$Type = $EnterpriseAdminsMember.ObjectClass
	$Enabled = ($AllUsers | Where-Object { $_.Name -eq $Name }).Enabled
	
	$obj = [PSCustomObject]@{
		
		'Name'    = $Name
		'Enabled' = $Enabled
		'Type'    = $Type
	}
	
	$EnterpriseAdminTable.Add($obj)
}

if (($EnterpriseAdminTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: Enterprise Admin members were found'
	}
	$EnterpriseAdminTable.Add($obj)
}

$DefaultComputersOU = (Get-ADDomain).computerscontainer
$DefaultComputers = Get-ADComputer -Filter * -Properties * -SearchBase "$DefaultComputersOU"

foreach ($DefaultComputer in $DefaultComputers)
{
	
	$obj = [PSCustomObject]@{
		
		'Name' = $DefaultComputer.Name
		'Enabled' = $DefaultComputer.Enabled
		'Operating System' = $DefaultComputer.OperatingSystem
		'Modified Date' = $DefaultComputer.Modified
		'Password Last Set' = $DefaultComputer.PasswordLastSet
		'Protect from Deletion' = $DefaultComputer.ProtectedFromAccidentalDeletion
	}
	
	$DefaultComputersinDefaultOUTable.Add($obj)
}

if (($DefaultComputersinDefaultOUTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No computers were found in the Default OU'
	}
	$DefaultComputersinDefaultOUTable.Add($obj)
}

$DefaultUsersOU = (Get-ADDomain).UsersContainer
$DefaultUsers = $Allusers | Where-Object { $_.DistinguishedName -like "*$($DefaultUsersOU)" } | Select-Object Name, UserPrincipalName, Enabled, ProtectedFromAccidentalDeletion, EmailAddress, @{ Name = 'lastlogon'; Expression = { LastLogonConvert $_.lastlogon } }, DistinguishedName

foreach ($DefaultUser in $DefaultUsers)
{
	
	$obj = [PSCustomObject]@{
		
		'Name' = $DefaultUser.Name
		'UserPrincipalName' = $DefaultUser.UserPrincipalName
		'Enabled' = $DefaultUser.Enabled
		'Protected from Deletion' = $DefaultUser.ProtectedFromAccidentalDeletion
		'Last Logon' = $DefaultUser.LastLogon
		'Email Address' = $DefaultUser.EmailAddress
	}
	
	$DefaultUsersinDefaultOUTable.Add($obj)
}
if (($DefaultUsersinDefaultOUTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No Users were found in the default OU'
	}
	$DefaultUsersinDefaultOUTable.Add($obj)
}


#Expiring Accounts
$LooseUsers = Search-ADAccount -AccountExpiring -UsersOnly

foreach ($LooseUser in $LooseUsers)
{
	
	$NameLoose = $LooseUser.Name
	$UPNLoose = $LooseUser.UserPrincipalName
	$ExpirationDate = $LooseUser.AccountExpirationDate
	$enabled = $LooseUser.Enabled
	
	$obj = [PSCustomObject]@{
		
		'Name'			    = $NameLoose
		'UserPrincipalName' = $UPNLoose
		'Expiration Date'   = $ExpirationDate
		'Enabled'		    = $enabled
	}
	
	$ExpiringAccountsTable.Add($obj)
}

if (($ExpiringAccountsTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No Users were found to expire soon'
	}
	$ExpiringAccountsTable.Add($obj)
}

#Security Logs
$SecurityLogs = Get-EventLog -Newest 7 -LogName "Security" | Where-Object { $_.Message -like "*An account*" }

foreach ($SecurityLog in $SecurityLogs)
{
	
	$TimeGenerated = $SecurityLog.TimeGenerated
	$EntryType = $SecurityLog.EntryType
	$Recipient = $SecurityLog.Message
	
	$obj = [PSCustomObject]@{
		
		'Time'    = $TimeGenerated
		'Type'    = $EntryType
		'Message' = $Recipient
	}
	
	$SecurityEventTable.Add($obj)
}

if (($SecurityEventTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No logon security events were found'
	}
	$SecurityEventTable.Add($obj)
}

#Tenant Domain
$Domains = Get-ADForest | Select-Object -ExpandProperty upnsuffixes | ForEach-Object{
	
	$obj = [PSCustomObject]@{
		
		'UPN Suffixes' = $_
		Valid		   = "True"
	}
	
	$DomainTable.Add($obj)
}
if (($DomainTable).Count -eq 0)
{
	
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No UPN Suffixes were found'
	}
	$DomainTable.Add($obj)
}
