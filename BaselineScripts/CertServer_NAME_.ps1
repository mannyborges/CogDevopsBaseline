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