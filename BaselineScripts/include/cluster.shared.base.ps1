########################################################################################################
# 
#
#
#   Cluster SHARED Baseline Library
#
#
#	Use this as include in your specific baseline script
#   Can be done by placing either line at the top of your script (without quotes):
#      ". .\include\cluster.xxx.base.ps1"
#      ". d:\BaselineScript\include\cluster.xxx.base.ps1"
#      ". \\server\path\to\cluster.xxx.base.ps1"
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
#        gc cluster.shared.base.ps1 | select-string "^function|functions - begin$" | foreach { $_.toString() -replace '^function', '#     ' -replace '- begin', '' }
#
#   cluster SHARED functions
#      Check-DST()
#      Check-PSRemoting()
#      Check-MachineKey()
#      Check-MachineKey-WebConfig()
#	   Check-MachineKey4CompatibilityModeSetting-WebConfig()
#      Check-ASPNETSessionState()
#      Check-ApplicationLog()
#      Check-IISRootFolder()
#      Check-IISDefaultWebSite()
#      Check-IISLogDirectory()
#      Check-IISHttpErrorsLocation()
#      Check-IISFoldersPermissions()
#      Check-IISF5XForwardedForFilter()
#      Remove-IISF5XForwardedForModulex86()
#      Check-IISF5XForwardedForModule()
#      Check-IISF5XForwardedForModule64()
#      Check-IISAppPool32BitMode()
#      Check-IISAppcmdPATH()
#      Check-IISHttpErrorsOverride()
#      Check-IISDefaultDocuments-Monster2.0()
#      Check-SessionStateOLD()
#      Check-SMTPService()
#      Check-SSLv2Disabled()
#      Check-SSLv3Disabled()
#      Check-DLLs()
#      Check-CryptoComproxy()
#      Check-QueueSyncTaskVbs()
#      Check-MonsterPerlLibraries()
#      Check-ConfigureExceptionMgmt()
#      Check-Administrators()
#      Check-EventLogReaders()
#      Check-ConfigFolder()
#      Check-NetworkShares()
#      Check-DisableStrictNameChecking()
#      Check-WindowsFeatures-WEBADMINOPM()
#      Check-DirectoriesAndPermissions-WEBADMINOPM()
#      Check-NetworkShares-WEBADMINOPM()
#      Check-IISDefaultDocuments-WEBADMINOPM()
#      Check-WindowsFeatures-JBAT()
#      Check-DirectoriesAndPermissions-JBAT()
#      Check-BGWConfig-JBAT()
#      Check-WindowsFeaturesNETAPP()
#      Check-Permissions-PCIFolders()
#      Check-WindowsFeatures-FRAUDAA()
#      Check-DirectoriesAndPermissionsNETAPP()
#      Check-NetworkSharesNETAPP()
#      Check-WindowsFeaturesNETSVCS()
#      Check-DirectoriesAndPermissionsNETSVCS()
#      Check-NetworkSharesNETSVCS()
#      Check-DirectoriesAndPermissionsNETWEB()
#      Check-NetworkSharesNETWEB()
#      Check-IncreasedHttpHeaderSize-DWP-NETWEB()
#      Check-WindowsFeaturesUNICA()
#      Check-DirectoriesAndPermissionsUNICA()
#      Check-NetworkSharesUNICA()
#      Check-ScaleoutClient()
#      Check-Mongos()
#      Check-QueueSyncTaskVbs_Removed()
#      Check-Java7-0-80-x64WithSafenet8()
#
########################################################################################################



########################################################################################################
#
#   cluster SHARED functions - begin
#
########################################################################################################


# Check daylight savings time
# -checked-
#################################################
function Check-DST()
{
	$TimeZoneID = "Eastern Standard Time"
	
	Write-Log
	Write-Log -Message "Checking Daylight savings time ..."
	Write-Log
	
	if ($Script:DataCenter -eq "Bristol" -or $Script:DataCenter -eq "Swindon")
	{
		$TimeZoneID = "GMT Standard Time"
	}
	
	Check-DaylightTimeZone -TimeZoneID $TimeZoneID
}


# Check Powershell Remoting
# -checked-
#################################################
function Check-PSRemoting()
{
    #not required in DWP
    if ($Script:SupportedLocales -notcontains 'DWP')
    {
        $ServiceName = "WinRM"
        
        $TrustedHosts = "opsdeploy101,opsdeploy201,opsdeploy301,opsdeploy401"
          
        if ($Script:Environment -ne "PROD")
        {
            Write-Log
            Write-Log -Message "Checking Powershell Remoting ..."
            Write-Log
            
            Check-Service -Name $ServiceName -StartupType "automatic" -ForceStartStop
            
            # checking trusted hosts
            if ((Get-Item WSMan:\localhost\Client\TrustedHosts).Value -eq $TrustedHosts)
            {
                Write-Log -Message "WSMan:\localhost\Client\TrustedHosts" -Category "WSMan" -ResultOK -ResultMessage "OK"
            }
            else
            {
                if ($Script:ValidateOnly)
                {
                    Write-Log -Message "WSMan:\localhost\Client\TrustedHosts" -Category "WSMan" -ResultFailure -ResultMessage "incorrect"
                }
                else
                {
                    Write-Log -Message "WSMan:\localhost\Client\TrustedHosts" -Category "WSMan" -ResultFailure -ResultMessage "to be updated"
                    
                    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $TrustedHosts -Force
                    
                    if ($?)
                    {
                        Write-Log -Message "-> updating WSMan:\localhost\Client\TrustedHosts" -ResultOK -ResultMessage "success"
                        Restart-Service $ServiceName
                    }
                    else
                    {
                        Write-Log -Message "-> updating WSMan:\localhost\Client\TrustedHosts" -ResultFailure -ResultMessage $Error[0].Exception.Message
                    }
                }
            }
            
            # checking PS session configuration - Microsoft.PowerShell
            if ((Get-ChildItem WSMan::localhost\Plugin | ? { $_.Name -eq "Microsoft.PowerShell" }).Name -eq "Microsoft.PowerShell")
            { 
                Write-Log -Message "WSMan::localhost\Plugin [Name = Microsoft.PowerShell]" -Category "WSMan" -ResultOK -ResultMessage "OK"
            }
            else
            {
                if ($Script:ValidateOnly)
                {
                    Write-Log -Message "WSMan::localhost\Plugin [Name = Microsoft.PowerShell]" -Category "WSMan" -ResultFailure -ResultMessage "missing"
                }
                else
                {
                    Write-Log -Message "WSMan::localhost\Plugin [Name = Microsoft.PowerShell]" -Category "WSMan" -ResultFailure -ResultMessage "to be added"
                    
                    Register-PSSessionConfiguration Microsoft.PowerShell -force
                    
                    if ($?)
                    {
                        Write-Log -Message "-> registering Microsoft.PowerShell to PS Session Configuration" -ResultOK -ResultMessage "success"
                    }
                    else
                    {
                        Write-Log -Message "-> registering Microsoft.PowerShell to PS Session Configuration" -ResultFailure -ResultMessage $Error[0].Exception.Message
                    }
                }
            }
            
            # checking PS session configuration - Microsoft.PowerShell32
            if ((Get-ChildItem WSMan::localhost\Plugin | ? { $_.Name -eq "Microsoft.PowerShell32" }).Name -eq "Microsoft.PowerShell32")
            { 
                Write-Log -Message "WSMan::localhost\Plugin [Name = Microsoft.PowerShell32]" -Category "WSMan" -ResultOK -ResultMessage "OK"
            }
            else
            {
                if ($Script:ValidateOnly)
                {
                    Write-Log -Message "WSMan::localhost\Plugin [Name = Microsoft.PowerShell32]" -Category "WSMan" -ResultFailure -ResultMessage "missing"
                }
                else
                {
                    Write-Log -Message "WSMan::localhost\Plugin [Name = Microsoft.PowerShell32]" -Category "WSMan" -ResultFailure -ResultMessage "to be added"
                    
                    Register-PSSessionConfiguration Microsoft.PowerShell32 -processorarchitecture x86 -force
                    
                    if ($?)
                    {
                        Write-Log -Message "-> registering Microsoft.PowerShell32 to PS Session Configuration" -ResultOK -ResultMessage "success"
                    }
                    else
                    {
                        Write-Log -Message "-> registering Microsoft.PowerShell32 to PS Session Configuration" -ResultFailure -ResultMessage $Error[0].Exception.Message
                    }
                }
            }
        }
    }
}






# Use for ALL SSL v2 AND V3 and weak cipher disables plus enables TLS
# -checked-
#################################################
function Check-SSLv2Disabled()
{
	Write-Log
	Write-Log -Message "Checking registry for obsolete SSL protocols, ciphers and possibly mice  ..."
	Write-Log
    if ($Script:SupportedLocales -contains 'NA')
	{
        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 2.0\Server" -Property "Enabled" -Value 0 -PropertyType dword
        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 2.0\Client" -Property "Enabled" -Value 0 -PropertyType dword
        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 3.0\Server" -Property "Enabled" -Value 0 -PropertyType dword
        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 3.0\Client" -Property "Enabled" -Value 0 -PropertyType dword
        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 3.0\Client" -Property "DisabledByDefault" -Value 1 -PropertyType dword
        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 3.0\Server" -Property "DisabledByDefault" -Value 1 -PropertyType dword
		Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\RC4 56/128" -Property "Enabled" -Value 0 -PropertyType dword
		Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\RC4 40/128" -Property "Enabled" -Value 0 -PropertyType dword
		Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\RC4 64/128" -Property "Enabled" -Value 0 -PropertyType dword
		Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\RC4 128/128" -Property "Enabled" -Value 0 -PropertyType dword
		Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\RC2 56/128" -Property "Enabled" -Value 0 -PropertyType dword
		Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\RC2 40/128" -Property "Enabled" -Value 0 -PropertyType dword
		Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\RC2 128/128" -Property "Enabled" -Value 0 -PropertyType dword
	}
	Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\TLS 1.0\Server" -Property "Enabled" -Value 1 -PropertyType dword
	Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\TLS 1.0\Client" -Property "Enabled" -Value 1 -PropertyType dword
	Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\RC2 128/128" #thisline doesn't do anything except a testpatth
	Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\RC4 128/128" #thisline doesn't do anything except a testpatth
	Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Ciphers\Triple DES 168/168" #thisline doesn't do anything except a testpatth
}

# Check registry for SSLv3 disabled
# -checked-
#################################################  DO NOT USE THIS the 2,0 version does 2 3 and enables TLS ciphers .
function Check-SSLv3Disabled()
{
	Write-Log
	Write-Log -Message "Checking registry for SSLv3 disabled ..."
	Write-Log
    if ($Script:SupportedLocales -contains 'NA')
	{
        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 3.0\Server" -Property "Enabled" -Value 0 -PropertyType dword
        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 3.0\Client" -Property "Enabled" -Value 0 -PropertyType dword
    }
}


function Check-ConfigureExceptionMgmt()
{
	Write-Log
	Write-Log -Message "Checking Microsoft ExceptionManagement dlls ..."
	Write-Log
	
	Check-Directory "D:\services\MicrosoftExceptionManagement"
	Check-File "D:\services\MicrosoftExceptionManagement\Microsoft.ApplicationBlocks.ExceptionManagement.dll" -SourceFile "$Script:StoragePath\3pty\Microsoft\.NET\ExceptionManagementLibraries\Microsoft.ApplicationBlocks.ExceptionManagement.dll"
	Check-File "D:\services\MicrosoftExceptionManagement\Microsoft.ApplicationBlocks.ExceptionManagement.Interfaces.dll" -SourceFile "$Script:StoragePath\3pty\Microsoft\.NET\ExceptionManagementLibraries\Microsoft.ApplicationBlocks.ExceptionManagement.Interfaces.dll"
	
	Write-Log -Message "InstallUtil.exe to Install ExceptionManagement (not run, but enabled if you supplied install flag)"
	if (-not $Script:ValidateOnly)
	{
		Write-Log -Message "Installing ExceptionManagement"
		$Result = Invoke-Expression "C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe /LogFile= d:\services\MicrosoftExceptionManagement\Microsoft.ApplicationBlocks.ExceptionManagement.dll"
		$Result = Invoke-Expression "C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe /LogFile= d:\services\MicrosoftExceptionManagement\Microsoft.ApplicationBlocks.ExceptionManagement.Interfaces.dll"
	}
	
	$Category = "REG"
	$Path = "HKLM:\SYSTEM\CurrentControlSet\services\eventlog\Application\ExceptionManagerInternalException"
	if (Test-Path -Path $Path)
		{ Write-Log -Category $Category -Message "$Path" -ResultOK -ResultMessage "found" }
	else
	{
		Write-Log -Category $Category -Message "$Path" -EntryType "ERROR" -ResultFailure -ResultMessage "not found"
		Write-Log -Message "  looks like InstallUtil.exe went wrong, try installation manually"
		Write-Log -Message "  C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe /LogFile= d:\services\MicrosoftExceptionManagement\Microsoft.ApplicationBlocks.ExceptionManagement.dll"
		Write-Log -Message "  C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe /LogFile= d:\services\MicrosoftExceptionManagement\Microsoft.ApplicationBlocks.ExceptionManagement.Interfaces.dll"
	}
	$Path = "HKLM:\SYSTEM\CurrentControlSet\services\eventlog\Application\ExceptionManagerPublishedException"
	if (Test-Path -Path $Path)
		{ Write-Log -Category $Category -Message "$Path" -ResultOK -ResultMessage "found" }
	else
	{
		Write-Log -Category $Category -Message "$Path" -EntryType "ERROR" -ResultFailure -ResultMessage "not found"
		Write-Log -Message "  looks like InstallUtil.exe went wrong, try installation manually"
		Write-Log -Message "  C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe /LogFile= d:\services\MicrosoftExceptionManagement\Microsoft.ApplicationBlocks.ExceptionManagement.dll"
		Write-Log -Message "  C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe /LogFile= d:\services\MicrosoftExceptionManagement\Microsoft.ApplicationBlocks.ExceptionManagement.Interfaces.dll"
	}
}

# Check Administrators
# -checked-
#################################################
function Check-Administrators()
{
	Write-Log
	Write-Log -Message "Checking users/groups in the Administration group ($Script:Environment) ..."
	Write-Log
	
	$Script:ComputerName =  $Env:COMPUTERNAME
	
	if ($Script:Environment -eq 'PROD')
	{
        # NA only
		if ($Script:SupportedLocales -contains 'NA')
        {
            Check-GroupMembership -IdentityReference ("$Script:DomainName\Batchjob") -Group "Administrators"
        }
		# NA and DWP production
		Check-GroupMembership -IdentityReference ("$Script:DomainName\Domain Admins") -Group "Administrators"
		Check-GroupMembership -IdentityReference ("$Script:DomainName\ProdEng") -Group "Administrators"
		Check-GroupMembership -IdentityReference ("$Script:DomainName\ServerMgmt") -Group "Administrators"
	}
	elseif ($Script:Environment -eq 'DEV')
	{
		if($Script:ComputerName -match  "NETWEBL")
        {
            Check-GroupMembership -IdentityReference ("$Script:DomainName\Domain Admins") -Group "Administrators"
		    Check-GroupMembership -IdentityReference ("$Script:DomainName\ProdEng") -Group "Administrators"
		    Check-GroupMembership -IdentityReference ("$Script:DomainName\ServerMgmt") -Group "Administrators"
	        Check-GroupMembership -IdentityReference ("$Script:DomainName\SSOAdmin") -Group "Administrators"
        }
        else
        {
			Check-GroupMembership -IdentityReference ("$Script:DomainName\Batchjob") -Group "Administrators"
			Check-GroupMembership -IdentityReference ("$Script:DomainName\Domain Admins") -Group "Administrators"
			Check-GroupMembership -IdentityReference ("$Script:DomainName\intbatch") -Group "Administrators"
			Check-GroupMembership -IdentityReference ("$Script:DomainName\ProdEng") -Group "Administrators"
			Check-GroupMembership -IdentityReference ("$Script:DomainName\QAAdmins") -Group "Administrators"
			Check-GroupMembership -IdentityReference ("$Script:DomainName\ServerMgmt") -Group "Administrators"
			Check-GroupMembership -IdentityReference ("$Script:DomainName\Dev-Admins") -Group "Administrators"
		}
	}
	elseif ($Script:Environment -eq 'QA')
	{
		if($Script:ComputerName -match  "NETWEBL")
        {
            Check-GroupMembership -IdentityReference ("$Script:DomainName\Domain Admins") -Group "Administrators"
		    Check-GroupMembership -IdentityReference ("$Script:DomainName\ProdEng") -Group "Administrators"
		    Check-GroupMembership -IdentityReference ("$Script:DomainName\QAAdmins") -Group "Administrators"
		    Check-GroupMembership -IdentityReference ("$Script:DomainName\ServerMgmt") -Group "Administrators"
            Check-GroupMembership -IdentityReference ("$Script:DomainName\SSOAdmin") -Group "Administrators"

        }
		else
		{
			Check-GroupMembership -IdentityReference ("$Script:DomainName\Domain Admins") -Group "Administrators"
			Check-GroupMembership -IdentityReference ("$Script:DomainName\ProdEng") -Group "Administrators"
			Check-GroupMembership -IdentityReference ("$Script:DomainName\QAAdmins") -Group "Administrators"
			Check-GroupMembership -IdentityReference ("$Script:DomainName\ServerMgmt") -Group "Administrators"
		}
        # NA only
		if ($Script:SupportedLocales -contains 'NA')
        {
            Check-GroupMembership -IdentityReference ("$Script:DomainName\qabatch") -Group "Administrators"
        }
	}
}


# Check Event Log Readers
# -checked-
#################################################
function Check-EventLogReaders()
{
    if ($Script:SupportedLocales -contains 'NA')
	{
        Write-Log
        Write-Log -Message "Checking users/groups in the Event Log Readers group ($Script:Environment) ..."
        Write-Log
        if ($Script:Environment -eq 'PROD')
        {
            Check-GroupMembership -IdentityReference ("$Script:DomainName\SiteEventLogReaders") -Group "Event Log Readers"
        }
        elseif ($Script:Environment -eq 'DEV')
        {
            Check-GroupMembership -IdentityReference "\Everyone" -Group "Event Log Readers"
            Check-GroupMembership -IdentityReference "NA\QA" -Group "Event Log Readers"
        }
        elseif ($Script:Environment -eq 'QA')
        {
        	Check-GroupMembership -IdentityReference "\Everyone" -Group "Event Log Readers"
        }
    }
}


# Check essential network shares
# -checked-
#################################################
function Check-NetworkShares()
{
	Write-Log
	Write-Log -Message "Checking network shares ($Script:Environment) ..."
	Write-Log
	
	if ($Script:Environment -eq 'PROD')
	{
		# Shouldn't have any
	}
	elseif ($Script:Environment -eq 'DEV')
	{
		Check-NetworkShare -Share "C" -Path "C:\" -Permissions "Everyone,READ"
		Check-NetworkShare -Share "D" -Path "D:\" -Permissions "Everyone,READ"
	}
	elseif ($Script:Environment -eq 'QA')
	{
        if ($Script:SupportedLocales -contains 'DWP')
		{
			Check-NetworkShare -Share "C" -Path "C:\" -Permissions (
			"$Script:DomainName\Site Log Readers,READ",
			"$Script:DomainName\Site Log Admins,CHANGE"
			)
        	Check-NetworkShare -Share "D" -Path "D:\" -Permissions (
			"$Script:DomainName\Site Log Readers,READ",
			"$Script:DomainName\Site Log Admins,CHANGE"
			)            
            # set permissions on the log folder 
            Check-Permissions "d:\logs" -Permissions ("$Script:DomainName\Site Log Admins:(OI)(CI)(F)", "$Script:DomainName\Site Log Readers:(OI)(CI)(R)")
		}
		else
		{
			Check-NetworkShare -Share "C" -Path "C:\" -Permissions "Everyone,READ"
			Check-NetworkShare -Share "D" -Path "D:\" -Permissions "Everyone,READ"
        }
	}
}










########################################################################################################
#
#   cluster SHARED functions - end
#
########################################################################################################


