########################################################################################################
#
#
#	
#
#   DO NOT forget to include common baseline library
#
#	Note - this must be run directly on the server that needs to be baselined
#	Prerequisites:
#      - Windows Server 
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
#. $Path\include\software.base.ps1  # future library when needed
. $Path\include\role.shared.base.ps1  # common role baseline functions usable on all servers
. $Path\include\role.jump.base.ps1    # functions that  are specific to jump servers 






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
Check-WindowsFeatures-Jump

#STEP Remove Features not needed on Jump boxes
Remove-WindowsFeatures-Jump

# STEP: In QA & DEV enable PS remoting
Check-PSRemoting

# STEP: Check daylight savings time
# Check-DST


# STEP: Check administrators
Check-Administrators

# STEP: Check Event Log Readers
Check-EventLogReaders



#$Script:ValidateOnly = $true
#Write-Log "Checking directory permissions...."

Check-DirectoriesAndPermissions-Jump

#$Script:ValidateOnly = $SaveValidateOnly


# STEP: Check essential network shares
Check-NetworkShares-Jump



# STEP: Check Application log size (128MB)
Check-ApplicationLog


# STEP: Check Scheduled Tasks
Check-ScheduledTasks-Jump


# STEP: print manual steps to be done
Check-ManualSteps-Jump


########################################################################################################
#  FINAL STEPS - IMPORTANT !!!!
########################################################################################################
Do-FinalSteps