########################################################################################################
# 
#
#
#   Core (Common) Baseline Library

#
#   Please DO NOT modify this file and make sure, you use only functions from this
#   library in your packages.
#
#
#	Use this as include in your specific baseline script
#   Can be done by placing either line at the top of your script (without quotes):
#      ". .\include\common.base.ps1"
#      ". d:\BaselineScript\include\common.base.ps1"
#      ". \\server\path\to\common.base.ps1"
#      (NOTE the DOT at beginning of line!)
#
#
#	Minimum Prerequisites:
#      - Windows Server 2008 R2 (PowerShell v2.0 included)
#            (module ServerManager only in W2K8 R2 and up)
#            (try-catch only in PowerShell v2.0)
#      - You must Set-ExecutionPolicy "Unrestricted" or "Bypass" before running script
#            (PS> Set-ExecutionPolicy Unrestricted)
#
#
#   FUNCTIONS LIST:
#      - to get functions list, run:
#        gc common.base.ps1 | select-string "^function|functions - begin$" | foreach { $_.toString() -replace '^function', '#     ' -replace '- begin', '' }
#      - Non-Private functions are supposed to be used in Packages library
#      - Private functions are supposed to be used in Non-Private functions in this Common library
#
#   Baseline script required functions 
#      Do-InitialSteps()
#      Do-FinalSteps()
#   System functions
#      Check-WindowsFeatures([string[]]$Features = @())
#      Check-WindowsFeatures-Remove-Features([string[]]$Features = @())
#      Check-DaylightTimeZone([string]$TimeZoneID = "Eastern Standard Time")
#      Check-GroupMembership([string]$IdentityReference, [string]$Group)
#      Check-EventLogSize([string]$Log, [int64]$Size)
#      Check-EnvPath([string]$PathEntry, [switch]$Remove)
#      Check-EnvironmentVariable([string]$Name, [string]$Value, [switch]$Remove)
#      Check-RegistrySetting([string]$Path, [string]$Property = '', $Value, $PropertyType)
#      Check-Service([string]$Name, $DisplayName, $BinaryPathName, $Description, $UserName, $StartupType, [switch]$ForceStartStop, [switch]$ForceRestart)  
#      Check-Service-StartupType([string]$Name, [switch]$Auto, [switch]$Manual, [switch]$Disabled, [switch]$ForceStartStop, [switch]$ForceRestart)
#      Check-Application([string]$AppName, [string]$AppVersion, [string]$CmdPath, [string]$CmdArguments)
#      Check-HotFix([string]$HotFixName, [string]$HotFixVersion, [string]$CmdPath, [string]$CmdArguments)
#      Check-AppUninstall([string]$AppName)
#      Check-VersionAppuninstall([string]$AppName, [string]$Version)
#      Check-ScheduledTask([string]$Name, $XmlDefinition)
#      Check-ScheduledTaskStatus([string]$Name, [switch]$Enable, [switch]$Disable)
#      Check-ScheduledTaskRemoval([string]$Name)
#   Filesystem functions
#      Check-Directory([string]$Path)
#      Check-DirectoryDelete([string]$Path, [switch]$Recursively)
#      Check-DirectoryMove([string]$FromPath, [string]$ToPath)
#      Check-File([string]$TargetFile, [string]$SourceFile)
#      Check-FileDelete([string]$AbsoluteFilePath)
#      Check-DirectoryTree([string]$TargetPath, [string]$SourcePath, $SkipItems = @(), $SkipItemsIfExist = @())
#      Check-Permissions([string]$Path, $Permissions = @(), [switch]$ExactMatch)
#      Check-NetworkShare([string]$Share, [string]$Path, $Permissions = @('Everyone,READ'), $Limit = $null)
#   XML functions 
#      Check-XmlProperty([string]$XmlPath, [string]$ElementXpath, [string]$Attribute, [string]$Value, $NameSpaces = @{})
#   Log functions
#      Write-Log([string]$Message = "", [string]$EntryType = "INFO", [string]$Category = "", [switch]$ResultOK, [switch]$ResultFailure, [string]$ResultMessage = "")
#   Misc functions
#      Get-UserInput([string]$Msg, [string]$Format, $DefaultValue)
#      Get-BaselineCredential([string]$UserName, [switch]$ReturnPasswordOnly)
#      Get-HttpRequest([string]$URL)
#   Private functions
#      Private-CheckSystemRequirements()
#      Private-ParseCommandLineArguments()
#      Private-PrintHelp()
#      Private-UninstallApp([string]$AppName)
#      Private-ReviewFileHeader()
#
#
########################################################################################################



########################################################################################################
#
#   Predefined variables - begin
#   DO NOT MODIFY
#
########################################################################################################

$Script:OpsDeployApiURL = "http://SOR.cognex.com/v1"
$Script:AltXmlDBFolder = "c:\xmlbase\"  # folder where alternate XML DB files are stored
$Script:AltMachinesXMLFile = "Machines.xml"
$Script:AltEnvironmentsXMLFile = "Environments.xml"

# [string]$Script:Environment
# Use it for putting logic into your packages, e.g. for switching between 
# copying config files for differrent environments.
# DO NOT modify this variable anywhere in your code!

[string]$Script:Environment = ""
[string]$Script:EnvironmentName = ""
[string]$Script:EnvironmentType = ""
[string]$Script:RoleName = ""  # Role name for the machine (e.g. JUMP, APP, DB, WEB, etc.)

# Implementation Branch of machine environment - we dont use that methodology but its easy to make it for future use now.

[string]$Script:ImplementationBranch = ""

# Name of DataCenter where the machine is located (e.g. Natick)

[string]$Script:DataCenter = ""

# Domain name based on datacenter
[string]$Script:DomainName = "NATICK-NT"  # default domain name	We can override it in Do-InitialSteps() function and by XML DB or API returns

# Supported locales for the machine (e.g. NA, EU, Global)

[array]$Script:SupportedLocales = @()

# Default script action is validation.
# For installation use -install command line parameter.
# Purpose: in common functions we switch between validation and install mode.
# This variable should be modified only by using -install command line parameter
# and should not be used outside of this common library.
[bool]$Script:ValidateOnly = $true

[bool]$Script:AutomaticMode = $false
[bool]$Script:DoLog = $true

# Default local log location
[string]$Script:LogDir = "c:\logs\baseline"

# In case of install mode, we want to create central log file in this directory
[string]$Script:CentralLogDir = "c:\logs\baseline"


# By default, we don't do passwords checks - validating (no password input required).
# The idea of this is, that if you run the script very often (e.g. when debugging it)
# you probably don't want to be asked for passwords every time.
# If any of your library packages requires password as an input, DO NOT place them
# into package in plaintext. Instead, get password using library function
# Get-CredentialPassword([string]$UserName), it will handle returning password for
# $UserName by either asking for it (popup window) or just returning it in case you already
# asked for $UserName's password anywhere in code (storing passwords in $Script:Passwords).
# Use this variable in your packages to evaluate whether the password check is turned on or not.
[bool]$Script:DoPasswordsCheck = $false


########################################################################################################


# Path to Remote storage
# You should be using this variable as part of any install path
[string]$Script:StoragePath = "" # will be set in Do-InitialSteps() function


# PS commands action preferences
# by default, we supress PS errors
# to see all PS errors use -errors command line parameter (e.g. for debugging)
$ErrorActionPreference = "SilentlyContinue"
$DebugPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
$ProgressPreference = "Continue"
$VerbosePreference = "SilentlyContinue"


########################################################################################################
#
#   Predefined variables - end
#
########################################################################################################





########################################################################################################
#
#   Baseline script required functions - begin
#
########################################################################################################

# Initialize sesion
#################################################
function Do-InitialSteps()
{
	#################################################
	# 1. parse command line parameters
	# 2. initialize log file(s)
	# 3. write log header
	#    - Command Line Parameters
	#    - logfile(s) path
	#    - Start Time
	#    - UserName
	#    - Machine - computername (OS version)
	#    - Environment (prod/qa/dev)
	#    - mode validation/install (automatic)
	#    - password check
	# 4. check system requirements
	#################################################
	
	
	$Script:ComputerName =  $Env:COMPUTERNAME
	$Script:UserName = $Env:USERNAME
	$Script:Date = Get-Date
	
	# summary array
	$Script:Summary = @{}
	$Script:Summary["INFO"] = 0
	$Script:Summary["WARN"] = 0
	$Script:Summary["ERROR"] = 0
	$Script:Summary["FATAL"] = 0
	$Script:Summary["OK"] = 0 # ResultOK
	$Script:Summary["KO"] = 0 # ResultFailure
	
	
	# 1. Parse command line arguments
	#################################################
	Private-ParseCommandLineArguments
	
	
	# 2. initializing log file(s)
	#################################################
	$LogFileName = "Baseline_" + $Script:ComputerName + "_" + (Get-Date -Date $Script:Date -Format 'yyyy-MM-dd-HH-mm-ss') + "_" + $PID + ".log"
	$Script:CentralLogFile = $Script:CentralLogDir + "\" + $LogFileName
	if ($Script:LogDir -ne "")
	{
		if (-not (Test-Path $Script:LogDir))
		{
			$Result = New-Item -Path $Script:LogDir -ItemType directory
		}
		$Script:LogFile = $Script:LogDir + "\" + $LogFileName
	}
	else
	{
		$Script:LogFile = $LogFileName
	}


	# 3. write log header
	#################################################
	Write-Log -Message "**************************************************************************************"
    Private-ReviewFileHeader 
    Write-Log -Message "**************************************************************************************"
	if ($Script:args.length -gt 0)
		{ Write-Log -Message ("Command line parameters: " + $Script:args) }
	else
		{ Write-Log -Message "Command line parameters: none" }
	if (-not $Script:ValidateOnly -and $Script:CentralLogDir -ne "")
		{ Write-Log -Message ("Central log file: " + $Script:CentralLogFile) }
	else
		{ Write-Log -Message "Central log file: none" }
	if ($Script:DoLog)
		{ Write-Log -Message ("Log file: " + $Script:LogFile) }
	else
		{ Write-Log -Message "Log file: none" }

	Write-Log -Message "**************************************************************************************"
	Write-Log -Message ("Start Time: " + $Script:Date)
	Write-Log -Message ("UserName: " + $Script:UserName)
	Write-Log -Message ("Machine: " + $Script:ComputerName)
	Write-Log -Message ("Environment: " + $Script:Environment)
	Write-Log -Message ("Domain Name: " + $Script:DomainName)
	Write-Log -Message ("Validate only mode: " + $Script:ValidateOnly)
	Write-Log -Message ("Automatic mode: " + $Script:AutomaticMode)
	if ($Script:AutomaticMode -and $Script:DoPasswordsCheck)
	{
		$Script:DoPasswordsCheck = $false
		Write-Log -Message "Passwords check: forcing to FALSE (running in automatic mode)"
	}
	else
	{
		Write-Log -Message ("Passwords check: " + $Script:DoPasswordsCheck)
	}
	
	if ($Script:AutomaticMode)
	{
		Write-Log -Message "**************************************************************************************"
		Write-Log -Message "WARNING: SCRIPT IS RUNNING IN AUTOMATIC MODE, ALL MANUAL INPUTS WILL BE SKIPPED"
	}
	Write-Log -Message "**************************************************************************************"
	
	
	# 4. check system requirements
	#################################################
	Private-CheckSystemRequirements
}



# Finalize session
#################################################
function Do-FinalSteps()
{
	Write-Log
	Write-Log -Message "**************************************************************************************"
	Write-Log -Message "Complete."
	if (-not $Script:ValidateOnly -and $Script:CentralLogDir -ne "")
		{ Write-Log -Message ("Central log file: " + $Script:CentralLogFile) }
	else
		{ Write-Log -Message "Central log file: none" }
	if ($Script:DoLog)
		{ Write-Log -Message ("Log file: " + $Script:LogFile) }
	else
		{ Write-Log -Message "Log file: none" }
	Write-Log -Message "**************************************************************************************"
	Write-Log -Message ("Result OK: "+$Script:Summary["OK"])
	Write-Log -Message ("Result Failure: "+$Script:Summary["KO"])
	Write-Log -Message "**************************************************************************************"
	Write-Log -Message ("INFO: "+$Script:Summary["INFO"]+"  WARNING: "+$Script:Summary["WARN"]+"  ERROR: "+$Script:Summary["ERROR"]+"  FATAL: "+$Script:Summary["FATAL"])
	
	exit
}

########################################################################################################
#
#   Baseline script required functions - end
#
########################################################################################################








########################################################################################################
#
#   System functions - begin
#
########################################################################################################

# Check Windows Features and Roles
#################################################
function Check-WindowsFeatures([string[]]$Features = @())
{
	$Category = "FEATURE"
	
	# Documentation can be found here - http://technet.microsoft.com/en-us/library/cc732263.aspx
	
	if ($Features.Count -eq 0)
	{
		Write-Log -Message "No features required."
		return 
	}
	
	[string[]]$FeaturesNeeded = @()
	
	#import the Server Manager Module.
	Write-Log -Message "Importing the Server Manager Module."
	Import-Module ServerManager
	
	# Generate a message indicating if the feature is installed or not
	foreach ($i in $Features)
	{
		if ((Get-WindowsFeature -Name $i).Installed -eq $true)
		{
			Write-Log -Message $i -Category $Category -ResultOK -ResultMessage "installed"
		}
		else 
		{
			if ($Script:ValidateOnly)
				{ $ResultMessage = "not installed" }
			else
				{ $ResultMessage = "to be installed" }
			
			Write-Log -Message $i -Category $Category -ResultFailure -ResultMessage $ResultMessage
			$FeaturesNeeded += $i
		}
	}
	
	if (-not $Script:ValidateOnly -and $FeaturesNeeded.Count -gt 0)
	{
		Write-Log -Message "-> Installing missing Windows Features and Roles ..."
		
		$Result = Add-WindowsFeature $FeaturesNeeded
		

			foreach ($Feature in $Result.FeatureResult)
			{
				if ($Feature.Success -eq $true)
					{ Write-Log -Message ("-> Feature: "+$Feature.DisplayName) -ResultOK -ResultMessage ("Restart needed: "+$Feature.RestartNeeded) }
				else
					{ Write-Log -Message ("-> Feature: "+$Feature.DisplayName) -EntryType "ERROR" -ResultFailure -ResultMessage ("Restart needed: "+$Feature.RestartNeeded) }
			}

	}
}


# Check Windows Features and Roles - Removal
#################################################
function Check-WindowsFeatures-Remove-Features([string[]]$Features = @())
{
	$Category = "FEATURE"
	
	# Documentation can be found here - http://technet.microsoft.com/en-us/library/cc732263.aspx
	
	if ($Features.Count -eq 0)
	{
		Write-Log -Message "No features to be removed."
		return 
	}
	
	[string[]]$FeaturesNeedToBeRemoved = @()
	
	#import the Server Manager Module.
	Write-Log -Message "Importing the Server Manager Module."
	Import-Module ServerManager
	
	# Generate a message indicating if the feature is installed or not
	foreach ($i in $Features)
	{
		if ((Get-WindowsFeature -Name $i).Installed -eq $true)
		{
			if ($Script:ValidateOnly)
				{ $ResultMessage = "installed (should not be)" }
			else
				{ $ResultMessage = "to be uninstalled" }
			
			Write-Log -Message $i -Category $Category -ResultFailure -ResultMessage $ResultMessage
			$FeaturesNeedToBeRemoved += $i
		}
		else 
		{
			Write-Log -Message $i -Category $Category -ResultOK -ResultMessage "not installed"
		}
	}
	
	if (-not $Script:ValidateOnly -and $FeaturesNeedToBeRemoved.Count -gt 0)
	{
		Write-Log -Message "-> Uninstalling Windows Features and Roles ..."
		
		$Result = Remove-WindowsFeature $FeaturesNeedToBeRemoved
		
		foreach ($Feature in $Result.FeatureResult)
		{
			if ($Feature.Success -eq $true)
				{ Write-Log -Message ("-> Feature: "+$Feature.DisplayName) -ResultOK -ResultMessage ("Restart needed: "+$Feature.RestartNeeded) }
			else
				{ Write-Log -Message ("-> Feature: "+$Feature.DisplayName) -EntryType "ERROR" -ResultFailure -ResultMessage ("Restart needed: "+$Feature.RestartNeeded) }
		}
	}
}


# Check daylight savings timezone
# See the tzutil /l for possible TimeZoneIDs
#################################################
function Check-DaylightTimeZone([string]$TimeZoneID = "Eastern Standard Time")
{
	$Category = "SYSTEM"
	
	$strTimezone = Get-WMIObject -class Win32_TimeZone -ComputerName .
	
	if($strTimezone.DaylightName -eq $TimeZoneID)
	{
		Write-Log -Message ("Daylight TimeZone: "+$strTimezone.DaylightName) -Category $Category -ResultOK -ResultMessage "correct"
	}
	else 
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message ("Daylight TimeZone: "+$strTimezone.DaylightName) -Category $Category -ResultFailure -ResultMessage "incorrect"
		}
		else
		{
			Write-Log -Message ("Daylight TimeZone: "+$strTimezone.DaylightName) -Category $Category -ResultFailure -ResultMessage "to be updated"
			
			$Result = Invoke-Expression ("tzutil /s `""+$TimeZoneID+"_dstoff`"")
			
			if ($LastExitCode -eq 0)
			{
				Write-Log -Message "-> Daylight TimeZone set to: $TimeZoneID" -ResultOK -ResultMessage "success"
			}
			else
			{
				Write-Log -Message "-> Daylight TimeZone NOT set to: $TimeZoneID" -EntryType "ERROR" -ResultFailure -ResultMessage $Result
			}
	    }
	}
}


# Check group membership
#################################################
function Check-GroupMembership([string]$IdentityReference, [string]$Group)
{
	$Category = "GROUP"
	
	# list members of local group  http://powershell.com/cs/media/p/3215.aspx
	
	$GroupObject = [ADSI]("WinNT://./" + $Group + ",group") 
 
    $Members = @() 
    $GroupObject.Members() | 
    % { 
        $AdsPath = $_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null) 
        # Domain members will have an ADSPath like WinNT://DomainName/UserName. 
        # Local accounts will have a value like WinNT://DomainName/ComputerName/UserName. 
        $a = $AdsPath.split('/',[StringSplitOptions]::RemoveEmptyEntries) 
        $Name = $a[-1] 
        $Domain = $a[-2]
		# hack for no domain
		if ($Domain -eq 'WinNT:') { $Domain = '' }
		
		$Members += "$Domain\$Name"
    } 
	
	if ( $Members -icontains $IdentityReference )
	{
		Write-Log -Message ($Group+": "+$IdentityReference) -Category $Category -ResultOK -ResultMessage "in group"
	}
	else
	{
		
		if ($Script:ValidateOnly)
		{
			Write-Log -Message ($Group+": "+$IdentityReference) -Category $Category -ResultFailure -ResultMessage "missing"
		}
		else
		{
			Write-Log -Message ($Group+": "+$IdentityReference) -Category $Category -ResultFailure -ResultMessage "to be added"
			
			try
			{
				$objUser = New-Object System.Security.Principal.NTAccount("$IdentityReference")
				$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])

				#$GroupObject.Add("WinNT://" + $IdentityReference.Split('\')[0] + "/" + $IdentityReference.Split('\')[1])
				$GroupObject.Add("WinNT://$strSID")
			}
			catch
			{
				$ErrorMsg = $_.Exception.Message.Replace("`r`n", "") # this could be better
			}
			
			if (-not $ErrorMsg)
			{
				Write-Log -Message "-> adding $IdentityReference to $Group group" -ResultOK -ResultMessage "success"
			}
			else
			{
				Write-Log -Message "-> adding $IdentityReference to $Group group" -EntryType "ERROR" -ResultFailure -ResultMessage $ErrorMsg
			}
		}
	}
}


# Check Event log size
#################################################
function Check-EventLogSize([string]$Log, [int64]$Size)
{
	$Category = "LOG"
	
	if (-not ($MaxSize = (get-eventlog -list | where {$_.logDisplayName -eq $Log}).maximumKilobytes))
	{
		Write-Log -Message "$Log not found (skipping check)" -EntryType "WARNING" -Category $Category
		return
	}
	
	$Msg = 	"$Log (size: ${MaxSize}kB, requested: ${Size}kB)"
	
	if ( $MaxSize -ge $Size )
	{
		Write-Log -Message $Msg -Category $Category -ResultOK -ResultMessage "OK"
	}
	else
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message $Msg -Category $Category -ResultFailure -ResultMessage "incorrect"
		}
		else
		{
			Write-Log -Message $Msg -Category $Category -ResultFailure -ResultMessage "to be updated"
			
			Limit-EventLog -LogName $Log -MaximumSize ($Size*1024)
			
			if ($?)
				{ Write-Log -Message "-> setting $Log log size to ${Size}kB" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> setting $Log log size to ${Size}kB" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
		}
	}
}


# Check PathEntry to Environment:PATH
#################################################
function Check-EnvPath([string]$PathEntry, [switch]$Remove)
{	
	# DO NOT use $env:path - this would change only PATH in current session
	$CurrentPath =  [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
	$PathEntry = $PathEntry.Trim()
	
	$Paths = $CurrentPath.Split(';') | %{ $_.Trim() }
	
	if ($Remove)
	{
		$Category = "ENV:PATH REMOVAL"
		
		if ($Paths -icontains $PathEntry)
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message $PathEntry -Category $Category -ResultFailure -ResultMessage "not needed"
			}
			else
			{
				Write-Log -Message $PathEntry -Category $Category -ResultFailure -ResultMessage "to be removed"
				
				try 
				{ 
					[System.Environment]::SetEnvironmentVariable("PATH", @($Paths | Where-Object {$_ -notlike $PathEntry}) -Join ';' ,"Machine")
				}
				catch 
				{
					Write-Log -Message "-> Removing $PathEntry from ENV:PATH" -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
					return
				}
				
				Write-Log -Message "-> Removing $PathEntry from ENV:PATH" -ResultOK -ResultMessage "success"
			}
		}
		else
		{
			Write-Log -Message $PathEntry -Category $Category -ResultOK -ResultMessage "not present"
		}
	}
	else
	{
		$Category = "ENV:PATH"
		
		if ($Paths -icontains $PathEntry)
		{
			Write-Log -Message $PathEntry -Category $Category -ResultOK -ResultMessage "present"
		}
		else
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message $PathEntry -Category $Category -ResultFailure -ResultMessage "not present"
			}
			else
			{
				Write-Log -Message $PathEntry -Category $Category -ResultFailure -ResultMessage "to be added"
				
				try 
				{ 
					[System.Environment]::SetEnvironmentVariable("PATH", ($Paths + $PathEntry) -Join ';' ,"Machine")
				}
				catch 
				{
					Write-Log -Message "-> Adding $PathEntry to ENV:PATH" -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
					return
				}
				
				Write-Log -Message "-> Adding $PathEntry to ENV:PATH" -ResultOK -ResultMessage "success"
			}
		}
	}
}


# Check Variable in Machine Environment
#################################################
function Check-EnvironmentVariable([string]$Name, [string]$Value, [switch]$Remove)
{
	$Name = $Name.Trim()
	$Value = $Value.Trim()
	$EnvVarValue =  [System.Environment]::GetEnvironmentVariable($Name, "Machine")
	
	if ($Remove)
	{
		$Category = "ENV:$Name REMOVAL"
		
		if ($EnvVarValue -eq $null)
		{
			Write-Log -Message "<null>" -Category $Category -ResultOK -ResultMessage "not present"
		}
		else
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message $EnvVarValue -Category $Category -ResultFailure -ResultMessage "not needed"
			}
			
			else
			{
				Write-Log -Message $EnvVarValue -Category $Category -ResultFailure -ResultMessage "to be removed"
				
				try 
				{ 
					[System.Environment]::SetEnvironmentVariable($Name, $null ,"Machine")
				}
				catch 
				{
					Write-Log -Message "-> Removing $Name from ENV" -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
					return
				}
				
				Write-Log -Message "-> Removing $Name from ENV" -ResultOK -ResultMessage "success"
			}
		}
	}
	else
	{
		$Category = "ENV:$Name"
		
		if ($EnvVarValue -eq $null)
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message "req: $Value" -Category $Category -ResultFailure -ResultMessage "not present"
			}
			else
			{
				Write-Log -Message "req: $Value" -Category $Category -ResultFailure -ResultMessage "to be added"
				
				try 
				{ 
					[System.Environment]::SetEnvironmentVariable($Name, $Value ,"Machine")
				}
				catch 
				{
					Write-Log -Message "-> Adding $Name to ENV" -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
					return
				}
				
				Write-Log -Message "-> Adding $Name to ENV" -ResultOK -ResultMessage "success"
			}
		}
		elseif ($EnvVarValue -ne $Value)
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message "cur: $EnvVarValue, req: $Value" -Category $Category -ResultFailure -ResultMessage "differs"
			}
			else
			{
				Write-Log -Message "cur: $EnvVarValue, req: $Value" -Category $Category -ResultFailure -ResultMessage "to be updated"
				
				try 
				{ 
					[System.Environment]::SetEnvironmentVariable($Name, $Value ,"Machine")
				}
				catch 
				{
					Write-Log -Message "-> Updating ENV:$Name to $Value" -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
					return
				}
				
				Write-Log -Message "-> Updating ENV:$Name to $Value" -ResultOK -ResultMessage "success"
			}
		}
		else
		{
			Write-Log -Message $Value -Category $Category -ResultOK -ResultMessage "OK"
		}
	}
}


# Check registry setting
#################################################
function Check-RegistrySetting([string]$Path, [string]$Property = '', $Value, $PropertyType)
{
	$Category = "REG"
	
	# PropertyType: "Microsoft.Win32.RegistryValueKind". The possible enumeration values are "String, ExpandString, Binary, DWord, MultiString, QWord, Unknown".
	# TODO: also check for same PropertyType
	
	
	#################################################
	function Check-RegistrySetting-Create-RegistryKey([string]$Path)
	{
		$Res = $true
		
		$PathToCreate = ''
		foreach ($tmp in $Path.Split('\'))
		{
			$tmp = $tmp.Trim()
			if ($tmp -ne '')
			{
				if ($PathToCreate -ne '') { $PathToCreate += '\' }
				$PathToCreate += $tmp
				
				if (-not (Test-Path $PathToCreate))
				{
					#there is a bug in powershell's registry provider that prevents editing registry keys with '/'s - so these have to be added using the old method instead of powershell's native methods
					if ($PathToCreate.Contains('/'))
					{
						$Temp = $PathToCreate.substring(0,$PathToCreate.indexof(":")) + $PathToCreate.substring($PathToCreate.indexof(":")+1)
						
						$Result = REG ADD $Temp 2> $null
						
						if ($LastExitCode -ne 0)
						{
							$Res = $false
							$Created = $false
							break
						}
						
						$Created = $true
					}
					else
					{
						if (-not (New-Item $PathToCreate))
						{
							$Res = $false
							$Created = $false
							break
						}
						
						$Created = $true
					}
				}
			}
		}
		
		if ($Created -eq $true)
		{
			Write-Log -Message "-> creating $Path key" -ResultOK -ResultMessage "success"
		}
		elseif ($Created -eq $false)
		{
			Write-Log -Message "-> creating $Path key" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
		}
		
		return $Res
	}

	
	#################################################
	function Check-RegistrySetting-Check-RegistryKey ([string]$Path)
	{
		if (Test-Path $Path)
		{
			Write-Log -Message "$Path key" -Category $Category -ResultOK -ResultMessage "found"
		}
		else
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message "$Path key" -Category $Category -ResultFailure -ResultMessage "not found"
			}
			else
			{
				Write-Log -Message "$Path key" -Category $Category -ResultFailure -ResultMessage "to be created"
				$Result = Check-RegistrySetting-Create-RegistryKey -Path $Path
			}
		}
	}
	
	#################################################
	function Check-RegistrySetting-Set-RegistryProperty ([string]$Path, [string]$Property, $Value, $PropertyType)
	{
		if ((Get-ItemProperty $Path).$Property -eq $null)
		{ 
			$Result = New-ItemProperty $Path -name $Property -value $Value -PropertyType $PropertyType
			if ($?)
				{ Write-Log -Message "-> adding $Path.$Property" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> adding $Path.$Property" -EntryType "ERROR" -ResultFailure -ResultMessage "failure" }
		}
		else
		{ 
			$Result = Set-ItemProperty $Path -name $Property -value $Value
			if ($?)
				{ Write-Log -Message "-> updating $Path.$Property" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> updating $Path.$Property" -EntryType "ERROR" -ResultFailure -ResultMessage "failure" }
		}
	}
	
	
	# checking key only
	if ($Property -eq '')
	{
		Check-RegistrySetting-Check-RegistryKey -Path $Path
		return
	}
	
	# else
	# checking property
	if ($Value -eq $null)
	{
		Write-Log -Message "$Path.$Property - value not specified (skipping check)" -EntryType "WARNING" -Category $Category 
		return
	}
	if ($PropertyType -eq $null)
	{
		Write-Log -Message "$Path.$Property - PropertyType not specified (skipping check)" -EntryType "WARNING" -Category $Category
		return
	}
	
	$RegValue = (Get-ItemProperty $Path).$Property
	
	if ($RegValue -eq $null)
	{
		if ($Script:ValidateOnly)
		{ 
			Write-Log -Message "$Path.$Property (cur: null, req: $Value)" -Category $Category -ResultFailure -ResultMessage "not found"
		}
		else
		{
			Write-Log -Message "$Path.$Property (cur: null, req: $Value)" -Category $Category -ResultFailure -ResultMessage "to be added"
			if (Check-RegistrySetting-Create-RegistryKey -Path $Path) 
			{
				Check-RegistrySetting-Set-RegistryProperty $Path -Property $Property -value $Value -PropertyType $PropertyType
			}
		}
	}
	elseif (($RegValue -eq $Value) -or ((Compare-Object $RegValue $Value) -eq $Null)) 
	{
		Write-Log -Message "$Path.$Property (cur: $RegValue, req: $Value)" -Category $Category -ResultOK -ResultMessage "OK"
	}
	else
	{
		if ($Script:ValidateOnly)
		{
			 Write-Log -Message "$Path.$Property (cur: $RegValue, req: $Value)" -Category $Category -ResultFailure -ResultMessage "incorrect"
		}
		else
		{
			Write-Log -Message "$Path.$Property (cur: $RegValue, req: $Value)" -Category $Category -ResultFailure -ResultMessage "to be updated"
			if (Check-RegistrySetting-Create-RegistryKey -Path $Path) 
			{
				Check-RegistrySetting-Set-RegistryProperty $Path -Property $Property -value $Value -PropertyType $PropertyType
			}
		}
	}
}


# Check Service
#################################################
function Check-Service([string]$Name, $DisplayName, $BinaryPathName, $Description, $UserName, $StartupType, [switch]$ForceStartStop, [switch]$ForceRestart)
{
	$Category = "SERVICE"
	
	#################################################
	function Check-Service-InnerCheck-ServiceProperty([string]$Property, [string]$Value)
	{
		switch ($Property)
		{
			"BinaryPathName" { $WmiProperty = "PathName" }
			"StartupType" { $WmiProperty = "StartMode" }
			"DisplayName" { $WmiProperty = "DisplayName" }
			"Description" { $WmiProperty = "Description" }
			"UserName" { $WmiProperty = "StartName" }
		}
		
		$PropertyValue = $Service.$WmiProperty
		
		if ($WmiProperty -eq "StartMode" -and $PropertyValue -eq "auto") { $PropertyValue = "automatic" }
		
		if ($PropertyValue -eq $Value)
		{
			Write-Log -Message "$Name.$Property = $PropertyValue (req: $Value)" -Category $Category -ResultOK -ResultMessage "OK"
		}
		else
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message "$Name.$Property = $PropertyValue (req: $Value)" -Category $Category -ResultFailure -ResultMessage ("incorrect")
			}
			else
			{
				Write-Log -Message "$Name.$Property = $PropertyValue (req: $Value)" -Category $Category -ResultFailure -ResultMessage ("to be updated")
				
				switch ($Property)
				{
					"BinaryPathName" { $Result = $Service.Change($null, $Value, $null, $null, $null, $null, $null, $null, $null, $null, $null) }
					"StartupType" { Set-Service -Name $Name -StartupType "$Value" }
					"DisplayName" { Set-Service -Name $Name -DisplayName "$Value" }
					"Description" { Set-Service -Name $Name -Description "$Value" }
					"UserName" {
						# changing credentials to system accounts
						if ($Value -eq "LocalSystem" -or $Value -eq "NT AUTHORITY\NetworkService")
						{
							$Result = $Service.Change($null, $null, $null, $null, $null, $null, $Value, "", $null, $null, $null)
						}
						# changing credentials to user defined
						else
						{
							if (($Cred = Get-BaselineCredential -UserName $UserName) -eq $null)
							{
								Write-Log -Message "No password for '$UserName' was entered, service $Name credential will not be updated." -EntryType "WARNING" -ResultFailure
								return
							}
							else
							{
								$Result = $Service.Change($null, $null, $null, $null, $null, $null, $Cred.UserName, [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:Credentials.Item($Cred.UserName).Password)), $null, $null, $null)
							}
						}
					}
				}
				
				if ($?)
				{
					if ($Result)
					{
						if ($Result.ReturnValue -eq 0)
							{ Write-Log -Message "-> updating $Name.$Property -> $Value" -ResultOK -ResultMessage "OK" }
						else
							{ Write-Log -Message "-> updating $Name.$Property -> $Value" -EntryType "ERROR" -ResultFailure -ResultMessage ("failure (Error "+$Result.ReturnValue+")") }
					}
					else
					{
						Write-Log -Message "-> updating $Name.$Property -> $Value" -ResultOK -ResultMessage "OK"
					}
				}
				else
				{
					Write-Log -Message "-> updating $Name.$Property -> $Value" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message
				}
			}
		}
	}
	
	
	#################################################
	function Check-Service-InnerCheck-ServiceStatus()
	{
		function Check-Service-InnerCheck-ServiceStatus-StartService()
		{
			Start-Service "$Name"
			if ($?)
				{ Write-Log -Message "-> starting $Name service" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> starting $Name service" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
		}
		function Check-Service-InnerCheck-ServiceStatus-StopService()
		{
			Stop-Service "$Name"
			if ($?)
				{ Write-Log -Message "-> stopping $Name service" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> stopping $Name service" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
		}
		function Check-Service-InnerCheck-ServiceStatus-RestartService()
		{
			Restart-Service "$Name"
			if ($?)
				{ Write-Log -Message "-> forcing $Name service restart" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> forcing $Name service restart" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
		}
		
		$service = gwmi win32_service -Filter "name='$Name'"
		
		# service is requested to auto
		if ($service.StartMode -eq "auto")
		{
			# service is running
			if ($service.State -eq "Running")
			{
				Write-Log -Message "$Name state" -Category $Category -ResultOK -ResultMessage "running"
				
				if (-not $Script:ValidateOnly -and $ForceRestart)
				{
					Check-Service-InnerCheck-ServiceStatus-RestartService
				}
			}
			# service is stopped
			else
			{
				if (-not $Script:ValidateOnly -and $ForceStartStop)
				{
					Write-Log -Message "$Name state" -Category $Category -ResultFailure -ResultMessage "stopped (to be started)"
					Check-Service-InnerCheck-ServiceStatus-StartService
				}
				else
				{
					Write-Log -Message "$Name state" -Category $Category -ResultFailure -ResultMessage "stopped"
				}
			}
		}
		# service is requested to manual
		elseif ($service.StartMode -eq "manual")
		{
			# service is running
			if ($service.State -eq "Running")
			{
				Write-Log -Message "$Name state" -Category $Category -ResultOK -ResultMessage "running"
				
				if (-not $Script:ValidateOnly -and $ForceRestart)
				{
					Check-Service-InnerCheck-ServiceStatus-RestartService
				}
			}
			# service is stopped
			else
			{
				Write-Log -Message "$Name state" -Category $Category -ResultOK -ResultMessage "stopped"
			}
		}
		# service is requested to disabled
		elseif ($service.StartMode -eq "disabled")
		{
			# service is running
			if ($service.State -eq "Running")
			{
				if (-not $Script:ValidateOnly -and $ForceStartStop)
				{
					Write-Log -Message "$Name state" -Category $Category -ResultFailure -ResultMessage "running (to be stopped)"
					Check-Service-InnerCheck-ServiceStatus-StopService
				}
				else
				{
					Write-Log -Message "$Name state" -Category $Category -ResultFailure -ResultMessage "running"
				}
			}
			# service is stopped
			else
			{
				Write-Log -Message "$Name state" -Category $Category -ResultOK -ResultMessage "stopped"
			}
		}
	}
	
	# service is installed, checking properties
	if ($Service = gwmi win32_service -Filter "name='$Name'")
	{
		Write-Log -Message "$Name is installed" -Category $Category -ResultOK
		
		if ($BinaryPathName -ne $null) { Check-Service-InnerCheck-ServiceProperty -Property "BinaryPathName" -Value $BinaryPathName }
		if ($StartupType -ne $null) { Check-Service-InnerCheck-ServiceProperty -Property "StartupType" -Value $StartupType }
		if ($DisplayName -ne $null) { Check-Service-InnerCheck-ServiceProperty -Property "DisplayName" -Value $DisplayName }
		if ($Description -ne $null) { Check-Service-InnerCheck-ServiceProperty -Property "Description" -Value $Description }
		if ($UserName -ne $null) { Check-Service-InnerCheck-ServiceProperty -Property "UserName" -Value $UserName }

		Check-Service-InnerCheck-ServiceStatus
	}
	# service is not installed
	else
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message "$Name is not installed" -Category $Category -ResultFailure
		}
		else
		{
			Write-Log -Message "$Name is not installed" -Category $Category -ResultFailure -ResultMessage "to be installed"
			
			if ($BinaryPathName -eq $null)
			{
				Write-Log -Message "BinaryPathName is not defined! Unable to install service $Name." -EntryType "ERROR" -Category $Category -ResultFailure
				return
			}
			
			# UserName defined, script is in automatic mode. Cannot install service b/c prompts are suppressed.
			if ($UserName -ne $null -and $Script:AutomaticMode)
			{
				Write-Log -Message "Running in automatic mode, service $Name will not be installed!" -EntryType "ERROR" -ResultFailure
				return
			}
			
			$Cmd = "New-Service -Name $Name -BinaryPathName `"$BinaryPathName`""
			if ($DisplayName -ne $null) { $Cmd += " -DisplayName `"$DisplayName`"" }
			if ($Description -ne $null) { $Cmd += " -Description `"$Description`"" }
			if ($StartupType -ne $null) { $Cmd += " -StartupType `"$StartupType`"" }
			
			if ($UserName -ne $null)
			{
				if ($UserName -ne "LocalSystem" -and $UserName -ne "NT AUTHORITY\NetworkService")
				{
					if (($Cred = Get-BaselineCredential -UserName $UserName) -eq $null)
					{
						Write-Log -Message "No password for '$UserName' was entered, service $Name will not be installed!" -EntryType "ERROR" -ResultFailure
						return
					}
					else
					{
						$Cmd += " -Credential `$Cred"
					}
				}
			}
			
			$Result = Invoke-Expression $Cmd

			if ($Result -ne $null)
				{ Write-Log -Message "-> installing $Name service" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> installing $Name service" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
		}
	}
}

# Check Application StartupType
#################################################
function Check-Service-StartupType([string]$Name, [switch]$Auto, [switch]$Manual, [switch]$Disabled, [switch]$ForceStartStop, [switch]$ForceRestart)
{
	$Category = "SERVICE"
	
    #################################################
	function Check-Service-InnerCheck-ServiceStatus()
	{
		function Check-Service-InnerCheck-ServiceStatus-StartService()
		{
			Start-Service "$Name"
			if ($?)
				{ Write-Log -Message "-> starting $Name service" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> starting $Name service" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
		}
		function Check-Service-InnerCheck-ServiceStatus-StopService()
		{
			Stop-Service "$Name"
			if ($?)
				{ Write-Log -Message "-> stopping $Name service" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> stopping $Name service" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
		}
		function Check-Service-InnerCheck-ServiceStatus-RestartService()
		{
			Restart-Service "$Name"
			if ($?)
				{ Write-Log -Message "-> forcing $Name service restart" -ResultOK -ResultMessage "success" }
			else
				{ Write-Log -Message "-> forcing $Name service restart" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
		}
		
		$service = gwmi win32_service -Filter "name='$Name'"
		
		# service is requested to auto
		if ($service.StartMode -eq "auto")
		{
			# service is running
			if ($service.State -eq "Running")
			{
				Write-Log -Message "$Name state" -Category $Category -ResultOK -ResultMessage "running"
				
				if (-not $Script:ValidateOnly -and $ForceRestart)
				{
					Check-Service-InnerCheck-ServiceStatus-RestartService
				}
			}
			# service is stopped
			else
			{
				if (-not $Script:ValidateOnly -and $ForceStartStop)
				{
					Write-Log -Message "$Name state" -Category $Category -ResultFailure -ResultMessage "stopped (to be started)"
					Check-Service-InnerCheck-ServiceStatus-StartService
				}
				else
				{
					Write-Log -Message "$Name state" -Category $Category -ResultFailure -ResultMessage "stopped"
				}
			}
		}
		# service is requested to manual
		elseif ($service.StartMode -eq "manual")
		{
			# service is running
			if ($service.State -eq "Running")
			{
				Write-Log -Message "$Name state" -Category $Category -ResultOK -ResultMessage "running"
				
				if (-not $Script:ValidateOnly -and $ForceRestart)
				{
					Check-Service-InnerCheck-ServiceStatus-RestartService
				}
			}
			# service is stopped
			else
			{
				Write-Log -Message "$Name state" -Category $Category -ResultOK -ResultMessage "stopped"
			}
		}
		# service is requested to disabled
		elseif ($service.StartMode -eq "disabled")
		{
			# service is running
			if ($service.State -eq "Running")
			{
				if (-not $Script:ValidateOnly -and $ForceStartStop)
				{
					Write-Log -Message "$Name state" -Category $Category -ResultFailure -ResultMessage "running (to be stopped)"
					Check-Service-InnerCheck-ServiceStatus-StopService
				}
				else
				{
					Write-Log -Message "$Name state" -Category $Category -ResultFailure -ResultMessage "running"
				}
			}
			# service is stopped
			else
			{
				Write-Log -Message "$Name state" -Category $Category -ResultOK -ResultMessage "stopped"
			}
		}
	}
    
	if ($Auto) { $StartupType = "Automatic"; $StartupTypeAlt = "Auto" }
	elseif ($Manual) { $StartupType = "Manual" }
	elseif ($Disabled) { $StartupType = "Disabled" }
	else { $StartupType = "UNKNOWN" }
	
	# service is installed, checking properties
	if ($StartupType -eq "UNKNOWN")
	{
		Write-Log -Message "-> Baseline BAD: Startup Type is set to $($StartupType)" -EntryType "ERROR" -ResultFailure -ResultMessage "you bad"
	}
	elseif ($Service = gwmi win32_service -Filter "name='$Name'")
	{
		Write-Log -Message "$Name found" -Category $Category -ResultOK
		if ($Script:ValidateOnly)
		{
			if (($Service.StartMode -eq $StartupType) -or ($Service.StartMode -eq $StartupTypeAlt))
			{
				Write-Log -Message "-> Startup Type is set to $($Service.StartMode)" -ResultOK -ResultMessage "good"
			}
			else
			{
				Write-Log -Message "-> Startup Type is set to $($Service.StartMode), expecting $StartupType" -EntryType "ERROR" -ResultFailure -ResultMessage "bad"
			}
		}
		else
		{
			if (($Service.StartMode -eq $StartupType) -or ($Service.StartMode -eq $StartupTypeAlt))
			{
				Write-Log -Message "-> Startup Type was already set to $($Service.StartMode)" -ResultOK -ResultMessage "good"
			}
			else
			{
				$ResultStartupType = "Set-Service `-Name `"$Name`" `-StartupType `"$StartupType`""
				Write-Log -Message "-> Running command: $($ResultStartupType)"
				$Result = Invoke-Expression $ResultStartupType
				$StartupTypeRecheck = gwmi win32_service -Filter "name='$Name'"
				
				if (($StartupTypeRecheck.StartMode -eq $StartupType) -or ($StartupTypeRecheck.StartMode -eq $StartupTypeAlt))
				{
					Write-Log -Message "-> Startup Type set to $($StartupTypeRecheck.StartMode)" -ResultOK -ResultMessage "success"
				}
				else
				{
					$StartupTypeRecheck
					Write-Log -Message "-> Startup Type can't be set to $($StartupTypeRecheck.StartMode) - trying to set: $($StartupType)" -EntryType "ERROR" -ResultFailure -ResultMessage "failed"
				}
			}
		}
        
        Check-Service-InnerCheck-ServiceStatus
	}
	# service is not installed
	else
	{
		Write-Log -Message "$Name is not installed - FastPass is supposed to install this" -Category $Category -ResultFailure -ResultMessage "re-run after RTM install"
	}
}

# Check Application
#################################################
function Check-Application([string]$AppName, [string]$AppVersion, [string]$CmdPath, [string]$CmdArguments)
{
	$Category = "APP"
	
	Write-Log
	Write-Log -Message "Checking $AppName ($AppVersion) ..."
	Write-Log
	
	$Cmd = $CmdPath
	if ($CmdArguments) { $Cmd += " '$CmdArguments'" }
	
	$InstalledVersion = Get-InstalledAppVersion -AppName $AppName
	
	# application is installed
	if ((($InstalledVersion -replace "\.",",")  -ge ($AppVersion -replace "\.",",")) -and $InstalledVersion -ne $false )
	{
		Write-Log -Message "$AppName CHECK($AppVersion) INSTALLED($InstalledVersion)" -Category $Category -ResultOK -ResultMessage "installed"
	}
	# application is not installed or version differs
	else
	{
		$Removed = $true
		
		# application is not installed
		if ($InstalledVersion -eq $false)
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "not installed"
			}
			else
			{
				Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "not installed (to be installed)"
			}
		}
		# version differs
		else
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "differs (found: $InstalledVersion)"
			}
			else
			{
				Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "differs (found: $InstalledVersion, to be upgraded)"
				$Removed = Private-UninstallApp -AppName $AppName
			}
		}
		
		# installing application
		if (-not $Script:ValidateOnly -and $Removed)
		{
			Write-Log -Message "-> Executing: $Cmd"
			Invoke-Expression "Start-Process $Cmd -Wait -NoNewWindow"
			$InstalledVersion = Get-InstalledAppVersion -AppName $AppName
			if ($InstalledVersion -replace "\.",","  -ge $AppVersion -replace "\.","," -and $InstalledVersion -ne $false)
			{
				Write-Log -Message "-> Install $AppName  CHECK($AppVersion) INSTALLED($InstalledVersion)" -ResultOK -ResultMessage "success"
			}
			else
			{
				Write-Log -Message "-> Install $AppName ($AppVersion)" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
			}
		}
	}
}

function Check-HotFix([string]$HotFixName, [string]$HotFixVersion, [string]$CmdPath, [string]$CmdArguments)
{
       $Category = "HotFix"
       
       Write-Log
       Write-Log -Message "Checking $HotFixName ($HotFixVersion) ..."
       Write-Log
       
       $Cmd = $CmdPath
       if ($CmdArguments) { $Cmd += " '$CmdArguments'" }
       
       $InstalledVersion = Get-InstalledAppVersion -AppName $HotFixName
       # HotFix is installed
       if ((($InstalledVersion -replace "\.",",")  -ge ($HotFixVersion -replace "\.",",")) -and ($InstalledVersion -ne $false) )
       {
              Write-Log -Message "$HotFixName CHECK($HotFixVersion) INSTALLED($InstalledVersion)" -Category $Category -ResultOK -ResultMessage "installed"
       }
       # HotFix is not installed or version differs
       else
       {
              
                 if ($Script:ValidateOnly)
                 {
                       Write-Log -Message "$HotFixName ($HotFixVersion)" -Category $Category -ResultFailure -ResultMessage "differs (found: $InstalledVersion)"
                 }
                 else
                 {
                       Write-Log -Message "$HotFixName ($HotFixVersion)" -Category $Category -ResultFailure -ResultMessage "differs (found: $InstalledVersion, to be upgraded)"
                       Write-Log -Message "-> Executing: $Cmd"
                       Invoke-Expression "Start-Process $Cmd -Wait -NoNewWindow"
                       $InstalledVersion = Get-InstalledAppVersion -HotFixName $HotFixName
                        if ((($InstalledVersion -replace "\.",",")  -ge ($HotFixVersion -replace "\.",",")) -and ($InstalledVersion -ne $false) )
                        {
                            Write-Log -Message "$HotFixName CHECK($HotFixVersion) INSTALLED($InstalledVersion)" -Category $Category -ResultOK -ResultMessage "installed"
                        }
                        else
                        {
                            Write-Log -Message "$HotFixName ($HotFixVersion)" -Category $Category -ResultFailure -ResultMessage "differs (found: $InstalledVersion)"
                        }
                }
              
       }
} 

# Check AppUninstall
#################################################
function Check-AppUninstall([string]$AppName)
{
	$Category = "APP"
	
	Write-Log
	Write-Log -Message "Checking uninstallation of $AppName ..."
	Write-Log
	
	$AppVersion = Get-InstalledAppVersion -AppName $AppName
	
	if ($AppVersion -ne $false)
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed"
		}
		else
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed (to be uninstalled)"
			$Removed = Private-UninstallApp -AppName $AppName
		}
	}
	else
	{
		Write-Log -Message "$AppName" -Category $Category -ResultOK -ResultMessage "not installed"
	}
}

# Check VersionAppUninstall
#################################################
function Check-VersionAppuninstall([string]$AppName, [string]$Version)
{
	$Category = "APP"
	
	Write-Log
	Write-Log -Message "Checking uninstallation of $AppName ($version)..."
	Write-Log
	
	$AppVersion = Get-InstalledAppVersion -AppName $AppName
	
	if ($AppVersion -eq $Version)
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed"
		}
		else
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed (to be uninstalled)"
			$Removed = Private-UninstallApp -AppName $AppName
		}
	}
	else
	{
		Write-Log -Message "$AppName" -Category $Category -ResultOK -ResultMessage "not installed"
	}
}



# Check Scheduled Task
#################################################
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
	#	    <Author>EU\thlavace</Author>
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
	
	#################################################
	function Check-ScheduledTask-CreateOrUpdateTask()
	{
		$XmlObj = [xml]$XmlDefinition
		
		if (($UserId = $XmlObj.Task.Principals.Principal.UserId) -eq $null)
		{
			Write-Log -Message "Cannot find UserName in task xml definition!" -Category $Category -EntryType "ERROR" -ResultFailure
			return
		}
		
		# defining action
		if ($SystemTask -eq $null) { $Action = "create" }
		else { $Action = "update" }
		
		switch ($UserId)
		{
			"S-1-5-18" # local system
				{ 
					$Password = $null
					$LogonType = 5
				}
			"S-1-5-19" # local service
				{ 
					$Password = $null
					$LogonType = 5
				}
			"S-1-5-20" # network service
				{ 
					$Password = $null
					$LogonType = 5
				}
			default
				{
					$Password = $null
					switch ($XmlObj.Task.Principals.Principal.LogonType)
					{
						"Password" { $LogonType = 1 }
						"InteractiveToken" { $LogonType = 3 }
						"S4U" { $LogonType = 2 }
					}
					if ($LogonType -eq 1)
					{
						# UserName defined, script is in automatic mode. Cannot create/update task b/c prompts are suppressed.
						if ($Script:AutomaticMode)
						{
							Write-Log -Message "Running in automatic mode, cannot $Action task '$Name' with username defined!" -EntryType "ERROR" -ResultFailure
							return
						}
			
						if (($Password = Get-BaselineCredential -UserName $UserId -ReturnPasswordOnly) -eq $null)
						{
							Write-Log -Message "No password for '$UserId' was entered, cannot $Action task '$Name'" -EntryType "WARNING" -ResultFailure
							return
						}
					}
				}
		}
		
		# http://msdn.microsoft.com/en-us/library/aa382575(v=VS.85).aspx
		# RegisterTask(Name, XmlDefinition, Flags, UserId, Password, LogonType)
		try
		{
			$Result = $RootFolder.RegisterTask($Name, $XmlDefinition, 6, $UserId, $Password, $LogonType)
		}
		catch
		{
			Write-Log -Message "-> $Action task '$Name'" -Category $Category -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
			return
		}
		
		Write-Log -Message "-> $Action task '$Name'" -Category $Category -EntryType "INFO" -ResultOK -ResultMessage "success"
	}
	
	# Reference the following article for scheduled task scripting 
	# http://msdn.microsoft.com/en-us/library/aa383607(v=VS.85).aspx

	#Create the TaskService object and connect to Vista/Win7/Win2k8 Server
	$SchedService = new-object -com("Schedule.Service")
	$SchedService.connect() 

	#Get to root folder (\) to create the task definition 
	$RootFolder = $SchedService.getfolder("\")
	$SystemTasks = $RootFolder.GetTasks(0)
	
	$SystemTask = $SystemTasks | ? { $_.Name -eq $Name }
	
	if ($SystemTask -eq $null)
	{ # task with $Name doesn't exist
		if ($Script:ValidateOnly)
		{
			Write-Log -Message $Name -Category $Category -ResultFailure -ResultMessage "not found"
		}
		else
		{
			# creating scheduled task
			Write-Log -Message $Name -Category $Category -ResultFailure -ResultMessage "not found (to be created)"
			
			Check-ScheduledTask-CreateOrUpdateTask
		}
	}
	else
	{ # task with $Name exists, comparing
		# $SystemTask.xml should be string here
		[string[]]$Obj1 = ((($SystemTask.xml -replace "`r", "") -ireplace "<\?xml.*?>", "").Trim() -split "`n" | % { $_.Trim() })
		# $XmlDefinition should be string here
		[string[]]$Obj2 = ((($XmlDefinition -replace "`r", "") -ireplace "<\?xml.*?>", "").Trim() -split "`n" | % { $_.Trim() })
		
		$Diff = Compare-Object -ReferenceObject $Obj1 -DifferenceObject $Obj2
		
		if ($Diff -eq $null)
		{ # no changes in task
			Write-Log -Message $Name -Category $Category -EntryType "INFO" -ResultOK -ResultMessage "OK"
		}
		else
		{ # task changed, printing differences
			Write-Log -Message $Name -Category $Category -EntryType "INFO" -ResultFailure -ResultMessage "need update"
			Write-Log -Message ("Differences found: "+$Diff.Length) -Category $Category -EntryType "INFO"
			$Diff | % { Write-Log -Message ($_.SideIndicator+" "+$_.InputObject) -Category $Category -EntryType "INFO" }
			if (-not $Script:ValidateOnly)
			{
				Check-ScheduledTask-CreateOrUpdateTask
			}
		}
	}
}

# Check Scheduled Task Status
#################################################
function Check-ScheduledTaskStatus([string]$Name, [switch]$Enable, [switch]$Disable)
{
	$Category = "SCHTASK"
	
	if (-not $Name)
	{
		Write-Log -Message "Task name not defined, skipping." -EntryType "WARNING" -Category $Category
		return
	}
    if ($Enable) { $Status = $true }
	elseif ($Disable) { $Status = $false }
	else
    {
        Write-Log -Message "Status name not defined, skipping." -EntryType "WARNING" -Category $Category
        return
    }
	    
	# Reference the following article for scheduled task scripting 
	# http://msdn.microsoft.com/en-us/library/aa383607(v=VS.85).aspx

	#Create the TaskService object and connect to Vista/Win7/Win2k8 Server
	$SchedService = new-object -com("Schedule.Service")
	$SchedService.connect() 

	#Get to root folder (\) to create the task definition 
	$RootFolder = $SchedService.getfolder("\")
	$SystemTasks = $RootFolder.GetTasks(0)
	
	$SystemTask = $SystemTasks | ? { $_.Name -eq $Name }
	
	if ($SystemTask -eq $null)
	{ # task with $Name doesn't exist
		if ($Script:ValidateOnly)
		{
			Write-Log -Message $Name -Category $Category -ResultFailure -ResultMessage "not found"
		}
		else
		{
			# have the user create scheduled task - either manually or RTM
			Write-Log -Message $Name -Category $Category -ResultFailure -ResultMessage "not found (please have it created)"
		}
	}
	else
	{ # task with $Name exists, enable or disable it
        $CurrentStatus = $SystemTask.Enabled
        
        if ($CurrentStatus -eq $Status)
        {
            Write-Log -Message $Name -Category $Category -EntryType "INFO" -ResultOK -ResultMessage "OK"
        }
        else
        {
            Write-Log -Message $Name -Category $Category -EntryType "INFO" -ResultFailure -ResultMessage "needs an update"
            Write-Log -Message ("    Task status is "+$SystemTask.Enabled+" and you want it "+$Status) -Category $Category -EntryType "INFO"
            if (-not $Script:ValidateOnly)
			{
				$SystemTask.Enabled = $Status
                $CurrentStatus = $SystemTask.Enabled
                if ($CurrentStatus -eq $Status)
                {
                    Write-Log -Message $Name -Category $Category -EntryType "INFO" -ResultOK -ResultMessage "OK"
                }
                else
                {
                    Write-Log -Message $Name -Category $Category -ResultFailure -ResultMessage "status not set correctly"
                }
			}
        }
	}
}

# Check Scheduled Task removal
#################################################
function Check-ScheduledTaskRemoval([string]$Name)
{
	$Category = "SCHTASK REMOVAL"
	
	if (-not $Name)
	{
		Write-Log -Message "Task name not defined, skipping." -EntryType "WARNING" -Category $Category
		return
	}
	
	# Reference the following article for scheduled task scripting 
	# http://msdn.microsoft.com/en-us/library/aa383607(v=VS.85).aspx

	#Create the TaskService object and connect to Vista/Win7/Win2k8 Server
	$SchedService = new-object -com("Schedule.Service")
	$SchedService.connect() 

	#Get to root folder (\) to create the task definition 
	$RootFolder = $SchedService.GetFolder("\")
	$SystemTasks = $RootFolder.GetTasks(0)
	
	$SystemTask = $SystemTasks | ? { $_.Name -eq $Name }
	
	if ($SystemTask -eq $null)
	{ # task with $Name doesn't exist
		Write-Log -Message $Name -Category $Category -ResultOK -ResultMessage "task not found"
	}
	else
	{ # task with $Name exists, removing
		if ($Script:ValidateOnly)
		{
			Write-Log -Message $Name -Category $Category -ResultFailure -ResultMessage "task found (should be removed)"
		}
		else
		{
			# removing scheduled task
			Write-Log -Message $Name -Category $Category -ResultFailure -ResultMessage "task found (will be removed)"
			
			try
			{
				$Result = $RootFolder.DeleteTask($Name, 0)
			}
			catch
			{
				Write-Log -Message "-> Removing task '$Name'" -Category $Category -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
				return
			}
			
			Write-Log -Message "-> Removing task '$Name'" -Category $Category -EntryType "INFO" -ResultOK -ResultMessage "success"
		}
	}
}



########################################################################################################
#
#   System functions - end
#
########################################################################################################






########################################################################################################
#
#   Filesystem functions - begin
#
########################################################################################################


# Check directory
#################################################
function Check-Directory([string]$Path)
{
	$Category = "DIR"
	
	if (Test-Path $Path)
	{
		Write-Log -Message $Path -Category $Category -ResultOK -ResultMessage "found"
	}
	else
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message $Path -Category $Category -ResultFailure -ResultMessage "not found"
		}
		else
		{
			Write-Log -Message $Path -Category $Category -ResultFailure -ResultMessage "not found (to be created)"
			
			$Result = New-Item -Path $Path -Force -ItemType directory
			
			if ($?)
			{
				Write-Log -Message "-> creating $Path" -ResultOK -ResultMessage "success"
			}
			else
			{
				Write-Log -Message "-> creating $Path" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message
			}
		}
	}
}

# Check directory delete
#################################################
function Check-DirectoryDelete([string]$Path, [switch]$Recursively)
{
	$Category = "DELETE DIR"

	if (Test-Path -Path $Path)
    {        
        # Validation test
        # if validating, don't delete it, else delete it
        if ($Script:ValidateOnly)
        {
            Write-Log -Message "$Path found" -Category $Category -ResultFailure -ResultMessage "should be deleted"
        }
        elseif (-not $Script:ValidateOnly)
        {
            Write-Log -Message "$Path found" -Category $Category -ResultFailure -ResultMessage "to be deleted"
            # delete the dir
            if($Recursively)
            {
                Remove-Item -Path $Path -Force:$true -Confirm:$false -Recurse:$true
            }
            else
            {
                Remove-Item -Path $Path -Force:$true -Confirm:$false -Recurse:$false
            }
            # if you delete it, recheck to see if it's deleted
            $Result = Test-Path -Path $Path
            # if you get true, that file exists, do this
            if ($Result)
            {
              Write-Log -Message "$Path still present" -Category $Category -ResultFailure -ResultMessage "failure"
            }
            # if it doesn't exist, good, tell user it was successful
            else
            {
                Write-Log -Message "$Path deleted" -Category $Category -ResultOK -ResultMessage "success"
            }
        }
    }
    else
    {
        Write-Log -Message "$Path not present" -Category $Category -ResultOK -ResultMessage "good"
    }
}


# Check directory move
#################################################
function Check-DirectoryMove([string]$FromPath, [string]$ToPath)
{
	$Category = "DELETE DIR"

	if (Test-Path -Path $FromPath)
    {        
        # Validation test
        # if validating, don't delete it, else delete it
        if ($Script:ValidateOnly)
        {
            Write-Log -Message "$FromPath found" -Category $Category -ResultFailure -ResultMessage "should be moved"
        }
        elseif (-not $Script:ValidateOnly)
        {
            Write-Log -Message "$FromPath found" -Category $Category -ResultFailure -ResultMessage "to be moved"
			
			if (Test-Path -Path $ToPath)
			{
				$CurrentDayTimeTmpDir = Get-Date -format "MM-dd-yyyy_hh_mm_tt"
				Move-Item -Path $ToPath -Destination "$($ToPath)_$($CurrentDayTimeTmpDir)" -Confirm:$false -Force:$true
			}
            # move dir
			Move-Item -Path $FromPath -Destination $ToPath -Confirm:$false -Force:$true

			# recheck
            $Result = Test-Path -Path $FromPath
			$ResultMoved = Test-Path -Path $ToPath
            # if you get true, that file exists, do this
            if ($Result)
            {
              Write-Log -Message "$FromPath still present" -Category $Category -ResultFailure -ResultMessage "failure"
            }
            # if it doesn't exist, good, tell user it was successful
            else
            {
				if($ResultMoved)
				{
	            	Write-Log -Message "$FromPath moved to $ToPath" -Category $Category -ResultOK -ResultMessage "success"
	            }
				else
				{
                	Write-Log -Message "$ToPath doesn't exist" -Category $Category -ResultFailure -ResultMessage "failure"
				}
            }
        }
    }
    else
    {
        Write-Log -Message "$FromPath not present" -Category $Category -ResultOK -ResultMessage "good"
    }
}
# Check file
#################################################
function Check-File([string]$TargetFile, [string]$SourceFile)
{
	$Category = "FILE"
	
	#################################################
	function Check-File-CopyFile
	{
		$Result = Copy-Item $SourceFile -Destination $TargetFile -Force
		
		if ($?)
		{
			Write-Log -Message "-> copying $SourceFile" -ResultOK -ResultMessage "success"
		}
		else
		{
			Write-Log -Message "-> copying $SourceFile" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message
		}
	}
	
	
	if ($SourceFile -eq $null -or $SourceFile -eq  "")
	{
		Write-Log -Message "$TargetFile - source file not defined! (skipping check)" -Category $Category -EntryType "WARNING"
		return
	}
	
	if (! (Test-Path $SourceFile))
	{
		Write-Log -Message "$TargetFile - source file '$SourceFile' not found! (skipping check)" -Category $Category -EntryType "WARNING"
		return
	}
		
	
	# testing if file exists
	if (Test-Path $TargetFile)
	{
		$TargetFileObj = Get-Item $TargetFile -Force
		$SourceFileObj = Get-Item $SourceFile -Force
		
		# files of same size
		if ($TargetFileObj.Length -eq $SourceFileObj.Length)
		{
			# checking content if size < 1mb (e.g. configuration files)
			if ($TargetFileObj.Length -lt 1024000)
			{
				if (-not (Compare-Object (gc $TargetFile) (gc $SourceFile)))
				{
					Write-Log -Message $TargetFile -Category $Category -ResultOK -ResultMessage "OK"
				}
				else
				{
					if ($Script:ValidateOnly)
					{
						Write-Log -Message $TargetFile -Category $Category -ResultFailure -ResultMessage "content differs"
					}
					else
					{
						Write-Log -Message $TargetFile -Category $Category -ResultFailure -ResultMessage "content differs (to be copied)"
						Check-File-CopyFile
					}
				}
			}
			else
			{
				Write-Log -Message $TargetFile -Category $Category -ResultOK -ResultMessage "OK"
			}
		}
		else
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message $TargetFile -Category $Category -ResultFailure -ResultMessage "size differs"
			}
			else
			{
				Write-Log -Message $TargetFile -Category $Category -ResultFailure -ResultMessage "size differs (to be copied)"
				Check-File-CopyFile
			}
		}
	}
	else
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message $TargetFile -Category $Category -ResultFailure -ResultMessage "not found"
		}
		else
		{
			Write-Log -Message $TargetFile -Category $Category -ResultFailure -ResultMessage "not found (to be copied)"
			Check-File-CopyFile
		}
	}
}


# Check File to be deleted
# checked
#################################################
function Check-FileDelete([string]$AbsoluteFilePath)
{
    $Category = "DELETE FILE"
	
    if (Test-Path -Path $AbsoluteFilePath)
    {        
        # Validation test
        # if validating, don't delete it, else delete it
        if ($Script:ValidateOnly)
        {
            Write-Log -Message "$AbsoluteFilePath found" -Category $Category -ResultFailure -ResultMessage "should be deleted"
        }
        elseif (-not $Script:ValidateOnly)
        {
            Write-Log -Message "$AbsoluteFilePath found" -Category $Category -ResultFailure -ResultMessage "to be deleted"
            # delete the file
            Remove-Item -Path $AbsoluteFilePath -Force:$true -Confirm:$false
            # if you delete it, recheck to see if it's deleted
            $Result = Test-Path -Path $AbsoluteFilePath
            # if you get true, that file exists, do this
            if ($Result)
            {
              Write-Log -Message "$AbsoluteFilePath still present" -Category $Category -ResultFailure -ResultMessage "failure"
            }
            # if it doesn't exist, good, tell user it was successful
            else
            {
                Write-Log -Message "$AbsoluteFilePath deleted" -Category $Category -ResultOK -ResultMessage "success"
            }
        }
    }
    else
    {
        Write-Log -Message "$AbsoluteFilePath not present" -Category $Category -ResultOK -ResultMessage "good"
    }
}

# Check directory tree
#################################################
function Check-DirectoryTree([string]$TargetPath, [string]$SourcePath, $SkipItems = @(), $SkipItemsIfExist = @())
{
	if ($SkipItems -is "String") { $SkipItems = @($SkipItems) }
	if ($SkipItemsIfExist -is "String") { $SkipItemsIfExist = @($SkipItemsIfExist) }
	
	$TargetPath = $TargetPath.TrimEnd("\")
	$SourcePath = $SourcePath.TrimEnd("\")
	
	$SkipItems = @($SkipItems | % {
		if ($_ -imatch "^\\\\" -or $_ -imatch "^\w:")
		{
			# absolute path of item to skip
			# replacing sourcepath with targetpath if given by mistake
			$_.ToLower().Replace($SourcePath.ToLower(), $TargetPath)
		}
		else
		{
			# relative path of item to skip
			# adding targetpath to item - creating absolute path
			$TargetPath + "\" + $_
		}
	})
	$SkipItemsIfExist = @($SkipItemsIfExist | % {
		if ($_ -imatch "^\\\\" -or $_ -imatch "^\w:")
		{
			# absolute path of item to skip
			# replacing sourcepath with targetpath if given by mistake
			$_.ToLower().Replace($SourcePath.ToLower(), $TargetPath)
		}
		else
		{
			# relative path of item to skip
			# adding targetpath to item - creating absolute path
			$TargetPath + "\" + $_
		}
	})
	
	
	#################################################
	function Check-DirectoryTree-Inner-CheckFolder([string]$Folder)
	{
		$Folder = $Folder.TrimEnd("\")
		$Path = $Folder.ToLower().Replace($SourcePath.ToLower(), $TargetPath)
		
		Check-Directory $Path
		
		if (Test-Path $Path)
		{
			foreach ($item in (Get-ChildItem $Folder -Force))
			{
				if ($item -is [System.IO.DirectoryInfo])
				{
					$Path = $item.Parent.FullName.TrimEnd("\")
					$Path = $Path.ToLower().Replace($SourcePath.ToLower(), $TargetPath) + "\" + $item.Name
					if (($SkipItems -icontains $Path) -or (($SkipItemsIfExist -icontains $Path) -and (Test-Path $Path)))
					{
						Write-Log -Message $Path -Category "DIR" -ResultMessage "skipped"
					}
					else
					{
						Check-DirectoryTree-Inner-CheckFolder -Folder $item.FullName
					}
				}
				else
				{
					$Path = $item.Directory.FullName.TrimEnd("\")
					$Path = $Path.ToLower().Replace($SourcePath.ToLower(), $TargetPath) + "\" + $item.Name
					if (($SkipItems -icontains $Path) -or (($SkipItemsIfExist -icontains $Path) -and (Test-Path $Path)))
					{
						Write-Log -Message $Path -Category "FILE" -ResultMessage "skipped"
					}
					else
					{
						Check-File -TargetFile $Path -SourceFile $item.FullName
					}
				}
			}
		}
	}
	
	Check-DirectoryTree-Inner-CheckFolder -Folder $SourcePath
}


# Check Permissions
#################################################
function Check-Permissions([string]$Path, $Permissions = @(), [switch]$ExactMatch)
{
	$Category = "ACL"
	$CategoryRULE = "ACL RULE"
	
	# access rights:
	#     F ... FullControl
	#     M ... Modify
	#     R ... Read
	#     W ... Write
	#     RX .. ReadAndExecute
	#     ( for more see Check-Permissions-Get-FileSystemRightName([string]$Perm) )
	# use -ExactMatch for setting explicit permissions (removes all other unnecessary permissions)
	
	if ($Permissions -is "String")
	{
		$Permissions = @($Permissions)
	}
	
	$Path = $Path.Trim()
	
	if (-not (Test-Path $Path))
	{
		Write-Log -Message "$Path - path not found (skipping check)" -Category $Category -EntryType "WARNING"
		return
	}
	
	
	# Check-Permissions-Get-FileSystemRightName
	#################################################
	function Check-Permissions-Get-FileSystemRightName([string]$Perm, [switch]$Reverse)
	{
		$Permissions = @{
			"A"  = "AppendData";
			"CP" = "ChangePermissions";
			"CD" = "CreateDirectories";
			"CF" = "CreateFiles";
			"D"  = "Delete";
			"DF" = "DeleteSubdirectoriesAndFiles";
			"EF" = "ExecuteFiles";
			"F"  = "FullControl";
			"LD" = "ListDirectory";
			"M"  = "Modify";
			"R"  = "Read";
			"RX" = "ReadAndExecute";
			"RA" = "ReadAttributes";
			"RD" = "ReadData";
			"RE" = "ReadExtendedAttributes";
			"RP" = "ReadPermissions";
			"SY" = "Synchronize";
			"TO" = "TakeOwnership";
			"TR" = "Traverse";
			"W"  = "Write";
			"WA" = "WriteAttributes";
			"WD" = "WriteData";
			"WE" = "WriteExtendedAttributes"
		}
		
		if ($Reverse)
		{
			$Keys = $Permissions.Keys | ? { $_ -ne "SY" }
			foreach ($Key in $Keys)
			{
				if ($Perm -imatch ("\b"+$Permissions.Item($Key)+"\b"))
				{
					return $Key
				}
			}
			return $Perm
		}
		else
		{
			if ($Permissions.ContainsKey($Perm))
				{ return $Permissions.Item($Perm) }
			else
				{ return $Perm }
		}
	}
	
	
	# Check-Permissions-Generate-ShortPerm
	#################################################
	function Check-Permissions-Generate-ShortPerm($Access)
	{
		$Perm = ""
		if ($Access.IsInherited) { $Perm += "(I)" }
		if ($Access.InheritanceFlags.ToString() -imatch "ObjectInherit") { $Perm += "(OI)" }
		if ($Access.InheritanceFlags.ToString() -imatch "ContainerInherit") { $Perm += "(CI)" }
		if ($Access.PropagationFlags.ToString() -imatch "InheritOnly") { $Perm += "(IO)" }
		$Perm += "("+(Check-Permissions-Get-FileSystemRightName -Perm $Access.FileSystemRights.ToString() -Reverse)+")"
		
		return $Perm
	}
	
	
	# Check-Permissions-Remove-Inheritance
	#################################################
	function Check-Permissions-Remove-Inheritance()
	{
		# removing inheritance, keeping current rights
		$acl.SetAccessRuleProtection( $true, $true )
		
		Set-Acl -AclObject $acl -Path $Path
		
		if ($?)
		{
			Write-Log -Message "-> removing folder inheritance" -ResultOK -ResultMessage "success"
			return $true
		}
		else
		{
			Write-Log -Message "-> removing folder inheritance" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message
			return $false
		}
	}
	
	
	# Check-Permissions-Search-RuleInAcl
	# returns:
	#      0 .. not found
	#      1 .. found and same
	#      2 .. found, same, but inherited!
	#################################################
	function Check-Permissions-Search-RuleInAcl($AccessRule, $Acl)
	{
		$Result = 0
		
		for ($a = 0; $a -lt $Acl.Count; $a++)
		{
			$Access = $Acl[$a]
			
			if ($Access.IdentityReference.Equals($AccessRule.IdentityReference))
			# we found principal in access rules
			# we can compare first found rule, as we need explicit (not inherited) permissions!
			{
				if (
					$Access.FileSystemRights.Equals($AccessRule.FileSystemRights) -and
					$Access.AccessControlType.Equals($AccessRule.AccessControlType) -and
					$Access.InheritanceFlags.Equals($AccessRule.InheritanceFlags) -and
					$Access.PropagationFlags.Equals($AccessRule.PropagationFlags)
					)
				{
					if ($Access.IsInherited -eq $false)
					{
						# found and same
						return 1
					}
					else
					{
						# found, same, but inherited!
						return 2
					}
				}
			}
		}
		
		# not found
		return $Result
	}
	

	$Msg = $Path
	if ($ExactMatch) { $Msg += " (exact)" }
	Write-Log -Message $Msg -Category $Category

	$PermissionsToProcess = New-Object System.Collections.ArrayList
	
	# cleaning and validating input
	foreach ($tmp in $Permissions)
	{
		# required properties
		[System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = "None"
		[System.Security.AccessControl.PropagationFlags]$PropagationFlags = "None"
		[System.Security.AccessControl.AccessControlType]$AccessControlType = "Allow"
		
		$split = $tmp.Split(':')
		
		if ($split.Length -gt 1)
		{
			$IdentityReference = $split[0].Trim()
			$Rights = $split[1].Trim()
			
			# InheritOnly
			if ($Rights -imatch "\(IO\)")
			{
				$Rights = $Rights -ireplace "\(IO\)", ""
				$PropagationFlags = "InheritOnly"
			}
			
			# ContainerInherit
			if ($Rights -imatch "\(CI\)")
			{
				$Rights = $Rights -ireplace "\(CI\)", ""
				$InheritanceFlags = "ContainerInherit"
			}
			
			# ObjectInherit
			if ($Rights -imatch "\(OI\)")
			{
				$Rights = $Rights -ireplace "\(OI\)", ""
				if ($InheritanceFlags.ToString() -eq "ContainerInherit")
					{ $InheritanceFlags = "ContainerInherit, ObjectInherit" }
				else
					{ $InheritanceFlags = "ObjectInherit" }
			}
			
			if ([System.Text.RegularExpressions.Regex]::Matches($Rights, "\(").Count -gt 1)
			{
				Write-Log -Message "$Path - $tmp - incorrect input permissions (skipping this rule)" -Category $CategoryRULE -EntryType "WARNING"
				continue
			}
			
			$FileSystemRights = Check-Permissions-Get-FileSystemRightName $Rights.Replace("(","").Replace(")","")
			
			$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
			$Index = $PermissionsToProcess.Add($AccessRule)
		}
		else
		{
			Write-Log -Message "$Path - $tmp - incorrect input (skipping this rule)" -Category $CategoryRULE -EntryType "WARNING"
		}
	}
	
	#gets the acl which is currently on the folder
	$acl = Get-Acl $Path
	
	$DirNeedUpdate = $false
	foreach ($AccessRule in $PermissionsToProcess)
	{
		$tmp = $AccessRule.IdentityReference.ToString()+":"+(Check-Permissions-Generate-ShortPerm -Access $AccessRule)
		$Result = Check-Permissions-Search-RuleInAcl -AccessRule $AccessRule -Acl $acl.Access
		
		switch ($Result)
		{
			0	{
					if ($Script:ValidateOnly)
					{
						Write-Log -Message "$Path - $tmp" -Category $CategoryRULE -ResultFailure -ResultMessage "not present"
					}
					else
					{
						Write-Log -Message "$Path - $tmp" -Category $CategoryRULE -ResultFailure -ResultMessage "not present (to be added)"
						$DirNeedUpdate = $true
					}
				}
			1	{ 
					Write-Log -Message "$Path - $tmp" -Category $CategoryRULE -ResultOK -ResultMessage "OK"
				}
			2	{
					Write-Log -Message "$Path - $tmp" -Category $CategoryRULE -ResultOK -ResultMessage "OK, but inherited"
				}
		}
	}
	
	if ($ExactMatch)
	{
		Write-Log -Message "$Path - checking for unneeded permissions" -Category $Category
		
		foreach ($AccessRule in $acl.Access)
		{
			$tmp = $AccessRule.IdentityReference.ToString()+":"+(Check-Permissions-Generate-ShortPerm -Access $AccessRule)
			$Result = Check-Permissions-Search-RuleInAcl -AccessRule $AccessRule -Acl $PermissionsToProcess
			
			if ($Result -eq 0)
			{
				if ($Script:ValidateOnly)
				{
					Write-Log -Message "$Path - $tmp" -Category $CategoryRULE -ResultFailure -ResultMessage "unneeded"
				}
				else
				{
					Write-Log -Message "$Path - $tmp" -Category $CategoryRULE -ResultFailure -ResultMessage "unneeded (to be removed)"
					$DirNeedUpdate = $true
				}
			}
		}
	}
	
	
	if (-not $Script:ValidateOnly -and $DirNeedUpdate)
	{
		# taking ownership
		$OriginalOwner = $acl.Owner
		if ($OriginalOwner -ne "BUILTIN\Administrators")
		{
			try 
			{ 
				$acl.SetOwner([System.Security.Principal.NTAccount]"BUILTIN\Administrators")
			}
			catch 
			{
				Write-Log -Message "-> taking ownership" -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
				return
			}

			Set-Acl -AclObject $acl -Path $Path
			
			if (-not $?)
			{
				Write-Log -Message "-> taking ownership" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message
				return
			}
			
			$acl = Get-Acl $Path
		}
		
		if ($ExactMatch)
		{
			if (-not (Check-Permissions-Remove-Inheritance)) { return }
			
			$acl = Get-Acl $Path
			
			foreach ($AccessRule in $acl.Access)
			{
				$tmp = $AccessRule.IdentityReference.ToString()+":"+(Check-Permissions-Generate-ShortPerm -Access $AccessRule)
				$Result = Check-Permissions-Search-RuleInAcl -AccessRule $AccessRule -Acl $PermissionsToProcess
			
				if ($Result -eq 0)
				{
					try 
					{ 
						$res = $acl.RemoveAccessRule($AccessRule)
					}
					catch
					{
						Write-Log -Message "-> removing $Path - $tmp" -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
						continue
					}
					
					Set-Acl -AclObject $acl $Path
					
					if ($?)
					{
						Write-Log -Message "-> removing $Path - $tmp" -ResultOK -ResultMessage "success"
					}
					else
					{
						Write-Log -Message "-> removing $Path - $tmp" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message
					}
				}
			}
		}
		
		foreach ($AccessRule in $PermissionsToProcess)
		{
			$tmp = $AccessRule.IdentityReference.ToString()+":"+(Check-Permissions-Generate-ShortPerm -Access $AccessRule)
			$Result = Check-Permissions-Search-RuleInAcl -AccessRule $AccessRule -Acl $acl.Access
			
			if ($Result -eq 0)
			{
				try 
				{ 
					$acl.AddAccessRule($AccessRule)
				}
				catch
				{
					Write-Log -Message "-> adding $Path - $tmp" -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message
					continue
				}
			}
			elseif ($Result -gt 1)
			{
				$accessModification = New-Object System.Security.AccessControl.AccessControlModification
				$accessModification.value__ = 2
				$modification = $false
				$res = $acl.ModifyAccessRule($accessModification, $AccessRule, [ref]$modification)
			}
			else
			{
				continue
			}
			
			Set-Acl -AclObject $acl $Path
			
			if ($?)
			{
				if ($Result -eq 0)
					{ Write-Log -Message "-> adding $Path - $tmp" -ResultOK -ResultMessage "success" }
				else
					{ Write-Log -Message "-> updating $Path - $tmp" -ResultOK -ResultMessage "success" }
			}
			else
			{
				if ($Result -eq 0)
					{ Write-Log -Message "-> adding $Path - $tmp" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
				else
					{ Write-Log -Message "-> updating $Path - $tmp" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message }
			}
		}
		
		
		# setting ownership back
		# have to use icacls because powershell security prevents changing the owner to someone else
		if ($OriginalOwner -ne "BUILTIN\Administrators")
		{
			Invoke-Expression "Start-Process icacls '`"$Path`" /setowner `"$OriginalOwner`"' -Wait"
		}
	}
}


# Check network share
#################################################
function Check-NetworkShare([string]$Share, [string]$Path, $Permissions = @('Everyone,READ'), $Limit = $null)
{
	$Category = "SHARE"
	$CategoryLIMIT = "SHARE LIMIT"
	$CategoryRULE = "SHARE RULE"
	
	if ($Limit) { $Limit = [int]$Limit }
	
	if ($Permissions -is "String")
	{
		$Permissions = @($Permissions)
	}
	
	if (-not (Test-Path $Path)) 
	{
		Write-Log -Message "$Share=$Path - path not found (skipping check)" -Category $Category -EntryType "WARNING"
		return
	}
	
	$FileSystemRights = @{ "READ" = "ReadAndExecute"; "CHANGE" = "Modify"; "FULL" = "FullControl" }
	
	#################################################
	function Check-NetworkShare-Get-SharePermissionName($FileSystemRight)
	{
		switch -wildcard ($FileSystemRight)
		{
			"ReadAndExecute*"   { return "READ" }
			"Modify*"           { return "CHANGE" }
			"FullControl"       { return "FULL" }
		}
		
		return "" # this shouldn't be returned
	}
	
	#################################################
	function Check-NetworkShare-Create-NetworkShare
	{
		$Grant = ""
		$Permissions | % { $Grant += " `"/GRANT:"+$_+"`"" }
		
		if ($Limit)
		{
			$Msg = "-> creating share $Share=$Path "+($Permissions -join " ")+" Users=$Limit"
			$Res = Invoke-Expression ("net share `"$Share=$Path`""+$Grant+" /USERS:$Limit 2>&1")
		}
		else
		{
			$Msg = "-> creating share $Share=$Path "+($Permissions -join " ")
			$Res = Invoke-Expression ("net share `"$Share=$Path`""+$Grant+" 2>&1")
		}
		
		if ($LastExitCode -gt 0)
		{
			Write-Log -Message $Msg -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
		}
		else
		{
			Write-Log -Message $Msg -ResultOK -ResultMessage "success"
		}
	}
	
	#################################################
	function Check-NetworkShare-Remove-NetworkShare
	{
		$Res = net share "$Share" /delete
		if ($LastExitCode -gt 0)
		{
			Write-Log -Message "-> deleting share $Share" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
			return $false 
		}
		
		Write-Log -Message "-> deleting share $Share" -ResultOK -ResultMessage "success"
		return $true
	}
	
	
	#################################################
	function Check-NetworkShare-Get-Share([String]$Name = "%", [String]$Computer = '.')
	{
	  $Shares = @() 
	  Get-WMIObject Win32_Share `
	    -Computer $Computer -Filter "Name LIKE '$Name'" | `
	    %{
	      $Access = @();
	      If ($_.Type -eq 0) {
	        $SD = (Get-WMIObject -Class Win32_LogicalShareSecuritySetting `
	          -Computer $Computer `
	          -Filter "Name='$($_.Name)'").GetSecurityDescriptor().Descriptor
	        $SD.DACL | %{
	          $Trustee = $_.Trustee.Name
	          If ($_.Trustee.Domain -ne $Null) { $Trustee = "$($_.Trustee.Domain)\$Trustee" }
	          $Access += New-Object System.Security.AccessControl.FileSystemAccessRule( `
	            $Trustee, $_.AccessMask, $_.AceType)
	        }
	      }
	      $Shares += $_ | Select-Object Name, Path, Description, Caption, `
	        @{n='Type';e={ Switch ($_.Type) {
	          0 { "Disk Drive" }
	          1 { "Print Queue" }
	          2 { "Device" }
	          2147483648 { "Disk Drive Admin" }
	          2147483649 { "Print Queue Admin" }
	          2147483650 { "Device Admin" }
	          2147483651 { "IPC Admin" } }} }, `
	        MaximumAllowed, AllowMaximum, Status, InstallDate, `
	        @{n='Access';e={ $Access }}
	  }
	  Return $Shares
	}
	
	
	# Check-NetworkShare-Search-RuleInAcl
	# returns bool ($true .. found, $false .. not found)
	#################################################
	function Check-NetworkShare-Search-RuleInAcl($AccessRule, $Acl)
	{
		for ($a = 0; $a -lt $Acl.Count; $a++)
		{
			$Access = $Acl[$a]
			
			if ($Access.IdentityReference.Equals($AccessRule.IdentityReference) -and
				$Access.FileSystemRights.Equals($AccessRule.FileSystemRights))
			{
				return $true
			}
		}
		
		# not found
		return $false
	}
	
	
	if ($ShareObj = Check-NetworkShare-Get-Share $Share)
	{
		$ShareNeedUpdate = $false
		
		# checking path
		if ($ShareObj.Path -eq $Path)
		{
			Write-Log -Message "$Share=$Path" -Category $Category -ResultOK -ResultMessage "exists"
			
			# checking share limit
			if ($Limit)
			{
				if ($ShareObj.MaximumAllowed -ne $Limit)
				{
					if ($Script:ValidateOnly)
					{
						Write-Log -Message "$Share - $Limit" -Category $CategoryLIMIT -ResultFailure -ResultMessage "differs"
					}
					else
					{
						Write-Log -Message "$Share - $Limit" -Category $CategoryLIMIT -ResultFailure -ResultMessage "differs (share will be updated)"
						$ShareNeedUpdate = $true
					}
				}
				else
				{
					Write-Log -Message "$Share - $Limit" -Category $CategoryLIMIT -ResultOK -ResultMessage "OK"
				}
			}
			else
			{
				if ($ShareObj.AllowMaximum -ne $true)
				{
					if ($Script:ValidateOnly)
					{
						Write-Log -Message "$Share - Unlimited" -Category $CategoryLIMIT -ResultFailure -ResultMessage "differs"
					}
					else
					{
						Write-Log -Message "$Share - Unlimited" -Category $CategoryLIMIT -ResultFailure -ResultMessage "differs (share will be updated)"
						$ShareNeedUpdate = $true
					}
				}
				else
				{
					Write-Log -Message "$Share - Unlimited" -Category $CategoryLIMIT -ResultOK -ResultMessage "OK"
				}
			}
			
			
			$PermissionsToProcess = New-Object System.Collections.ArrayList
	
			# cleaning and validating input permissions
			foreach ($tmp in $Permissions)
			{
				# required properties
				[System.Security.AccessControl.InheritanceFlags]$InheritanceFlags = "None"
				[System.Security.AccessControl.PropagationFlags]$PropagationFlags = "None"
				[System.Security.AccessControl.AccessControlType]$AccessControlType = "Allow"
				
				$split = $tmp.Split(',')
		
				if ($split.Length -gt 1)
				{
					$IdentityReference = $split[0].Trim()
					if (-not ($FSR = $FileSystemRights[$split[1].Trim()]))
					{
						Write-Log -Message "$Share - $tmp - incorrect input permissions (skipping this rule)" -Category $CategoryRULE -EntryType "WARNING"
						continue
					}
					
					$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference, $FSR, $InheritanceFlags, $PropagationFlags, $AccessControlType)
					$Index = $PermissionsToProcess.Add($AccessRule)
				}
				else
				{
					Write-Log -Message "$Share - $tmp - incorrect input (skipping this rule)" -Category $CategoryRULE -EntryType "WARNING"
				}
			}
			
			# checking permissions on share
			foreach ($AccessRule in $PermissionsToProcess)
			{
				$tmp = $AccessRule.IdentityReference.ToString()+","+(Check-NetworkShare-Get-SharePermissionName($AccessRule.FileSystemRights.ToString()))

				if (Check-NetworkShare-Search-RuleInAcl -AccessRule $AccessRule -Acl @($ShareObj.Access))
				{
					Write-Log -Message "$Share - $tmp" -Category $CategoryRULE -ResultOK -ResultMessage "OK"
				}
				else
				{
					if ($Script:ValidateOnly)
					{
						Write-Log -Message "$Share - $tmp" -Category $CategoryRULE -ResultFailure -ResultMessage "not present"
					}
					else
					{
						Write-Log -Message "$Share - $tmp" -Category $CategoryRULE -ResultFailure -ResultMessage "not present (to be added)"
						$ShareNeedUpdate = $true
					}
				}
			}
			
			# checking for unneeded permissions
			foreach ($AccessRule in @($ShareObj.Access))
			{
				if (-not (Check-NetworkShare-Search-RuleInAcl -AccessRule $AccessRule -Acl $PermissionsToProcess))
				{
					$tmp = $AccessRule.IdentityReference.ToString()+","+(Check-NetworkShare-Get-SharePermissionName($AccessRule.FileSystemRights.ToString()))
					
					if ($Script:ValidateOnly)
					{
						Write-Log -Message "$Share - $tmp" -Category $CategoryRULE -ResultFailure -ResultMessage "unneeded"
					}
					else
					{
						Write-Log -Message "$Share - $tmp" -Category $CategoryRULE -ResultFailure -ResultMessage "unneeded (to be removed)"
						$ShareNeedUpdate = $true
					}
				}
			}
		}
		# path not same, need update
		else
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message "$Share=$Path" -Category $Category -ResultFailure -ResultMessage "path incorrect"
			}
			else
			{
				Write-Log -Message "$Share=$Path" -Category $Category -ResultFailure -ResultMessage "path incorrect (share will be upadted)"
				$ShareNeedUpdate = $true
			}
		}

		if (-not $Script:ValidateOnly -and $ShareNeedUpdate)
		{
			if (Check-NetworkShare-Remove-NetworkShare) { Check-NetworkShare-Create-NetworkShare }
		}
	}
	else
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message "$Share=$Path" -Category $Category -ResultFailure -ResultMessage "missing"
		}
		else
		{
			Write-Log -Message "$Share=$Path" -Category $Category -ResultFailure -ResultMessage "missing (to be created)"
			Check-NetworkShare-Create-NetworkShare
		}
	}
}

########################################################################################################
#
#   Filesystem functions - end
#
########################################################################################################


########################################################################################################
#
#   XML functions - begin
#
########################################################################################################



# Check XmlProperty
#################################################
function Check-XmlProperty([string]$XmlPath, [string]$ElementXpath, [string]$Attribute, [string]$Value, $NameSpaces = @{})
{
	# $ElementXpath and $Attribute are case sensitive!
	
	$Category = "XML"
	
	if ($Attribute)
		{ $Msg = "$ElementXpath.$Attribute" }
	else
		{ $Msg = "$ElementXpath" }
	
	if (-not $XmlPath)
	{
		Write-Log -Message "$Msg - file not specified (skipping check)" -EntryType "WARNING" -Category $Category
		return
	}
	
	if (-not (Test-Path -Path $XmlPath))
	{
		Write-Log -Message "$Msg - '$XmlPath' not found (skipping check)" -EntryType "WARNING" -Category $Category
		return
	}
	
	$xml = [xml](get-content $XmlPath)
	$nsman = [System.Xml.XmlNamespaceManager]($xml.NameTable)
	
	foreach ($key in $NameSpaces.Keys)
	{
		$nsman.AddNamespace($key, $NameSpaces[$key])
	}
	
	$elem = $xml.SelectSingleNode($ElementXpath, $nsman)
	
	$Updated = $false
	
	# element not found
	if (-not $elem)
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message $Msg -Category $Category -ResultFailure -ResultMessage "missing"
		}
		else
		{
			# addding element
			Write-Log -Message $Msg -Category $Category -ResultFailure -ResultMessage "missing (to be added)"
			
			#$CleanElement = $ElementXpath -replace "/[^:/]+:", "/"
			$TargetElementName = $ElementXpath.Substring($ElementXpath.LastIndexOf('/')+1)
			$TargetElementPrefix = ""
			if ($TargetElementName.IndexOf(':') -gt 0)
			{
				$TargetElementPrefix = $TargetElementName.Substring(0, $TargetElementName.IndexOf(':'))
				$TargetElementName = $TargetElementName.Substring($TargetElementName.IndexOf(':')+1)
			}
			
			if ($TargetElementPrefix -ne "")
				{ $elem = $xml.CreateElement($TargetElementName, $NameSpaces[$TargetElementPrefix]) }
			else
				{ $elem = $xml.CreateElement($TargetElementName) }
			
			# setting attribute if needed
			if ($Attribute -and $Value) { $result = $elem.SetAttribute($Attribute, $Value) }
			
			$ParentNodeXPATH = $ElementXpath.Substring(0, $ElementXpath.LastIndexOf('/'))
			$node = $xml.SelectSingleNode($ParentNodeXPATH, $nsman)
			
			if ($node)
			{
				$result = $node.AppendChild($elem)
				$Updated = $true
				
				Write-Log -Message "-> adding $Msg" -ResultOK -ResultMessage "OK"
			}
			else
			{
				Write-Log -Message "-> adding $Msg" -EntryType "ERROR" -ResultFailure -ResultMessage "failure, parent node doesn't exist"
			}
		}
	}
	elseif ($Attribute -and $Value -ne $elem.GetAttribute($Attribute))
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message $Msg -Category $Category -ResultFailure -ResultMessage "incorrect"
		}
		else
		{
			# updating atribute
			Write-Log -Message $Msg -Category $Category -ResultFailure -ResultMessage "incorrect (to be updated)"
			
			$result = $elem.SetAttribute($Attribute, $Value)
			$Updated = $true
			
			Write-Log -Message "-> updating $Msg" -ResultOK -ResultMessage "OK"
		}
	}
	else
	{
		Write-Log -Message $Msg -Category $Category -ResultOK -ResultMessage "correct"
	}
	
	# saving configuration if updated
	if (-not $Script:ValidateOnly -and $Updated)
	{
		try
		{ 
			$xml.Save($XmlPath)
		}
		catch
		{ 
			Write-Log -Message "-> saving $XmlPath" -EntryType "ERROR" -ResultFailure -ResultMessage $_.Exception.Message.Trim()
			return
		}
		
		Write-Log -Message "-> saving $XmlPath" -ResultOK -ResultMessage "success"
	}
}



########################################################################################################
#
#   XML functions - end
#
########################################################################################################





########################################################################################################
#
#   Log functions - begin
#
########################################################################################################

function Write-Log([string]$Message = "", [string]$EntryType = "INFO", [string]$Category = "", [switch]$ResultOK, [switch]$ResultFailure, [string]$ResultMessage = "")
{
	<#
	.SYNOPSIS 
	Prints the message to Host and writes to log file if required.

	.DESCRIPTION
	Prints the message to Host and writes to log file if required.
	Write-Log prints entry using Write-Host.
	If not suppressed, entry is written to log file "Baseline_<COMPUTERNAME>_YYYY-MM-DD-HH-MM-SS.log"
	using Out-File. You can suppress output to log file by using "-nolog" command line parameter.
	If the script is in install mode ("-install" command line parameter), entry is written
	also into log file in central location.

	.PARAMETER Message
	Optional. Default is empty string.
	Specifies the message to be printed. Can be any text.

	.PARAMETER EntryType
	Optional.
	Specifies the entry type.
	Default is INFO. Can be one of INFO | WARNING | ERROR | FATAL.
	INFO is used in most of cases.
	WARNING - check/set/update operation cannot be executed because of some reason.
	ERROR - set/update operation failed.
	FATAL - script cannot continue due to fatal error.
	
	.PARAMETER Category
	Optional.
	Specifies the entry category.
	Default is none. Can be any text.
	Example: "XML", "ASP.NET", "IIS", "DIR", "FILE", ...
	
	.PARAMETER ResultOK
	Optional.
	Switch parameter to be used, when set/update operation succeeded.
	
	.PARAMETER ResultFailure
	Optional.
	Switch parameter to be used, when set/update operation failed.
	
	.PARAMETER ResultMessage
	Optional.
	Specifies the additional message when ResultOK or ResultFailure is used. Can be any text.

	.INPUTS
	None. You cannot pipe objects to Write-Log.

	.OUTPUTS
	Write-Log doesn't return any value. However, it prints the message to Host and into log file if required.
	
	.EXAMPLE
	Write-Log -Message "This is just some info message"
	Output:
	03:12:54 INFO   ------- : This is just some info message

	.EXAMPLE
	Write-Log
	Output:
	03:12:54 INFO   ------- :

	.EXAMPLE
	Write-Log -Message "SMTP-Server" -Category "FEATURE" -ResultOK -ResultMessage "installed"
	Output:
	05:24:06 INFO   Correct : FEATURE> SMTP-Server                             installed

	.EXAMPLE
	Write-Log -Message ($Group+": "+$IdentityReference) -Category "GROUP" -ResultFailure -ResultMessage "missing"
	Output:
	17:33:27 INFO   Failure : GROUP> Administrators: OPS\batchjob              missing
	
	.EXAMPLE
	Write-Log -Message "-> setting $Log log size to ${Size}kB" -ResultOK -ResultMessage "success"
	Output:
	10:28:15 INFO   Correct : -> setting Application log size to 131072kB      success
	
	.EXAMPLE
	Write-Log -Message "-> creating $Path" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message
	Output:
	20:54:08 ERROR  Failure : -> creating d:\test\aaa                          Access to the path 'aaa' is denied.
	
	.EXAMPLE
	Write-Log -Message "$TargetFile not found (skipping)" -EntryType "WARNING" -Category "COM"
	Output:
	20:54:08 WARN   ------- : COM> D:\services\MNSAVLuceneBridge\bin\AltaVistaInterface.dll not found (skipping)
	
	#>
	
	if ($EntryType -inotmatch "^(info|warning|error|fatal)$") { $EntryType = "INFO" }
	if ($EntryType -eq "warning") { $EntryType = "WARN" }	
	$EntryType = $EntryType.ToUpper()
	$Script:Summary[$EntryType]++ # increasing counter
	
	# cleaning $Category
	if ($Category -ne "") { $Message = $Category.ToUpper()+"> "+$Message }
	
	# setting $Result
	if ($ResultOK)
	{ 
		$Result = "Correct"
		$Script:Summary["OK"]++ # increasing counter
	}
	elseif ($ResultFailure)
	{
		$Result = "Failure"
		$Script:Summary["KO"]++ # increasing counter
	}
	else
	{
		$Result = "-------"
	}
	
	# formatting output line
	$Time = Get-Date -Format "HH:mm:ss"

	# formatting line and writing output
	$Line = ""
	$Line += $Msg = ("{0,-8} {1,-6} " -f $Time, $EntryType)
	Write-Host $Msg -NoNewline
	$Line += $Msg = ("{0,-7}" -f $Result)
	if ($ResultOK)
		{ Write-Host $Msg -ForegroundColor Green -NoNewline }
	elseif ($ResultFailure)
		{ Write-Host $Msg -ForegroundColor Red -NoNewline }
	else
		{ Write-Host $Msg -NoNewline }
	$Line += $Msg = (" : {0,-70}  {1}" -f $Message, $ResultMessage)
	Write-Host $Msg
	
	# logging into file
	if ($Script:DoLog) { $Line | Out-File -FilePath $Script:LogFile -Append }
	if (-not $Script:ValidateOnly -and $Script:CentralLogDir -ne "") { $Line | Out-File -FilePath $Script:CentralLogFile -Append }
}

########################################################################################################
#
#   Log functions - end
#
########################################################################################################







########################################################################################################
#
#   Misc functions - begin
#
########################################################################################################


# Get user input
#################################################
function Get-UserInput([string]$Msg, [string]$Format, $DefaultValue)
{
	if (-not $DefaultValue)
	{
		do { $Value = Read-Host "$Msg" }
			while ($Value -inotmatch $Format)
	}
	else
	{
		do { $Value = Read-Host "$Msg [$DefaultValue]" }
			while ($Value -ne "" -and $Value -inotmatch $Format)
		
		if ($Value -eq "") { $Value = $DefaultValue }
	}
	
	return $Value
}



# Get Baseline Credential
#################################################
function Get-BaselineCredential([string]$UserName, [switch]$ReturnPasswordOnly)
{
	# array of credentials already exist, looking for $UserName
	if ($Script:Credentials -ne $null)
	{
		if ($Script:Credentials.ContainsKey($UserName))
		{
			if ($ReturnPasswordOnly)
			{
				return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:Credentials.Item($UserName).Password))
			}
			else
			{
				return $Script:Credentials.Item($UserName)
			}
		}
	}
	# array of credentails doesn't exitst, creating
	else
	{
		$Script:Credentials = @{}
	}
	
	# asking for credential
	if (-not ($Cred = $host.ui.PromptForCredential("Need credential", "Please enter credential.", $UserName, $null)))
	{
		return $null
	}
	
	# adding to array
	$Script:Credentials.Add($Cred.UserName, $Cred)
	
	if ($ReturnPasswordOnly)
	{
		return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:Credentials.Item($Cred.UserName).Password))
	}
	else
	{
		return $Script:Credentials.Item($Cred.UserName)
	}
}


# Get-HttpRequest
#################################################
function Get-HttpRequest([string]$URL)
{
    $request = [System.Net.WebRequest]::Create($URL)
	$request.Proxy = $null
    $request.Method = "GET"
    $request.Accept = "application/xml"  # Might make an input for other forms of returns like JSON, you can always copy pasta this function 
	                                     # and modify it for your needs in the role specific shared script
	$response = $request.GetResponse()
		
    try
	{
        $requestStream = $response.GetResponseStream()
    }
	catch
	{
		Write-Log -EntryType "WARN" -Message "Get-HttpRequest exception thrown: $_"
		Write-Log -Message "Get-HttpRequest URL: $URL"
		return
    }
	
    $readStream = new-object System.IO.StreamReader $requestStream
    new-variable db
    $db = $readStream.ReadToEnd()
    $readStream.Close()
    $response.Close()
    return ,[xml]$db
}


########################################################################################################
#
#   Misc functions - end
#
########################################################################################################





########################################################################################################
#
#   Private functions - begin
#
########################################################################################################


# Make sure the server is W2K8 R2 or greater
#################################################
function Private-CheckSystemRequirements()
{
	# checking for admin rights
	if (-not $Script:ValidateOnly) # allowing running validation under any account
	{
		$user = [Security.Principal.WindowsIdentity]::GetCurrent()
		if (-not (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
		{
			Write-Log -EntryType Fatal -Message "This script must be run with administrators privileges"
			Do-FinalSteps
			Exit
		}
	}
}


# Reads command line arguments
#################################################
function Private-ParseCommandLineArguments() 
{
	$Values = $Script:args
	
	#################################################
	function Private-ParseCommandLineArguments-Get-ParameterValue($Index)
	{
		# value is missing
		if ($Index+1 -ge $Values.Count -OR $Values[$Index+1].Substring(0,1) -eq "-")
		{
			Write-Host "Error: Missing value for parameter:" $Values[$Index] -ForeGroundColor Red
			Private-PrintHelp
			Exit
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
				{ Private-PrintHelp; Exit }
			-h
				{ Private-PrintHelp; Exit }
			-install
				{ $Script:ValidateOnly = $false }
			-i
				{ $Script:ValidateOnly = $false }
			-environment
				{ $Script:Environment = (Private-ParseCommandLineArguments-Get-ParameterValue($a)).ToUpper(); $a++ }
			-env
				{ $Script:Environment = (Private-ParseCommandLineArguments-Get-ParameterValue($a)).ToUpper(); $a++ }
			-automatic
				{ $Script:AutomaticMode = $true }
			-a
				{ $Script:AutomaticMode = $true }
			-atd
				{ $Script:AutomaticModeTemporaryDirectory = Private-ParseCommandLineArguments-Get-ParameterValue($a); $a++ }
			-logdir
				{ $Script:LogDir = Private-ParseCommandLineArguments-Get-ParameterValue($a); $a++ }
			-ld
				{ $Script:LogDir = Private-ParseCommandLineArguments-Get-ParameterValue($a); $a++ }
			-nolog
				{ $Script:DoLog = $false }
			-nl
				{ $Script:DoLog = $false }
			-errors
				{ $Script:ErrorActionPreference = "Continue" }
			-e
				{ $Script:ErrorActionPreference = "Continue" }
			-dopwdcheck
				{ $Script:DoPasswordsCheck = $true; }
			-dpc
				{ $Script:DoPasswordsCheck = $true; }
			-illurl
				{ $Script:OpsDeployApiURL = (Private-ParseCommandLineArguments-Get-ParameterValue($a)).TrimEnd('/'); $a++ }
			-xmldb
				{ $Script:AltXmlDBFolder = (Private-ParseCommandLineArguments-Get-ParameterValue($a)).TrimEnd('/') + "/"; $a++ }
			default
			{
				Write-Host "Error: Unknown parameter:" $Values[$a] -ForeGroundColor Red
				Private-PrintHelp
				Exit
			}
		}
		$a++
	}
}


# Output help
#################################################
function Private-PrintHelp()
{
	Write-Host
	Write-Host Usage: -ForeGroundColor Green
	Write-Host 
	Write-Host "script.ps1 [-help|-h] [-environment|-env <ENV>] [-install|-i] [-automatic|-a]"
	Write-Host "           [-logdir|-ld <DIR>] [-nolog|-nl] [-dopwdcheck|-dpc] [-errors|-e]"
	Write-Host "           [-xmldb <DIR>]"
	Write-Host
	Write-Host "  -help               Show this help"
	Write-Host "  -environment <ENV>  Set manually environment the server belongs to (PROD/QA/DEV)"
	Write-Host "  -install            Check system and install/update stuff"
	Write-Host "  -automatic          Script will skip all manual inputs"
	Write-Host "  -logdir <DIR>       Specify local log directory"
	Write-Host "  -nolog              Do not create local log"
	Write-Host "  -errors             Script will also print PS errors"
	Write-Host "  -dopwdcheck         Script will validate passwords if any (manual input is required)"
	#Write-Host "  -illurl <URL>       API URL (default $Script:OpsDeployApiURL)" # add [-illurl <URL>] back when needed
	Write-Host "  -xmldb <DIR>        Instead of API use Machines.xml and Environments.xml from <DIR> folder"
	Write-Host
}



# Uninstall Application
#################################################
function Private-UninstallApp([string]$AppName)
{
	$App = Get-WmiObject -Class Win32_Product | ?{ $_.Name -eq "$AppName" }
	
	If (-not $App)
	{
		Write-Log -Message "-> uninstalling $AppName" -EntryType "WARNING" -ResultMessage "application not found"
		return $true
	}
	
	$Result = $App.Uninstall()
	
	if ($Result.ReturnValue -ne 0)
	{
		Write-Log -Message "-> uninstalling $AppName" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
		return $false
	}
	else
	{
		Write-Log -Message "-> uninstalling $AppName" -ResultOK -ResultMessage "success"
		return $true
	}
}

# checks baseline header and displays formatted info
################################################
function Private-ReviewFileHeader()
{
    #$Path = Split-Path -parent $MyInvocation.MyCommand.Definition # No need as this comes from the first part of baseline script
    $HistoryFormat = "{0,-12} {1,-9} {2,-9} {3,-20} {4,-20} {5}" # "Changelist","Revision","Author","Modify Date/Time","Source Date/Time","File Name/Message"
    $HistoryFormatNoHistory = "{0,-32} {1,-41} {2}"
    
    $Message = ("$HistoryFormat" -f "Changelist","Revision","Author","Modify Date/Time","Source Date/Time","File Name/Message")
    Write-Log -Message "$Message"
    
    foreach ($item in (Get-ChildItem $Path -Filter "*.ps1" -Recurse -Force))
    {
        # only perform on files, not directories
    	if ($item -isnot [System.IO.DirectoryInfo])
    	{
           $DateTime = $($item.LastWriteTime.ToString('yyyy/MM/dd HH:mm:ss'))
            $NameFromLocalSystem = $item.Name
            if ($NameFromLocalSystem.Length -gt 30){ $ShortNameFromLocalSystem = $NameFromLocalSystem.Substring(0, $NameFromLocalSystem.IndexOf("", 30)) }
            else {$ShortNameFromLocalSystem = $NameFromLocalSystem }
    	}
    }
}

########################################################################################################
#
#   Private functions - end
#
########################################################################################################

