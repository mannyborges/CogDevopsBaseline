########################################################################################################
# 
#
#
#   role SHARED Baseline Library
#
#
#	Use this as include in your specific baseline script
#   Can be done by placing either line at the top of your script (without quotes):
#      ". .\include\role.xxx.base.ps1"
#      ". d:\BaselineScript\include\role.xxx.base.ps1"
#      ". \\server\path\to\role.xxx.base.ps1"
#      (NOTE the DOT at beginning of line!)
#
#
#	Prerequisites:
#      - Windows Server 2008 R2 (PowerShell v2.0 included)
#            (module ServerManager only in W2K8 R2 and up)
#            (try-catch only in PowerShell v2.0)
#      - You must Set-ExecutionPolicy "Unrestricted" or "Bypass" before running script
#            (PS> Set-ExecutionPolicy Unrestricted)
#
#
#   FUNCTIONS LIST:
#      - to get functions list, run:
#        gc role.jump.base.ps1 | select-string "^function|functions - begin$" | foreach { $_.toString() -replace '^function', '#     ' -replace '- begin', '' }
#
#   role SHARED functions

#
########################################################################################################



########################################################################################################
#
#   role SHARED functions - begin
#
########################################################################################################



function Check-WindowsFeatures-Jump()
{
	$Features = 
("FileAndStorage-Services","File-Services","FS-FileServer","Storage-Services",
"NET-Framework-45-Features","NET-Framework-45-Core","NET-WCF-Services45",
"NET-WCF-TCP-PortSharing45","Windows-Defender","RSAT",
"RSAT-Feature-Tools","RSAT-Role-Tools","RSAT-AD-Tools",
"RSAT-AD-PowerShell","RSAT-ADDS","RSAT-AD-AdminCenter",
"RSAT-ADDS-Tools","RSAT-ADLDS","RSAT-Hyper-V-Tools","Hyper-V-Tools",
"Hyper-V-PowerShell","RSAT-RDS-Tools","UpdateServices-RSAT","UpdateServices-API",
"UpdateServices-UI","RSAT-ADCS","RSAT-ADCS-Mgmt","RSAT-Online-Responder","System-DataArchiver",
"WindowsAdminCenterSetup","PowerShellRoot","PowerShell",
"Wireless-Networking","WoW64-Support","XPS-Viewer",   ### adding in RSAT tools for jump boxes ###
"RSAT-Feature-Tools-BitLocker",
"RSAT-Feature-Tools-BitLocker-RemoteAdminTool",
"RSAT-Feature-Tools-BitLocker-BdeAducExt",
"RSAT-Bits-Server",
"RSAT-DataCenterBridging-LLDP-Tools",
"RSAT-Clustering-AutomationServer",
"RSAT-Clustering-CmdInterface",
"RSAT-NLB",
"RSAT-Shielded-VM-Tools",
"RSAT-SNMP",
"RSAT-SMS",
"RSAT-Storage-Replica",
"RSAT-System-Insights",
"RSAT-WINS",
"RSAT-RDS-Gateway",
"RSAT-RDS-Licensing-Diagnosis-UI",
"RSAT-ADRMS",
"RSAT-DHCP",
"RSAT-DNS-Server",
"RSAT-Fax",
"RSAT-File-Services",
"RSAT-DFS-Mgmt-Con",
"RSAT-FSRM-Mgmt",
"RSAT-NFS-Admin",
"RSAT-NetworkController",
"RSAT-NPAS",
"RSAT-Print-Services",
"RSAT-RemoteAccess",
"RSAT-RemoteAccess-Mgmt",
"RSAT-RemoteAccess-PowerShell",
"RSAT-VA-Tools")
	
	Write-Log
	Write-Log -Message "Checking Windows Features and Roles ..."
	Write-Log
	
	Check-WindowsFeatures -Features $Features
}


function Remove-WindowsFeatures-Jump()
{
	$Features = "RSAT-Clustering",
                "RSAT-Clustering-Mgmt",
                "RSAT-Clustering-PowerShell"
	
	Write-Log
	Write-Log -Message "Removing unneeded Windows Features and Roles ..."
	Write-Log
	
	Check-WindowsFeatures-Remove-Features -Features $Features
}

function Check-DirectoriesAndPermissions-Jump ()
{
	Write-Log
	Write-Log -Message "Checking Jump Server specific directory permissions ..."
	Write-Log

	# Check C:\JumpShares
	Check-DirectoryAndPermissions -Path "C:\Drop" -Owner "$Script:DomainName\Administrators" -Permissions @("$Script:DomainName\mborges00,FULL;$Script:DomainName\Administrators,FULL") -Recurse $false

}	

function Check-NetworkShares-Jump ()
{
	Write-Log
	Write-Log -Message "Checking Jump Server specific network shares ..."
	Write-Log

	# Check JumpShares share
	Check-NetworkShare -Share "Drop$" -Path "C:\drop" -Permissions "$Script:DomainName\Administrators,FULL" #seperate with semicolon for multiple entries

}

function Check-ManualSteps-Jump {
	Write-Log
	Write-Log -Message "Manual Steps for Jump Servers ..."
	Write-Log

	Write-Log -Message "  * Put Instructions here including copy paste commands."
	
}