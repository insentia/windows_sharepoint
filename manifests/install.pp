# == Class: windows_sharepoint
#
# Full description of class windows_sharepoint here.
#
# === Parameters
#
# === Examples
#
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class windows_sharepoint::install 
(
  $ensure  = present,
  ## XML input file
  $xmlinputfile                              = hiera('windows_sharepoint::xmlinputfile', ''),               # if specify all other options will be desactivated
  $basepath                                  = hiera('windows_sharepoint::basepath', 'C:\\'),
  $userxml                                   = hiera('windows_sharepoint::userxml', 'C:\users.xml'),
  ## Install parameters
  $key                                       = hiera('windows_sharepoint::key', ''),
  $offline                                   = hiera('windows_sharepoint::offline', false),
  $autoadminlogon                            = hiera('windows_sharepoint::autoadminlogon', true),
  $setupaccountpassword                      = hiera('windows_sharepoint::setupaccountpassword', ''),
  $disableloopbackcheck                      = hiera('windows_sharepoint::disableloopbackcheck', true),
  $disableunusedservices                     = hiera('windows_sharepoint::disableunusedservices', true),
  $disableieenhancedsecurity                 = hiera('windows_sharepoint::disableieenhancedsecurity', true),
  $certificaterevocationlistcheck            = hiera('windows_sharepoint::certificaterevocationlistcheck', true),
  
  ## Farm parameters
  $passphrase                                = hiera('windows_sharepoint::passphrase', ''),
  $spfarmaccount                             = hiera('windows_sharepoint::spfarmaccount', ''),
  $spfarmpassword                            = hiera('windows_sharepoint::spfarmpassword', ''),                 # if empty will check XML File
  
  $centraladminprovision                     = hiera('windows_sharepoint::centraladminprovision', 'localhost'),       #where to provision
  $centraladmindatabase                      = hiera('windows_sharepoint::centraladmindatabase', 'Content_Admin'),
  $centraladminport                          = hiera('windows_sharepoint::centraladminport', 4242),
  $centraladminssl                           = hiera('windows_sharepoint::centraladminssl', false),
  
  $dbserver                                  = hiera('windows_sharepoint::dbserver', 'SQL_ALIAS'),                  # name of alias, or name of SQL Server
  $dbalias                                   = hiera('windows_sharepoint::dbalias', true),
  $dbaliasport                               = hiera('windows_sharepoint::dbaliasport', ''),                  # if empty default will used
  $dbaliasinstance                           = hiera('windows_sharepoint::dbaliasinstance', ''),                  # name of SQL Server
  
  $dbprefix                                  = hiera('windows_sharepoint::dbprefix', 'SP2013'),            # Prefix for DB
  $dbuser                                    = hiera('windows_sharepoint::dbuser', ''),
  $dbpassword                                = hiera('windows_sharepoint::dbpassword', ''),
  $configdb                                  = hiera('windows_sharepoint::configdb', 'ConfigDB'),
  
  ## Services part
  $sanboxedcodeservicestart                  = hiera('windows_sharepoint::sanboxedcodeservicestart', false),
  $claimstowindowstokenserverstart           = hiera('windows_sharepoint::claimstowindowstokenserverstart', false),
  $claimstowindowstokenserverupdateaccount   = hiera('windows_sharepoint::claimstowindowstokenserverupdateaccount', false),
  
  $smtpinstall                               = hiera('windows_sharepoint::smtpinstall', false),
  $smtpoutgoingemailconfigure                = hiera('windows_sharepoint::smtpoutgoingemailconfigure', false),
  $smtpoutgoingserver                        = hiera('windows_sharepoint::smtpoutgoingserver', ''),
  $smtpoutgoingemailaddress                  = hiera('windows_sharepoint::smtpoutgoingemailaddress', ''),
  $smtpoutgoingreplytoemail                  = hiera('windows_sharepoint::smtpoutgoingreplytoemail', ''),

  $incomingemailstart                        = hiera('windows_sharepoint::incomingemailstart', 'localhost'),
  $distributedcachestart                     = hiera('windows_sharepoint::distributedcachestart', 'localhost'),
  $workflowtimerstart                        = hiera('windows_sharepoint::workflowtimerstart', 'localhost'),
  $foundationwebapplicationstart             = hiera('windows_sharepoint::foundationwebapplicationstart', 'localhost'),

  $spapppoolaccount                          = hiera('windows_sharepoint::spapppoolaccount', ''),
  $spapppoolpassword                         = hiera('windows_sharepoint::spapppoolpassword', ''),                 # if empty will check XML File
  $spservicesaccount                         = hiera('windows_sharepoint::spservicesaccount', ''),
  $spservicespassword                        = hiera('windows_sharepoint::spservicespassword', ''),                 # if empty will check XML File
  $spsearchaccount                           = hiera('windows_sharepoint::spsearchaccount', ''),
  $spsearchpassword                          = hiera('windows_sharepoint::spsearchpassword', ''),                 # if empty will check XML File
  $spsuperreaderaccount                      = hiera('windows_sharepoint::spsuperreaderaccount', ''),
  $spsuperuseraccount                        = hiera('windows_sharepoint::spsuperuseraccount', ''),
  $spcrawlaccount                            = hiera('windows_sharepoint::spcrawlaccount', ''),
  $spcrawlpassword                           = hiera('windows_sharepoint::spcrawlpassword', ''),                 # if empty will check XML File
  $spsyncaccount                             = hiera('windows_sharepoint::spsyncaccount', ''),
  $spsyncpassword                            = hiera('windows_sharepoint::spsyncpassword', ''),                # if empty will check XML File
  $spusrprfaccount                           = hiera('windows_sharepoint::spusrprfaccount', ''),
  $spusrprfpassword                          = hiera('windows_sharepoint::spusrprfpassword', ''),                # if empty will check XML File
  $spexcelaccount                            = hiera('windows_sharepoint::spexcelaccount', ''),
  $spexcelpassword                           = hiera('windows_sharepoint::spexcelpassword', ''),                # if empty will check XML File

  ## Log
  $logcompress                               = hiera('windows_sharepoint::logcompress', true),
  $iislogspath                               = hiera('windows_sharepoint::iislogspath', 'C:\SPLOGS\IIS'),
  $ulslogspath                               = hiera('windows_sharepoint::ulslogspath', 'C:\SPLOGS\ULS'),
  $usagelogspath                             = hiera('windows_sharepoint::usagelogspath', 'C:\SPLOGS\USAGE'),
  
  ###DefaultWebApp
  $removedefaultwebapp                       = hiera('windows_sharepoint::removedefaultwebapp', false),             # if true the default web app will be removed.
  $webappurl                                 = hiera('windows_sharepoint::webappurl', 'https://localhost'),
  $applicationPool                           = hiera('windows_sharepoint::applicationPool', 'SharePointDefault_App_Pool'),
  $webappname                                = hiera('windows_sharepoint::webappname', 'SharePoint Default Web App'),
  $webappport                                = hiera('windows_sharepoint::webappport', 443),
  $webappdatabasename                        = hiera('windows_sharepoint::webappdatabasename', 'Content_SharePointDefault'),
  
  ##DefaultSiteCol
  $siteurl                                   = hiera('windows_sharepoint::siteurl', 'https://localhost'),
  $sitecolname                               = hiera('windows_sharepoint::sitecolname', 'WebSite'),
  $sitecoltemplate                           = hiera('windows_sharepoint::sitecoltemplate', 'STS#0'),
  $sitecoltime24                             = hiera('windows_sharepoint::sitecoltime24', true),
  $sitecollcid                               = hiera('windows_sharepoint::sitecollcid', 1033),
  $sitecollocale                             = hiera('windows_sharepoint::sitecollocale', 'en-us'),
  $sitecolowner                              = hiera('windows_sharepoint::sitecolowner', ''),
  
  $mysitehost                                = hiera('windows_sharepoint::mysitehost', ''),
  $mysitemanagedpath                         = hiera('windows_sharepoint::mysitemanagedpath', 'personal'),
  
  $spversion                                 = hiera('windows_sharepoint::spversion', 'Foundation'),
  $computername                              = hiera('windows_sharepoint::computername', $::hostname),
)
{
  if(!empty($xmlinputfile)){ # Install with xml file
    ## need to copy $xmlinputfile to C:\Puppet-SharePoint\AutoSPInstaller
    fail('not yet implemented')
  }else{ ## Install without a xml file
    if($spversion != 'Foundation'){
      #fail('XML File will be generated only for Foundation version. For others version please fill you AutoSPInstallerInput.xml file')
      notice("using $spversion")
    }
    if((empty($spfarmaccount) or empty($spapppoolaccount) or empty($spservicesaccount) or empty($spsearchaccount) or empty($spcrawlaccount) or empty($spsuperreaderaccount) or empty($spsuperuseraccount)) and $spversion == 'Foundation'){
       fail('All Accounts need to be specify (spfarmaccount, spapppoolaccount, spservicesaccount, spsearchaccount, spcrawlaccount, spsuperreaderaccount, spsuperuseraccount)')
    }

    if((empty($spfarmaccount) or empty($spapppoolaccount) or empty($spservicesaccount) or empty($spsearchaccount) or empty($spcrawlaccount) or empty($spsuperreaderaccount) or empty($spsuperuseraccount) or empty($spsyncaccount) or empty($spusrprfaccount)) and $spversion == 'Standard'){
       fail('All Accounts need to be specify except spexcelaccount')
    }

    if((empty($spfarmaccount) or empty($spapppoolaccount) or empty($spservicesaccount) or empty($spsearchaccount) or empty($spcrawlaccount) or empty($spsuperreaderaccount) or empty($spsuperuseraccount) or empty($spsyncaccount) or empty($spusrprfaccount) or empty($spexcelaccount)) and $spversion == 'Enterprise'){
       fail('All Accounts need to be specify')
    }

    if($autoadminlogon == true and empty(setupaccountpassword)){
      fail('If autoadminlogin is set to true you need to specify your setup password')
    }
    if(empty($dbserver)){
      fail('DBServer is mandatory')
    }
    if($dbalias == true and empty(dbaliasinstance)){
      fail('Can\'t set DBalias to true without specify a dbaliasinstance')
    }
    if(empty($sitecolowner)){
      fail('Site Col Owner can\'t be empty')
    }
    if(empty(key)){
      fail('A serial number (key) is mandatory')
    }
    if(empty(passphrase)){
      fail('PassPhrase is empty')
    }
    if($centraladminport < 1023 or $centraladminport > 32767 or $centraladminport == 443 or centraladmindatabase == 80){
      fail('centraladminport can\'t be set to this value. CentralAdminPort need to be superior at 1023, inferior at 32767 and different of 443 and 80')
    }
    file{"$basepath\\Puppet-SharePoint\\generatexml.ps1":
      content => template('windows_sharepoint/autospinstaller.erb'),
      replace => yes,
    }
    exec{"Generate XML":
      provider => powershell,
      command  => "$basepath\\Puppet-SharePoint\\generatexml.ps1",
      require  => File["$basepath\\Puppet-SharePoint\\generatexml.ps1"],
      onlyif   => "if ((test-path '${basepath}\\Puppet-SharePoint\\xmlgenerated') -eq \$true){exit 1;}",
    }

    if($spversion == 'Foundation'){

      exec{"Lauching AutoSPInstaller":
        provider => powershell,
        command  => "New-Item -Path \"HKLM:\\Software\\\" -Name 'AutoSPInstaller' -Force | Out-Null;New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 1 -PropertyType 'String' -Force | Out-Null;\$password = ConvertTo-SecureString '${setupaccountpassword}' -AsPlainText -Force; \$cred= New-Object System.Management.Automation.PSCredential (\"\$env:userdomain\\Administrator\", \$password);Start-Process \"\$pshome\\powershell.exe\" -Verb RunAs -Wait -WorkingDirectory '${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\' -ArgumentList '-ExecutionPolicy Bypass .\\AutoSPInstallerMain.ps1 -inputFile \"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml\" -unattended';Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){\$getSPStateServiceApplication = Get-SPStateServiceApplication;if(\$getSPStateServiceApplication -ne \$null){New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 0 -PropertyType 'String' -Force | Out-Null;}}",
        timeout  => "7200",
        onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){\$getSPStateServiceApplication = Get-SPStateServiceApplication;if(\$getSPStateServiceApplication -eq \$null){exit 0;}else{New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 0 -PropertyType 'String' -Force | Out-Null;exit 1;}}else{exit 0;}}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){exit 1;}else{exit 0;}}}" 
      }
    }elsif($spversion == 'Standard'){
      exec{"Lauching AutoSPInstaller":
        provider => powershell,
        command  => "New-Item -Path \"HKLM:\\Software\\\" -Name 'AutoSPInstaller' -Force | Out-Null;New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 1 -PropertyType 'String' -Force | Out-Null;\$password = ConvertTo-SecureString '${setupaccountpassword}' -AsPlainText -Force; \$cred= New-Object System.Management.Automation.PSCredential (\"\$env:userdomain\\Administrator\", \$password);Start-Process \"\$pshome\\powershell.exe\" -Verb RunAs -Wait -WorkingDirectory '${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\' -ArgumentList '-ExecutionPolicy Bypass .\\AutoSPInstallerMain.ps1 -inputFile \"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml\" -unattended';Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){\$getSPUPS = Get-SPServiceApplication | ?{\$_.DisplayName -Match \"User Profile \"};if(\$getSPUPS -ne \$null){New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 0 -PropertyType 'String' -Force | Out-Null;}}",
        timeout  => "7200",
        onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){\$getSPUPS = Get-SPServiceApplication | ?{\$_.DisplayName -Match \"User Profile \"};if(\$getSPUPS -eq \$null){exit 0;}else{New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 0 -PropertyType 'String' -Force | Out-Null;exit 1;}}else{exit 0;}}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){exit 1;}else{exit 0;}}}" 
      }
    }elsif($spversion == 'Enterprise'){
      exec{"Lauching AutoSPInstaller":
        provider => powershell,
        command  => "New-Item -Path \"HKLM:\\Software\\\" -Name 'AutoSPInstaller' -Force | Out-Null;New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 1 -PropertyType 'String' -Force | Out-Null;\$password = ConvertTo-SecureString '${setupaccountpassword}' -AsPlainText -Force; \$cred= New-Object System.Management.Automation.PSCredential (\"\$env:userdomain\\Administrator\", \$password);Start-Process \"\$pshome\\powershell.exe\" -Verb RunAs -Wait -WorkingDirectory '${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\' -ArgumentList '-ExecutionPolicy Bypass .\\AutoSPInstallerMain.ps1 -inputFile \"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml\" -unattended';Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){\$getExcel = Get-SPExcelServiceApplication | ?{\$_.DisplayName -Match \"Excel Services \"};if(\$getExcel -ne \$null){New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 0 -PropertyType 'String' -Force | Out-Null;}}",
        timeout  => "7200",
        onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){\$getExcel = Get-SPExcelServiceApplication | ?{\$_.DisplayName -Match \"Excel Services \"};if(\$getExcel -eq \$null){exit 0;}else{New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 0 -PropertyType 'String' -Force | Out-Null;exit 1;}}else{exit 0;}}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){exit 1;}else{exit 0;}}}" 
      }
    }
    
    exec{"SetCentralAdmin Port":
      provider => powershell,
      command  => "Add-PSSnapin Microsoft.SharePoint.PowerShell -ea SilentlyContinue;Set-SPCentralAdministration -Port ${centraladminport} -Confirm:\$false",
      onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){exit 1;}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;if(\$snapin.count -eq 1){\$getSPStateServiceApplication = Get-SPStateServiceApplication;if(\$getSPStateServiceApplication -eq \$null){exit 1;}else{\$port = [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]::Local.Sites.VirtualServer.Port;if(\$port -eq ${centraladminport}){exit 1;}}}else{exit 1;}}}else{\$port = [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]::Local.Sites.VirtualServer.Port;if(\$port -eq ${centraladminport}){exit 1;}}",
    }
    if($removedefaultwebapp){
      windows_sharepoint::webapplication{"default - $webappname":
        url                    => "${webappurl}",
        applicationpoolname    => "${applicationPool}",
        webappname             => "${webappname}",
        databasename           => "${webappdatabasename}",
        applicationpoolaccount => "${spapppoolaccount}",
        ensure                 => absent,
      }
      Exec["Generate XML"] -> Exec["Lauching AutoSPInstaller"] -> Exec["SetCentralAdmin Port"] -> Windows_sharepoint::Webapplication ["default - $webappname"]
    }else{
      Exec["Generate XML"] -> Exec["Lauching AutoSPInstaller"] -> Exec["SetCentralAdmin Port"]
    }

  }
}
