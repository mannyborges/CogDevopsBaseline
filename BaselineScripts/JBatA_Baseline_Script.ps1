########################################################################################################
#
#
#	
#
#   DO NOT forget to include common baseline library
#
#	Note - this must be run directly on the server that needs to be baselined
#	Prerequisites:
#      - Windows Server 2008 R2 (PowerShell v2.0 included)
#            (Module ServerManager only in W2K8 R2 and up)
#            (try-catch only in PowerShell v2.0)
#      - You must Set-ExecutionPolicy "Unrestricted" or "Bypass" before running script
#            (PS> Set-ExecutionPolicy Unrestricted)
#
#
########################################################################################################



########################################################################################################
#  Including base libraries
########################################################################################################
$Path = Split-Path -parent $MyInvocation.MyCommand.Definition
. $Path\include\common.base.ps1
. $Path\include\software.base.ps1
. $Path\include\cluster.shared.base.ps1
. $Path\include\cluster.jbata.base.ps1






########################################################################################################
#  INITIAL STEPS - IMPORTANT !!!!
########################################################################################################
Do-InitialSteps



##########################################################
# Ensure Powershell versin is at correct level           # 
##########################################################
Check-PowerShell5



########################################################################################################
#  General Script
########################################################################################################



# STEP: Windows Features and Roles
Check-WindowsFeatures-JBAT

# STEP: In QA & DEV enable PS remoting
Check-PSRemoting

# STEP: Check daylight savings time
Check-DST

# STEP: Check MSDeploy 3.5
Check-MSDeploy35

# STEP: Check LogParser 2.2
Check-LogParser22

# STEP: Check MSXML 4.0 SP3 Parser Uninstall
Check-MSXMLParser40SP3-Uninstall

# STEP: Check administrators
Check-Administrators

# STEP: Check Event Log Readers
Check-EventLogReaders

# STEP: checking essential directories with permissions
#$SaveValidateOnly = $Script:ValidateOnly

#$Script:ValidateOnly = $true
#Write-Log "Checking directory permissions.... No Updates here!!!!!!!!!!!!!!!"

Check-DirectoriesAndPermissions-JBAT
Check-DirectoriesAndPermissions-JBATA

#$Script:ValidateOnly = $SaveValidateOnly


# STEP: Check essential network shares
Check-NetworkShares-JBATA



# STEP: Check Application log size (128MB)
Check-ApplicationLog

# STEP: Check IIS
Check-IISRootFolder
Check-IISLogDirectory
Check-IISHttpErrorsLocation
Check-IISFoldersPermissions
Check-IISAppPool32BitMode
Check-IISAppcmdPATH
Check-IISDefaultWebSite
Check-IISDefaultDocuments-Monster2.0

# STEP: Check Machine Key (might be needed by SafeNet)
Check-MachineKey

# STEP: Check Exception Management
Check-ConfigureExceptionMgmt

# STEP: Check-dotNetv46
Check-dotNetv46

# STEP: Safenet
Check-Safenet511

# STEP: Check Java  
Check-Java-JBATA

# STEP: Java 1.7.0.13 32bit version
#  32 bit not needed
Check-JAVA-1-6-Not-In-Path

# STEP: Apache Ant
Check-Apache-Ant-1-7-0

# STEP: Apache Tomcat 
Check-Apache-Tomcat-7-0-35-x64

# STEP: safenet for java
Check-Java8-SafeNet511
Check-Safenet-GlobalFrameworkConfig-JBATA

# STEP: WinSCP client
Check-WinScpClient

# STEP: Check Winzip 12.1
Check-WinZip12.1

# STEP: Check d:\{LOCALE}\businessgateway\BGW.config
Check-BGWConfig-JBAT

# STEP: Check FileTransferService
Check-FileTransferService-JBATA

# STEP: Check Scheduled Tasks
Check-ScheduledTasks-JBATA

# STEP: Check Java based Scheduled Tasks
Check-JavaBasedScheduledTasks-JBATA

# STEP: Check BgwKitsInstall scheduled task
Check-BgwKitsInstallScheduledTask-JBATA

# STEP: Check registry setting for DisableStrictNameChecking
Check-DisableStrictNameChecking

# STEP: Check that BackConnectionHostNames is set up for bgwbatch.internal.monster.com
Check-EnableBackConnection-JBATA 

# STEP: Install AppFabric

Check-MSAppFabric-JBATA

# STEP: print manual steps to be done
Check-ManualSteps-JBATA


########################################################################################################
#  FINAL STEPS - IMPORTANT !!!!
########################################################################################################
Do-FinalSteps