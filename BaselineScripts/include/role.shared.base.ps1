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
#        gc role.shared.base.ps1 | select-string "^function|functions - begin$" | foreach { $_.toString() -replace '^function', '#     ' -replace '- begin', '' }
#
#   role SHARED functions

#
########################################################################################################



########################################################################################################
#
#   role SHARED functions - begin
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


        $ServiceName = "WinRM"
        
        $TrustedHosts = "AM-IT-t2100VRjd"
          
   
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
    







# Use for ALL SSL v2 AND V3 and weak cipher disables plus enables TLS
# -checked-
#################################################
function Check-SSLv2Disabled()
{
	Write-Log
	Write-Log -Message "Checking registry for obsolete SSL protocols, ciphers and possibly mice  ..."
	Write-Log

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

        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 3.0\Server" -Property "Enabled" -Value 0 -PropertyType dword
        Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SChannel\Protocols\SSL 3.0\Client" -Property "Enabled" -Value 0 -PropertyType dword
    
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
	
# $Script:DomainName is set in Do-InitialSteps function in BaselineScripts\Baseline_Common.ps1
		Check-GroupMembership -IdentityReference ("$Script:DomainName\Domain Admins") -Group "Administrators"
		Check-GroupMembership -IdentityReference ("$Script:DomainName\mborges") -Group "Administrators"
		Check-GroupMembership -IdentityReference ("$Script:DomainName\SRV-IS SolarOps") -Group "Administrators"
        Check-GroupMembership -IdentityReference ("$Script:DomainName\SRV-Local Admin") -Group "Administrators"
        Check-GroupMembership -IdentityReference ("$Script:DomainName\SRV-Sec-Admins") -Group "Administrators"
        Check-GroupMembership -IdentityReference ("$Script:DomainName\WKS-Lansweep Admin") -Group "Administrators"
	
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
  
            Check-GroupMembership -IdentityReference ("$Script:DomainName\SiteEventLogReaders") -Group "Event Log Readers"  # not sure this exists but we must have something i am guessing?

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
		# Check-NetworkShare -Share "C" -Path "C:\" -Permissions "Everyone,READ"
		# Check-NetworkShare -Share "D" -Path "D:\" -Permissions "Everyone,READ"
	}
	
}










########################################################################################################
#
#   role SHARED functions - end
#
########################################################################################################


