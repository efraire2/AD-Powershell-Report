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
