########################################################################################################
# 
#
#
#   Software Baseline Library
#
#
#	Use this as include in your specific baseline script
#   Can be done by placing either line at the top of your script (without quotes):
#      ". .\include\software.base.ps1"
#      ". d:\BaselineScript\include\software.base.ps1"
#      ". \\server\path\to\software.base.ps1"
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
#        gc software.base.ps1 | select-string "^function|functions - begin$" | foreach { $_.toString() -replace '^function', '#     ' -replace '- begin', '' }
#
#   Software functions
#      Check-MSDeploy11()
#      Check-MSDeploy11-Uninstall()
#      Check-MSDeploy35()
#      Check-LogParser22()
#      Check-MSXMLParser40SP3()
#      Check-MSXMLParser40SP3-Uninstall()
#      Check-Safenet511([string]$SafeNetBit = "x86", [bool]$SafeNetLegacy = $false)
#      Check-Java7-SafeNet511([bool]$SafeNetLegacy = $false)
#      Check-Java7-SafeNet8-4-2([bool]$SafeNetLegacy = $false)
#      Check-Java8-SafeNet511()
#      Check-dotNetv4()
#      Check-dotNetv45()
#      Check-dotNetv46()
#      Check-dotNetv461()
#      Check-dotNetv4withHotfix()
#      Check-MVC2()
#      Check-MVC2Hotfix()
#      Check-MVC3()
#      Check-MVC3Hotfix()
#      Check-MVC3-Uninstall()
#      Check-MVC4()
#      Check-MVC4Hotfix()
#      Check-ScaleoutClient-4-2-22()
#      Check-ActivePerl-5-10-1007()
#      Check-ActivePerl-5-8-8-822()
#      Check-MSAppFabric()
#      Check-JDK1-6-0-22-x64-Uninstall()
#      Check-JDK1-6-0-4-x86-Uninstall()
#      Check-JDK1-6-0-35-x64-Uninstall()
#      Check-JDK1-6-0-38-x64-Uninstall()
#      Check-JDK1-6-0-38-x86-Uninstall()
#      Check-JDK1-7-0-13-x64()
#      Check-Java1-7-0-13-x86-Uninstall()
#      Check-JDK1-7-0-13-x86()
#      Check-JDK1-7-0-13-x64-Uninstall()
#      Check-JRE1-5-0-22_Uninstall()
#      Check-Java-7-0-17-x64-Uninstall()
#      Check-JDK1-7-0-13-x86-Uninstall()
#      Check-JRE1-6-0-38-x64()
#      Check-JRE1-6-0-45-x64()
#      Check-JRE1-7-0-17-x64()
#      Check-JRE1-7-0-17-x86()
#      Check-JRE1-7-0-25-x86()
#      Check-JDK1-7-0-25-x64()
#      Check-JRE1-7-0-25-x64()
#      Check-JRE1-7-0-72-x86()
#      Check-JRE1-7-0-25-x86_Uninstall()
#      Check-JRE1-7-0-40-x64()
#      Check-JRE1-7-0-40-x86()
#      Check-Java ( [string] $AppName, [string] $AppVersion, [string] $InstallCmd, [string] $InstallFolder, [boolean] $is32bit )
#      Check-JDK1-7-0-67-x64()
#      Check-JDK1-7-0-67-x86()
#      Check-JRE1-7-0-67-x64()
#      Check-JRE1-7-0-67-x86()
#      Check-JDK1-7-0-67-x64_Uninstall()
#      Check-JDK1-7-0-80-x86()
#      Check-JRE1-7-0-80-x64()
#      Check-JRE1-7-0-80-x64_Uninstall()
#      Check-JRE1-8-0-66-x64()
#      Check-UnixTools()
#      Check-Apache-Tomcat-7-0-35-x64()
#      Check-Apache-Ant-1-7-0()
#      Check-MSReportViewer()
#      Check-MSReportViewerSP1()
#      Check-AsembleyFileVersion([string] $AsemblyDll)
#      Check-MSReportViewerSP1HotFix()
#      Check-PerforceClient-2009.2-x64()
#      Check-PerforceClient-2013.3-x64()
#      Check-PerforceClient-2015.2-x64()
#      Check-Perforce_CMD_Client()
#      Check-WinScpClient()
#      Check-WinZip12.1()
#      Check-MSVCRT-2010-x64()
#      Check-MSVCRT-2010-x86()
#      Check-MSVCRT-2010-x64-fixed()
#      Check-MSVCRT-2010-x86-fixed()
#      Check-MSVCRT-2012-x64()
#      Check-MSVCRT-2012-x86()
#      Check-MSVCRT-2013-x64()
#      Check-MSVCRT-2013-x86()
#      Check-MSVCRT-2015-x64()
#      Check-MSVCRT-2015-x86()
#      Check-MongoS-221-withoutConfig()
#      Check-MongoS-configOnly()
#      Check-MSChartControls()
#      Check-MSChartControlsSP1()
#      Check-HFKB2540745()
#      Check-KB2840628()
#      Check-ScaleoutClient-4-2-32()
#      Check-ScaleoutClient-4-2-32Removal()
#      Check-ScaleoutClient-5-0-23()
#      Check-ScaleoutClient-5-0-23Removal()
#      Check-ScaleoutClient-5-1-5()
#      Check-ScaleoutServer-5-1-5()
#      Check-IISRewriteModule2()
#      Check-AccessDatabaseEngine()
#      Check-Gallio-v331-x64()
#      Check-SymantecScanEngine52142()
#      Get-EnvCredential()
#      Check-SymantecScanEngine52142-Uninstall()
#      Check-SymantecProtectionEngine75034()
#      Configure-SafenetConfigV8
#      Check-SafeNet8
#      Check-PowerShell5()
#      test-Posh5
#
########################################################################################################




########################################################################################################
#
#   Software functions - begin
#
########################################################################################################


# Check MSDeploy 1.1
# -checked-
#################################################
function Check-MSDeploy11()
{
	# we use WebDeploy 1.1
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\WebDeploy\WebDeploy1.1_x64_en-US.msi"
	$InstallCmd = "msiexec"
	$listenURL = "http://+:58008/MSDeploy/"
	$InstallCmdArgs = "/I `"$InstallPkg`" ADDLOCAL=ALL LISTENURL=$listenURL /qb /norestart"
	$AppName = "Web Deployment Tool"
	$AppVersion = "1.1.0618"
	$ServiceName = "MsDepSvc"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
	# this will be uncommented later
	#Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Services\MsDepSvc\Parameters" -Property "ListenUrl" -Value $listenURL -PropertyType String
	
	Check-EnvPath -PathEntry "C:\Program Files\IIS\Microsoft Web Deploy\"
	
	Check-Service -Name $ServiceName -StartupType "automatic" -ForceStartStop
}

# Check MSDeploy 1.1 Uninstall
# -checked-
#################################################
function Check-MSDeploy11-Uninstall()
{
	$AppName = "Web Deployment Tool"
	$ServiceName = "MsDepSvc"
	
	# Uninstall application
	Check-AppUninstall -AppName $AppName
	
	# Removing environment path
	Check-EnvPath -PathEntry "C:\Program Files\IIS\Microsoft Web Deploy\" -Remove
	
	# Restarting the service
	Check-Service -Name $ServiceName -StartupType "automatic" -ForceStartStop
}

# Check MSDeploy 3.5
# -checked-
#################################################

function Check-MSDeploy35()
{
	# We use WebDeploy 3.5
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\WebDeploy\3.5\WebDeploy3.5_x64_en-US.msi"
	$InstallCmd = "msiexec"
	$listenURL = "http://+:58008/MSDeploy/"
	$InstallCmdArgs = "/I `"$InstallPkg`" ADDLOCAL=ALL LISTENURL=$listenURL /qb /norestart"
	$AppName = "Microsoft Web Deploy 3.5"
	$AppVersion = "3.1237.1764"
	$ServiceName = "MsDepSvc"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
	# this will be uncommented later
	# Check-RegistrySetting -Path "HKLM:\System\CurrentControlSet\Services\MsDepSvc\Parameters" -Property "ListenUrl" -Value $listenURL -PropertyType String
	
	Check-EnvPath -PathEntry "C:\Program Files\IIS\Microsoft Web Deploy V3\"
	
	Check-Service -Name $ServiceName -StartupType "automatic" -ForceStartStop
}

# Check LogParser22
# -checked-
#################################################
function Check-LogParser22()
{
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\LogParser\LogParser.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /qb /norestart"
	$AppName = "Log Parser 2.2"
	$AppVersion = "2.2.10"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}


# Check MSXML 4.0 SP3 Parser
# -checked-
#################################################
function Check-MSXMLParser40SP3()
{
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSXML\4.0sp3\msxml.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /qb /norestart REBOOT=REALLYSUPPRESS"
	$AppName = "MSXML 4.0 SP3 Parser"
	$AppVersion = "4.30.2100.0"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}

#Check MSXMLParser40SP3 and KB's uninstalled (see https://jira.monster.com:8443/browse/PRODENG-270)
function Check-MSXMLParser40SP3-Uninstall()
{
	$AppNames = "MSXML 4.0 SP3 Parser (KB973685)","MSXML 4.0 SP3 Parser (KB2721691)","MSXML 4.0 SP3 Parser (KB2758694)","MSXML 4.0 SP3 Parser"
    foreach($AppName in $AppNames)
    {
        Check-AppUninstall -AppName $AppName
    }
}

# Check Safenet 5.1.1 (32 and 64 bit) x64 if you want 64bit otherwise 32-bit is default
# Example of 32-bit: Check-Safenet511
# Example of 64-bit: Check-Safenet511 x64
# -checked-
#################################################
function Check-Safenet511([string]$SafeNetBit = "x86", [bool]$SafeNetLegacy = $false)
{
	
	# 2a. Prep before uninstall
	$OLDAppPath = Get-InstalledAppLocation -AppName "Ingrian Provider for .NET"
	
	# 1. Check old version of SafeNet and remove if flag is set to uninstall
	Check-AppUninstall -AppName "Ingrian Provider for .NET" # previous version of Safenet
	
	# 2b. Remove old SafeNet/Ingrian paths, if they exist
	if ($OLDAppPath)
	{
		$OLDAppPath = $OLDAppPath.TrimEnd("\")
		Check-EnvPath -PathEntry "$AppPath\FIPS" -Remove
	}
	
	#2c. Remove 32 bit if 64 is desired
	if ($SafeNetBit -eq "x64")
	{
		Check-AppUninstall -AppName "SafeNet ProtectApp for .NET 32 bit"
	}
	
	# 3. Install SafeNet new version, if installed
	if ($SafeNetBit -eq "x64")
	{
		$InstallPkg = "$Script:StoragePath\3pty\SafeNet\5.1.1\611-009849-002_datasecure_protectapp_dotnet_64bit_windows_v5.1.1.010-004.msi"
		$AppName = "SafeNet ProtectApp for .NET 64 bit"
	}
	else
	{
		$InstallPkg = "$Script:StoragePath\3pty\SafeNet\5.1.1\611-009849-001_datasecure_protectapp_dotnet_32bit_windows_v5.1.1.010-004.msi"
		$AppName = "SafeNet ProtectApp for .NET 32 bit"
	}
	
#	if($Env:computername -match "FTP" -or $Env:computername -match "JOBVIEW" -or $Env:computername -match "LOGS" -or $Env:computername -match "CANAPP" -or $Env:computername -match "CANBATCH" -or $Env:computername -match "CANDB" -or $Env:computername -match "CANRPTDB" -or $Env:computername -match "CACHE" -or $Env:computername -match "JBATA")
#	{
#		Write-Log -Message "       This machine doesn't need SafeNet"
#	}
	
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /qb /norestart"
	$AppVersion = "5.1.1.010.004"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
	
	# 4. Copy .crt and IngrianNAE.properties based on where we find SafeNet installed AND depending on the server type: DEV/QA/PROD and Data Center
	# 5. Add path if it's not there
	# 6. Setup permission for Network Service
	# 7. machine.config
	$AppPath = Get-InstalledAppLocation -AppName $AppName
	if ($AppPath)
	{
		$AppPath = $AppPath.TrimEnd("\")
		$NetworkPath = "$Script:StoragePath\3pty\SafeNet\5.1.1"
		
		# 4
		# Location of Config/Cert files
		
		# Maynard production
		if ($Script:DataCenter -eq "Maynard")
		{
			$CertFile = "prod_sn8_client2016.crt"
			$SafeNetCertFile = "$NetworkPath\client_prod\$CertFile"
			$propFilewithx86 = "$NetworkPath\client_prod\may\IngrianNAE.properties"
			$propFilewithoutx86 = "$NetworkPath\client_prod\may\IngrianNAE.properties.i64"
		}
		# Bedford
		elseif ($Script:DataCenter -eq "Bedford")
		{
			if ($Script:Environment -eq "QA")
			{
				$CertFile = "qa_sn8_client2016.crt"
				$SafeNetCertFile = "$NetworkPath\client_qa\$CertFile"
				$propFilewithx86 = "$NetworkPath\client_qa\IngrianNAE.properties.withX86"
				$propFilewithoutx86 = "$NetworkPath\client_qa\IngrianNAE.properties.withoutX86"
			}
			elseif ($Script:Environment -eq "DEV")
			{
				$CertFile = "dev_sn8_client2016.crt"
				$SafeNetCertFile = "$NetworkPath\client_dev\$CertFile"
				$propFilewithx86 = "$NetworkPath\client_dev\IngrianNAE.properties.i64"
				$propFilewithoutx86 = "$NetworkPath\client_dev\IngrianNAE.properties.x86"
			}
			else # Production
			{
                if ($SafeNetLegacy)
                {
                    $CertFile = "prod-sn-km-client.crt"
                    $propFilewithx86 = "$NetworkPath\client_prod\bed\IngrianNAE.properties.legacy"
                    $propFilewithoutx86 = "$NetworkPath\client_prod\bed\IngrianNAE.properties.i64.legacy"
                }
                else
                {
                    $CertFile = "prod_sn8_client2016.crt"
                    $propFilewithx86 = "$NetworkPath\client_prod\bed\IngrianNAE.properties"
                     $propFilewithoutx86 = "$NetworkPath\client_prod\bed\IngrianNAE.properties.i64"
                }
                
                $SafeNetCertFile = "$NetworkPath\client_prod\$CertFile"
               
			}
		}
		# Swindon/Bristol
		elseif ($Script:DataCenter -eq "Swindon") 
		{
			if ($Script:EnvironmentType -eq "DWP_QA1")
			{
				$CertFile = "qa1-sn-km-ca801.crt"
				$SafeNetCertFile = "$NetworkPath\client_qa1_dwp\$CertFile"
				$propFilewithx86 = "$NetworkPath\client_qa1_dwp\IngrianNAE.properties.withX86"
				$propFilewithoutx86 = "$NetworkPath\client_qa1_dwp\IngrianNAE.properties.withoutX86"
			}
			elseif ($Script:EnvironmentType -eq "DWP_QA2")
			{
				$CertFile = "Monster-Internal-DWP-CA.crt"
				$SafeNetCertFile = "$NetworkPath\client_qa2_dwp\$CertFile"
				$propFilewithx86 = "$NetworkPath\client_qa2_dwp\IngrianNAE.properties.withX86"
				$propFilewithoutx86 = "$NetworkPath\client_qa2_dwp\IngrianNAE.properties.withoutX86"
			}
			 else # Production Swindon
        {
                $CertFile = "Monster-Internal-DWP-CA.crt"
                $SafeNetCertFile = "$NetworkPath\client_prod_dwp\Swindon\$CertFile"
                $propFilewithx86 = "$NetworkPath\client_prod_dwp\Swindon\IngrianNAE.properties.withX86"
                $propFilewithoutx86 = "$NetworkPath\client_prod_dwp\Swindon\IngrianNAE.properties.withoutX86"
        }
        }
        # Bristol Production
        elseif ($Script:DataCenter -eq "Bristol")
        {
                $CertFile = "Monster-Internal-DWP-CA.crt"
                $SafeNetCertFile = "$NetworkPath\client_prod_dwp\Bristol\$CertFile"
                $propFilewithx86 = "$NetworkPath\client_prod_dwp\Bristol\IngrianNAE.properties.withX86"
				$propFilewithoutx86 = "$NetworkPath\client_prod_dwp\Bristol\IngrianNAE.properties.withoutX86"
        }
        # South Boston production
        elseif ($Script:DataCenter -eq "South Boston")
        {
            if ($SafeNetLegacy)
            {
                $CertFile = "prod-sn-km-client.crt"
                $propFilewithx86 = "$NetworkPath\client_prod\sb\IngrianNAE.properties.legacy"
                $propFilewithoutx86 = "$NetworkPath\client_prod\sb\IngrianNAE.properties.i64.legacy"
            }
            else
            {
                $CertFile = "prod_sn8_client2016.crt"
                $propFilewithx86 = "$NetworkPath\client_prod\sb\IngrianNAE.properties"
                $propFilewithoutx86 = "$NetworkPath\client_prod\sb\IngrianNAE.properties.i64"
            }
                
                $SafeNetCertFile = "$NetworkPath\client_prod\$CertFile"
        }
		
		# Now, depending on where SafeNet folder sits, we need to copy files accordingly (because the prop file has hard coded path to cert file)
		if (Test-Path -Path "$AppPath\DotNet\ingdnp.dll")
		{
			Check-File -TargetFile "$AppPath\DotNet\$CertFile" -SourceFile $SafeNetCertFile

			if ($SafeNetBit -eq "x64")
			{
				Check-File -TargetFile "$AppPath\DotNet\IngrianNAE.properties" -SourceFile $propFilewithoutx86
			}
			else
			{
				Check-File -TargetFile "$AppPath\DotNet\IngrianNAE.properties" -SourceFile $propFilewithx86
			}
		}
		else
		{
			Write-Log -Message "Can't find SafeNet, skipping files check." -EntryType "WARNING" 
		}
		
		
		# 5
		# Application is installed, we have path
		Check-EnvPath -PathEntry "$AppPath\FIPS"
		
		# 6
		Check-Permissions $AppPath -Permissions "NT AUTHORITY\NETWORK SERVICE:(OI)(CI)(R)"
		
		# 7
		# adding Safenet stuff into machine configs
		$ConfigPaths = (
			"c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config", 
			"c:\WINDOWS\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config",
			"C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\Config\machine.config", 
			"C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"
		)
		
		# part of # 7
		foreach ($config in $ConfigPaths)
		{
			if (Test-Path $config)
			{
				Write-Log -Message "Checking config $config"
				
				Check-XmlProperty -XmlPath $config -ElementXpath '/configuration/runtime/ns:assemblyBinding' -NameSpaces @{"ns" = "urn:schemas-microsoft-com:asm.v1"}
				
				Check-XmlProperty -XmlPath $config -ElementXpath '/configuration/runtime/ns:assemblyBinding/ns:dependentAssembly' -NameSpaces @{"ns" = "urn:schemas-microsoft-com:asm.v1"}
				
				Check-XmlProperty -XmlPath $config -ElementXpath '/configuration/runtime/ns:assemblyBinding/ns:dependentAssembly/ns:assemblyIdentity' -Attribute name -Value "ingdnp" -NameSpaces @{"ns" = "urn:schemas-microsoft-com:asm.v1"}
				Check-XmlProperty -XmlPath $config -ElementXpath '/configuration/runtime/ns:assemblyBinding/ns:dependentAssembly/ns:assemblyIdentity' -Attribute publicKeyToken -Value "c73d618bb0b678e0" -NameSpaces @{"ns" = "urn:schemas-microsoft-com:asm.v1"}
				Check-XmlProperty -XmlPath $config -ElementXpath '/configuration/runtime/ns:assemblyBinding/ns:dependentAssembly/ns:assemblyIdentity' -Attribute culture -Value "neutral" -NameSpaces @{"ns" = "urn:schemas-microsoft-com:asm.v1"}
				
				Check-XmlProperty -XmlPath $config -ElementXpath '/configuration/runtime/ns:assemblyBinding/ns:dependentAssembly/ns:bindingRedirect' -Attribute oldVersion -Value "0.0.0.0-5.1.1.10004" -NameSpaces @{"ns" = "urn:schemas-microsoft-com:asm.v1"}
				Check-XmlProperty -XmlPath $config -ElementXpath '/configuration/runtime/ns:assemblyBinding/ns:dependentAssembly/ns:bindingRedirect' -Attribute newVersion -Value "5.1.1.10004" -NameSpaces @{"ns" = "urn:schemas-microsoft-com:asm.v1"}
			}
		}
	}
}

# Check Java 7 Safenet 5.1.1 
# -checked-
#################################################
function Check-Java7-SafeNet511([bool]$SafeNetLegacy = $false)
{
	Write-Log
	Write-Log -Message "Checking Java SafeNet..."
	Write-Log
	
	if ( test-path "$($env:JAVA_HOME)\jre" )
	{
		$JRE_HOME =  "$([System.Environment]::GetEnvironmentVariable("JAVA_HOME","Machine"))\jre"
	}
	else
	{
		$JRE_HOME = "$([System.Environment]::GetEnvironmentVariable("JAVA_HOME","Machine"))"
	}

	Write-Log -Message "JRE_HOME: $JRE_HOME"
	
    Write-Log
	Write-Log -Message "Checking library files..."
	Write-Log
    $SourceZip = "$Script:StoragePath\3pty\SafeNet\5.1.1\java_install\lib.security.7.zip"
	$TargetDir = "$JRE_HOME\lib\security"
	Check-MSDeployZip -SourceZip $SourceZip -TargetDir $TargetDir
	Write-Log
	Write-Log -Message "Checking security files..."
	Write-Log
	
	
    $SourceZip = "$Script:StoragePath\3pty\SafeNet\5.1.1\java_install\lib.ext.zip"
	$TargetDir = "$JRE_HOME\lib\ext"

	Check-MSDeployZip -SourceZip $SourceZip -TargetDir $TargetDir
    $NetworkPath = "$Script:StoragePath\3pty\SafeNet\5.1.1"
    # Location of Config/Cert files
		
	# Bedford
    if ($Script:DataCenter -eq "Bedford")
    {
        if ($Script:Environment -eq "QA")
        {
            $CertFile = "qa_sn8_client2016.crt"
            $SafeNetCertFile = "$NetworkPath\client_qa\$CertFile"
            $propFilewithjava = "$NetworkPath\client_qa\IngrianNAE.properties.java.windows"
        }
        elseif ($Script:Environment -eq "DEV")
        {
            $CertFile = "dev_sn8_client2016.crt"
            $SafeNetCertFile = "$NetworkPath\client_dev\$CertFile"
            $propFilewithjava = "$NetworkPath\client_dev\IngrianNAE.properties.java.windows"
        }
        else # Production
        {
            if ($SafeNetLegacy)
            {
                $CertFile = "prod-sn-km-client.crt"
                $propFilewithjava = "$NetworkPath\client_prod\bed\IngrianNAE.properties.java.windows.legacy"
            }
            else
            {
                $CertFile = "prod_sn8_client2016.crt"
                $propFilewithjava = "$NetworkPath\client_prod\bed\IngrianNAE.properties.java.windows"
            }
                
            $SafeNetCertFile = "$NetworkPath\client_prod\$CertFile"
        }
    }
    # Swindon
    elseif ($Script:DataCenter -eq "Swindon") 
    {
        if ($Script:EnvironmentType -eq "DWP_QA1")
        {
            $CertFile = "qa1-sn-km-ca801.crt"
            $SafeNetCertFile = "$NetworkPath\client_qa1_dwp\$CertFile"
            $propFilewithjava = "$NetworkPath\client_qa1_dwp\IngrianNAE.properties.java.windows"
        }
        elseif ($Script:EnvironmentType -eq "DWP_QA2")
        {
            $CertFile = "Monster-Internal-DWP-CA.crt"
            $SafeNetCertFile = "$NetworkPath\client_qa2_dwp\$CertFile"
            $propFilewithjava = "$NetworkPath\client_qa2_dwp\IngrianNAE.properties.java.windows"
        }
        else # Production Swindon
        {
            $CertFile = "Monster-Internal-DWP-CA.crt"
            $SafeNetCertFile = "$NetworkPath\client_prod_dwp\Swindon\$CertFile"
            $propFilewithjava = "$NetworkPath\client_prod_dwp\Swindon\IngrianNAE.properties.java.windows"
        }
    }
    # Bristol Production
    elseif ($Script:DataCenter -eq "Bristol")
    {
            $CertFile = "Monster-Internal-DWP-CA.crt"
            $SafeNetCertFile = "$NetworkPath\client_prod_dwp\Bristol\$CertFile"
            $propFilewithjava = "$NetworkPath\client_prod_dwp\Bristol\IngrianNAE.properties.java.windows"
    }
    # South Boston production
    elseif ($Script:DataCenter -eq "South Boston")
    {
        if ($SafeNetLegacy)
            {
                $CertFile = "prod-sn-km-client.crt"
                $propFilewithjava = "$NetworkPath\client_prod\sb\IngrianNAE.properties.java.windows.legacy"
            }
            else
            {
                $CertFile = "prod_sn8_client2016.crt"
                $propFilewithjava = "$NetworkPath\client_prod\sb\IngrianNAE.properties.java.windows"
            }
                
            $SafeNetCertFile = "$NetworkPath\client_prod\$CertFile"
    }
    
    # Now, depending on where SafeNet folder sits, we need to copy files accordingly (because the prop file has hard coded path to cert file)
    if (Test-Path -Path "$JRE_HOME\lib\ext\IngrianNAE-5.1.1.jar")
    {
        Check-File -TargetFile "$JRE_HOME\lib\ext\$CertFile" -SourceFile $SafeNetCertFile
        Check-File -TargetFile "$JRE_HOME\lib\ext\IngrianNAE.properties" -SourceFile $propFilewithjava
    }
    else
    {
        Write-Log -Message "Can't find SafeNet for Java 64, skipping files check." -EntryType "WARNING" 
    }

    $alias = $CertFile.split(".")[0]
    $currentLocation= pwd
    set-location "$JRE_HOME\bin"
    $Result =  .\keytool.exe -list -keystore ..\lib\security\cacerts -storepass changeit | select-string -pattern $alias  | select -last 1
    $Result
    if ($Result -imatch $alias)
    {
        Write-Log -Message "-> Java Safenet cert : $alias found " -ResultOK -ResultMessage "success"
    }
    else
    {
        if (-not $Script:ValidateOnly)
        {            
            .\keytool -import -keystore ..\lib\security\cacerts -storepass changeit -alias $alias -file "$JRE_HOME\lib\ext\$CertFile" 
        }
        else
        {
            Write-Log -Message ("Java Safenet Certs: "+$alias ) -Category "Java SafeNet" -ResultFailure -ResultMessage "Missing"
        }
    }
    cd $currentLocation
}



# Check Java 8 Safenet 5.1.1 
# -checked-
#################################################
function Check-Java8-SafeNet511()
{
	Write-Log
	Write-Log -Message "Checking Java1.8 for SafeNet..."
	Write-Log
	
	$TempPolicyFolder = "d:\temp\jce-policy-8"
	$TempSecurityFolder = "d:\temp\jce-security-8"
	
	if ( test-path "$($env:JAVA_HOME)\jre" )
	{
		$JRE_HOME =  "$($env:JAVA_HOME)\jre"
	}
	else
	{
		$JRE_HOME = "$($env:JAVA_HOME)"
	}

	Write-Log -Message "JRE_HOME: $JRE_HOME"
	
	$SaveValidOnly = $Script:ValidateOnly
	
	#temporarily set the validateOnly flag to false to fetch the kits locally
	$Script:ValidateOnly = $false
		
	Write-Log
	Write-Log -Message "Getting local copy of jce_policy-8.zip to compare against $JRE_HOME\lib\security..."
	Write-Log
	$SourceZip = "$Script:StoragePath\3pty\SafeNet\5.1.1\java_install\jce_policy-8.zip"
	$TargetDir = "$TempPolicyFolder"
	Check-MSDeployZip -SourceZip $SourceZip -TargetDir $TargetDir
	Write-Log
	Write-Log
	
	Write-Log
	Write-Log -Message "Getting local copy of lib.security.8.zip to compare against $JRE_HOME\lib\security..."
	Write-Log
	$SourceZip = "$Script:StoragePath\3pty\SafeNet\5.1.1\java_install\lib.security.8.zip"
	$TargetDir = "$TempSecurityFolder"
	Check-MSDeployZip -SourceZip $SourceZip -TargetDir $TargetDir
	Write-Log
	Write-Log

	
	## set the validate only flag back to its original state
	$Script:ValidateOnly = $SaveValidOnly

	if ( $Script:ValidateOnly -eq $false )
	{
		Write-Log -Message "backing up current java policy files.."	
		Check-File  "$JRE_HOME\lib\security\local_policy.jar_old"   "$JRE_HOME\lib\security\local_policy.jar"
		Check-File "$JRE_HOME\lib\security\US_export_policy.jar_old"  "$JRE_HOME\lib\security\US_export_policy.jar"
	}
	
	Write-Log
	Write-Log -Message "Checking contents of jce_policy-8.zip  against $JRE_HOME\lib\security..."

	Check-File "$JRE_HOME\lib\security\local_policy.jar" 		"$TempPolicyFolder\UnlimitedJCEPolicyJDK8\local_policy.jar" 
	Check-File "$JRE_HOME\lib\security\US_export_policy.jar" 	"$TempPolicyFolder\UnlimitedJCEPolicyJDK8\US_export_policy.jar" 
	
	
	if ( $ValidateOnly -eq $false )
	{
			Write-Log -Message "backing up current java security files.."
			Check-File "$JRE_HOME\lib\security\java.security_old"   "$JRE_HOME\lib\security\java.security"

	}
	
	Write-Log
	Write-Log -Message "Checking contents of lib.security.8.zip against $JRE_HOME\lib\security..."
	Write-Log
	Check-File "$JRE_HOME\lib\security\java.security"   "$TempSecurityFolder\java.security" 
	
	Write-Log
	Write-Log -Message "Checking contents of lib.ext.zip against $JRE_HOME\lib\ext..."
	Write-Log
    $SourceZip = "$Script:StoragePath\3pty\SafeNet\5.1.1\java_install\lib.ext.zip"
	$TargetDir = "$JRE_HOME\lib\ext"

	Check-MSDeployZip -SourceZip $SourceZip -TargetDir $TargetDir
	
	
    $NetworkPath = "$Script:StoragePath\3pty\SafeNet\5.1.1"
    # Location of Config/Cert files
		
	# Bedford
    if ($Script:DataCenter -eq "Bedford")
    {
        if ($Script:Environment -eq "QA")
        {
            $CertFile = "qa_sn8_client2016.crt"
            $SafeNetCertFile = "$NetworkPath\client_qa\$CertFile"
            $propFilewithjava = "$NetworkPath\client_qa\IngrianNAE.properties.java.windows"
        }
        elseif ($Script:Environment -eq "DEV")
        {
            $CertFile = "dev_sn8_client2016.crt"
            $SafeNetCertFile = "$NetworkPath\client_dev\$CertFile"
            $propFilewithjava = "$NetworkPath\client_dev\IngrianNAE.properties.java.windows"
        }
        else # Production
        {
            $CertFile = "prod_sn8_client2016.crt"
            $SafeNetCertFile = "$NetworkPath\client_prod\$CertFile"
            $propFilewithjava = "$NetworkPath\client_prod\bed\IngrianNAE.properties.java.windows"
        }
    }
    # Swindon
    elseif ($Script:DataCenter -eq "Swindon") 
    {
        if ($Script:EnvironmentType -eq "DWP_QA1")
        {
            $CertFile = "qa1-sn-km-ca801.crt"
            $SafeNetCertFile = "$NetworkPath\client_qa1_dwp\$CertFile"
            $propFilewithjava = "$NetworkPath\client_qa1_dwp\IngrianNAE.properties.java.windows"
        }
        elseif ($Script:EnvironmentType -eq "DWP_QA2")
        {
            $CertFile = "Monster-Internal-DWP-CA.crt"
            $SafeNetCertFile = "$NetworkPath\client_qa2_dwp\$CertFile"
            $propFilewithjava = "$NetworkPath\client_qa2_dwp\IngrianNAE.properties.java.windows"
        }
        else # Production Swindon
        {
            $CertFile = "Monster-Internal-DWP-CA.crt"
            $SafeNetCertFile = "$NetworkPath\client_prod_dwp\Swindon\$CertFile"
            $propFilewithjava = "$NetworkPath\client_prod_dwp\Swindon\IngrianNAE.properties.java.windows"
        }
    }
    # Bristol Production
    elseif ($Script:DataCenter -eq "Bristol")
    {
            $CertFile = "Monster-Internal-DWP-CA.crt"
            $SafeNetCertFile = "$NetworkPath\client_prod_dwp\Bristol\$CertFile"
            $propFilewithjava = "$NetworkPath\client_prod_dwp\Bristol\IngrianNAE.properties.java.windows"
    }
    # South Boston production
    elseif ($Script:DataCenter -eq "South Boston")
    {
        $CertFile = "prod_sn8_client2016.crt"
        $SafeNetCertFile = "$NetworkPath\client_prod\$CertFile"
        $propFilewithjava = "$NetworkPath\client_prod\sb\IngrianNAE.properties.java.windows"
    }
    
    # Now, depending on where SafeNet folder sits, we need to copy files accordingly (because the prop file has hard coded path to cert file)
    if (Test-Path -Path "$JRE_HOME\lib\ext\IngrianNAE-5.1.1.jar")
    {
        Check-File -TargetFile "$JRE_HOME\lib\ext\$CertFile" -SourceFile $SafeNetCertFile
        Check-File -TargetFile "$JRE_HOME\lib\ext\IngrianNAE.properties" -SourceFile $propFilewithjava
    }
    else
    {
        Write-Log -Message "Can't find SafeNet for Java 64, skipping files check." -EntryType "WARNING" 
    }

	# Make the cert file modifiable.
	Write-Log
	Write-Log -Message "Checking that cacerts file is not read only..."

	
	$file = Get-Item "$JRE_HOME\lib\security\cacerts"
	if ($file.IsReadOnly -eq $true)  
	{  
		Write-Log -Message "...File:$file is read only..." -ResultFailure -ResultMessage "Not OK"
		if ( $Script:ValidateOnly -eq $false )
		{
			Write-Log -Message "...File:$file is read only..." -ResultFailure -ResultFailure "updating"
			$file.IsReadOnly = $false  
			if ($file.IsReadOnly -eq $false)
			{
				Write-Log -Message "...File:$file now not readonly..." -ResultOK -ResultMessage "success"
			}
			else
			{
				Write-Log -Message "...Could not make File:$file readonly..." -ResultFailure -ResultMessage "ERROR"
			}			
		}
	}
	else
	{
		Write-Log -Message "...File:$file is NOT read only..." -ResultOK -ResultMessage "success"
	}
	Write-Log
	
    $alias = $CertFile.split(".")[0]
    $currentLocation= pwd
    set-location "$JRE_HOME\bin"
    $Result =  .\keytool.exe -list -keystore ..\lib\security\cacerts -storepass changeit | select-string -pattern $alias  | select -last 1
    $Result
    if ($Result -imatch $alias)
    {
        Write-Log -Message "-> Java Safenet cert : $alias found " -ResultOK -ResultMessage "success"
    }
    else
    {
        if (-not $Script:ValidateOnly)
        {            
            .\keytool -import -keystore ..\lib\security\cacerts -storepass changeit -alias $alias -file "$JRE_HOME\lib\ext\$CertFile" 
        }
        else
        {
            Write-Log -Message ("Java Safenet Certs: "+$alias ) -Category "Java SafeNet" -ResultFailure -ResultMessage "Missing"
        }
    }
    cd $currentLocation
}


# Check dotNetv4
# -checked-
#################################################
function Check-dotNetv4()
{
	function Check-dotNetCert-InnerCheck([string]$CertName, [string]$CertLocation)
	{
		# Check to see if cert's install and install if ValidateOnly is set to true and only if it's not installed
		$Result = certutil -store | select-string -pattern $CertName | select -Last 1
		if ($Result -match $CertName)
		{
			Write-Log -Message $CertName -Category "CERT" -ResultOK -ResultMessage "installed"
		}
		else
		{
			if ($Script:ValidateOnly)
			{
				Write-Log -Message $CertName -Category "CERT" -ResultFailure -ResultMessage "not installed"
			}
			else
			{
				Write-Log -Message $CertName -Category "CERT" -ResultFailure -ResultMessage "not installed (to be installed)"
				
				# Install it and store results in $tmp variable, we don't want to see any of it
				$tmp = certutil -addstore CA $CertLocation
				Start-Sleep 1	
				if ((certutil -store | select-string -pattern $CertName | select -Last 1) -match $CertName)
				{
					Write-Log -Message "-> installing '$CertName' from '$CertLocation'" -ResultOK -ResultMessage "success"
				}
				else
				{
					Write-Log -Message "-> installing '$CertName' from '$CertLocation'" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
				}
			}
		}
	}
	
	Write-Log
	Write-Log -Message "Checking certificates required to install dotNET v4..."
	Write-Log
	
	# Certs - make sure they are installed before we do anything
	$CertName = "Microsoft Code Signing PCA"
	$CertLocation = "$Script:StoragePath\3pty\Microsoft\.NET\v4.0\CSPCA.crl"
	Check-dotNetCert-InnerCheck -CertName $CertName -CertLocation $CertLocation
	
	$CertName = "Microsoft Timestamping PCA"
	$CertLocation = "$Script:StoragePath\3pty\Microsoft\.NET\v4.0\tspca.crl"
	Check-dotNetCert-InnerCheck -CertName $CertName -CertLocation $CertLocation
		
	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\.NET\v4.0\dotNetFx40_Full_x86_x64.exe"
	$AppName = "Microsoft .NET Framework 4 Extended"
	$AppVersion = "4.0.30319"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check dotNetv45
# -checked-
#################################################
function Check-dotNetv45()
{
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\.NET\v4.5\dotnetfx45_full_x86_x64.exe"
	$AppName = "Microsoft .NET Framework 4.5"
	$AppVersion = "4.5.50709"	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# dotnetv46
#################################################
function Check-dotNetv46()
{
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\.NET\v4.6\NDP46-KB3045557-x86-x64-AllOS-ENU.exe"
	$AppName = "Microsoft .NET Framework 4.6"
	$AppVersion = "4.6.00081"	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# dotnetv461
#################################################
function Check-dotNetv461()
{
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\.NET\v4.6.1\NDP461-KB3102436-x86-x64-AllOS-ENU.exe"
	$AppName = "Microsoft .NET Framework 4.6.1"
	$AppVersion = "4.6.01055"	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check dotNetv4 with hotfix
#################################################
function Check-dotNetv4withHotfix()
{
	$AppName = "Microsoft .NET Framework 4 Extended"
	$version = Get-InstalledAppVersion -appname $appname
	if ($version -eq "4.0.30320")
	{
		Write-Log -Message " Version of .NET 4 $($version) meets or exceeds requirements"  -ResultOK -ResultMessage "Good Enough"
	}
	elseif ($version -eq "4.0.30319")
	{
		Write-Log -Message " Version of .NET 4 $($version) meets or exceeds requirements"  -ResultOK -ResultMessage "Good Enough"
		Check-HFKB2540745
	} 
	else
	{
		Check-dotNetv4
	}
}


# Check MVC v2
# -checked-
#################################################
function Check-MVC2()
{	
	# Application itself 
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MVC\v2\aspnetmvc2.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /quiet /norestart"
	$AppName = "Microsoft ASP.NET MVC 2"
	$AppVersion = "2.0.50217.0"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}

# Check MVC v2 with hotfix KB2990942
# -checked-
#################################################
function Check-MVC2Hotfix()
{      
       # Application itself 
       $InstallPkg = "$Script:StoragePath\3pty\Microsoft\MVC\v3\AspNetMVC2-KB2990942.msi"
       $InstallCmd = "msiexec"
       $InstallCmdArgs = "/I `"$InstallPkg`" /quiet /norestart"
       $HotFixName = "Microsoft ASP.NET MVC 2"
       $HotFixVersion = "2.0.60814.0"
       
       Check-HotFix -HotFixName $HotFixName -HotFixVersion $HotFixVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
} 

# Check MVC v3
# -checked-
#################################################
function Check-MVC3()
{	
	# Application itself 
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MVC\v3\AspNetMVC3ToolsUpdateSetup.exe"
	$AppName = "Microsoft ASP.NET MVC 3"
	$AppVersion = "3.0.20105.0"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check MVC v3 with hotfix KB2990942
# -checked-
#################################################
function Check-MVC3Hotfix()
{      
       # Application itself 
       $InstallPkg = "$Script:StoragePath\3pty\Microsoft\MVC\v3\AspNetMVC3-KB2990942.msi"
       $InstallCmd = "msiexec"
       $InstallCmdArgs = "/I `"$InstallPkg`" /quiet /norestart"
       $HotFixName = "Microsoft ASP.NET MVC 3"
       $HotFixVersion = "3.0.50813.0"
       
       Check-HotFix -HotFixName $HotFixName -HotFixVersion $HotFixVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
} 


# Check MVC v3 Uninstall
# -checked-
#################################################
function Check-MVC3-Uninstall()
{
	$AppName = "Microsoft ASP.NET MVC 3"
    Check-AppUninstall -AppName $AppName
}


# Check MVC v4
# -checked-
#################################################
function Check-MVC4()
{	
	# Application itself 
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MVC\v4\AspNetMVC4Setup.exe"
	$AppName = "Microsoft ASP.NET MVC 4"
	$AppVersion = "4.0.20714.0"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}


# Check MVC v4 with hotfix KB2990942
# -checked-
#################################################
function Check-MVC4Hotfix()
{	
    # Application itself
       $InstallPkg = "$Script:StoragePath\3pty\Microsoft\MVC\v4\AspNetMVC4.msi"
       $InstallCmd = "msiexec"
       $InstallCmdArgs = "/I `"$InstallPkg`" /quiet /norestart"
       $HotFixName = "Microsoft ASP.NET MVC 4 Runtime"
       $HotFixVersion = "4.0.40804.0"
       
       Check-HotFix -HotFixName $HotFixName -HotFixVersion $HotFixVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs 
}

# Check Microsoft ASP.NET Web Pages
# -checked-
##################################################
function Check-ASP.NET-Web-Pages()
{
  Write-Log
	Write-Log -Message "Checking Microsoft ASP.NET Web Pages Package ..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\AspNetWebPages\AspNetWebPages.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /quiet /norestart"
	$AppName = "Microsoft ASP.NET Web Pages"
	$AppVersion = "1.0.20105.0"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}

# Check ScaleoutClient 4.2.22
# -notchecked-
#################################################
function Check-ScaleoutClient-4-2-22()
{
	# 64bit client
	$InstallPkg = "$Script:StoragePath\3pty\ScaleOut\v_4.2.22.186\64BIT_Installs\64BIT_NET40\soss_setup64_net40.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /qb /norestart INSTALLTYPE=2"
	$AppName = "ScaleOut StateServer x64 Edition"
	$AppVersion = "4.2.22"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
	# 32bit client libraries
	$InstallPkg = "$Script:StoragePath\3pty\ScaleOut\v_4.2.22.186\64BIT_Installs\64BIT_NET40\soss_setup32LibsOn64_net40.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /qb /norestart"
	$AppName = "ScaleOut StateServer 32-bit Client Libraries"
	$AppVersion = "4.2.22"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}


# Check ActivePerl 5.10.1007
# -checked-
#################################################
function Check-ActivePerl-5-10-1007()
{
	$InstallPkg = "$Script:StoragePath\3pty\ActiveState\Perl\OtherVersions\ActivePerl-5.10.1.1007-MSWin32-x86-291969.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /qb /norestart TARGETDIR=`"d:\`" PERL_PATH=`"Yes`" PERL_EXT=`"Yes`" PL_IISMAP=`"Yes`""
	$AppName = "ActivePerl 5.10.1 Build 1007"
	$AppVersion = "5.10.1007"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
	Check-EnvPath -PathEntry "d:\Perl\site\bin"
	Check-EnvPath -PathEntry "d:\Perl\bin"
}


# Check ActivePerl 5.8.8.822
# -checked-
#################################################
function Check-ActivePerl-5-8-8-822()
{
	# Install ActivePerl-5.8.8.822
	$InstallPkg = "$Script:StoragePath\3pty\ActiveState\Perl\OtherVersions\ActivePerl-5.8.8.822-MSWin32-x86-280952.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /qb /norestart TARGETDIR=`"d:\`" PERL_PATH=`"Yes`" PERL_EXT=`"Yes`" PL_IISMAP=`"Yes`""
	$AppName = "ActivePerl 5.8.8 Build 822"
	$AppVersion = "5.8.822"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
	Check-EnvPath -PathEntry "d:\Perl\site\bin"
	Check-EnvPath -PathEntry "d:\Perl\bin"
}


# Check Microsoft AppFabric
# -checked-
#################################################
function Check-MSAppFabric()
{	
	# Application itself 
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\AppFabric\WindowsServerAppFabricSetup_x64_6.1.exe"
	$KB = "KB970622"
	$AppName = "Microsoft AppFabric $KB"
	
	# Check to see if KB's install and install if ValidateOnly is set to true and only if it's not installed
	$Result = Get-WmiObject -Query 'select * from Win32_QuickFixEngineering' | where {$_.HotFixID -Like $KB }
	if ($Result -ne $null)
	{
		Write-Log -Message $AppName -Category "KB" -ResultOK -ResultMessage "installed"
	}
	else
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message $AppName -Category "KB" -ResultFailure -ResultMessage "not installed"
		}
		else
		{
			Write-Log -Message $AppName -Category "KB" -ResultFailure -ResultMessage "not installed (to be installed)"
			
			# Install KB with default options
			#Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
			$Cmd = $InstallPkg
			$CmdArguments = "/install hostingservices /SkipUpdates"
			$Cmd += " '$CmdArguments'"
			
			Write-Log -Message "-> Executing: $Cmd"
			Invoke-Expression "Start-Process $Cmd -Wait -NoNewWindow"
			
			# Check it again
			$Result2 = Get-WmiObject -Query 'select * from Win32_QuickFixEngineering' | where {$_.HotFixID -Like $KB }
			if ($Result2 -ne $null)
			{
				Write-Log -Message "-> installing '$AppName' from '$InstallPkg'" -ResultOK -ResultMessage "success"
			}
			else
			{
				Write-Log -Message "-> installing '$AppName' from '$InstallPkg'" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
			}
		}
	}

}

# Check JDK 1.6.0.22 64-bit (NETAPPB and NETSVCSA need this) - added 07/18/2011 -Nihir
# JBATA and JWEBA needs that too - Tomas
# -checked-
#################################################
function Check-JDK1-6-0-22-x64-Uninstall()
{
    $AppName = "Java(TM) SE Development Kit 6 Update 22 (64-bit)"
    Check-AppUninstall -AppName $AppName
}

# Check JDK 1.6.0.4 32-bit - added by Steve
# -checked-
#################################################
function Check-JDK1-6-0-4-x86-Uninstall()
{
	$AppName = "Java(TM) SE Development Kit 6 Update 4"
    Check-AppUninstall -AppName $AppName
}

#################################################
function Check-JDK1-6-0-35-x64-Uninstall()
{
    $AppName = "Java(TM) SE Runtime Environment 6 Update 35 (64-bit)"
    Check-AppUninstall -AppName $AppName
}

#################################################
function Check-JDK1-6-0-38-x64-Uninstall()
{
     $AppName = "Java(TM) 6 Update 38 (64-bit)"
     Check-AppUninstall -AppName $AppName
}

#################################################
function Check-JDK1-6-0-38-x86-Uninstall()
{
     $AppName = "Java(TM) 6 Update 38"
     Check-AppUninstall -AppName $AppName
}

# Check JDK 1.7.0.13 64-bit JBATA needs this - 02/12/2013 - Robin
# -checked-
#################################################
function Check-JDK1-7-0-13-x64()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.13\jdk-7u13-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jdk-7u13-windows-x64 REBOOT=Suppress`" "
     $AppName = "Java SE Development Kit 7 Update 13 (64-bit)"
     $AppVersion = "1.7.0.130"

     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "d:\jdk-7u13-windows-x64\bin"
     
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME" -Value "d:\jdk-7u13-windows-x64"

}

#################################################
function Check-Java1-7-0-13-x86-Uninstall()
{
     $AppName = "Java(TM) 7 Update 13"
	 $Version = "7.0.130"
	 	Write-Log -Message "Uninstalling $appname $Version"
     Check-VersionAppuninstall -AppName $AppName -Version $Version 
}


# Check JDK 1.7.0.13 32-bit JBATA needs this - 02/12/2013 - Robin
# -checked-
#################################################
function Check-JDK1-7-0-13-x86()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.13\jdk-7u13-windows-i586.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jdk-7u13 REBOOT=Suppress`" "
     $AppName = "Java SE Development Kit 7 Update 13"
     $AppVersion = "1.7.0.130"

     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "d:\jdk-7u13\bin"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME32" -Value "d:\jdk-7u13"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA32_HOME" -Value "d:\jdk-7u13"


	 
}

#################################################
function Check-JDK1-7-0-13-x64-Uninstall()
{
#    $AppName = "Java SE Development Kit 7 Update 13 (64bit)"
	$Category = "APP"
	$AppName = "Java"
	$AppVersion = "7.0.130"
	

	$InstallPkg = "$Script:StoragePath\3pty\Java\1.7.0.13\jdk1.7.0_13_x64\jdk1.7.0_13.msi"
	$UnInstallCmd = "msiexec"
	$UnInstallCmdArgs = "/uninstall `"$InstallPkg`" /qn /norestart"

	$Cmd = $UnInstallCmd + " '$UnInstallCmdArgs'"
	
	$InstalledVersion = Get-InstalledAppVersion -AppName $AppName
	
	Write-Log -Message "Checking uninstalled - Java version: $InstalledVersion"
	
	if ( $InstalledVersion -eq $AppVersion ) {
		
	
		# installing application
		if (-not $Script:ValidateOnly )
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed (to be removed)"
			Write-Log -Message "-> removing with command: $Cmd"
			Invoke-Expression "Start-Process $Cmd -Wait -NoNewWindow"
			
			# Then doing next check
			Check-VersionAppuninstall -AppName $AppName -Version "7.0.130"
	
			# all of java 1.7.0.13 should be gone now... recheck
			$InstalledVersion = Get-InstalledAppVersion -AppName $AppName
	
			# if the version could not be removed... fail
			if ( $InstalledVersion -eq $AppVersion ) {
				Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "could not be removed"
			}

		}
		else
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed"
			Write-Log -Message "-> WOULD remove with command: $Cmd"
		}

	}
	else {
		Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultOK -ResultMessage "not installed"
	}
	
}
	

function Check-JRE1-5-0-22_Uninstall()
{
	# Application itself 
	#$InstallPkg = "`"$Script:StoragePath\3pty\Java\1.5.0.22\jre-1_5_0_22-windows-i586-p.exe`" /v`"/qn REBOOT=Suppress`" "
	$AppName = "J2SE Runtime Environment 5.0 Update 22"
	#$AppVersion = "1.5.0.220"

	#Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
    Check-AppUninstall -AppName $AppName
}


# Check Check-Java-7-0-17-x64-Uninstall()
# -checked-
#################################################
function Check-Java-7-0-17-x64-Uninstall()
{
	$AppName = "Java 7 Update 17 (64-bit)"
	$Category = "APP"
	$AppVersion = "7.0.170"
	

	$InstallPkg = "$Script:StoragePath\3pty\Java\1.7.0.17\jre1.7.0_17_x64\jre1.7.0_17.msi"
	$UnInstallCmd = "msiexec"
	$UnInstallCmdArgs = "/uninstall `"$InstallPkg`" /qn /norestart"

	$Cmd = $UnInstallCmd + " '$UnInstallCmdArgs'"
	
	$InstalledVersion = Get-InstalledAppVersion -AppName $AppName
	
	Write-Log -Message "Checking uninstalled - Java version: $InstalledVersion"
	
	if ( $InstalledVersion -eq $AppVersion ) {
		
	
		# installing application
		if (-not $Script:ValidateOnly )
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed (to be removed)"
			Write-Log -Message "-> removing with command: $Cmd"
			Invoke-Expression "Start-Process $Cmd -Wait -NoNewWindow"
			
			# Then doing next check
			Check-VersionAppuninstall -AppName $AppName -Version $AppVersion
	
			# all of java 1.7.0.17 should be gone now... recheck
			$InstalledVersion = Get-InstalledAppVersion -AppName $AppName
	
			# if the version could not be removed... fail
			if ( $InstalledVersion -eq $AppVersion ) {
				Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "could not be removed"
			}

		}
		else
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed"
			Write-Log -Message "-> WOULD remove with command: $Cmd"
		}

	}
	else {
		Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultOK -ResultMessage "not installed"
	}
	
}

#################################################
function Check-JDK1-7-0-13-x86-Uninstall()
{
	$AppName = "Java SE Development Kit 7 Update 13"
	$Category = "APP"
	#$AppName = "Java"
	$AppVersion = "1.7.0.130"
	

	$InstallPkg = "$Script:StoragePath\3pty\Java\1.7.0.13\jdk1.7.0_13_x86\jdk1.7.0_13.msi"
	$UnInstallCmd = "msiexec"
	$UnInstallCmdArgs = "/uninstall `"$InstallPkg`" /qn /norestart"

	$Cmd = $UnInstallCmd + " '$UnInstallCmdArgs'"
	
	$InstalledVersion = Get-InstalledAppVersion -AppName $AppName
	
	Write-Log -Message "Checking uninstalled - Java version: $InstalledVersion"
	
	if ( $InstalledVersion -eq $AppVersion ) {
		
	
		# installing application
		if (-not $Script:ValidateOnly )
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed (to be removed)"
			Write-Log -Message "-> removing with command: $Cmd"
			Invoke-Expression "Start-Process $Cmd -Wait -NoNewWindow"
			
			# Then doing next check
			Check-VersionAppuninstall -AppName $AppName -Version "1.7.0.130"
	
			# all of java 1.7.0.13 should be gone now... recheck
			$InstalledVersion = Get-InstalledAppVersion -AppName $AppName
	
			# if the version could not be removed... fail
			if ( $InstalledVersion -eq $AppVersion ) {
				Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "could not be removed"
			}

		}
		else
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "installed"
			Write-Log -Message "-> WOULD remove with command: $Cmd"
		}

	}
	else {
		Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultOK -ResultMessage "not installed"
	}
	
}

#################################################



#################################################
function Check-JRE1-6-0-38-x64()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\java\1.6.0.38\jre-6u38-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre-6u38-windows-x64 REBOOT=Suppress`" "
     $AppName = "Java(TM) 6 Update 38 (64-bit)"
     $AppVersion = "6.0.380"
     
     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "D:\jre-6u38-windows-x64\bin"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME" -Value "d:\jre-6u38-windows-x64"
                
}

#################################################
function Check-JRE1-6-0-45-x64()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\java\1.6.0.45\jre-6u45-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre-6u45-windows-x64 REBOOT=Suppress`" "
     $AppName = "Java(TM) 6 Update 45 (64-bit)"
     $AppVersion = "6.0.450"
     
     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "D:\jre-6u45-windows-x64\bin"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME" -Value "d:\jre-6u45-windows-x64"
                
}

# Check JRE 1.7.0.17 64-bit
# -checked-
#################################################
function Check-JRE1-7-0-17-x64()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.17\jre-7u17-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre-7u17-windows-x64 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 17 (64-bit)"
     $AppVersion = "7.0.170"

     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "d:\jre-7u17-windows-x64\bin"
     
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME" -Value "d:\jre-7u17-windows-x64"

}


# Check JRE 1.7.0.17 32-bit
# -checked-
#################################################
function Check-JRE1-7-0-17-x86()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.17\jre-7u17-windows-i586.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre-7u17 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 17"
     $AppVersion = "7.0.170"

     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "d:\jre-7u17\bin"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME32" -Value "d:\jre-7u17"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA32_HOME" -Value "d:\jre-7u17"
}

#################################################
function Check-JRE1-7-0-25-x86() 
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\java\1.7.0.25\jre-7u25-windows-i586.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre1.7.0_25 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 25"
     $AppVersion = "7.0.250"
     
     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "D:\jre1.7.0_25\bin"
     
     # add ENV:JAVA_HOME32
     Check-EnvironmentVariable -Name "JAVA_HOME32" -Value "d:\jre1.7.0_25"
	 
	# add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA32_HOME" -Value "d:\jre1.7.0_25"
     
   
}
#################################################
function Check-JDK1-7-0-25-x64()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\java\1.7.0.25\jdk-7u25-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jdk-7u25-windows-x64 REBOOT=Suppress`" "
     $AppName = "Java SE Development Kit 7 Update 25 (64-bit)"
     $AppVersion = "1.7.0.250"
     
     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "D:\jdk-7u25-windows-x64\jre\bin"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME" -Value "d:\jdk-7u25-windows-x64\jre"
	 
	#check Wow64Node 
     #Check-RegistrySetting -Path "HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment\1.7" -Property "JavaHome" -Value "D:\jre-7u25-windows-x64" -PropertyType String
     #Check-RegistrySetting -Path "HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment\1.7" -Property "RuntimeLib" -Value "D:\jre-7u25-windows-x64\bin\server\jvm.dll" -PropertyType String

}

# Check JRE 1.7.0.25 64-bit
# -checked-
#################################################
function Check-JRE1-7-0-25-x64()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.25\jre-7u25-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre-7u25-windows-x64 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 25 (64-bit)"
     $AppVersion = "7.0.250"

     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "d:\jre-7u25-windows-x64\bin"
     
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME" -Value "d:\jre-7u25-windows-x64\"

}

#################################################
# Check JRE 1.7.0.72 32-bit - Rezki # This was required by Symantec Protection Engine 7.5
# -checked-
#################################################
function Check-JRE1-7-0-72-x86() 
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\java\1.7.0.72\jre-7u72-windows-i586.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre1.7.0_72 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 72"
     $AppVersion = "7.0.720"
     
     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "D:\jre1.7.0_72\bin"
     
     # add ENV:JAVA_HOME32
     Check-EnvironmentVariable -Name "JAVA_HOME32" -Value "d:\jre1.7.0_72"
	 
	# add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA32_HOME" -Value "d:\jre1.7.0_72"
}
	 
#################################################
function Check-JRE1-7-0-25-x86_Uninstall()
{
	# Application itself 
	# $InstallPkg = "`"$Script:StoragePath\3pty\java\1.7.0.25\jre-7u25-windows-i586.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre1.7.0_25 REBOOT=Suppress`" "
	$AppName = "Java 7 Update 25"
	#$AppVersion = "7.0.250"

	#Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
    Check-AppUninstall -AppName $AppName
}

# Check JRE 1.7.0.40 64-bit
# -checked-
#################################################
function Check-JRE1-7-0-40-x64()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.40\jre-7u40-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre-7u40-windows-x64 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 40 (64-bit)"
     $AppVersion = "7.0.400"

     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "d:\jre-7u40-windows-x64\bin"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME" -Value "d:\jre-7u40-windows-x64"
}


# Check JRE 1.7.0.40 32-bit
# -checked-
#################################################
function Check-JRE1-7-0-40-x86()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.40\jre-7u40-windows-i586.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre-7u40 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 40"
     $AppVersion = "7.0.400"

     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "d:\jre-7u40\bin"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME32" -Value "d:\jre-7u40"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA32_HOME" -Value "d:\jre-7u40"
}


function Check-Java ( [string] $AppName, [string] $AppVersion, [string] $InstallCmd, [string] $InstallFolder, [boolean] $is32bit )
{

     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry $InstallFolder\bin
  
		
	if ( $is32bit )
	{
		# add ENV:JAVA_HOME
		Check-EnvironmentVariable -Name "JAVA_HOME32" -Value $InstallFolder
     
		# add ENV:JAVA_HOME
		Check-EnvironmentVariable -Name "JAVA32_HOME" -Value $InstallFolder
	}
	else
	{
	
		# add ENV:JAVA_HOME
		Check-EnvironmentVariable -Name "JAVA_HOME" -Value $InstallFolder
	}
}




# Check JDK 1.7.0.67 64-bit JBATA needs this - 08/27/2014 - Robin
# -checked-
#################################################
function Check-JDK1-7-0-67-x64()
{
     # Application itself 
	 
	 $InstallFolder = "d:\jdk-7u67-windows-x64"	 
     $InstallCmd = "`"$Script:StoragePath\3pty\Java\1.7.0.67\jdk-7u67-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES ADDLOCAL=ToolsFeature,SourceFeature INSTALLDIR=$InstallFolder JAVAUPDATE=0 REBOOT=Suppress`" "
     $AppName = "Java SE Development Kit 7 Update 67 (64-bit)"
     $AppVersion = "1.7.0.670"

     Check-Java -AppName $AppName -AppVersion $AppVersion -InstallCmd $InstallCmd -InstallFolder $InstallFolder -is32bit $false 
     
     
}
# not checked
#################################################
function Check-JDK1-7-0-67-x86() 
{
     # Application itself 
	 $InstallFolder = "d:\jdk-7u67-windows-32bit"	 	 
     $InstallPkg = "`"$Script:StoragePath\3pty\java\1.7.0.67\jdk-7u67-windows-i586.exe`" /v`"/qn /s AgreeToLicense=YES ADDLOCAL=ToolsFeature,SourceFeature INSTALLDIR=$InstallFolder JAVAUPDATE=0 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 67"
     $AppVersion = "1.7.0.670"
     
  
     Check-Java -AppName $AppName -AppVersion $AppVersion -InstallCmd $InstallCmd -InstallFolder $InstallFolder -is32bit $true
	   
   
}

# Check JRE 1.7.0.67 64-bit
# -not checked-
#################################################
function Check-JRE1-7-0-67-x64()
{
     # Application itself 
	 $InstallFolder = "d:\jre-7u67-windows-x64"
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.67\jre-7u67-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=$InstallFolder JAVAUPDATE=0 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 67 (64-bit)"
     $AppVersion = "1.7.0.670"

     Check-Java -AppName $AppName -AppVersion $AppVersion -InstallCmd $InstallCmd -InstallFolder $InstallFolder -is32bit $false	 
}

# Check JRE 1.7.0.67 32-bit
# -not checked-
#################################################
function Check-JRE1-7-0-67-x86()
{
     # Application itself 
	 $InstallFolder = "d:\jre-7u67-window-32bit"
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.67\jre-7u67-windows-i586.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=$InstalllFolder JAVAUPDATE=0 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 67"
     $AppVersion = "1.7.0.670"

     Check-Java -AppName $AppName -AppVersion $AppVersion -InstallCmd $InstallCmd -InstallFolder $InstallFolder -is32bit $true	 

}

#################################################
function Check-JDK1-7-0-67-x64_Uninstall()
{
	$AppName = "Java 7 Update 67"
	
	Write-Log -Message "Checking uninstalled - $AppName"
    Check-AppUninstall -AppName $AppName
}

#################################################
Function Check-JDK1-7-0-80-x86()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\java\1.7.0.80\jdk-7u80-windows-i586.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jdk-7u80 REBOOT=Suppress`" "
     $AppName = "Java SE Development Kit 7 Update 80"
     $AppVersion = "7.0.800"
     $TargetPath = "d:\jdk-7u80"
	 
     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "D:\jdk-7u80\bin"
     
     # add ENV:JAVA_HOME
	Check-EnvironmentVariable -Name "JAVA_HOME32" -Value $TargetPath 
	Check-EnvironmentVariable -Name "JAVA32_HOME" -Value $TargetPath 
}

# Check JRE 1.7.0.80 64-bit
# -checked- 
#################################################
function Check-JRE1-7-0-80-x64()
{
     # Application itself 
     $InstallPkg = "`"$Script:StoragePath\3pty\Java\1.7.0.80\jre-7u80-windows-x64.exe`" /v`"/qn /s AgreeToLicense=YES INSTALLDIR=d:\jre-7u80-windows-x64 REBOOT=Suppress`" "
     $AppName = "Java 7 Update 80 (64-bit)"
     $AppVersion = "7.0.800"

     Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg # -CmdArguments $InstallPkg
     
     # Add to env path:
     Check-EnvPath -PathEntry "d:\jre-7u80-windows-x64\bin"
     
     # add ENV:JAVA_HOME
     Check-EnvironmentVariable -Name "JAVA_HOME" -Value "d:\jre-7u80-windows-x64"
}

#################################################
function Check-JRE1-7-0-80-x64_Uninstall()
{
	$AppName = "Java 7 Update 80 (64-bit)"
	
	Write-Log -Message "Checking uninstalled - $AppName"
    Check-AppUninstall -AppName $AppName
}


# Check JRE 1.8.0.66 32-bit
# -checked-
#################################################
function Check-JRE1-8-0-66-x64()
{
     # Application itself 
 	$AppName = "Java 1.8 Update 66"
	 $TargetPath = "d:\jre-8u66-window-x64"
     $SourcePath = "$Script:StoragePath\3pty\Java\1.8.0.66\jre-windows-x64-standalone"
	 $SkipItemsIfExist = @("d:\jre-8u66-window-x64\lib\security\cacerts","d:\jre-8u66-window-x64\lib\security\java.security",
							"d:\jre-8u66-window-x64\lib\security\local_policy.jar","d:\jre-8u66-window-x64\lib\security\local_policy.jar",
							"d:\jre-8u66-window-x64\lib\security\US_export_policy.jar")
	 
     $AppName = "Java 8 Update 66"
     $AppVersion = "1.8.0.66"
	 
	Write-Log -Message "Checking installation of  - $AppName"
	 
	Check-DirectoryTree $TargetPath  $SourcePath -SkipItemsIfExist $SkipItemsIfExist

	Check-EnvironmentVariable -Name "JAVA_HOME" -Value $TargetPath 
	Check-EnvPath -PathEntry "$TargetPath\bin" -Add

	
}


#################################################
function Check-UnixTools()
{
	Write-Log
	Write-Log -Message "Checking UnixTools..."
	Write-Log
	
	# First make sure dir exists
	Check-Directory "D:\UnixTools"
	
	# Next make sure each of these files are in place
	$UnixTools = @("unzip.exe","wget.exe","libeay32.dll","libiconv2.dll","libintl3.dll","libssl32.dll")
	foreach	($UnixTool in $UnixTools)
	{
		Check-File "D:\UnixTools\$UnixTool" -SourceFile "$Script:StoragePath\3pty\UnixTools\$UnixTool"
	}
	
	# Last, make sure path is added to env path
	Check-EnvPath -PathEntry "D:\UnixTools"
}

# Check Apache Tomcat 7.0.35 x64
# -checked-
#################################################
function Check-Apache-Tomcat-7-0-35-x64()
{
	Write-Log
	Write-Log -Message "Checking Apache Tomcat 7.0.35 x64..."
	Write-Log

	
	$SourceZip = "$Script:StoragePath\3pty\tomcat\apache-tomcat-7.0.35-windows-x64.zip"
	$TargetDir = "d:\"

	Check-MSDeployZip -SourceZip $SourceZip -TargetDir $TargetDir
	
	Check-EnvironmentVariable -Name "CATALINA_HOME" -Value "d:\apache-tomcat-7.0.35"
}



# Check Apache Ant 1.7.0
# -checked-
#################################################
function Check-Apache-Ant-1-7-0()
{
	Write-Log
	Write-Log -Message "Checking Apache Ant 1.7.0..."
	Write-Log
	
	$SourceZip = "$Script:StoragePath\3pty\ant\1.7.0\apache-ant-1.7.0-bin.zip"
	$TargetDir = "d:\"

	Check-MSDeployZip -SourceZip $SourceZip -TargetDir $TargetDir
	
	Check-EnvironmentVariable -Name "ANT_HOME" -Value "d:\apache-ant-1.7.0"
	
	Check-EnvPath -PathEntry "d:\apache-ant-1.7.0\bin"
}



# Check Microsoft ReportViewer 2010
#################################################
function Check-MSReportViewer()
{
	Write-Log
	Write-Log -Message "Checking ReportViewer..."
	Write-Log

	# Application itself
	$InstallPkg = "'$Script:StoragePath\3pty\Microsoft\ReportViewer\ReportViewer2010\ReportViewer.exe'"
	$AppName =  "Microsoft ReportViewer 2010 Redistributable"
	$AppVersion = "10.0.30319"
	$CmdArgs = "/norestart /passive"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments $CmdArgs

}

# Check Microsoft ReportViewer 2010 SP1
#################################################
function Check-MSReportViewerSP1()
{
	Write-Log
	Write-Log -Message "Checking ReportViewer SP1..."
	Write-Log
	# Application itself
	$InstallPkg = "'$Script:StoragePath\3pty\Microsoft\ReportViewer\ReportViewer2010\ReportViewerSP1.exe'"
	$AppName =  "Microsoft ReportViewer 2010 SP1 Redistributable"
	$AppVersion = "10.0.40219"
	$CmdArgs = "/i /q /norestart"
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments $CmdArgs
  
}
# Check Assembly file version
#################################################
function Check-AsembleyFileVersion([string] $AsemblyDll)
{
    $fileVersion = (Get-ChildItem -path C:\Windows\assembly\GAC_MSIL -Filter $AsemblyDll -Recurse |
        ForEach-Object {
            try {
                $_ | Add-Member NoteProperty FileVersion ($_.VersionInfo.FileVersion)
                $_ | Add-Member NoteProperty AssemblyVersion (
                    [Reflection.Assembly]::LoadFile($_.FullName).GetName().Version
                )
            } catch {}
            $_
        } |
        Select-Object fullName,FileVersion,AssemblyVersion).FileVersion
    return $fileVersion
}

# Check Microsoft ReportViewer 2010 SP1 HotFix
#################################################
function Check-MSReportViewerSP1HotFix()
{
	Write-Log
	Write-Log -Message "Checking ReportViewer Hotfix ..."
	Write-Log

	# Application itself
	$Category = "APP"
	$AppName =  "Hotfix for Microsoft Visual Studio 2010 (KB2778094)"
	$AppVersion = "10.0.40219"
	$PatchVersion = "10.0.40219.432"
	
	if (TEST-PATH -PATH "C:\Windows\assembly\GAC_MSIL\Microsoft.ReportViewer.WebForms")
	{
		$loc =  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.ReportViewer.Webforms").location
		$installedDLL = (get-item $loc).VersionInfo
		$InstalledVersion = $installedDLL.productversion 

		if ($PatchVersion -eq $InstalledVersion)
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultOK -ResultMessage "installed"
		}
		else
		{
		# installing application
			if (-not $Script:ValidateOnly)
			{
				$Cmd = "'$Script:StoragePath\3pty\Microsoft\ReportViewer\ReportViewer2010\VS10SP1-KB2778094-x86.exe'"
				$CmdArgs = "/i /q /norestart"
				$Cmd += " '$CmdArgs'"
				Write-Log -Message "-> Executing: $Cmd"
				Invoke-Expression "Start-Process $Cmd -Wait -NoNewWindow"
				Write-Log -message "Restarting IIS..."
				Invoke-Command -scriptblock {iisreset /restart}
				if ($PatchVersion -eq $InstalledVersion)
				{
					Write-Log -Message "-> Install $AppName ($InstalledVersion)" -ResultOK -ResultMessage "success "
				}
				else
				{
					Write-Log -Message "-> Install $AppName ($AppVersion)" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
				}
			}
		}
	}
	else
	{
		Write-Log -Message "-> Could not find C:\Windows\assembly\GAC_MSIL\Microsoft.ReportViewer.WebForms" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
	}
}



# Check Perforce client 2009.2 64-bit
# -checked-
#################################################
function Check-PerforceClient-2009.2-x64()
{
	# Application itself 
	$InstallCmd = "$Script:StoragePath\3pty\Perforce\P4V_2009.2_64Bit\p4vinst64.exe"
	$InstallCmdArgs = "/v`"/qn REBOOT=ReallySuppress`""
	$AppName = "Perforce Visual Components"
	$AppVersion = "092.23.6331"

	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}

# Check Perforce client 2013.3 64-bit - ralberth, P4 Upgrade
# -checked-
#################################################
function Check-PerforceClient-2013.3-x64()
{
	# Application itself 
	$InstallCmd = "$Script:StoragePath\3pty\Perforce\P4V_2013.3_64Bit\p4vinst64.exe"
	$InstallCmdArgs = "/v`"/qn REBOOT=ReallySuppress`""
	$AppName = "Perforce Visual Components"
	$AppVersion = "134.77.1678"

	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}

# Check Perforce client 2015.2 64-bit - ralberth, P4 Upgrade
# -checked-
#################################################
function Check-PerforceClient-2015.2-x64()
{
	# Application itself 
	$InstallCmd = "$Script:StoragePath\3pty\Perforce\P4V_2015.2_64Bit\p4vinst64.exe"
	$InstallCmdArgs = "/v`"/qn REBOOT=ReallySuppress`""
	$AppName = "Helix Visual Components"
	$AppVersion = "152.145.8499"

	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}

# Check Perforce client 2009.2 64-bit - AMIYN, 1/29/14 FOR APPSUPP CLUSTER
# -checked-
#################################################
function Check-Perforce_CMD_Client()
{
    #Application itself 
    $InstallCmd = "$Script:StoragePath\3pty\Perforce\CMD_Client\perforce64.exe"
    #$InstallCmdArgs = "/v`"/qn REBOOT=ReallySuppress`""
    $InstallCmdArgs = "/v`"/qn ADDLOCAL=P4,P4USER=ReadOnly,P4PORT=source.monster.com:1844,P4PASSWD=ReadOnly,P4CLIENT=Project.ReadOnly.DEVAPPSUPP201`""
    $AppName = "Perforce Server Components"
    $AppVersion = "133.77.0086"
    Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
       
    #p4 set P4PORT=source.monster.com:1844
    #p4 set P4USER=ReadOnly
    #p4 set P4PASSWD=ReadOnly
    #p4 set P4CLIENT=Project.ReadOnly.DEVAPPSUPP201 

    Check-EnvPath (“c:\program files\perforce”)

}

# Check WinSCP client
# (DEV00598705)
# -checked-
#################################################
function Check-WinScpClient()
{
	$SourcePath = "$Script:StoragePath\3pty\WinSCP"
	$TargetPath = "d:\WinSCP"
	
	Write-Log
	Write-Log -Message "Checking WinSCP client ..."
	Write-Log
	
	Check-DirectoryTree -TargetPath $TargetPath -SourcePath $SourcePath
	
	Check-EnvPath -PathEntry $TargetPath
}


# Check WinZip 12.1
# -checked-
#################################################
function Check-WinZip12.1()
{
	# Application itself 
	$InstallPkg = "$Script:StoragePath\3pty\WinZip\WinZip12.1\winzip121.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs =  "/I `"$InstallPkg`" /qn INSTALLCMD=`"/noqp /noc4u /notip /autoinstall`" "
	$AppName = "WinZip 12.1"
	$AppVersion = "12.1.8497"

	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
	Check-File -TargetFile "c:\ProgramData\WinZip\WinZip.wzmul" -SourceFile "$Script:StoragePath\Implementation\$Script:ImplementationBranch\Deployment\Licenses\Winzip\Winzip12.1\WinZip.wzmul"
}

# Check Microsoft Visual C++ 2010 Redistributable Package (x64)
# -checked-
##################################################
function Check-MSVCRT-2010-x64()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2010 Redistributable Package (x64)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2010\vcredist_x64.exe"
	$AppName = "Microsoft Visual C++ 2010  x64 Redistributable - 10.0.30319"
	$AppVersion = "10.0.30319"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check Microsoft Visual C++ 2010 Redistributable Package (x86)
# -checked-
##################################################
function Check-MSVCRT-2010-x86()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2010 Redistributable Package (x86)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2010\vcredist_x86.exe"
	$AppName = "Microsoft Visual C++ 2010  x86 Redistributable - 10.0.30319"
	$AppVersion = "10.0.30319"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check Microsoft Visual C++ 2010 Redistributable Package (x64) fixed version
# -checked-
##################################################
function Check-MSVCRT-2010-x64-fixed()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2010 Redistributable Package (x64)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2010\vcredist_x64_325.exe"
	$AppName = "Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219"
	$AppVersion = "10.0.40219"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check Microsoft Visual C++ 2010 Redistributable Package (x86) fixed version
# -checked-
##################################################
function Check-MSVCRT-2010-x86-fixed()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2010 Redistributable Package (x86)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2010\vcredist_x86_325.exe"
	$AppName = "Microsoft Visual C++ 2010  x86 Redistributable - 10.0.40219"
	$AppVersion = "10.0.40219"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check Microsoft Visual C++ 2012 Redistributable Package (x64)
# -checked-
##################################################
function Check-MSVCRT-2012-x64()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2012 Redistributable Package (x64)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2012\vcredist_x64.exe"
	$AppName = "Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.61030"
	$AppVersion = "11.0.61030"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check Microsoft Visual C++ 2012 Redistributable Package (x86)
# -checked-
##################################################
function Check-MSVCRT-2012-x86()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2012 Redistributable Package (x86)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2012\vcredist_x86.exe"
	$AppName = "Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.61030"
	$AppVersion = "11.0.61030"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check Microsoft Visual C++ 2013 Redistributable Package (x64)
# -checked-
##################################################
function Check-MSVCRT-2013-x64()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2013 Redistributable Package (x64)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2013\vcredist_x64.exe"
	$AppName = "Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.30501"
	$AppVersion = "12.0.30501"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check Microsoft Visual C++ 2013 Redistributable Package (x86)
# -checked-
##################################################
function Check-MSVCRT-2013-x86()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2013 Redistributable Package (x86)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2013\vcredist_x86.exe"
	$AppName = "Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.30501"
	$AppVersion = "12.0.30501"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check Microsoft Visual C++ 2015 Redistributable Package (x64)
# -checked-
##################################################
function Check-MSVCRT-2015-x64()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2015 Redistributable Package (x64)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2015\vc_redist.x64.exe"
	$AppName = "Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.23026"
	$AppVersion = "14.0.23026"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check Microsoft Visual C++ 2015 Redistributable Package (x86)
# -checked-
##################################################
function Check-MSVCRT-2015-x86()
{
  Write-Log
	Write-Log -Message "Checking Microsoft Visual C++ 2015 Redistributable Package (x86)..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\MSVCRT\2015\vc_redist.x86.exe"
	$AppName = "Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.23026"
	$AppVersion = "14.0.23026"
	#$SleepForSeconds = 360
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments "/norestart /passive"
}

# Check MongoDB Client Service v2.2.1
# -checked-# Check MongoDB Client Service v2.2.1
# -checked-
#################################################
function Check-MongoS-221-withoutConfig()
{
	$Application = "Mongos 32-64-bit_2008plus v2.2.1"
    $ApplicationOld = "Mongos (old)"
	
	Write-Log
	Write-Log -Message "Checking for $Application..."
	Write-Log
	
    $Category = "APP"
	$OldInstPath = "D:\mongodb"
    $InstPath = "D:\Services\Mongos"
    $MongoConfFile = "D:\services\MongosConfig\mongos.conf"
    $MongoLogsDir = "D:\logs\mongodb"
    $BinaryLocation = $($InstPath)+"\mongos.exe"
	$InstSource = "$Script:StoragePath\3pty\MongoDB\mongodb-win32-x86_64-2008plus-2.2.1"
	$ServiceName = "Mongos"
	$ServiceDisplayName = $ServiceName
	$ServiceBinaryPathName = "$($BinaryLocation) --config=$($MongoConfFile) --service"
	$ServiceDescription = "MongoDB 32-64-bit v2.2.1 is used for probook/beknown application."
	$ServiceStartupType = "Automatic"
    
    # necessary dirs
	Check-Directory $MongoLogsDir
    Check-Directory "D:\Services"
    Check-Directory $InstPath
	
    # uninstall the old service if found installed
    if ($Script:ValidateOnly)
	{
        # detect old version
        if ((Test-Path -path "$($OldInstPath)\bin\mongos.exe") -or (Test-Path -path "$($OldInstPath)\bin\v1.8.4.ver") -or (Test-Path -path "D:\mongodb\bin\v1.8.1.ver"))
        {
            Write-Log -Message $ApplicationOld -Category $Category -ResultFailure -ResultMessage "found"
        }
        # check for new version
        if (!(Test-Path -path "$BinaryLocation") -or !(Test-Path -path "$InstPath\v2.2.1.ver"))
		{
			Write-Log -Message $Application -Category $Category -ResultFailure -ResultMessage "not found"
		}
    }
    else
    {
        # remove old service
        if ((Test-Path -path "$($OldInstPath)\bin\mongos.exe") -or (Test-Path -path "$($OldInstPath)\bin\v1.8.4.ver") -or (Test-Path -path "D:\mongodb\bin\v1.8.1.ver"))
        {
            Write-Log -Message $ApplicationOld -Category $Category -ResultFailure -ResultMessage "found (to be uninstalled)"
            # Stop Mongo service if running
			$OldMongoServiceName = "mongos"
			Stop-Service $OldMongoServiceName
			if ($?)
			{
				Write-Log -Message "-> stopping '$OldMongoServiceName' service" -ResultOK -ResultMessage "success"
				# Also delete it
				$RemoveService = "& sc.exe delete $OldMongoServiceName"
				$Results = Invoke-Expression $RemoveService
				Start-Sleep 5
				Write-Log -Message "$OldMongoServiceName deleted (will be recreated)" -Category "SERVICE" -ResultOK
                
			}
			else
			{
                Write-Log -Message "-> stopping '$OldMongoServiceName' service" -EntryType "ERROR" -ResultFailure -ResultMessage $Error[0].Exception.Message
            }
        }
        
        # remove old files
        if ((Test-Path -path "$OldInstPath"))
        {
            Write-Log -Message "$OldInstPath" -Category $Category -ResultFailure -ResultMessage "found (to be moved to D:\temp)"
            $CurrentDayTime = Get-Date -format "MM-dd-yyyy_hh_mm_ss_tt"
                Move-Item -Path $OldInstPath -Destination "D:\temp\mongodb_old_$($CurrentDayTime)"
            
            if (!(Test-Path -path "$OldInstPath"))
            {
                Write-Log -Message "-> $OldInstPath moved to D:\temp" -ResultOK -ResultMessage "success"
            }
            else
            {
                Write-Log -Message "-> error moving $OldInstPath" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
            }
        }
        
        if ((Test-Path -path "D:\WindowsResourceKit"))
        {
            Write-Log -Message "WindowsResourceKit" -Category $Category -ResultFailure -ResultMessage "found (to be moved to D:\temp)"
            $CurrentDayTime = Get-Date -format "MM-dd-yyyy_hh_mm_ss_tt"
            Move-Item -Path "D:\WindowsResourceKit" -Destination "D:\temp\mongodb_WindowsResourceKit_$($CurrentDayTime)"
            
            if (!(Test-Path -path "D:\WindowsResourceKit"))
            {
                Write-Log -Message "-> D:\WindowsResourceKit moved to D:\temp" -ResultOK -ResultMessage "success"
            }
            else
            {
                Write-Log -Message "-> error moving D:\WindowsResourceKit" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
            }
        }
    }
    
    # new version
    Check-File -TargetFile "$($InstPath)\GNU-AGPL-3.0" -SourceFile "$Script:StoragePath\3pty\MongoDB\mongodb-win32-x86_64-2008plus-2.2.1\GNU-AGPL-3.0"
    Check-File -TargetFile "$($InstPath)\README" -SourceFile "$Script:StoragePath\3pty\MongoDB\mongodb-win32-x86_64-2008plus-2.2.1\README"
    Check-File -TargetFile "$($InstPath)\THIRD-PARTY-NOTICES" -SourceFile "$Script:StoragePath\3pty\MongoDB\mongodb-win32-x86_64-2008plus-2.2.1\THIRD-PARTY-NOTICES"
    Check-File -TargetFile "$($InstPath)\mongos.exe" -SourceFile "$Script:StoragePath\3pty\MongoDB\mongodb-win32-x86_64-2008plus-2.2.1\bin\mongos.exe"
    Check-File -TargetFile "$($InstPath)\v2.2.1.ver" -SourceFile "$Script:StoragePath\3pty\MongoDB\mongodb-win32-x86_64-2008plus-2.2.1\bin\v2.2.1.ver"
    
    # Write-Log -Message "-> Installing with binary path: $($ServiceBinaryPathName)" -Category "SERVICE" -ResultOK
    # create service if it doesn't exist
    Check-Service -Name $ServiceName -DisplayName $ServiceDisplayName -BinaryPathName $ServiceBinaryPathName -Description $ServiceDescription -StartupType $ServiceStartupType
    
	Write-Log
}

# Check MongoDB Client Config ONLY
# -checked-
#################################################
function Check-MongoS-configOnly()
{
	$Script:ApplicationMongo = "mongos.conf"
	
	Write-Log
	Write-Log -Message "Checking $Script:ApplicationMongo..."
	Write-Log
	
    $Script:CategoryMongo = "CONF"
    
    # necessary dirs
    $MongoConfDir = "D:\Services\MongosConfig"
    Check-Directory $MongoConfDir
    $Script:MongoConfFile = "$MongoConfDir\mongos.conf"
    $CurrentDayTime = Get-Date -format "MM-dd-yyyy_hh_mm_ss_tt"
    $Script:TempMongoConfFile = "D:\temp\mongos_$($CurrentDayTime).tmp"
    $Script:MongosLog = "D:\logs\mongodb\mongos.log"
    $Script:CheckDB = $false
    $Script:IfDifferentUpdate = $false
    $Script:CreateNewFile = $false
    $Script:DBMissingInAPI = $false
   
    function CheckForPort([string]$DB)
    {
        $DefaultMongoDBPort = "47019"
        if ($DB -imatch ":") {
            return "$($DB)"
        }
        else {
            return "$($DB):$($DefaultMongoDBPort)"
        }
    }

    function GetMongoDB()
    {
        [array]$MongoList = @()
        [xml]$MongoDBXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Script:EnvironmentName+"/DBs/?Type=Mongo")
        if ($MongoDBXML.DBs.IsEmpty) {
            $Script:DBMissingInAPI = $true
            return "NoActiveDB_InAPI"
        }
        
        $MongoDBXML.DBs.DB | % { $MongoList += $_.Name }
        switch ($MongoList.Count) {
            1 {
                $MongoDBs = CheckForPort $MongoList[0]
            }
            3 {
                [string]$MongoDBs = $null
                $MongoList = $MongoList | Sort-Object # sort the MongoDBs
                $DB1 = CheckForPort $MongoList[0].ToLower()
                $DB2 = CheckForPort $MongoList[1].ToLower()
                $DB3 = CheckForPort $MongoList[2].ToLower()
                $MongoDBs = $DB1+","+$DB2+","+$DB3
            }
            default {
                #Write-Host "Unhandled # of DB in API: " + $($MongoList.Count)
                $Script:DBMissingInAPI = $true
                return "NoActiveDB_InAPI"
            }
        }
        return $MongoDBs
    }

    function CreateTempFile()
    {
        $NewlyGeneratedContent = '#mongos.conf

#-----------------------------------------------
# Env Specific
#-----------------------------------------------
#fork=true
port=19019
configdb=' + $Script:DBsInAPI + '

# Update log path
logpath=D:\logs\mongodb\mongos.log

#-----------------------------------------------
# Monitor and update as required
#-----------------------------------------------
verbose=v

#-----------------------------------------------
# Static
#-----------------------------------------------
logappend=true
'
        $Results = New-Item "$($Script:TempMongoConfFile)" -ItemType file -Value $NewlyGeneratedContent -Force:$true -Confirm:$false
        # Write-Host "temp file created: $($Script:TempMongoConfFile)"
    }

    function Check-MongoConfig()
    {
        if (Test-Path $Script:MongoConfFile) {
            $CurrentFile = gc $Script:MongoConfFile
            $NewFile = gc $Script:TempMongoConfFile
            $CompareResults = Compare-Object $CurrentFile $NewFile    
            if ($CompareResults) {
                $Script:CreateNewFile = $true
                Write-Log -Message $Script:ApplicationMongo -Category $Script:CategoryMongo -ResultFailure -ResultMessage "file needs to be recreated"
            }
            #Write-Host "Recreate file? $($Script:CreateNewFile)"
            
            # read file and parse configdb
            $FileContent = Get-Content -Path $Script:MongoConfFile
            $FileContent| ForEach-Object {
                $line = $_
                if ($line -imatch "configdb=") {
                    $Var1 = @()
                    #$_.Split("=") | %{ $_.Split(":") } | %{ $_.Split(",") } | %{ $Var1 += $_ }
                    $_.Split("=") | %{ $_.Split(",") } | %{ $Var1 += $_ }
                }
            }
                
            # based on configdb, take appropriate action to either update it or skip it
            switch ($Var1.Length) {
                2 {
                    #Write-Host "DB found in conf:" $Var1[1]
                    $Var2 = $Var1[1].Split(":")
                    $Script:CheckDB = $true
                    $Script:IfDifferentUpdate = $true
                }
                4 {
                    $Var2 = $Var1[1].Split(":")
                    $Script:CheckDB = $true
                    $Script:IfDifferentUpdate = $true
                }
                default {
                    #Write-Host "Unhandled # of DB in Config: " + $Var1.Length
                    $Script:CheckDB = $false
                    $Script:CreateNewFile = $true
                }
            }
           
            if ($Script:CheckDB) {
                $i = 1 #skip 1
                while ($i -lt $Var1.Count) {
                    [string]$CurrentItem = $Var1[$i]
                    # "found match"
                    if ($DBsInAPI -match $CurrentItem) { $Script:IfDifferentUpdate = $false }
                    # "didn't find match"
                    else { $Script:IfDifferentUpdate = $true }
                    $i++
                }
            }
        }
    }

    function DeleteMongoTempFile() {
        Remove-Item -Path $Script:TempMongoConfFile -Confirm:$false -Force:$true
    }

    $Script:DBsInAPI = GetMongoDB
    CreateTempFile

    if ($Script:DBMissingInAPI) {
        #Write-Host "DB is missing in API for $($Script:EnvironmentName) - not touching existing file"
        Write-Log -Message $Script:ApplicationMongo -Category $Script:CategoryMongo -ResultFailure -ResultMessage "DB missing in API"
    }
    else
    {
        Check-MongoConfig
        # if file doesn't exist, create one
        if (!(Test-Path $Script:MongoConfFile) -or $Script:CreateNewFile)
        {
            Write-Log -Message $Script:ApplicationMongo -Category $Script:CategoryMongo -ResultFailure -ResultMessage "needs to be recreated"
            #$NewlyGeneratedContent
            if (!($Script:ValidateOnly))
            {
                Copy-Item $Script:TempMongoConfFile $Script:MongoConfFile -Force:$true -Confirm:$false
                Check-MongoConfig
                Write-Log -Message "-> mongos.conf file created" -Category $Script:CategoryMongo -ResultOK -ResultMessage "success"
            }
        }
    }
    DeleteMongoTempFile    
	Write-Log
}

# Check Microsoft Chart Controls
#################################################
function Check-MSChartControls()
{
	Write-Log
	Write-Log -Message "Checking ChartControls..."
	Write-Log

	# Application itself
	$InstallPkg = "'$Script:StoragePath\3pty\Microsoft\MSChart\MSChart.exe'"
	$AppName =  "Microsoft Chart Controls for Microsoft .NET Framework 3.5"
	$AppVersion = "3.5.30730.0"
	$CmdArgs = "/i /norestart /passive"
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments $CmdArgs

}

# Check Microsoft Chart Controls
#################################################
function Check-MSChartControlsSP1()
{
	Write-Log
	Write-Log -Message "Checking ChartControls..."
	Write-Log
	# Application itself
	$InstallPkg = "'$Script:StoragePath\3pty\Microsoft\MSChart\SP1HF1\MSChart_KB2500170.exe'"
	$AppName =  "Microsoft Chart Controls for Microsoft .NET Framework 3.5"
	$AppVersion = "3.5.30730.0" 
    $LogsPath = "D:\logs\MSChartControls"
	$CmdArgs = "/i /norestart /passive /log $LogsPath"
    Check-Directory "D:\logs\MSChartControls"
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments $CmdArgs
}

function Check-HFKB2540745()
{
	Write-Log
	Write-Log -Message "Checking HOTFIX KB2540745..."
	Write-Log

	# make sure cert is installed - same cert used by .NET
	$CertPath = "$Script:StoragePath\3pty\Microsoft\.NET\v4.0\CSPCA.crl"
	$CertPath2 = "$Script:StoragePath\3pty\Microsoft\.NET\v4.0\tspca.crl"
	certutil -addstore CA $CertPath
    certutil -addstore CA $CertPath2
	
	# Application itself
	$InstallPkg = "'$Script:StoragePath\3pty\Microsoft\KB2540745\NDP40-KB2540745-x64.exe'"
	$AppName =  "HOTFIX KB2540745"
	$AppVersion = "1.3.2.6557"
	$CmdArgs = "/passive /promptrestart /log d:\logs\hotfix\hotfix250475.txt"
	$a = (Get-ChildItem c:\Windows\Microsoft.NET\Framework\v4.0.30319\clr.dll  -ErrorVariable error1 -ErrorAction SilentlyContinue)

		if ($a.VersionInfo.ProductPrivatePart -clt "488"){
		#Write-Host $computer "  " $a.Name $a.VersionInfo.productversion "is OLD" -ForegroundColor magenta
		#Write-Host $computer "  " $a.Name $a.VersionInfo.productversion "is Good enough" -ForegroundColor Green
		Write-Log -Message " Version of $($a.Name) $($a.VersionInfo.productversion) is OLD"  -ResultFailure -ResultMessage "CRAP"

		Check-Application -AppName $AppName  -CmdPath $InstallPkg -CmdArguments $CmdArgs
		}
		elseif ($a.VersionInfo.ProductPrivatePart -cge "488"){
		#Write-Host $computer "  " $a.Name $a.VersionInfo.productversion "is Good enough" -ForegroundColor Green
		Write-Log -Message " Version of $($a.Name) $($a.VersionInfo.productversion) meets or exceeds requirements"  -ResultOK -ResultMessage "Good Enough"
		}	
	#Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments $CmdArgs

}
function Check-KB2840628()
{
	Write-Log
	Write-Log -Message "Checking HOTFIX KB2840628..."
	Write-Log

	# Application itself
	$InstallPkg = "'$Script:StoragePath\3pty\Microsoft\KB2840628\NDP40-KB2402064-x64.exe'"
	$AppName =  "HOTFIX KB2840628"
	$AppVersion = "10.0.30319"
	$CmdArgs = "/passive /promptrestart /log d:\logs\hotfix\hotfix2840628.txt"
	
	[regex]$regex = "KB2840628v2|KB2840628"
	$kbs = dir 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Updates\Microsoft .NET Framework 4 Client Profile\' | where { $_.name -match "KB2840628" } 
       
        if ($kbs -notmatch $regex)
		{	
			#Install HotFix
			Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallPkg -CmdArguments $CmdArgs
			
		}	
		else
		{
			Write-Log -Message $AppName -Category "KB" -ResultOK -ResultMessage "installed"
		}	
	

}


# Check-ScaleoutClient-4-2-32
# Installs scaleout client and libraries to D:
#################################################
function Check-ScaleoutClient-4-2-32()
{
	# SOSS configuration
	$SOSSManagementPort = "717"
	if ($Script:EnvironmentName -eq "QAPL")
		{ $SOSSServerPort = "750" }
	else
		{ $SOSSServerPort = "718" }

	# 64bit client
	$InstallPkg = "$Script:StoragePath\3pty\ScaleOut\v_4.2.32.196\soss_setup64_net40_4232.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /quiet INSTALLTYPE=2 TARGETDIR=`"d:\Program Files\ScaleOut_Software\StateServer`" "
	$AppName = "ScaleOut StateServer x64 Edition"
	$AppVersion = "4.2.32"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
	
	# 32bit client libraries
	$InstallPkg = "$Script:StoragePath\3pty\ScaleOut\v_4.2.32.196\soss_setup32LibsOn64_net40_4232.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs =  "/I `"$InstallPkg`" /quiet INSTALLTYPE=2 TARGETDIR=`"D:\Program Files (x86)\ScaleOut_Software\StateServer`" "
	$AppName = "ScaleOut StateServer 32-bit Client Libraries"
	$AppVersion = "4.2.32"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
    #UKDWP1.8: disable checking SOSS configuration when using the xmldb
    #this is one of the lesson learnt from UKDWP1.5 release
    if ($Script:AltXmlDBFolder -eq "")
    {
        # getting array of statecache servers IPs
        $StatecacheXML = Get-HttpRequest -URL ($Script:OpsDeployApiURL+"/environments/"+$Script:EnvironmentName+"/Clusters/STATECACHE/Machines/")
        $StatecacheMachines = $StatecacheXML.Machines.Machine | ? { $_.DataCenter -eq $Script:DataCenter -and $_.Status -eq "Active" }

        $SOSSServerIPs = @($StatecacheMachines | % { $_.IPAddress })

        if ($SOSSServerIPs.Count -eq 0)
        {
            Write-Log
            Write-Log -EntryType "ERROR" -Message ("Cannot detect STATECACHE machines IPs from "+$Script:OpsDeployApiURL+"/environments/"+$Script:EnvironmentName+"/Clusters/STATECACHE/Machines/")
            Write-Log -Message "SOSS gateway configuration check will be skipped"
        }
        else
        {
            $MachineNumber = [int]($Script:ComputerName.Substring($Script:ComputerName.length-3,3)) # getting this machine number
            $SOSSServerIP = $SOSSServerIPs[($MachineNumber % $SOSSServerIPs.Count)]

            # checking scaleout configuration
            $SOSSconfig = 'D:\Program Files\ScaleOut_Software\StateServer\soss_client_params.txt'
            if (-not (Test-Path $SOSSconfig))
            {
                Write-Log
                Write-Log -EntryType "ERROR" -Message "$SOSSconfig not found!"
                Write-Log -Message "SOSS gateway configuration check will be skipped"
            }
            else
            {
                $RequestedConfig = "__SOSS_remote_client_access, $SOSSManagementPort, $SOSSServerIP, $SOSSServerPort"

                $Content = Get-Content $SOSSconfig
                $LineFound = $null
                for ($a = 0; $a -lt $Content.Count; $a++)
                {
                    if ($Content[$a] -imatch "rem_gw") { $LineFound = $a }
                }

                if ($LineFound -eq $null)
                {
                    Write-Log
                    Write-Log -Message "SOSS gateway configuration" -ResultFailure -ResultMessage "not configured"
                    if (-not $Script:ValidateOnly)
                    {
                        ("`r`nrem_gw            " + $RequestedConfig) | Out-File -Append -FilePath $SOSSconfig -Force -Encoding "ASCII"
                        if ($?)
                        {
                            Write-Log -Message "-> updating $SOSSconfig" -ResultOK -ResultMessage "updated"
                        }
                        else
                        {
                            Write-Log -Message "-> updating $SOSSconfig" -ResultFailure -ResultMessage "failure"
                        }
                    }
                }
                else
                {
                    if ($Content[$LineFound] -imatch ("rem_gw\s+"+$RequestedConfig))
                    {
                        Write-Log
                        Write-Log -Message "SOSS gateway configuration" -ResultOK -ResultMessage "OK"
                    }
                    else
                    {
                        Write-Log
                        Write-Log -Message "SOSS gateway configuration" -ResultFailure -ResultMessage "differs"
                        if (-not $Script:ValidateOnly)
                        {
                            $Content[$LineFound] = "rem_gw            " + $RequestedConfig
                            $Content | Out-File -FilePath $SOSSconfig -Force -Encoding "ASCII"
                            if ($?)
                            {
                                Write-Log -Message "-> updating $SOSSconfig" -ResultOK -ResultMessage "updated"
                            }
                            else
                            {
                                Write-Log -Message "-> updating $SOSSconfig" -ResultFailure -ResultMessage "failure"
                            }
                        }
                    }
                }
            }
        }
    }
    else
    {
        Write-Log -Message "-> AltXmlDBFolder is NOT empty. Not checking SOSS configuration when using the xmldb. Lesson Learnt from UKDWP1.5" -ResultFailure -ResultMessage "failure"
    }
	
	Write-Log
	
	# checking proper paths in registry
	Check-RegistrySetting -Path "HKLM:\SOFTWARE\Scaleout_Software\StateServer" -Property "InstallPath" -Value "D:\Program Files\ScaleOut_Software\StateServer\" -PropertyType String
	Check-RegistrySetting -Path "HKLM:\SOFTWARE\Wow6432Node\Scaleout_Software\StateServer" -Property "InstallPath" -Value "D:\Program Files\ScaleOut_Software\StateServer" -PropertyType String
	
	Write-Log
}


# Check-ScaleoutClient-4-2-32Removal
# Removes scaleout 4.0 from client D:
#################################################
function Check-ScaleoutClient-4-2-32Removal()
{
		$OLDAppPath = Get-InstalledAppLocation -AppName "ScaleOut StateServer x64 Edition"
		$AppName = "ScaleOut StateServer x64 Edition"
		Check-VersionAppuninstall -appname $AppName -version "4.2.32"
        Check-Appuninstall -appname "ScaleOut StateServer 32-bit Client Libraries" -version "4.2.32"

}	
		
		
# Check-ScaleoutClient-5-0-23
# Installs scaleout client D:
#################################################		
function Check-ScaleoutClient-5-0-23()
{
if ($Script:EnvironmentType -ne "Prod")
	{
		$InstallPkg = "$Script:StoragePath\3pty\ScaleOut\v_5.0.23.223\soss_setup64.msi"
		$InstallCmd = "msiexec"
		$InstallCmdArgs = "/i `"$InstallPkg`" /quiet ADDLOCAL=ManagementTools,DotNet20Libs,DotNet35Libs,DotNet40Libs APPLICATIONFOLDER=`"d:\Program Files\ScaleOut_Software\StateServer`" "
		$AppName = "ScaleOut StateServer x64 Edition"
		$AppVersion = "5.0.23"
    	$Script:output = "d:\Program Files\ScaleOut_Software\StateServer\soss_client_params.txt"
		Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
#Updating the Parameters file
        if (!($Script:ValidateOnly))
		{
		Write-Log
        Write-Log -Message "Checking the SOSS parameters file based on Environment..."
        $ParametersOnServer = @(Get-Content $output)
	    $sor = "$Script:StoragePath\3pty\ScaleOut\v_5.0.23.223\parameters.xml"
        $ParametersInSOR = @()
		[xml]$parameters = @(Get-Content $sor)
            Foreach ($Environment in $parameters.Environments.Environment | ? { $_.name -match $script:EnvironmentName})
            	{
            	Foreach ($Parameter in $Environment.Parameters.Parameter) 
            		{
                    [string]$file_contents = $Parameter.Name + "		" + $Parameter.Value
                    $ParametersInSOR += $file_contents             
                    }
            	}													
            $compare = @(Compare-Object  $ParametersInSOR $ParametersOnServer)
		$NUM = 1
		$ParametersOK = "True"
		
		if ($compare -ne $null)
				{
				$ParametersOK = "False"
				}
		If ($ParametersOK -match "True")
				{
				write-log
				write-log -message "SOSS parameters file matches SOR" -ResultOK -ResultMessage OK
				write-log
				}
		If ($ParametersOK -match "False")
				{	
				write-log
				write-log -message "SOSS parameters file DOES NOT match SOR" -ResultFAILure -ResultMessage Failure
			    Write-Log
                Write-Log -Message "Updating the SOSS parameters file based on Environment..."
                Write-Log
                Remove-Item "$output"
                $sor = "$Script:StoragePath\3pty\ScaleOut\v_5.0.23.223\parameters.xml"
                If ($sor -eq $NULL)
                    {
                      Write-Log -Message "Unable to read parameters file, check //3pty/ScaleOut/v_5.0.23.223/Parameters.xml..."  -ResultFailure -ResultMessage "Failure"
                    } 
               [xml]$parameters = @(Get-Content $sor) 
                Foreach ($Environment in $parameters.Environments.Environment | ? { $_.name -match $script:EnvironmentName})
                {
                Foreach ($Parameter in $Environment.Parameters.Parameter) 
                    {
                    [string]$file_contents = $Parameter.Name + "		" + $Parameter.Value
                    Add-Content "$output" "$file_contents"
                    Write-Log -Message $file_contents                    
                    If ($file_contents -eq $NULL)
                          {
                            Write-Log -Message "Unable to set SOSS parameters file" -ResultFailure -ResultMessage "Failure"
                          }         
                    }
                }
        		if (!(Test-Path $Script:output))           
                	{
                	Write-Log        
                	Write-Log -Message "-> SOSS parameters file not Updated..." -ResultFailure -ResultMessage "Failure, check //3pty/ScaleOut/v_5.0.23.223/Parameters.xml"
                	Write-Log   
                	}
        		else
                	{
                	Write-Log        
                	Write-Log -Message "-> SOSS parameters file Updated..." -ResultOK -ResultMessage OK
					Write-log
                	}
            	}
		}	
        else
            {	
			$ParametersOnServer = @(Get-Content $output)
	    	$sor = "$Script:StoragePath\3pty\ScaleOut\v_5.0.23.223\parameters.xml"
        	$ParametersInSOR = @()
			[xml]$parameters = @(Get-Content $sor)
            Foreach ($Environment in $parameters.Environments.Environment | ? { $_.name -match $script:EnvironmentName})
            	{
            	Foreach ($Parameter in $Environment.Parameters.Parameter) 
            		{
                    [string]$file_contents = $Parameter.Name + "		" + $Parameter.Value
                    $ParametersInSOR += $file_contents             
                    }
            	}													
            $compare = @(Compare-Object  $ParametersInSOR $ParametersOnServer)
			$NUM = 1
			$ParametersOK = "True"
		
			if ($compare -ne $null)
				{
				$ParametersOK = "False"
				}
			If ($ParametersOK -match "True")
				{
				write-log
				write-log -message "SOSS Parameters file matches SOR" -ResultOK -ResultMessage OK
				write-log
				}
			If ($ParametersOK -match "False")
				{
				write-log
				write-log -message "SOSS Parameters file DOES NOT match SOR" -ResultFAILure -ResultMessage Failure
				write-log
				}
		
			}		
	}
}

# Check-ScaleoutClient-5-0-23Removal
# Removes scaleout 5.0 from client D:
#################################################
function Check-ScaleoutClient-5-0-23Removal()
{
	if ($Script:EnvironmentType -ne "Prod")
	{
		$OLDAppPath = Get-InstalledAppLocation -AppName "ScaleOut StateServer x64 Edition"
		$AppName = "ScaleOut StateServer x64 Edition"
		Check-VersionAppuninstall -appname $AppName -version "5.0.23"
	}	
}		
		
		
# Check-ScaleoutClient-5-1-5
# Installs scaleout client D:
#################################################		
function Check-ScaleoutClient-5-1-5()
{
		$InstallPkg = "$Script:StoragePath\3pty\ScaleOut\v_5.1.5.235\soss_setup64.msi"
		$InstallCmd = "msiexec"
		$InstallCmdArgs = "/i `"$InstallPkg`" /quiet ADDLOCAL=ManagementTools,DotNet20Libs,DotNet35Libs,DotNet40Libs APPLICATIONFOLDER=`"d:\Program Files\ScaleOut_Software\StateServer`" "
		$AppName = "ScaleOut StateServer x64 Edition"
		$AppVersion = "5.1.5"
    	$Script:output = "d:\Program Files\ScaleOut_Software\StateServer\soss_client_params.txt"
		Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
#Updating the Parameters file
        if (!($Script:ValidateOnly))
    {
		Write-Log
        Write-Log -Message "Checking the SOSS parameters file based on Environment..."
        $ParametersOnServer = @(Get-Content $output)
	    $sor = "$Script:StoragePath\3pty\ScaleOut\parameters.xml"
        $ParametersInSOR = @()
		[xml]$parameters = @(Get-Content $sor)
        $parameters2 = $parameters.Environments.Environment | ? { $_.name -ieq $script:EnvironmentName}
		$parameters3 = $parameters2.Datacenters.Datacenter | ? { $_.name -ieq $script:datacenter} 
            	Foreach ($Parameter in $parameters3.Parameters.Parameter) 
            		{
                    [string]$file_contents = $Parameter.Name + "		" + $Parameter.Value
                    $ParametersInSOR += $file_contents             
                    }
            													
            $compare = @(Compare-Object  $ParametersInSOR $ParametersOnServer)
		$NUM = 1
		$ParametersOK = "True"
		
		if ($compare -ne $null)
				{
				$ParametersOK = "False"
				}
		If ($ParametersOK -match "True")
				{
				write-log
				write-log -message "SOSS parameters file matches SOR" -ResultOK -ResultMessage OK
				write-log
				}
		If ($ParametersOK -match "False")
				{	
				write-log
				write-log -message "SOSS parameters file DOES NOT match SOR" -ResultFAILure -ResultMessage Failure
			    Write-Log
                Write-Log -Message "Updating the SOSS parameters file based on Environment..."
                Write-Log
                Remove-Item "$output"
                $sor = "$Script:StoragePath\3pty\ScaleOut\parameters.xml"
                If ($sor -eq $NULL)
                    {
                      Write-Log -Message "Unable to read parameters file, check //3pty/ScaleOut/Parameters.xml..."  -ResultFailure -ResultMessage "Failure"
                    } 
               [xml]$parameters = @(Get-Content $sor) 
        			$parameters2 = $parameters.Environments.Environment | ? { $_.name -ieq $script:EnvironmentName}
					$parameters3 = $parameters2.Datacenters.Datacenter | ? { $_.name -ieq $script:datacenter} 
                    	Foreach ($Parameter in $parameters3.Parameters.Parameter) 
                    {
                    [string]$file_contents = $Parameter.Name + "		" + $Parameter.Value
                    Add-Content "$output" "$file_contents"
                    Write-Log -Message $file_contents                    
                    If ($file_contents -eq $NULL)
                          {
                            Write-Log -Message "Unable to set SOSS parameters file" -ResultFailure -ResultMessage "Failure"
                          }         
                    }
                }
        		if (!(Test-Path $Script:output))           
                	{
                	Write-Log        
                	Write-Log -Message "-> SOSS parameters file not Updated..." -ResultFailure -ResultMessage "Failure, check //3pty/ScaleOut/Parameters.xml"
                	Write-Log   
                	}
        		else
                	{
                	Write-Log        
                	Write-Log -Message "-> SOSS parameters file Updated..." -ResultOK -ResultMessage OK
					Write-log
                	}
    }
        else
            {	
                $ParametersOnServer = @(Get-Content $output)
                $sor = "$Script:StoragePath\3pty\ScaleOut\parameters.xml"
                $ParametersInSOR = @()
                [xml]$parameters = @(Get-Content $sor)
                $parameters2 = $parameters.Environments.Environment | ? { $_.name -ieq $script:EnvironmentName}
                $parameters3 = $parameters2.Datacenters.Datacenter | ? { $_.name -ieq $script:datacenter}
                    Foreach ($Parameter in $parameters3.Parameters.Parameter) 
                        {
                        [string]$file_contents = $Parameter.Name + "		" + $Parameter.Value
                        $ParametersInSOR += $file_contents             
                        }													
                $compare = @(Compare-Object  $ParametersInSOR $ParametersOnServer)
                $NUM = 1
                $ParametersOK = "True"
		
                if ($compare -ne $null)
                    {
                    $ParametersOK = "False"
                    }
                If ($ParametersOK -match "True")
                    {
                    write-log
                    write-log -message "SOSS Parameters file matches SOR" -ResultOK -ResultMessage OK
                    write-log
                    }
                If ($ParametersOK -match "False")
                    {
                    write-log
                    write-log -message "SOSS Parameters file DOES NOT match SOR" -ResultFAILure -ResultMessage Failure
                    write-log
                    }
		
            }
}

# Check-ScaleoutServer-5-1-5
# Installs scaleout Server on C:
#################################################		
function Check-ScaleoutServer-5-1-5()
{
if ($Script:EnvironmentType -ne "Prod")
	{
		$InstallPkg = "$Script:StoragePath\3pty\ScaleOut\v_5.1.5.235\soss_setup64.msi"
		$InstallCmd = "msiexec"
		$InstallCmdArgs = "/i `"$InstallPkg`" /quiet INSTALLLEVEL=1000"
		$AppName = "ScaleOut StateServer x64 Edition"
		$AppVersion = "5.1.5"
    	$Script:output = "c:\Program Files\ScaleOut_Software\StateServer\soss_params.txt"
		Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
    }
}

# IIS Rewrite module 2
#################################################
function Check-IISRewriteModule2()
{
	Write-Log
	Write-Log -Message "Checking IIS Rewrite module 2 ..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\IIS\IISRewriteModule2\rewrite_2.0_rtw_x64.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /quiet /norestart"
	$AppName =  "IIS URL Rewrite Module 2"
	$AppVersion = "7.2.2"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}


# IIS Advanced Logging module 
#################################################
function Check-IISAdvancedLoggingModule1()
{
	Write-Log
	Write-Log -Message "Checking IIS Advanced Logging 1.0 ..."
	Write-Log

	# Application itself
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\IIS\IISAdvancedLoggingModule\AdvancedLogging64.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /quiet /norestart"
	$AppName =  "IIS Advanced Logging 1.0"
	$AppVersion = "1.0.0625.10"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}



# Check-AccessDatabaseEngine-12-0-4518-1031
# -checked-
#################################################
function Check-AccessDatabaseEngine()
{	
	# Application itself 
	$InstallPkg = "$Script:StoragePath\3pty\Microsoft\Office\2007OfficeSystemDriver\AceRedist.msi"
    $AppName = "Microsoft Office Access database engine 2007 (English)"
    $InstallCmd = "msiexec"
	$AppVersion = "12.0.4518.1031"
	$InstallCmdArgs = "/i `"$InstallPkg`"/qn /norestart /passive"
    Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}


# Check Gallio v3.3.1
# -checked-
#################################################
function Check-Gallio-v331-x64()
{
	$InstallPkg = "$Script:StoragePath\3pty\Gallio\3.3.1\GallioBundle-3.3.458.0-Setup-x64.msi"
	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /qb /norestart INSTALLDIR=`"d:\Gallio`""
	$AppName = "Gallio 3.3 build 458"
	$AppVersion = "3.3.458.0"
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
}


function Check-SymantecScanEngine52142()
{
	# This requires JRE 1.7.0.x before you install it
	$Category = "APP"
	$AppName = "Symantec Scan Engine"
	$AppVersion = "5.2.14.2"
    $OldAppVersion = "5.2.4.37"

    $InstallCmd = """$Script:StoragePath\3pty\Symantec\Scan_Engine_5.2.14\Win32\install.bat"""
	
	Write-Log
	Write-Log -Message "Checking $AppName ..."
	Write-Log -Message "Install cmd: $InstallCmd"
	Write-Log
	
	$Version = Get-InstalledAppVersion -AppName $AppName 
	$SymantecScanEngine_dir_found = Test-Path "D:\Program Files\Symantec\Scan Engine"
	
    # uninstall old version if found
    if ($Version -eq $OldAppVersion)
    {
        if ($Script:ValidateOnly)
		{
			Write-Log -Message "$AppName ($OldAppVersion)" -Category $Category -ResultFailure -ResultMessage "old version installed"
		}
		else
		{
			Write-Log -Message "$AppName ($OldAppVersion)" -Category $Category -ResultFailure -ResultMessage "old version installed (to be uninstalled)"
            Check-AppUninstall -AppName $AppName
		}
    }

	if ( ( -not $Version ) -or ( $Version -and (-not $SymantecScanEngine_dir_found )  -or ( $Version -eq $OldAppVersion ) ) ) 
	{
		if ($Script:ValidateOnly)
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "not installed"
		}
		else
		{
			Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultFailure -ResultMessage "not installed (to be installed)"
		}
		
		# installing application
		if (-not $Script:ValidateOnly)
		{
			Write-Log -Message "-> Executing: $InstallCmd"
			Invoke-Expression "Start-Process $InstallCmd -Wait -NoNewWindow"
			$Version = Get-InstalledAppVersion -AppName $AppName
			
			$SymantecScanEngine_dir_found = Test-Path "D:\Program Files\Symantec\Scan Engine"
			
			if ( ( -not $Version ) -or ( $Version -and (-not $SymantecScanEngine_dir_found ) ) ) 
			{
				Write-Log -Message "-> Install $AppName ($AppVersion)" -EntryType "ERROR" -ResultFailure -ResultMessage "failure"
			}
			else
			{
				Write-Log -Message "-> Install $AppName ($AppVersion)" -ResultOK -ResultMessage "success"
			}
		}
	}	
	else
	{			
		Write-Log -Message "$AppName ($AppVersion)" -Category $Category -ResultOK -ResultMessage "installed"
	}
	
	## Uninstall Old License ##
	# Remove old license dir

	Write-Log
	Write-Log -Message "Uninstalling old license ..."
	Write-Log


	Check-Directory "C:\Program Files (x86)\Common Files\Symantec Shared\Licenses"
	
	# Next install license file if not there
	Check-File -TargetFile "C:\Program Files (x86)\Common Files\Symantec Shared\Licenses\12086569_25501515.slf" -SourceFile "$Script:StoragePath\3pty\Symantec\Licenses\Scan_or_ProtectionEngine\12086569_25501515.slf"
	
	Check-File -TargetFile "C:\Program Files (x86)\Common Files\Symantec Shared\Licenses\14950661_37444760.slf" -SourceFile "$Script:StoragePath\3pty\Symantec\Licenses\Scan_or_ProtectionEngine\Expiration_May-08-2016\14950661_37444760.slf"

	Check-File -TargetFile "C:\Program Files (x86)\Common Files\Symantec Shared\Licenses\14950661_37444774.slf" -SourceFile "$Script:StoragePath\3pty\Symantec\Licenses\Scan_or_ProtectionEngine\Expiration_May-08-2016\14950661_37444774.slf"

	Check-File -TargetFile "C:\Program Files (x86)\Common Files\Symantec Shared\Licenses\14950661_37444777.slf" -SourceFile "$Script:StoragePath\3pty\Symantec\Licenses\Scan_or_ProtectionEngine\Expiration_May-08-2016\14950661_37444777.slf"
	
	# restart symcscan service to apply new license
	if (-not $Script:ValidateOnly)
	{
		Restart-Service "symcscan"
		if ($?)
		{
			Write-Log -Message "-> restarting symcscan service" -ResultOK -ResultMessage "success"
		}
		else
		{
			Write-Log -Message "-> restarting symcscan service" -EntryType "ERROR" -ResultFailure -ResultMessage  $Error[0].Exception.Message
		}
	}
}


#Get Environment Credentials
function Get-EnvCredential()
{
	if ($Script:Environment -eq 'DEV')
    {
        return  "$Script:DomainName\intbatch"
    }
    elseif ($Script:Environment -eq 'QA')
    {
        return "$Script:DomainName\qabatch"			
    }
    else
    {
        return "$Script:DomainName\batchjob"
    }
}




function Check-SymantecProtectionEngine75034()
{
	# Update Java to the latest version v7
	## Install SPE v7.5##
	$Category = "APP"
	$AppName = "Symantec Protection Engine"
	$AppVersion = "7.5.0.34"
    $InstallCmd = """$Script:StoragePath\3pty\Symantec\Symantec_Protection_Engine\7.5.0.34\Symantec_Protection_Engine\Win32\SymantecProtectionEngine.exe"""
	
    # If INSTALLDIR's name has a space, extra quotes needed. For example '""" D:\Program Files """'
	$installDir = '"""D:\Apps\SymantecProtectionEngine"""'
    $EncryptionPassWord = "48BE10517096C78F798C4E19D094B44F7AE1549129C397A4EE082C67B6DD05F2C23D5CEB226DAA9BAEED6866E5B7D757AC1F5B52ED9B2BC92F5C58F8A48A3796A6602F0DA32E847D97857E2A48D5C2C3"
	$InstallCmdArgs = "/s /v`"/qn ENCRYPTED_PASSWORD=$EncryptionPassWord INSTALLDIR=$installDIR `" "
	
	Check-Application -AppName $AppName -AppVersion $AppVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
	
	Write-Log
	Write-Log -Message "Checking $AppName ..."
	Write-Log -Message "Install cmd: $InstallCmd"
	Write-Log

	## Install License ## 
	# First make sure dir exists
	Check-Directory "C:\ProgramData\Symantec Shared\Licenses"
	
	# Next install license file if not there
	Check-File -TargetFile "C:\ProgramData\Symantec Shared\Licenses\12086569_25501515.slf" -SourceFile "$Script:StoragePath\3pty\Symantec\Licenses\Scan_or_ProtectionEngine\12086569_25501515.slf"
	
	Check-File -TargetFile "C:\ProgramData\Symantec Shared\Licenses\14950661_37444760.slf" -SourceFile "$Script:StoragePath\3pty\Symantec\Licenses\Scan_or_ProtectionEngine\Expiration_May-08-2018\16126669_42802416.slf"

	# restart symcscan service to apply new license
	if (-not $Script:ValidateOnly)
	{
		Restart-Service "symcscan"
		if ($?)
		{
			Write-Log -Message "-> restarting symcscan service" -ResultOK -ResultMessage "success"
		}
		else
		{
			Write-Log -Message "-> restarting symcscan service" -EntryType "ERROR" -ResultFailure -ResultMessage  $Error[0].Exception.Message
		}
	}
	
	#Write-Log
	#Write-Log
	#Write-Log
	
}

function Configure-SafenetConfigV8 
{    
    Param
    (
       [Parameter(Mandatory=$true)]
       [string]$dc1,
	   [Parameter(Mandatory=$true)]
       [int]$typebits
    )

	switch ($typebits) 
    { 
        "32" {$ca_filepath = "C:\Program Files (x86)\SafeNet ProtectApp\DotNet\";break} 
        "64" {$ca_filepath = "C:\Program Files\SafeNet ProtectApp\DotNet\";break} 
   		default {$loopout="now";break}
	}



	if($loopout -eq "now"){break}
	
	$env = $Script:Environment

	$ca_file=("{0}{1}_sn8_client2016.crt" -F $ca_filepath, $env)
	$ca_source_file=("{0}\3pty\SafeNet\Client_8.4.2\clientcerts\{1}_sn8_client2016.crt" -F $Script:StoragePath, $env)
	$config_source_file = ("{3}\3pty\SafeNet\Client_8.4.2\configs\ProtectAppForDotNet.properties.{0}{1}{2}bit" -f $env,$dc1,$typebits,$Script:StoragePath)
	$configfile =("{0}ProtectAppForDotNet.properties" -F $ca_filepath);
    

		Check-File -TargetFile $ca_file -SourceFile $ca_source_file
		Check-File -TargetFile $configfile -SourceFile $config_source_file
		return $returnFile;
		}

function Check-SafeNet8
{ Param
    (
        [Parameter(Mandatory=$true)]
       [string]$Type
	       )
  write-host $type -ForegroundColor Yellow
	switch ($type) 
    { 
        "32bit" {$bitness = "32";
			     $InstallPkg = "$Script:StoragePath\3pty\SafeNet\Client_8.4.2\SafeNet32ProtectApp_NET.msi";break} 
        "64bit" {$bitness = "64";
			     $InstallPkg = "$Script:StoragePath\3pty\SafeNet\Client_8.4.2\SafeNet64ProtectApp_NET.msi";break}  
        "winjava"  {$bitness = "32";
			     $InstallPkg = "$Script:StoragePath\3pty\SafeNet\Client_8.4.2\SafeNet32ProtectApp_NET.msi";break}
		"linuxjava"  {$bitness = "32";
			     $InstallPkg = "$Script:StoragePath\3pty\SafeNet\Client_8.4.2\SafeNet32ProtectApp_NET.msi";break}
   		default {$loopout="now";
            write-host "i broke, you said " $type break;} 
	}
    write-host $Script:DataCenter -ForegroundColor Yellow
    	switch ($Script:DataCenter) 
    { 
        "Bedford" {$dc1="BE";break} 
        "South Boston" {$dc1="SB";break}
   		default {$loopout="now";write-host "NOT IN THIS DATACENTER!!!" ;break}
	}

	if($loopout -eq "now"){
	Write-Log -Message "-> You have a bad value being passed into 'Check-SafeNet8' " -EntryType "ERROR" -ResultFailure 
	break}

	$InstallCmd = "msiexec"
	$InstallCmdArgs = "/I `"$InstallPkg`" /qb /norestart"
	$AppName = ("SafeNet ProtectApp for .NET {0} bit" -f $bitness)
	$oldversion = '5.1.1.010.004'
	$NewVersion = '8.4.2.5'

 
 Check-VersionAppuninstall -AppName $AppName -Version $oldversion
 Check-Application -AppName $AppName -AppVersion $NewVersion -CmdPath $InstallCmd -CmdArguments $InstallCmdArgs
 
 
 
 $AAAdebug = Configure-SafenetConfigV8 -dc1 $dc1 -typebits $bitness 
 	[string]$AppPath = (Get-InstalledAppLocation -AppName $AppName).TOSTRING().TrimEnd("\")

 	Check-Permissions $AppPath -Permissions "NT AUTHORITY\NETWORK SERVICE:(OI)(CI)(R)"
 
} 


function Check-PowerShell5()
{
	#nesting 2 functions inside to do the work 

	Function Get-Posh5InstallParams 
	{ 
		$objectproperties= @{
			KBID = ""
			InstallSource = ""
			InstallCommand = "wusa"
			InstallParams = "/quiet /norestart"
			osVersion = "OS Not Valid"
			Status = "OK"
			}
	$InstallObject = New-Object -TypeName PSObject -Property $objectproperties ;

    $os = (Get-WmiObject -class Win32_OperatingSystem )#-ComputerName "netsvcsa201")
	
	Switch -regex ($os.Caption) 
		{ 
        "Windows 7|2008 R2" {
				$InstallObject.osVersion = $os.Caption; 
				$InstallObject.InstallSource='\3pty\Microsoft\PowerShell_v5\Win7AndW2K8R2-KB3134760-x64.msu';
				$InstallObject.KBID = "KB3134760";		
				}
		"2012 R2" {
				$InstallObject.osVersion = $os.Caption; 
				$InstallObject.InstallSource='\3pty\Microsoft\PowerShell_v5\Win8.1AndW2K12R2-KB3134758-x64.msu';
				$InstallObject.KBID = "KB3134758";
				}
       default {$InstallObject.STATUS = $os.Caption} 
    }
    return $InstallObject
	}

Function test-Posh5
	{
	$haz =  "NEED";
	if ($PSVersionTable.PSVersion.Major -ge 5) { $haz = "OK";}
	return $haz;
	}

	

$OS_Version_based_Install_Params = Get-Posh5InstallParams 
#Write-Host (" You Have {0}  {1}" -f $OS_Version_based_Install_Params.OsVersion,
#									$OS_Version_based_Install_Params.Status)
	Write-Log
	Write-Log -Message "Checking to see if Powershell 5 is alive..."
	Write-Log
# ...\3pty\Microsoft\PowerShell_v5\Win8.1AndW2K12R2-KB3134758-x64.msu
# ...\3pty\Microsoft\PowerShell_v5\Win7AndW2K8R2-KB3134760-x64.msu
	# Application itself

	$intalledstate = test-Posh5
	if ($intalledstate -eq "OK"){
		Write-Log -Message "Powershell 5 is alive!!!!!!" -ResultOK -ResultMessage "installed";
		}
	else{	
	Write-Log -Message "I Find your lack of WMI 5 disturbing." -EntryType "ERROR" -ResultFailure -ResultMessage "not present";
	$intalledstate_params = Get-Posh5InstallParams
	if ( !$Script:ValidateOnly)
	{
		$installaction = ("Start-Process -FilePath `"{0}`" -ArgumentList `"{3}{1} {2}`" -Wait" -f $intalledstate_params.InstallCommand, 
									  $intalledstate_params.InstallSource,
									  $intalledstate_params.InstallParams,
									  $Script:StoragePath)
		
		Write-Log -Message $installaction
										  
		Invoke-Expression $installaction

	}
	

	}

}

# Check Java 7 Safenet 8-4-2
# -checked-
#################################################
function Check-Java-SafeNet8
{ Param
    (
        [Parameter(Mandatory=$true)]
       [int32]$JavaVersion,
       [Parameter(Mandatory=$true)]
       [bool]$SafeNetLegacy
       
	 )
     
	Write-Log
	Write-Log -Message "Checking Java SafeNet..."
	Write-Log
	
	if ( test-path "$($env:JAVA_HOME)\jre" )
	{
		$JRE_HOME =  "$([System.Environment]::GetEnvironmentVariable("JAVA_HOME","Machine"))\jre"
	}
	else
	{
		$JRE_HOME = "$([System.Environment]::GetEnvironmentVariable("JAVA_HOME","Machine"))"
	}

	Write-Log -Message "JRE_HOME: $JRE_HOME"
	
    $libSecurity = "{0}\3pty\SafeNet\java_install\lib.security.Java{1}.zip" -F $Script:StoragePath, $JavaVersion
    $libSecurityTargetDir = "$JRE_HOME\lib\security"
    
    $libExt = "{0}\3pty\SafeNet\java_install\lib.ext.SN8.zip" -F $Script:StoragePath
    $libExtTargetDir = "$JRE_HOME\lib\ext"
    
    Write-Log
	Write-Log -Message "Checking security library files..."
	Write-Log
    
	Check-MSDeployZip -SourceZip $libSecurity -TargetDir $libSecurityTargetDir
    
	Write-Log
	Write-Log -Message "Checking ext library files..."
	Write-Log
	

	Check-MSDeployZip -SourceZip $libExt -TargetDir $libExtTargetDir
    
    $NetworkPath = "$Script:StoragePath\3pty\SafeNet\Client_8.4.2"
    $certSuffix = "_sn8_client2016.crt"
    $envtype = $Script:Environment.tolower()

    

    if (($envtype -imatch "prod") -and ($SafeNetLegacy -eq $true ))
    {
    $NetworkPath = "$Script:StoragePath\3pty\SafeNet\5.1.1"
    $certSuffix = "-sn-km-client.crt"
    }
    
    Write-Log -Message "NetworkPath is $NetworkPath  CERT $certSuffix ENVTYPE: $envtype LEGACY: $SafeNetLegacy" 
    
    # Location of Config/Cert files
    switch ($Script:DataCenter) 
    { 
        "Bedford" {$dc1="be";break} 
        "South Boston" {$dc1="sb";break}
   		default {
				Write-Log -Message "This Data Centre is not supported." -EntryType "ERROR" 
				exit
				break
		}
	}

    
    $extPath = "$JRE_HOME\lib\ext\"

    $CertFile = ("{0}{1}" -F $envtype,$certSuffix)	
	$ca_file=("{0}{1}" -F $extPath, $CertFile)
	$ca_source_file=("{0}\clientcerts\{1}" -F $NetworkPath, $CertFile)
	$config_source_file = ("{0}\configs\IngrianNAE.properties.{1}{2}java" -f $NetworkPath,$envtype,$dc1)
	$configfile =("{0}IngrianNAE.properties" -F $extPath);
    
 <#   if ( ($envtype -imatch "prod") -and ($SafeNetLegacy ))
    {
        
          if ($dc1 -eq "sb")
            {
                $ca_source_file = "$Script:StoragePath\3pty\SafeNet\5.1.1\client_prod\sb\IngrianNAE.properties.java.windows.legacy"
            }
            else
            {
                $ca_source_file = "$Script:StoragePath\3pty\SafeNet\5.1.1\client_prod\bed\IngrianNAE.properties.java.windows.legacy"
            }
                
        }
    
    #>
    # Now, depending on where SafeNet folder sits, we need to copy files accordingly (because the prop file has hard coded path to cert file)
    if (Test-Path -Path "$JRE_HOME\lib\ext\IngrianNAE-8.3.0.000.jar")
    {
        Check-File -TargetFile $ca_file -SourceFile $ca_source_file
	    Check-File -TargetFile $configfile -SourceFile $config_source_file
    }
    else
    {
        Write-Log -Message "Can't find SafeNet necessary files for Java, skipping files check." -EntryType "ERROR" 
        exit
    }

    $alias = $CertFile.split(".")[0]
    $currentLocation= pwd
    set-location "$JRE_HOME\bin"
    $Result =  .\keytool.exe -list -keystore ..\lib\security\cacerts -storepass changeit | select-string -pattern $alias  | select -last 1
    $Result
    if ($Result -imatch $alias)
    {
        Write-Log -Message "-> Java Safenet cert : $alias found " -ResultOK -ResultMessage "success"
    }
    else
    {
        if (-not $Script:ValidateOnly)
        {            
            .\keytool -import -keystore ..\lib\security\cacerts -storepass changeit -alias $alias -file "$JRE_HOME\lib\ext\$CertFile" 
        }
        else
        {
            Write-Log -Message ("Java Safenet Certs: "+$alias ) -Category "Java SafeNet" -ResultFailure -ResultMessage "Missing"
        }
    }
    cd $currentLocation
}

# Check RemoveJavaFolder
# -checked-
#################################################
function Check-RemoveJavaFolder()
{
    $JRE_HOME = "$([System.Environment]::GetEnvironmentVariable("JAVA_HOME","Machine"))"

    Write-Log -Message "Removing Java Folder - $JRE_HOME"
    Check-DirectoryDelete -Path $JRE_HOME -Recursively  $true

}

# Handle the binding redirect that can't be packed into the server level package
# -checked-
#################################################


########################################################################################################
#
#   Software functions - end
#
########################################################################################################
