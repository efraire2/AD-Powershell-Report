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