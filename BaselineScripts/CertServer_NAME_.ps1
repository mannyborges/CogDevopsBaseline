########################################################################################################
#
#
#	
#
#   DO NOT forget to include common baseline library
#
#	Note - this must be run directly on the server that needs to be baselined
#	Prerequisites:
#      - Windows Server (PowerShell v2.0 included)
#            (Module ServerManager )
#         
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
# . $Path\include\cluster.SPECIAL.base.ps1  # this is a placeholder for any server specific baseline functions for this server or server role






########################################################################################################
#  INITIAL STEPS - IMPORTANT !!!!
########################################################################################################
Do-InitialSteps


<#
$XmlDefinition = {Import or define XML } scheduled task definition

$Name = "Task Name"
#>

function Check-ScheduledTask([string]$Name, $XmlDefinition)
{
	#	$XmlDefinition is string representing task xml definition.
	#	Can be stored directly in script or get from file, e.g. "gc c:\file.xml"
	#	Scheduled task can be easily exported to xml from Task Scheduler or via schtasks.exe.
	#
	#	Example of $XmlDefinition content:
	#	
	#	<?xml version="1.0" encoding="UTF-16"?>
	#	<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
	#	  <RegistrationInfo>
	#	    <Date>2011-07-28T10:46:34.8761122</Date>
	#	    <Author>mborges</Author>
	#	  </RegistrationInfo>
	#	  <Triggers>
	#	    <CalendarTrigger>
	#	      <StartBoundary>2011-07-28T01:00:00</StartBoundary>
	#	      <Enabled>true</Enabled>
	#	      <ScheduleByDay>
	#	        <DaysInterval>1</DaysInterval>
	#	      </ScheduleByDay>
	#	    </CalendarTrigger>
	#	  </Triggers>
	#	  <Principals>
	#	    <Principal id="Author">
	#	      <UserId>S-1-5-18</UserId>
	#	      <RunLevel>LeastPrivilege</RunLevel>
	#	    </Principal>
	#	  </Principals>
	#	  <Settings>
	#	    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
	#	    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
	#	    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
	#	    <AllowHardTerminate>true</AllowHardTerminate>
	#	    <StartWhenAvailable>false</StartWhenAvailable>
	#	    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
	#	    <IdleSettings>
	#	      <StopOnIdleEnd>true</StopOnIdleEnd>
	#	      <RestartOnIdle>false</RestartOnIdle>
	#	    </IdleSettings>
	#	    <AllowStartOnDemand>true</AllowStartOnDemand>
	#	    <Enabled>true</Enabled>
	#	    <Hidden>false</Hidden>
	#	    <RunOnlyIfIdle>false</RunOnlyIfIdle>
	#	    <WakeToRun>false</WakeToRun>
	#	    <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
	#	    <Priority>7</Priority>
	#	  </Settings>
	#	  <Actions Context="Author">
	#	    <Exec>
	#	      <Command>c:\test.bat</Command>
	#	    </Exec>
	#	  </Actions>
	#	</Task>
	
	$Category = "SCHTASK"
	
	if (-not $Name)
	{
		Write-Log -Message "Task name not defined, skipping." -EntryType "WARNING" -Category $Category
		return
	}
	
	if (-not $XmlDefinition)
	{
		Write-Log -Message "Task xml definition not defined!" -EntryType "ERROR" -Category $Category -ResultFailure
		return
	}
	
	# $XmlDefinition input is array -> reformatting to string
	if ($XmlDefinition -is "Array")
	{
		$XmlDefinition = [string]($XmlDefinition -join "`n")
	}
}	
	#################################################