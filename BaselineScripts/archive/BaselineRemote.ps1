########################################################################################################
# Header, do NOT touch: $File: //SiteDev/Site.2017/.NET/Monster/Apps/ApplicationSupport/BaselineScripts/BaselineRemote.ps1 $ | $DateTime: 2016/11/16 01:45:48 $ | $Author: mmohddom $ | $Change: 4747125 $ | $Revision: #1 $
#
#
#   BaselineRemote
#   Created by: Tomas Hlavacek
#
#
#	Prerequisites:
#      - Windows Server 2008 R2 (PowerShell v2.0 included)
#            (try-catch only in PowerShell v2.0)
#      - You must Set-ExecutionPolicy "Unrestricted" or "Bypass" before running script
#            (PS> Set-ExecutionPolicy Unrestricted)
#
#
########################################################################################################





########################################################################################################
#
#   Predefined variables - begin
#   DO NOT MODIFY
#
########################################################################################################

$Script:OpsDeployApiURL = "http://illuminations.monster.com/v1"


$Script:TargetEnvironment = $null   # set in Validate-UserInput
$Script:TargetCluster = $null       # set in Validate-UserInput
$Script:TargetMachine = $null       # set in Validate-UserInput
$Script:TargetGroup = $null         # set in Validate-UserInput

$Script:ExecutionMode = $null       # set in Validate-UserInput

$Script:Debug = $false

$Script:ScriptName = $MyInvocation.MyCommand.Name

$Script:AllowedClusters = "ADMINOPM", "JBATA", "JBATB", "NETAPPA", "NETAPPB", "NETAPPC", "NETAPPD", "NETSVCSA", "NETSVCSB",
                          "NETSVCSC", "NETSVCSD", "NETWEBA", "NETWEBB", "NETWEBC", "NETWEBD", "NETWEBE", "ORCH", "OPSDEPLOY", 
						  "SYNC", "UNICAMISC", "UNICA", "WEBADMIN", "WEBAUTO"

$Script:MachinesToProcess = @{}     # filled in Validate-UserInput

$Script:TmpPath = $null             # set in Do-InitialSteps

$Script:KeyGUID = ([guid]::NewGuid()).ToString()
$Script:ScheduledTaskName = "BaselineRemote_"+$Script:KeyGUID

########################################################################################################
#
#   Predefined variables - end
#
########################################################################################################





########################################################################################################
#
#   Functions - begin
#
########################################################################################################


# Initialize sesion
#################################################
function Do-InitialSteps()
{
	$Script:ComputerName =  $Env:COMPUTERNAME
	$Script:UserName = $Env:USERNAME
	$Script:Date = Get-Date
	

	# Check system requirements
	#################################################
	Check-SystemRequirements
	
	
	# Parse command line arguments
	#################################################
	Parse-CommandLineArguments
	
	
	# Parse command line arguments
	#################################################
	Validate-UserInput
	
	
	if ($Script:MachinesToProcess.Count -eq 0)
	{
		# no work to do
		Write-Log
		Write-Log -EntryType "WARNING" -Message "No valid/allowed input."
		Write-Log -Message ("Allowed clusters: "+($Script:AllowedClusters -join ", "))
		Write-Log
		Exit
	}
	
	# Setting temporary folder path
	#################################################
	$Script:TmpPath = "\\SYNC201\d$\temp\"+$Script:KeyGUID
}

# Finalize session
#################################################
function Do-FinalSteps()
{
	#Write-Host "*** Press enter to exit ***"
	#Read-Host
	
	Exit
}


# Make sure the server is W2K8 R2 or greater
#################################################
function Check-SystemRequirements()
{
	$OS = (get-wmiobject Win32_OperatingSystem).version
	if ($OS -lt '6.1')
	{
		Write-Log -EntryType Fatal -Message "Operating System must be Windows Server 2008 R2 or higher to run this script"
		Exit
	}
	
	$user = [Security.Principal.WindowsIdentity]::GetCurrent()
	if (-not (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
	{
		Write-Log -EntryType Fatal -Message "This script must be run with administrators privileges"
		Exit
	}
}


# Validate user input
#################################################
function Validate-UserInput()
{
	#################################################
	function Validate-UserInput-ParseMachine($Machine)
	{
		$MachineObject = "" | select Name, IPAddress, DataCenter, TaskName, BaselineScript
		
		$MachineObject.Name = $Machine.Name.ToString()
		$MachineObject.IPAddress = $Machine.IPAddress.ToString()
		$MachineObject.DataCenter = $Machine.DataCenter.ToString()
		$MachineObject.TaskName = $Script:ScheduledTaskName
		
		$MachineObject.BaselineScript = "\\SYNC201\d\p4\deploy\Implementation\"+$Environment.ImplementationBranch+"\Deployment\BaselineScript\"+$Machine.Cluster+"_Baseline_Script.ps1"
		
		return $MachineObject
	}
	
	
	# execution mode not specified
	if ($Script:ExecutionMode -eq $null)
	{
		Write-Log -EntryType "ERROR" -Message "You must specify execution mode."
		Print-Help
		Exit
	}
	
	# target machine(s) specified, cleaning other input
	if ($Script:TargetMachine -ne $null)
	{
		$Script:TargetEnvironment = $null
		$Script:TargetCluster = $null
		$Script:TargetGroup = $null
	}
	
	# no machines specified, checking other target input
	if ($Script:TargetMachine -eq $null)
	{
		# environment must be specified
		if ($Script:TargetEnvironment -eq $null)
		{
			Write-Log -EntryType "ERROR" -Message "You must specify target machines or environment."
			Print-Help
			Exit
		}
		
		# cannot specify more than one environment
		if ($Script:TargetEnvironment -is [System.Array])
		{
			Write-Log -EntryType "ERROR" -Message "You can specify only one environment at a time."
			Print-Help
			Exit
		}
		
		$EnvironmentsXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/")
		$Environment = $EnvironmentsXML.Environments.Environment | ? { $_.Name -eq $Script:TargetEnvironment }
		# environment specified must be valid
		if ($Environment -eq $null)
		{
			Write-Log -EntryType "ERROR" -Message "You must specify valid environment name."
			Print-Help
			Exit
		}
		
		# Prod implementation branch fix
		if ($Environment.Type -eq "Prod") { $Environment.ImplementationBranch = "Production" }
		
		$Script:TargetEnvironment = $Environment.Name
		
		# cluster is specified
		if ($Script:TargetCluster -ne $null)
		{
			# cannot specify more than one cluster
			if ($Script:TargetCluster -is [System.Array])
			{
				Write-Log -EntryType "ERROR" -Message "You can specify only one cluster at a time."
				Print-Help
				Exit
			}
			
			$ClustersXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Script:TargetEnvironment+"/clusters/")
			$Cluster = $ClustersXML.Clusters.Cluster | ? { $_.Name -eq $Script:TargetCluster }
			# cluster specified must be valid
			if ($Cluster -eq $null)
			{
				Write-Log -EntryType "ERROR" -Message "You must specify valid cluster name."
				Print-Help
				Exit
			}
			
			$Script:TargetCluster = $Cluster.Name
		}
		
		# group is specified
		if ($Script:TargetGroup -ne $null)
		{
			# cannot specify more than one group
			if ($Script:TargetGroup -is [System.Array])
			{
				Write-Log -EntryType "ERROR" -Message "You can specify only one group at a time."
				Print-Help
				Exit
			}
			
			# only Odds/Evens are supported
			if ($Script:TargetGroup -inotmatch "^(Odds|Evens)$")
			{
				Write-Log -EntryType "ERROR" -Message "Only Odds/Evens groups are supported at the moment."
				Print-Help
				Exit
			}
			$Script:TargetGroup = $Script:TargetGroup.substring(0,1).toupper()+$Script:TargetGroup.substring(1).tolower()
		}
		
		#################################################
		# trying to get list of machines
		#################################################
		
		# cluster is specified
		if ($Script:TargetCluster -ne $null)
		{
			# group is specified
			if ($Script:TargetGroup -ne $null)
			{
				# getting group from cluster
				$MachinesXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Script:TargetEnvironment+"/clusters/"+$Script:TargetCluster+"/machine_groups/"+$Script:TargetGroup)
				$Script:TargetMachine = @($MachinesXML.MachineGroup.Machines.Machine | % { $_.Name } )
			}
			# group is not specified
			else
			{
				# getting cluster all machines
				$MachinesXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Script:TargetEnvironment+"/clusters/"+$Script:TargetCluster+"/machines/")
				$Script:TargetMachine = @($MachinesXML.Machines.Machine | % { $_.Name } )
			}
		}
		# cluster is not specified
		else
		{
			# group is specified
			if ($Script:TargetGroup -ne $null)
			{
				# we got to loop through each cluster to get group machines
				if ($Script:TargetCluster -eq $null -and $Script:TargetGroup -ne $null)
				{
					$Script:TargetMachine = @()
					$ClustersXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Script:TargetEnvironment+"/clusters/")
					$ClustersXML.Clusters.Cluster | % {
						# getting group from cluster
						$MachinesXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Script:TargetEnvironment+"/clusters/"+$_.Name+"/machine_groups/"+$Script:TargetGroup)
						$Script:TargetMachine += @($MachinesXML.MachineGroup.Machines.Machine | % { $_.Name } )
					}
				}
			}
			# group is not specified
			else
			{
				# getting all machines in environment
				$MachinesXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Script:TargetEnvironment+"/machines/")
				$Script:TargetMachine = @($MachinesXML.Machines.Machine | % { $_.Name } )
			}
		}
		
		$MachinesXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Script:TargetEnvironment+"/machines/")
		$Script:TargetMachine | % {
			$MachineName = $_
			if ($Machine = $MachinesXML.Machines.Machine | ? { $_.Name -eq $MachineName -and $_.Status -eq "Active" })
			{
				# add only if allowed cluster
				if ($Script:AllowedClusters -icontains $Machine.Cluster) { $Script:MachinesToProcess[$MachineName] = Validate-UserInput-ParseMachine -Machine $Machine }
			}
		}
	}
	# machines specified, checking them
	else
	{
		$Script:TargetMachine | % {
			$MachineName = $_
			$MachineXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/machines/"+$MachineName)
			if ($Machine = $MachineXML.Machine | ? { $_.Status -eq "Active" })
			{
				if ($Environment)
				{
					if ($Environment.Name -ne $Machine.Environment)
					{
						Write-Log -EntryType "ERROR" -Message "Machines specified must belong to same environment."
						Exit
					}
				}
				else
				{
					$EnvironmentXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Machine.Environment)
					$Environment = $EnvironmentXML.Environment
					
					# Prod implementation branch fix
					if ($Environment.Type -eq "Prod") { $Environment.ImplementationBranch = "Production" }
				}
				
				# add only if allowed cluster
				if ($Script:AllowedClusters -icontains $Machine.Cluster) { $Script:MachinesToProcess[$MachineName] = Validate-UserInput-ParseMachine -Machine $Machine }
			}
		}
	}
}



# Reads command line arguments
#################################################
function Parse-CommandLineArguments() 
{
	$Values = $Script:args
	
	#################################################
	function Parse-CommandLineArguments-Get-ParameterValue($Index, $IsOptional = $false)
	{
		# value is missing
		if ($Index+1 -ge $Values.Count -OR ($Values[$Index+1] -is "string" -and $Values[$Index+1].Substring(0,1) -eq "-"))
		{
			if ($IsOptional -eq $false)
			{
				Write-Host "Error: Missing value for parameter:" $Values[$Index] -ForeGroundColor Red
				Print-Help
				Exit
			}
			else
			{
				return
			}
		}
		# returning value
		return $Values[$Index+1]
	}
	
	$a = 0
	while ($a -lt $Values.Count)
	{
		switch ($Values[$a].ToLower()) 
		{
			-help
				{ Print-Help; Exit }
			-h
				{ Print-Help; Exit }
			-e
				{ $Script:TargetEnvironment = Parse-CommandLineArguments-Get-ParameterValue($a); $a++ }
			-c
				{ $Script:TargetCluster = Parse-CommandLineArguments-Get-ParameterValue($a); $a++ }
			-m
				{ $Script:TargetMachine = Parse-CommandLineArguments-Get-ParameterValue($a); $a++ }
			-g
				{ $Script:TargetGroup = Parse-CommandLineArguments-Get-ParameterValue($a); $a++ }
			-i
				{
					if ($Script:ExecutionMode -ne $null)
					{
						Write-Log -EntryType "ERROR" -Message "You can specify only one execution mode at a time."
						Print-Help
						Exit
					}
					$Script:ExecutionMode = "install"
				}
			-v
				{
					if ($Script:ExecutionMode -ne $null)
					{
						Write-Log -EntryType "ERROR" -Message "You can specify only one execution mode at a time."
						Print-Help
						Exit
					}
					$Script:ExecutionMode = "validate"
				}
			-q
				{
					if ($Script:ExecutionMode -ne $null)
					{
						Write-Log -EntryType "ERROR" -Message "You can specify only one execution mode at a time."
						Print-Help
						Exit
					}
					$Script:ExecutionMode = "query"
				}
			-d
				{ $Script:Debug = $true }
			default
			{
				Write-Host "Error: Unknown parameter:" $Values[$a] -ForeGroundColor Red
				Print-Help
				Exit
			}
		}
		$a++
	}
}


# Output help
#################################################
function Print-Help()
{
	Write-Host
	Write-Host Usage: -ForeGroundColor Green
	Write-Host 
	Write-Host "$Script:ScriptName [-e <envName>] [-c <clusterName>|-m <machineName,machineName,...>]"
	Write-Host "                   [-g <groupName>] [-i|-v|-q] [-h]"
	Write-Host
	Write-Host "TARGET OPTIONS:"
	Write-Host "  -e <envName>          The Environment to perform an action against."
	Write-Host "  -c <clusterName>      The Cluster in the environment to perform and action against."
	Write-Host "  -m <machineName,...>  The Machine(s) to perform an action against."
	Write-Host "  -g <groupName>        The Machine Group to perform an action against. (Odds/Evens)"
	Write-Host
	Write-Host "EXECUTION MODES:"
	Write-Host "  -i                    Run baseline script in INSTALLATION mode."
	Write-Host "  -v                    Run baseline script in VALIDATE mode."
	Write-Host "  -q                    Only view latest baseline script run results."
	Write-Host
	Write-Host "OTHER OPTIONS:"
	Write-Host "  -h, -help             Show this help."
	Write-Host
	
}


# Get-HttpRequest
#################################################
function Get-HttpRequest([String]$URL)
{
	$request = [System.Net.WebRequest]::Create($URL)
	$request.Proxy = $null
	$request.Method = "GET"
	$request.Accept = "application/xml"
	$response = $request.GetResponse()
		
	try
	{
		$requestStream = $response.GetResponseStream()
	}
	catch
	{
		Write-Log -EntryType "FATAL" -Message ("An error occurred retreiving: "+$URL)
		Exit
	}
	
	$readStream = new-object System.IO.StreamReader $requestStream
	new-variable db
	$db = $readStream.ReadToEnd()
	$readStream.Close()
	$response.Close()
	return ,[xml]$db
}


# Write-Log
#################################################
function Write-Log([string]$Message = "", [string]$EntryType)
{
	if ($EntryType -and ($EntryType -inotmatch "^(info|warning|error|fatal|debug)$")) { $EntryType = $null }
	if ($EntryType -and ($EntryType -eq "warning")) { $EntryType = "WARN" }
	
	# time
	$Time = Get-Date -Format "HH:mm:ss"
	
	if ($EntryType)
	{
		$EntryType = $EntryType.ToUpper()
		switch ($EntryType)
		{
			"WARN"	{ Write-Host -ForegroundColor Yellow ("{0,-6} : {1}" -f $EntryType, $Message) }
			"ERROR"	{ Write-Host -ForegroundColor Red ("{0,-6} : {1}" -f $EntryType, $Message) }
			"FATAL"	{ Write-Host -ForegroundColor Magenta ("{0,-6} : {1}" -f $EntryType, $Message) }
			"DEBUG"	{ if ($Script:Debug) { Write-Host -ForegroundColor Gray ("{0,-6} : {1}" -f $EntryType, $Message) } }
			default	{ Write-Host ("{0,-6} : {1}" -f $EntryType, $Message) }
		}
	}
	else
	{
		Write-Host $Message
	}
}


# Process-BaselineRemote
#################################################
function Process-BaselineRemote()
{
	Write-Log -Message ("Requested machines: "+($Script:MachinesToProcess.Keys -join ", " ))
	
	# QUERY mode
	if ($Script:ExecutionMode -eq "query")
	{
		$Results = Get-BaselineResults
		View-BaselineResults -Results $Results
	}
	
	# VALIDATION mode
	elseif ($Script:ExecutionMode -eq "validate")
	{
		Get-UserCredentials
		$ScheduledTasks = Run-ScheduledTasks -Mode validate
		$TasksResults = Get-TasksResults -ScheduledTasks $ScheduledTasks
		$Results = Get-BaselineResults -TasksResults $TasksResults
		View-BaselineResults -Results $Results
	}
	
	# INSTALL mode
	elseif ($Script:ExecutionMode -eq "install")
	{
#		Get-UserCredentials
#		$ScheduledTasks = Run-ScheduledTasks -Mode install
#		$TasksResults = Get-TasksResults -ScheduledTasks $ScheduledTasks
#		$Results = Get-BaselineResults -TasksResults $TasksResults
#		View-BaselineResults -Results $Results
	}
}


# Run-ScheduledTasks
#################################################
function Run-ScheduledTasks($Mode)
{
	$MaxJobs = 10 # Max concurrent running jobs.
	$Jobs = @()
	$Results = @{}
	
	Write-Host "Executing tasks on machines."
	
	#################################################
	# Job script block
	#################################################
	$sb =
	{
		$TaskXmlDefinition = '<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>'+(get-date -format "yyyy-MM-ddTHH:mm:ss.0000000")+'</Date>
    <Author>BaselineRemote</Author>
  </RegistrationInfo>
  <Triggers />
  <Principals>
    <Principal id="Author">
      <UserId>{USERNAME}</UserId>
      <LogonType>Password</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT2H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-ExecutionPolicy bypass {SCRIPTPATH} {SCRIPTARGUMENTS}</Arguments>
    </Exec>
  </Actions>
</Task>'
		$Machine = $input | Select-Object

		
		$Task = "" | select Name, XmlDefinition
		$Task.Name = $Machine.TaskName
		$Task.XmlDefinition = $TaskXmlDefinition -ireplace "{USERNAME}", $Machine.UserName
		$Task.XmlDefinition = $Task.XmlDefinition -ireplace "{SCRIPTPATH}", $Machine.BaselineScript
		$Task.XmlDefinition = $Task.XmlDefinition -ireplace "{SCRIPTARGUMENTS}", $Machine.ScriptArguments
		
		#Create the TaskService object and connect to Vista/Win7/Win2k8 Server
		$SchedService = new-object -com("Schedule.Service")
		$SchedService.connect($Machine.Name)
		
		#Get to root folder (\) to create the task definition 
		$RootFolder = $SchedService.GetFolder("\")
		$SystemTasks = $RootFolder.GetTasks(0)
		
		# cleaning system from previous tasks (just in case)
		foreach ($SystemTask in ($SystemTasks | ? { $_.name -imatch "^BaselineRemote_[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}$" }))
		{
			#Write-Host $SystemTask.Name
			$RootFolder.DeleteTask($SystemTask.Name, $null)
		}
		
		$Result = "" | select MachineName, TaskName, InstanceGuid, CreationSuccess, RunSuccess, ErrorMessage
		$Result.MachineName = $Machine.Name
		$Result.TaskName = $Task.Name
		
		# http://msdn.microsoft.com/en-us/library/aa382575(v=VS.85).aspx
		# RegisterTask(Name, XmlDefinition, Flags, UserId, Password, LogonType)
		$LogonType = 1 # Password
		try
		{
			$SystemTask = $RootFolder.RegisterTask($Task.Name, $Task.XmlDefinition, 6, $Machine.UserName, $Machine.Password, $LogonType)
		}
		catch
		{
			$Result.CreationSuccess = $false
			$Result.ErrorMessage = $_.Exception.Message
			return $Result
		}
		
		$Result.CreationSuccess = $true
		
		
		# trying to run task
		$Result.RunSuccess = $true
		try
		{
			$RunningTask = $SystemTask.Run($null)
			$Result.InstanceGuid = $RunningTask.InstanceGuid
		}
		catch
		{
			$Result.RunSuccess = $false
			$Result.ErrorMessage = $_.Exception.Message
		}
		
		return $Result
	}
	#################################################
	# End of Job script block
	#################################################
	

	# Process server list.
	foreach ($MachineObject in $Script:MachinesToProcess.Values)
	{
		Add-Member -InputObject $MachineObject -MemberType NoteProperty -Name UserName -Value $Script:Credential.username
		Add-Member -InputObject $MachineObject -MemberType NoteProperty -Name Password -Value $Script:Credential.GetNetworkCredential().password
		
		if ($Mode -eq "install")
		{
			# install mode
			Add-Member -InputObject $MachineObject -MemberType NoteProperty -Name ScriptArguments -Value ("-i -a -atd "+$Script:TmpPath)
		}
		else
		{
			# validate mode
			Add-Member -InputObject $MachineObject -MemberType NoteProperty -Name ScriptArguments -Value ""
		}
		
		Write-Log -EntryType "DEBUG" -Message ("Creating scheduled task "+$MachineObject.TaskName+" on machine "+$MachineObject.Name)
		
		# Spin up job.
		$Jobs += Start-Job -Name $MachineObject.Name -ScriptBlock $sb -InputObject $MachineObject
		$Running = @($Jobs | ? {$_.State -eq 'Running'})
		
		# Throttle jobs.
		while ($Running.Count -ge $MaxJobs)
		{
			$Finished = Wait-Job -Job $Jobs -Any
			$Running = @($Jobs | ? {$_.State -eq 'Running'})
		}
	}
	
	# Wait for remaining.
	Wait-Job -Job $Jobs > $null
	
	$Jobs | % { $Temp = Receive-Job -Id $_.Id; $Results[$_.Name] = $Temp }
	$Jobs | Remove-Job -Force
	
	return $Results
}


# Process-BaselineRemote
#################################################
function Get-TasksResults($ScheduledTasks)
{
	$MaxJobs = 10 # Max concurrent running jobs.
	$Results = @{}
	$Jobs = @{}
	$JobsDel = @()
	
	Write-Host "Waiting for tasks on machines to finish."
	
	
	#################################################
	# Task deletion Job script block
	#################################################
	$TDScriptBlock = 
	{
		$TaskObject = $input | Select-Object
		
		#Create the TaskService object and connect to Vista/Win7/Win2k8 Server
		$SchedService = new-object -com("Schedule.Service")
		$SchedService.connect($TaskObject.MachineName)
		
		#Get to root folder (\)
		$RootFolder = $SchedService.GetFolder("\")
		
		try
		{
			$RootFolder.DeleteTask($TaskObject.TaskName,$null)
		}
		catch
		{
			return $false
		}
		
		return $true
	}
	#################################################
	# End of Task deletion Job script block
	#################################################
	
	
	
	#################################################
	function Get-TasksResults-DeleteScheduledTask($TaskObject)
	{
		Write-Log -EntryType "DEBUG" -Message ("Deleting scheduled task "+$TaskObject.TaskName+" on machine "+$TaskObject.MachineName)
		
		# Spin up job.
		$JobsDel += Start-Job -Name $TaskObject.MachineName -ScriptBlock $TDScriptBlock -InputObject $TaskObject
		$Running = @($JobsDel | ? {$_.State -eq 'Running'})
		
		# Throttle jobs.
		while ($Running.Count -ge $MaxJobs)
		{
			$Finished = Wait-Job -Job $JobsDel -Any
			$Running = @($JobsDel | ? {$_.State -eq 'Running'})
		}
	}
	
	
	
	#################################################
	# Task status Job script block
	#################################################
	$TSScriptBlock = 
	{
		$TaskObject = $input | Select-Object
		
		#################################################
		function Get-TaskInstancePID()
		{
			return 1
			
			$StartTime = (get-date).AddMinutes(-10)
			$Events = Get-WinEvent -FilterHashtable @{logname = "Microsoft-Windows-TaskScheduler/Operational"; StartTime = $StartTime} -computername $TaskObject.MachineName
			
			$Events | % {
				if ($_.Message -imatch ($TaskObject.TaskName+".+process ID (\d+)"))
				{
					return $Matches[1]
				}
			}
		}
		
		
		#Create the TaskService object and connect to Vista/Win7/Win2k8 Server
		$SchedService = new-object -com("Schedule.Service")
		$SchedService.connect($TaskObject.MachineName)
		
		#Get to root folder (\)
		$RootFolder = $SchedService.GetFolder("\")
		
		
		$Result = "" | select MachineName, ResultCode, ResultMessage, ErrorMessage, PID
		$Result.MachineName = $TaskObject.MachineName
		
		# task is missing
		try
		{
			$SystemTask = $RootFolder.GetTask($TaskObject.TaskName)
		}
		catch
		{
			# task is missing or error
			$Result.ResultCode = 3
			$Result.ResultMessage = "Scheduled task is missing on target machine."
			$Result.ErrorMessage = $_.Exception.Message
			
			return $Result
		}
		
		# task is running
		if ($SystemTask.State -eq 4)
		{
			$Result.ResultCode = 4
			$Result.ResultMessage = "Scheduled task is running."
			
			return $Result
		}
		
		# task finished
		if ($SystemTask.LastRunTime -gt '1900-01-01' -and $SystemTask.State -eq 3)
		{
			$Result.PID = Get-TaskInstancePID -TaskObject $TaskObject
			$Result.ResultCode = 0
			$Result.ResultMessage = "Scheduled task has finished with result code "+$SystemTask.LastTaskResult
			
			return $Result
		}
		
		# task ran once
		if ($SystemTask.LastRunTime -gt '1900-01-01' -and $SystemTask.State -ne 2)
		{
			$Result.PID = Get-TaskInstancePID -TaskObject $TaskObject
			$Result.ResultCode = 5
			$Result.ResultMessage = "Scheduled task has finished with result code "+$SystemTask.LastTaskResult
			
			return $Result
		}
		
		# task is queued
		if ($SystemTask.State -eq 2)
		{
			$Result.ResultCode = 6
			$Result.ResultMessage = "Scheduled task is queued."
			
			return $Result
		}
		
		# task is ready (and did not run)
		if ($SystemTask.State -eq 3)
		{
			try
			{
				$RunningTask = $SystemTask.Run($null)
			}
			catch
			{
				$Result.ResultCode = 7
				$Result.ResultMessage = "Unable to run scheduled task."
				$Result.ErrorMessage = $_.Exception.Message
				
				return $Result
			}
			
			$Result.ResultCode = 4
			$Result.ResultMessage = "Scheduled task is running."
			
			return $Result
		}
		
		# task is in unknown state
		if ($SystemTask.State -eq 0)
		{
			$Result.ResultCode = 8
			$Result.ResultMessage = "Scheduled task is unknown state."
			$Result.ErrorMessage = "Scheduled task is unknown state"
			
			return $Result
		}
		
		# task is disabled
		if ($SystemTask.State -eq 1)
		{
			$Result.ResultCode = 9
			$Result.ResultMessage = "Scheduled task is disabled."
			$Result.ErrorMessage = "Scheduled task is disabled"
			
			return $Result
		}
	}
	#################################################
	# End of Task status Job script block
	#################################################
	
	
	# cleaning $ScheduledTasks
	foreach ($TaskObject in $ScheduledTasks.Values)
	{
		if ($TaskObject.CreationSuccess -eq $false -or $TaskObject.RunSuccess -eq $false)
		{
			$Result = "" | select MachineName, ResultCode, ResultMessage, ErrorMessage, PID
			$Result.MachineName = $TaskObject.MachineName
			
			if ($TaskObject.CreationSuccess -eq $false)
			{
				$Result.ResultCode = 1
				$Result.ResultMessage = "Scheduled task was not created on target machine."
			}
			else
			{
				$Result.ResultCode = 2
				$Result.ResultMessage = "Scheduled task did not run on target machine."
				
				Get-TasksResults-DeleteScheduledTask -TaskObject $TaskObject
			}
			$Result.ErrorMessage = $TaskObject.ErrorMessage
			
			$Results[$Result.MachineName] = $Result
			
			$ScheduledTasks.Remove($TaskObject.MachineName) # removing machine from processing
		}
	}
	
	# removing finished deletion jobs
	if ($JobsDel.Count -gt 0)
	{
		# Wait for remaining.
		Wait-Job -Job $JobsDel > $null
		
		$JobsDel | Remove-Job -Force
	}
	
	
	$JobsDel = @() # resetting array
	$MissingCounters = @{}
	
	while ($ScheduledTasks.Count -gt 0)
	{
		# cycling through tasks results
		foreach ($TaskObject in $ScheduledTasks.Values)
		{
			######## create job for machine only if not exists ########
			if (-not $Jobs.ContainsKey($TaskObject.MachineName))
			{
				# Spin up job.
				#Write-Log -EntryType "DEBUG" -Message ("Starting job "+$TaskObject.MachineName)
				
				$Jobs[$TaskObject.MachineName] = Start-Job -Name $TaskObject.MachineName -ScriptBlock $TSScriptBlock -InputObject $TaskObject
				$Running = @($Jobs.Values | ? {$_.State -eq 'Running'})
			
				# Throttle jobs.
				while ($Running.Count -ge $MaxJobs)
				{
					$Finished = Wait-Job -Job $Jobs -Any
					$Running = @($Jobs.Values | ? {$_.State -eq 'Running'})
				}
			}
		}
		
		
		
		$Completed = @($Jobs.Values | ? {$_.State -eq 'Completed'} | select Id, Name, State )
		
		$Completed | % {
			#Write-Log -EntryType "DEBUG" -Message ("Receiving job id "+$_.Id)
			$Temp = Receive-Job -Id $_.Id;
			
			switch ($Temp.ResultCode)
			{
				# task finished
				0	{
						$Results[$Temp.MachineName] = $Temp
						Get-TasksResults-DeleteScheduledTask -TaskObject $ScheduledTasks[$Temp.MachineName]
						$ScheduledTasks.Remove($Temp.MachineName) # removing machine from processing
					}
				# task is missing on target box
				3	{
						$Results[$Temp.MachineName] = $Temp
						if ($MissingCounters.ContainsKey($Temp.MachineName))
						{
							$MissingCounters[$Temp.MachineName]++
							if ($MissingCounters[$Temp.MachineName] -ge 3)
							{
								$ScheduledTasks.Remove($Temp.MachineName) # removing machine from processing
							}
						}
						else
						{
							$MissingCounters[$Temp.MachineName] = 1
						}
					}
				# task is running
				4	{
						$Results[$Temp.MachineName] = $Temp
					}
				# task ran once
				5	{
						$Results[$Temp.MachineName] = $Temp
						Get-TasksResults-DeleteScheduledTask -TaskObject $ScheduledTasks[$Temp.MachineName]
						$ScheduledTasks.Remove($Temp.MachineName) # removing machine from processing
					}
				# task is queued
				6	{
						$Results[$Temp.MachineName] = $Temp
					}
				# unable to run task
				7	{
						$Results[$Temp.MachineName] = $Temp
						Get-TasksResults-DeleteScheduledTask -TaskObject $ScheduledTasks[$Temp.MachineName]
						$ScheduledTasks.Remove($Temp.MachineName) # removing machine from processing
					}
				# task is in uknown state
				8	{
						$Results[$Temp.MachineName] = $Temp
						Get-TasksResults-DeleteScheduledTask -TaskObject $ScheduledTasks[$Temp.MachineName]
						$ScheduledTasks.Remove($Temp.MachineName) # removing machine from processing
					}
				# task is disabled
				9	{
						$Results[$Temp.MachineName] = $Temp
						Get-TasksResults-DeleteScheduledTask -TaskObject $ScheduledTasks[$Temp.MachineName]
						$ScheduledTasks.Remove($Temp.MachineName) # removing machine from processing
					}
			}
			
			#Write-Log -EntryType "DEBUG" -Message ("Removing job id "+$_.Id)
			$Jobs.Remove($_.Name)
			Remove-Job -Id $_.Id -Force
			
		}
		
		if ($ScheduledTasks.Count -gt 0)
		{
			if ($LastJobCount -eq $null -or $LastJobCount -ne $ScheduledTasks.Count)
			{
				if ($LastJobCount -eq $null) { $LastJobCount = $ScheduledTasks.Count }
				
				if ($ScheduledTasks.Count -gt 4)
				{
					Write-Host -ForegroundColor Gray ("Still waiting on: "+($ScheduledTasks.Keys | select -First 1)+" and "+($ScheduledTasks.Count-1)+" more machines!")
				}
				else
				{
					Write-Host -ForegroundColor Gray ("Still waiting on: "+($ScheduledTasks.Keys -join ", "))
				}
			}
			
			$LastJobCount = $ScheduledTasks.Count
			
			Start-Sleep 3
		}
	}
	
	# removing finished deletion jobs
	if ($JobsDel.Count -gt 0)
	{
		# Wait for remaining.
		Wait-Job -Job $JobsDel > $null
		
		$JobsDel | Remove-Job -Force
	}
	
	return $Results
}



# Get-BaselineResults
#################################################
function Get-BaselineResults($TasksResults)
{
	$MaxJobs = 10 # Max concurrent running jobs.
	$Jobs = @()
	$Results = @{}
	
	Write-Host "Getting and parsing logs from machines."
	
	#################################################
	# Log parsing Job script block
	#################################################
	$sb =
	{
		$MachineObject = $input | Select-Object
		
		$LogDir = "\\"+$MachineObject.IPAddress+"\d$\logs\baseline"
		$File = Get-ChildItem -Filter ("Baseline_"+$MachineObject.Name+"*.log") -Path $LogDir | sort -prop LastWriteTime | select -last 1
		
		$Result = "" | select MachineName, UserName, DateTime, Mode, LogFile, LogContent, TaskResultCode, TaskResultMessage, ErrorMessage, ResultOK, ResultFailure, ResultINFO, ResultWARNING, ResultERROR, ResultFATAL
		$Result.MachineName = $MachineObject.Name
		
		if (-not $File)
		{
			$Result.ErrorMessage = "No valid baseline log found."
			return $Result
		}
		
		$Result.LogFile = $File.FullName
		$Result.LogContent = @{}
		
		$ContextLines = 1
		
		$LogContent = (Get-Content $Result.LogFile)
		
		for ($a = 0; $a -lt $LogContent.Count; $a++)
		{
			# DateTime
			if ($Result.DateTime -eq $null -and $LogContent[$a] -imatch "^(\S+)\s+(\S+)\s+(\S+)\s+:\s+Start Time: (.*)\s*$")
			{
				$Result.DateTime = $Matches[4]
				continue
			}
			# UserName
			if ($Result.UserName -eq $null -and $LogContent[$a] -imatch "^(\S+)\s+(\S+)\s+(\S+)\s+:\s+UserName: (.*)\s*$")
			{
				$Result.UserName = $Matches[4]
				continue
			}
			# Mode
			if ($Result.Mode -eq $null -and $LogContent[$a] -imatch "^(\S+)\s+(\S+)\s+(\S+)\s+:\s+Validate only mode: (True|False)\s*$")
			{
				if ($Matches[4] -eq "True")
				{
					$Result.Mode = 'validation'
				}
				else
				{
					$Result.Mode = 'installation'
				}
				continue
			}
			# ResultOK
			if  ($Result.ResultOK -eq $null -and $LogContent[$a] -imatch "^(\S+)\s+(\S+)\s+(\S+)\s+:\s+Result OK: (\d+)\s*$")
			{
				$Result.ResultOK = [int]$Matches[4]
				continue
			}
			# ResultFailure
			if ($Result.ResultFailure -eq $null -and $LogContent[$a] -imatch "^(\S+)\s+(\S+)\s+(\S+)\s+:\s+Result Failure: (\d+)\s*$")
			{
				$Result.ResultFailure = [int]$Matches[4]
				continue
			}
			# Summary
			if ($Result.ResultINFO -eq $null -and $LogContent[$a] -imatch "^(\S+)\s+(\S+)\s+(\S+)\s+:\s+INFO:\s+(\d+)\s+WARNING:\s+(\d+)\s+ERROR:\s+(\d+)\s+FATAL:\s+(\d+)\s*$")
			{
				$Result.ResultINFO = [int]$Matches[4]
				$Result.ResultWARNING = [int]$Matches[5]
				$Result.ResultERROR = [int]$Matches[6]
				$Result.ResultFATAL = [int]$Matches[7]
				continue
			}
			
			if ($LogContent[$a] -imatch "^(\S+)\s+(\S+)\s+Failure\s+:.*$" -or $LogContent[$a] -inotmatch "^(\S+)\s+INFO\s+")
			{
				for ($b = $a-$ContextLines; $b -le $a+$ContextLines; $b++)
				{
					if ($b -ge 0 -and $b -lt $LogContent.Count)
					{
						$Result.LogContent[$b] = $LogContent[$b]
					}
				}
			}
		}
		
		return $Result
	}
	#################################################
	# End of Log parsing Job script block
	#################################################
	
	
	function Get-BaselineResults-StartJob($MachineObject)
	{
		# Spin up job.
		$Job = Start-Job -Name $MachineObject.Name -ScriptBlock $sb -InputObject $MachineObject
		$Running = @($Jobs | ? {$_.State -eq 'Running'})
		
		# Throttle jobs.
		while ($Running.Count -ge $MaxJobs)
		{
			$Finished = Wait-Job -Job $Jobs -Any
			$Running = @($Jobs | ? {$_.State -eq 'Running'})
		}
		
		return $Job
	}
	
	
	# Process server list.
	foreach ($MachineObject in $Script:MachinesToProcess.Values)
	{
		if ($TasksResults -ne $null)
		{
			if ($TasksResults[$MachineObject.Name].ResultCode -eq 0)
			{
				Add-Member -InputObject $MachineObject -MemberType NoteProperty -Name PID -Value $TasksResults.PID
				$Jobs += Get-BaselineResults-StartJob -MachineObject $MachineObject
			}
			elseif ($TasksResults[$MachineObject.Name].ResultCode -eq 5)
			{
				Add-Member -InputObject $MachineObject -MemberType NoteProperty -Name PID -Value $TasksResults.PID
				$Jobs += Get-BaselineResults-StartJob -MachineObject $MachineObject
			}
			else
			{
				$Result = "" | select MachineName, UserName, DateTime, Mode, LogFile, LogContent, TaskResultCode, TaskResultMessage, ErrorMessage, ResultOK, ResultFailure, ResultINFO, ResultWARNING, ResultERROR, ResultFATAL
				$Result.MachineName = $MachineObject.Name
				$Result.TaskResultCode = $TasksResults.ResultCode
				$Result.TaskResultMessage = $TasksResults.ResultMessage
				$Result.ErrorMessage = $TasksResults.ErrorMessage
				
				$Results[$Result.MachineName] = $Result
			}
		}
		else
		{
			$Jobs += Get-BaselineResults-StartJob -MachineObject $MachineObject
		}
	}
	
	if ($Jobs.Count -gt 0)
	{
		# Wait for remaining.
		Wait-Job -Job $Jobs > $null
		
		$Jobs | % { $Temp = Receive-Job -Id $_.Id; $Results[$Temp.MachineName] = $Temp }
		$Jobs | Remove-Job -Force
	}
	
	return $Results
}


# View-BaselineResults
#################################################
function View-BaselineResults($Results)
{
	$Machines = $Results.Keys | sort
	
	foreach ($MachineName in $Machines)
	{
		Write-Host
		Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
		Write-Host $MachineName -ForegroundColor Cyan
		Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
		
		if ($Results[$MachineName].LogFile -eq $null)
		{
			Write-Host
			Write-Host $Results[$MachineName].TaskResultMessage -ForegroundColor Red 
			Write-Host $Results[$MachineName].ErrorMessage -ForegroundColor Red 
			continue
		}
		
		Write-Host ("{0,-20} : {1}" -f "Baseline runtime", $Results[$MachineName].DateTime)
		Write-Host ("{0,-20} : {1}" -f "Baseline username", $Results[$MachineName].UserName)
		Write-Host ("{0,-20} : {1}" -f "Baseline mode", $Results[$MachineName].Mode)
		Write-Host ("{0,-20} : {1}" -f "Baseline logfile", $Results[$MachineName].LogFile)
		
		Write-Host
		
		Write-Host ("{0,-15} : {1,-10} " -f "Result OK", $Results[$MachineName].ResultOK) -NoNewline
		Write-Host ("{0} : {1}   " -f "INFO", $Results[$MachineName].ResultINFO) -NoNewline
		if ($Results[$MachineName].ResultERROR -gt 0)
			{ Write-Host ("{0} : {1}   " -f "ERROR", $Results[$MachineName].ResultERROR) -ForegroundColor Red -NoNewline }
		else
			{ Write-Host ("{0} : {1}   " -f "ERROR", $Results[$MachineName].ResultERROR) -NoNewline }
		if ($Results[$MachineName].ResultWARNING -gt 0)
			{ Write-Host ("{0} : {1}   " -f "WARNING", $Results[$MachineName].ResultWARNING) -ForegroundColor Yellow -NoNewline }
		else
			{ Write-Host ("{0} : {1}   " -f "WARNING", $Results[$MachineName].ResultWARNING) -NoNewline }
		if ($Results[$MachineName].ResultFATAL -gt 0)
			{ Write-Host ("{0} : {1}   " -f "FATAL", $Results[$MachineName].ResultFATAL) -ForegroundColor Magenta }
		else
			{ Write-Host ("{0} : {1}   " -f "FATAL", $Results[$MachineName].ResultFATAL) }	
		if ($Results[$MachineName].ResultFailure -gt 0)
			{ Write-Host ("{0,-15} : {1,-10} " -f "Result Failure", $Results[$MachineName].ResultFailure) -ForegroundColor Red }
		else
			{ Write-Host ("{0,-15} : {1,-10} " -f "Result Failure", $Results[$MachineName].ResultFailure) }			
		
		if ($Results[$MachineName].LogContent -ne $null -and $Results[$MachineName].LogContent.Count -gt 0)
		{
			Write-Host
			Write-Host " Line #: Line content" -ForegroundColor Gray
			Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Gray
			$Keys = $Results[$MachineName].LogContent.Keys | sort
			foreach ($LineNumber in $Keys)
			{
				if ($Results[$MachineName].LogContent[$LineNumber] -imatch "^(\S+)\s+(\S+)\s+Failure\s+:.*$" -or $Results[$MachineName].LogContent[$LineNumber] -inotmatch "^(\S+)\s+INFO\s+")
					{ Write-Host ("   {0,4}: {1} " -f $LineNumber, $Results[$MachineName].LogContent[$LineNumber]) -ForegroundColor DarkGray }
				else
					{ Write-Host ("   {0,4}: {1} " -f $LineNumber, $Results[$MachineName].LogContent[$LineNumber]) -ForegroundColor Gray }
			}
		}
	}
	
	Write-Host
}





# Get-UserCredentials
#################################################
function Get-UserCredentials()
{
	$Success = $false
	$UserName = $Env:USERDOMAIN+"\"+$Env:USERNAME
	
	for ($a = 1; $a -le 3; $a++) # 3 attempts
	{
		$Cred = $host.ui.PromptForCredential("Need credential (attempt $a of 3)", "Please enter your password.", $UserName, $null)
		
		if ($Cred -eq $null) { break }
		
		$UserName = $Cred.username
	 	$Password = $Cred.GetNetworkCredential().password

		# Get current domain using logged-on user's credentials
		$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
		$Domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

		if ($Domain.name -ne $null)
		{
			$Success = $true
			$Script:Credential = $Cred
	 		Write-Log -EntryType "DEBUG" ("Successfully authenticated with domain "+$Domain.name)
			break
		}
	}
	
	if ($Success -ne $true)
	{
		Write-Log
	 	Write-Log -EntryType "ERROR" -Message "Authentication failed - please verify your username and password."
		Write-Log -EntryType "WARNING" -Message "You need to enter valid administrator credential."
		Write-Log
	 	Exit
	}
}


########################################################################################################
#
#   Functions - end
#
########################################################################################################





########################################################################################################
#
#   Code - begin
#
########################################################################################################

Do-InitialSteps

Process-BaselineRemote

Do-FinalSteps

Exit

########################################################################################################
#
#   Code - end
#
########################################################################################################