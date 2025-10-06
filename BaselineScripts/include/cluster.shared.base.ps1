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



function Check-IISDefaultWebSite()
{
	Write-Log
	Write-Log -Message "Checking Default Web Site ..."
	Write-Log
	
	if (-not (Import-WebAdministration)) 
	{
		Write-Log -Message "Cannot load module WebAdministration" -EntryType "ERROR"
		return
	}
	
	if ((Get-WebsiteState -Name "Default Web Site") -eq $null)
	{
		Write-Log -Message "Default Web Site not present, skipping check." -EntryType "INFO"
	}
	else
	{
		$WebSitePath = "d:\wwwroot\default"
		
		Check-Directory $WebSitePath
		Check-WebConfigurationProperty -filter '/system.applicationHost/sites/site[@name="Default Web Site"]/application[@path="/"]/virtualDirectory' -Name physicalPath -value $WebSitePath
		
		if (-not $Script:ValidateOnly)
		{
			$SourceObjects = "d:\wwwroot\aspnet_client", "d:\wwwroot\iisstart.htm", "d:\wwwroot\welcome.png"
			
			foreach ($Object in $SourceObjects)
			{
				if (Test-Path -Path $Object)
				{
					Move-Item -Path $Object -Destination $WebSitePath
				}
			}
		}
	}
}


# Check IIS log directory
# -checked-
#################################################
function Check-IISLogDirectory()
{
	Write-Log
	Write-Log -Message "Checking IIS log directory ..."
	Write-Log
	
	Check-Directory "D:\logs\www"
	Check-Directory "D:\logs\FailedReqLogFiles"

	# check logfile directories
	Check-WebConfigurationProperty -filter '/system.applicationHost/sites/siteDefaults/traceFailedRequestsLogging' -Name directory -value "D:\logs\FailedReqLogFiles"
	Check-WebConfigurationProperty -filter '/system.applicationHost/sites/siteDefaults/logfile' -Name directory -value "D:\logs\www"
	Check-WebConfigurationProperty -filter '/system.applicationHost/log/centralBinaryLogFile' -Name directory -value "D:\logs\www"
	Check-WebConfigurationProperty -filter '/system.applicationHost/log/centralW3CLogFile' -Name directory -value "D:\logs\www"
	
	# disabling traceFailedRequestsLogging by default
	Check-WebConfigurationProperty -filter '/system.applicationHost/sites/siteDefaults/traceFailedRequestsLogging' -Name enabled -value "false"
}


# Check IIS httpErrors files locations
# -checked-
#################################################
function Check-IISHttpErrorsLocation()
{
	$NewIISRootFolder = "D:\inetpub"
	
	Write-Log
	Write-Log -Message "Checking IIS httpErrors files locations ..."
	Write-Log
	
	Check-WebConfigurationProperty -filter '/system.webServer/httpErrors/error[@statusCode="401"]' -Name prefixLanguageFilePath -value "$NewIISRootFolder\custerr"
	Check-WebConfigurationProperty -filter '/system.webServer/httpErrors/error[@statusCode="403"]' -Name prefixLanguageFilePath -value "$NewIISRootFolder\custerr"
	Check-WebConfigurationProperty -filter '/system.webServer/httpErrors/error[@statusCode="404"]' -Name prefixLanguageFilePath -value "$NewIISRootFolder\custerr"
	Check-WebConfigurationProperty -filter '/system.webServer/httpErrors/error[@statusCode="405"]' -Name prefixLanguageFilePath -value "$NewIISRootFolder\custerr"
	Check-WebConfigurationProperty -filter '/system.webServer/httpErrors/error[@statusCode="406"]' -Name prefixLanguageFilePath -value "$NewIISRootFolder\custerr"
	Check-WebConfigurationProperty -filter '/system.webServer/httpErrors/error[@statusCode="412"]' -Name prefixLanguageFilePath -value "$NewIISRootFolder\custerr"
	Check-WebConfigurationProperty -filter '/system.webServer/httpErrors/error[@statusCode="500"]' -Name prefixLanguageFilePath -value "$NewIISRootFolder\custerr"
	Check-WebConfigurationProperty -filter '/system.webServer/httpErrors/error[@statusCode="501"]' -Name prefixLanguageFilePath -value "$NewIISRootFolder\custerr"
	Check-WebConfigurationProperty -filter '/system.webServer/httpErrors/error[@statusCode="502"]' -Name prefixLanguageFilePath -value "$NewIISRootFolder\custerr"
}


# Check permissions on IIS folders
# -checked-
#################################################
function Check-IISFoldersPermissions()
{
	Write-Log
	Write-Log -Message "Checking permissions on IIS folders ..."
	Write-Log
	
	# Check permissions on folders
	
	# d:\wwwroot
		#-explicit-
		#BUILTIN\IIS_IUSRS:(OI)(CI)(RX)
		#-other inherited-
	Check-Permissions "D:\wwwroot" -Permissions "BUILTIN\IIS_IUSRS:(OI)(CI)(RX)"
	
	# d:\inetpub
		# handled by xcopy in Check-IISRootFolder - copied from c:
	
	# d:\inetpub\temp\IIS Temporary Compressed Files
	# d:\inetpub\temp\IIS Temporary Compressed Files
    if($($Env:computername) -notmatch "NETWEBL")
    {
	    Check-Permissions "D:\inetpub\temp\IIS Temporary Compressed Files" -Permissions (
		"NT AUTHORITY\SYSTEM:(OI)(CI)(F)", 
		"BUILTIN\Administrators:(OI)(CI)(F)", 
		"BUILTIN\IIS_IUSRS:(OI)(CI)(F)"
		) -ExactMatch
    }
    else
    {
        Write-Log
	    Write-Log -Message "Checking D:\inetpub\temp\IIS Temporary Compressed Files"
	    Write-Log

        if(Test-Path -Path "D:\inetpub\temp\IIS Temporary Compressed Files")
        {
            Write-Log
	        Write-Log -Message "Removing D:\inetpub\temp\IIS Temporary Compressed Files"
	        Write-Log
            Remove-Item -Path "D:\inetpub\temp\IIS Temporary Compressed Files" # not required 
        }
        else
        {
             Write-Log
	         Write-Log -Message "Not present D:\inetpub\temp\IIS Temporary Compressed Files" -Category "DIR" -ResultOK -ResultMessage "OK"
	         Write-Log
        }
       
    }
	
	# d:\inetpub\temp\
	# d:\inetpub\temp\ASP Compiled Templates
	# -have inherited rights-
}




# Check IIS AppPool 32Bit Mode
# -checked-
#################################################
function Check-IISAppPool32BitMode()
{
	Write-Log
	Write-Log -Message "Checking IIS AppPool 32Bit mode ..."
	Write-Log
	
	$Update = Check-WebConfigurationProperty -Filter "/system.applicationHost/applicationPools/applicationPoolDefaults" -Name enable32BitAppOnWin64 -Value true -ReturnUpdate
	
	if ($Update -eq $true)
	{
		Restart-Service "W3SVC"
		if ($?)
		{
			Write-Log -Message "-> restarting W3SVC service" -ResultOK -ResultMessage "success"
		}
		else
		{
			Write-Log -Message "-> restarting W3SVC service" -EntryType "ERROR" -ResultFailure -ResultMessage  $Error[0].Exception.Message
		}
	}
}


# Check IIS appcmd path
# -checked-
#################################################
function Check-IISAppcmdPATH()
{
	Write-Log
	Write-Log -Message "Checking path to appcmd in PATH ..."
	Write-Log
	
	Check-EnvPath -PathEntry "C:\Windows\System32\inetsrv\"
}


# Check-IISHttpErrorsOverride()
# -checked-
# unlocking httpErrors section allows it to be overridden on application basis
# This allows custom erorrs to be configured in the web.configs of IIS7 applications 
#   instead of having to configure them in IIS itself
############################################################################
function Check-IISHttpErrorsOverride()
{
	Write-Log
	Write-Log -Message "Checking if custom errors are allowed.."
	Write-Log
	
	$ConfigFile = "c:\WINDOWS\system32\inetsrv\config\applicationHost.config"
	
	Check-XmlProperty -XmlPath $ConfigFile -ElementXpath '/configuration/configSections/sectionGroup[@name="system.webServer"]/section[@name="httpErrors"]' -Attribute overrideModeDefault -Value "Allow"
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
            Check-GroupMembership -IdentityReference "NA\Monster-dev" -Group "Event Log Readers"
            Check-GroupMembership -IdentityReference "NA\QA" -Group "Event Log Readers"
        }
        elseif ($Script:Environment -eq 'QA')
        {
        	Check-GroupMembership -IdentityReference "\Everyone" -Group "Event Log Readers"
        }
    }
}

# Check folder d:\Config
# -checked-
#################################################
function Check-ConfigFolder()
{
	$TargetPath = "D:\Config"
	$SourcePath = "$Script:StoragePath\depot\Production\common\Config"
	
	Write-Log
	Write-Log -Message "Checking folder d:\Config ..."
	Write-Log
	
	Check-DirectoryTree -TargetPath $TargetPath -SourcePath $SourcePath
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


#
# This feature when enabled allows a DNS alias to be used to point to a share on the 
#   local machine
function Check-BackConnectionHostNames([string[]]$DNSAlias)
{
	Write-Log
	Write-Log -Message "Checking registry setting for BackConnectionHostNames for alias $DNSAlias..."
	Write-Log
	
	Check-RegistrySetting -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -Property "BackConnectionHostNames" -Value $DNSAlias -PropertyType "MultiString"

}




function Check-DisableStrictNameChecking()
{
	Write-Log
	Write-Log -Message "Checking registry setting for DisableStrictNameChecking..."
	Write-Log
	
	Check-RegistrySetting -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" -Property "DisableStrictNameChecking" -Value 1 -PropertyType Dword

}

<# EXAMPLE of cluster specific functions #>



function Check-WindowsFeatures-JBAT()
{
	$Features =
	# Application Server:
	"AS-NET-Framework","AS-TCP-Port-Sharing",
	# Application Server - WAS Support:
	"AS-HTTP-Activation","AS-TCP-Activation","AS-Named-Pipes",
	# File Services:
	"FS-FileServer",
	# Web server - Common HTTP Features:
	"Web-Common-Http","Web-Static-Content","Web-Default-Doc","Web-Dir-Browsing","Web-Http-Errors","Web-Http-Redirect",
	# Web server - Application Development:
	"Web-Asp-Net","Web-Net-Ext","Web-ASP","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Includes",
	# Web server - Health and Diagnostic:
	"Web-Http-Logging","Web-Log-Libraries","Web-Request-Monitor","Web-Http-Tracing","Web-Custom-Logging","Web-ODBC-Logging",
	# Web Server (IIS) - Web server - Security:
	"Web-Basic-Auth","Web-Windows-Auth","Web-Url-Auth","Web-Filtering","Web-IP-Security",
	# Web Server (IIS) - Web server - Performance:
	"Web-Stat-Compression","Web-Dyn-Compression",
	# Web Server (IIS) - Management Tools:
	"Web-Mgmt-Console","Web-Scripting-Tools","Web-Mgmt-Service",
	# Web Server (IIS) - Management Tools - IIS6 Management Compatibility:
	"Web-Metabase","Web-WMI","Web-Lgcy-Scripting","Web-Lgcy-Mgmt-Console",
	# .NET Framework 3.5.1 Features:
	"NET-Framework-Core",
	# .NET Framework 3.5.1 Features - WCF Activation:
	"NET-HTTP-Activation","NET-Non-HTTP-Activ",
	# Connection Manager Administration Kit:
	"CMAK",
	# Remote Server Administration Tools - Role Administration Tools:
	"RSAT-Web-Server",
	# Remote Server Administration Tools - Feature Administration Tools:
	"RSAT-SMTP",
	# SMTP Server:
	# "SMTP-Server", - NO MS SMTP SERVICE ON MONSTER 2.0 SERVERS !
	# SNMP Services:
	"SNMP-Service","SNMP-WMI-Provider",
	# Windows Process Activation Service
	"WAS-Process-Model","WAS-NET-Environment","WAS-Config-APIs"
	
	Write-Log
	Write-Log -Message "Checking Windows Features and Roles ..."
	Write-Log
	
	Check-WindowsFeatures -Features $Features
}


# Check essential directories and permissions on JBAT
# -checked-
#################################################
function Check-DirectoriesAndPermissions-JBAT()
{
	Write-Log
	Write-Log -Message "Checking directories and permissions ..."
	Write-Log
	
	Check-Directory "C:\temp"
	Check-Directory "D:\db"
	Check-Directory "D:\temp"
	Check-Directory "D:\xsl"
    
    # Added per DEV00725341 - BatchFramework will use this
    Check-Directory "D:\Batch"
	Check-Permissions "D:\Batch" -Permissions (
            			"BUILTIN\Administrators:(OI)(CI)(F)", 
            			"NT AUTHORITY\NETWORK SERVICE:(OI)(CI)(F)",
            			"NT AUTHORITY\NETWORK:(OI)(CI)(F)",
            			"NT AUTHORITY\SYSTEM:(OI)(CI)(F)",
            			"CREATOR OWNER:(OI)(CI)(IO)(F)",
            			"BUILTIN\Users:(OI)(CI)(RX)",
            			"BUILTIN\Users:(CI)(AD)"
					)
	# NA folders
	if ($Script:SupportedLocales -contains 'NA')
	{
		Check-Directory "d:\NA\batch\MessageBroker"
		Check-Directory "d:\NA\businessgateway"
		Check-Directory "d:\NA\cache"
		Check-Directory "d:\NA\Config"
		Check-Directory "d:\logs\NA" 
	}
	# DWP folders
	if ($Script:SupportedLocales -contains 'DWP')
	{
		Check-Directory "d:\DWP\batch\MessageBroker"
		Check-Directory "d:\DWP\businessgateway"
		Check-Directory "d:\DWP\cache"
		Check-Directory "d:\DWP\Config"
		Check-Directory "d:\logs\DWP"
       
	}
    
}





########################################################################################################
#
#   cluster SHARED functions - end
#
########################################################################################################


