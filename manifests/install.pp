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
  $xmlinputfile                              = $xmlinputfile,               # if specify all other options will be desactivated
  $basepath                                  = $basepath,
  $userxml                                   = $userxml,
  ## Install parameters
  $key                                       = $key,
  $offline                                   = $offline,
  $autoadminlogon                            = $autoadminlogon,
  $setupaccountpassword                      = $setupaccountpassword,
  $disableloopbackcheck                      = $disableloopbackcheck,
  $disableunusedservices                     = $disableunusedservices,
  $disableieenhancedsecurity                 = $disableieenhancedsecurity,
  $certificaterevocationlistcheck            = $certificaterevocationlistcheck,
  
  ## Farm parameters
  $passphrase                                = $passphrase,
  $spfarmaccount                             = $spfarmaccount,
  $spfarmpassword                            = $spfarmpassword,                 # if empty will check XML File
  
  $centraladminprovision                     = $centraladminprovision,        #where to provision
  $centraladmindatabase                      = $centraladmindatabase,
  $centraladminport                          = $centraladminport,
  $centraladminssl                           = $centraladminssl,
  
  $dbserver                                  = $dbserver,                  # name of alias, or name of SQL Server
  $dbalias                                   = $dbalias,
  $dbaliasport                               = $dbaliasport,                  # if empty default will used
  $dbaliasinstance                           = $dbaliasinstance,                  # name of SQL Server
  
  $dbprefix                                  = $dbprefix,            # Prefix for DB
  $dbuser                                    = $dbuser,
  $dbpassword                                = $dbpassword,
  $configdb                                  = $configdb,
  
  ## Services part
  $sanboxedcodeservicestart                  = $sanboxedcodeservicestart,
  $claimstowindowstokenserverstart           = $claimstowindowstokenserverstart,
  $claimstowindowstokenserverupdateaccount   = $claimstowindowstokenserverupdateaccount,
  
  $smtpinstall                               = $smtpinstall,
  $smtpoutgoingemailconfigure                = $smtpoutgoingemailconfigure,
  $smtpoutgoingserver                        = $smtpoutgoingserver,
  $smtpoutgoingemailaddress                  = $smtpoutgoingemailaddress,
  $smtpoutgoingreplytoemail                  = $smtpoutgoingreplytoemail,

  $incomingemailstart                        = $incomingemailstart, 
  $distributedcachestart                     = $distributedcachestart, 
  $workflowtimerstart                        = $workflowtimerstart, 
  $foundationwebapplicationstart             = $foundationwebapplicationstart,

  $spapppoolaccount                          = $spapppoolaccount,
  $spapppoolpassword                         = $spapppoolpassword,                 # if empty will check XML File
  $spservicesaccount                         = $spservicesaccount,
  $spservicespassword                        = $spservicespassword,                 # if empty will check XML File
  $spsearchaccount                           = $spsearchaccount,
  $spsearchpassword                          = $spsearchpassword,                 # if empty will check XML File
  $spsuperreaderaccount                      = $spsuperreaderaccount,
  $spsuperuseraccount                        = $spsuperuseraccount,
  $spcrawlaccount                            = $spcrawlaccount,
  $spcrawlpassword                           = $spcrawlpassword,                 # if empty will check XML File

  ## Log
  $logcompress                               = $logcompress,
  $iislogspath                               = $iislogspath,
  $ulslogspath                               = $ulslogspath,
  $usagelogspath                             = $usagelogspath,
  
  ###DefaultWebApp
  $removedefaultwebapp                       = $removedefaultwebapp,              # if true the default web app will be removed.
  $webappurl                                 = $webappurl,
  $applicationPool                           = $applicationPool,
  $webappname                                = $webappname,
  $webappport                                = $webappport,
  $webappdatabasename                        = $webappdatabasename,
  
  ##DefaultSiteCol
  $siteurl                                   = $siteurl,
  $sitecolname                               = $sitecolname,
  $sitecoltemplate                           = $sitecoltemplate,
  $sitecoltime24                             = $sitecoltime24,
  $sitecollcid                               = $sitecollcid,
  $sitecollocale                             = $sitecollocale,
  $sitecolowner                              = $sitecolowner,
  
  $spversion                                 = $spversion,
  $computername                              = $computername,
)
{
  if(!empty($xmlinputfile)){ # Install with xml file
    ## need to copy $xmlinputfile to C:\Puppet-SharePoint\AutoSPInstaller
    fail('not yet implemented')
  }else{ ## Install without a xml file
    if($spversion != 'Foundation'){
      fail('XML File will be generated only for Foundation version. For others version please fill you AutoSPInstallerInput.xml file')
    }
    if(empty($spfarmaccount) or empty($spapppoolaccount) or empty($spservicesaccount) or empty($spsearchaccount) or empty($spcrawlaccount) or empty($spsuperreaderaccount) or empty($spsuperuseraccount)){
       fail('All Accounts need to be specify (spfarmaccount, spapppoolaccount, spservicesaccount, spsearchaccount, spcrawlaccount, spsuperreaderaccount, spsuperuseraccount)')
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

    exec{"Lauching AutoSPInstaller":
      provider => powershell,
      command  => "New-Item -Path \"HKLM:\\Software\\\" -Name 'AutoSPInstaller' -Force | Out-Null;New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 1 -PropertyType 'String' -Force | Out-Null;Start-Process 'powershell.exe' -ArgumentList '-ExecutionPolicy Bypass .\\AutoSPInstallerMain.ps1 -inputFile ${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml -unattended' -Wait  -WorkingDirectory '${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\' -Verb RunAs ;New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 0 -PropertyType 'String' -Force | Out-Null;",
      timeout  => "7200",
      onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1' -eq \$true){Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;\$snapin = Get-PSSnapin '*SharePoint.PowerShell';if(\$snapin.count -eq 1){\$getSPStateServiceApplication = Get-SPStateServiceApplication;if(\$getSPStateServiceApplication -eq \$null){exit 1;}else{New-ItemProperty -Path \"HKLM:\\Software\\AutoSPInstaller\\\" -Name 'PuppetSharePointInstallInProgress' -Value 0 -PropertyType 'String' -Force | Out-Null;exit 1;}}else{exit 1;}}else{exit 1;}}" 
    }

    exec{"SetCentralAdmin Port":
      provider => powershell,
      command  => "Add-PSSnapin Microsoft.SharePoint.PowerShell;Set-SPCentralAdministration -Port ${centraladminport} -Confirm:\$false",
      onlyif   => "Add-PSSnapin 'Microsoft.SharePoint.PowerShell';\$port = [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]::Local.Sites.VirtualServer.Port;if(\$port -eq ${centraladminport}){exit 1;}",
    }
    if(removedefaultwebapp){
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
