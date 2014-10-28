# == Class: windows_sharepoint
#
# Full description of class windows_sharepoint here.
#
# === Parameters
#
# removedefaultwebapp : A default web app its created when installing SharePoint, you can remove it by set this parameters to true
#
# === Examples
#
# class{'windows_sharepoint':
#   languagepackspath => 'C:\\source\\LanguagePacks',
#   sppath => 'C:\\source\\sharepoint.exe',
#   spversion  => 'Foundation',
#   setupaccountpassword  => 'P@ssw0rd',
#   spfarmaccount => 's-spfarm',
#   dbserver => 'SQL_ALIAS',
#   dbaliasinstance => 'localhost',
#   spapppoolaccount => 'spapppool',
#   spservicesaccount => 'spservices',
#   spsearchaccount => 'spsearch',
#   spcrawlaccount => 'spcrawl',
#   spsuperreaderaccount => 'spsuperreader',
#   spsuperuseraccount => 'spsuperuser',
#   removedefaultwebapp => true,
#   sitecolowner => 'spfarm',
#   key => 'SYOUR-PRODU-CTKEY-OFSPS-2012S',
#   passphrase => 'WeN33daCompl1cat3DP@ssphrase',
# }
# === Authors
#
# Jerome RIVIERE <www.jerome-riviere.re>
#
# === Copyright
#
# Copyright 2014, unless otherwise noted.
#
class windows_sharepoint 
(
  ## Prep SP
  $basepath          = 'C:\\',
  $languagepackspath = '',
  $updatespath       = '',
  $sppath            = '',
  $spversion         = 'Foundation',
  
  ## XML input file
  $xmlinputfile                              = '',               # if specify all other options will be desactivated
  $userxml                                   = 'C:\users.xml',
  ## Install parameters
  $key                                       = '',
  $offline                                   = false,
  $autoadminlogon                            = true,
  $setupaccountpassword                      = '',
  $disableloopbackcheck                      = true,
  $disableunusedservices                     = true,
  $disableieenhancedsecurity                 = true,
  $certificaterevocationlistcheck            = true,
  
  ## Farm parameters
  $passphrase                                = '',
  $spfarmaccount                             = '',
  $spfarmpassword                            = '',                 # if empty will check XML File
  
  $centraladminprovision                     = 'localhost',        #where to provision
  $centraladmindatabase                      = 'Content_Admin',
  $centraladminport                          = 4242,
  $centraladminssl                           = false,
  
  $dbserver                                  = 'SQL_ALIAS',                  # name of alias, or name of SQL Server
  $dbalias                                   = true,
  $dbaliasport                               = '',                  # if empty default will used
  $dbaliasinstance                           = '',                  # name of SQL Server
  
  $dbprefix                                  = 'SP2013',            # Prefix for DB
  $dbuser                                    = '',
  $dbpassword                                = '',
  $configdb                                  = 'ConfigDB',
  
  ## Services part
  $sanboxedcodeservicestart                  = false,
  $claimstowindowstokenserverstart           = false,
  $claimstowindowstokenserverupdateaccount   = false,
  
  $smtpinstall                               = false,
  $smtpoutgoingemailconfigure                = false,
  $smtpoutgoingserver                        = '',
  $smtpoutgoingemailaddress                  = '',
  $smtpoutgoingreplytoemail                  = '',

  $incomingemailstart                        = 'localhost', 
  $distributedcachestart                     = 'localhost', 
  $workflowtimerstart                        = 'localhost', 
  $foundationwebapplicationstart             = 'localhost',

  $spapppoolaccount                          = '',
  $spapppoolpassword                         = '',                 # if empty will check XML File
  $spservicesaccount                         = '',
  $spservicespassword                        = '',                 # if empty will check XML File
  $spsearchaccount                           = '',
  $spsearchpassword                          = '',                 # if empty will check XML File
  $spsuperreaderaccount                      = '',
  $spsuperuseraccount                        = '',
  $spcrawlaccount                            = '',
  $spcrawlpassword                           = '',                 # if empty will check XML File
  $spsyncaccount                             = '',
  $spsyncpassword                            = '',                 # if empty will check XML File
  $spusrprfaccount                           = '',
  $spusrprfpassword                          = '',                # if empty will check XML File
  $spexcelaccount                            = '',
  $spexcelpassword                           = '',                # if empty will check XML File

  ## Log
  $logcompress                               = true,
  $iislogspath                               = 'C:\SPLOGS\IIS',
  $ulslogspath                               = 'C:\LOGS\ULS',
  $usagelogspath                             = 'C:\LOGS\USAGE',
  
  ###DefaultWebApp
  $removedefaultwebapp                       = false,              # if true the default web app will be removed.
  $webappurl                                 = 'https://localhost',
  $applicationPool                           = 'SharePointDefault_App_Pool',
  $webappname                                = 'SharePoint Default Web App',
  $webappport                                = 443,
  $webappdatabasename                        = 'Content_SharePointDefault',
  
  ##DefaultSiteCol
  $siteurl                                   = 'https://localhost',
  $sitecolname                               = 'WebSite',
  $sitecoltemplate                           = 'STS#0',
  $sitecoltime24                             = true,
  $sitecollcid                               = 1033,
  $sitecollocale                             = 'en-us',
  $sitecolowner                              = '',  
  
  $mysitehost                                = hiera('windows_sharepoint::mysitehost', ''),
  $mysitemanagedpath                         = hiera('windows_sharepoint::mysitemanagedpath', 'personal'),
  
  $computername                              = $::hostname,        #will take computername from facter
){
  class{"windows_sharepoint::prepsp":
    basepath          => $basepath,
    languagepackspath => $languagepackspath,
    updatespath       => $updatespath,
    sppath            => $sppath,
    spversion         => $spversion,
  }

  class{"windows_sharepoint::install":
  ## XML input file
    xmlinputfile                              => $xmlinputfile,
    basepath                                  => $basepath,
    userxml                                   => $userxml,
  ## Install parameters
    key                                       => $key,
    offline                                   => $offline,
    autoadminlogon                            => $autoadminlogon,
    setupaccountpassword                      => $setupaccountpassword,
    disableloopbackcheck                      => $disableloopbackcheck,
    disableunusedservices                     => $disableunusedservices,
    disableieenhancedsecurity                 => $disableieenhancedsecurity,
    certificaterevocationlistcheck            => $certificaterevocationlistcheck,

  ## Farm parameters
    passphrase                                => $passphrase,
    spfarmaccount                             => $spfarmaccount,
    spfarmpassword                            => $spfarmpassword,

    centraladminprovision                     => $centraladminprovision,
    centraladmindatabase                      => $centraladmindatabase,
    centraladminport                          => $centraladminport,
    centraladminssl                           => $centraladminssl,

    dbserver                                  => $dbserver,
    dbalias                                   => $dbalias,
    dbaliasport                               => $dbaliasport,
    dbaliasinstance                           => $dbaliasinstance,

    dbprefix                                  => $dbprefix,
    dbuser                                    => $dbuser,
    dbpassword                                => $dbpassword,
    configdb                                  => $configdb,

  ## Services part
    sanboxedcodeservicestart                  => $sanboxedcodeservicestart,
    claimstowindowstokenserverstart           => $claimstowindowstokenserverstart,
    claimstowindowstokenserverupdateaccount   => $claimstowindowstokenserverupdateaccount,

    smtpinstall                               => $smtpinstall,
    smtpoutgoingemailconfigure                => $smtpoutgoingemailconfigure,
    smtpoutgoingserver                        => $smtpoutgoingserver,
    smtpoutgoingemailaddress                  => $smtpoutgoingemailaddress,
    smtpoutgoingreplytoemail                  => $smtpoutgoingreplytoemail,

    incomingemailstart                        => $incomingemailstart, 
    distributedcachestart                     => $distributedcachestart, 
    workflowtimerstart                        => $workflowtimerstart, 
    foundationwebapplicationstart             => $foundationwebapplicationstart,

    spapppoolaccount                          => $spapppoolaccount,
    spapppoolpassword                         => $spapppoolpassword,
    spservicesaccount                         => $spservicesaccount,
    spservicespassword                        => $spservicespassword,
    spsearchaccount                           => $spsearchaccount,
    spsearchpassword                          => $spsearchpassword,
    spsuperreaderaccount                      => $spsuperreaderaccount,
    spsuperuseraccount                        => $spsuperuseraccount,
    spcrawlaccount                            => $spcrawlaccount,
    spcrawlpassword                           => $spcrawlpassword,
    spsyncaccount                             => $spsyncaccount,
    spsyncpassword                            => $spsyncpassword,
    spusrprfaccount                           => $spusrprfaccount,
    spusrprfpassword                          => $spusrprfpassword,
    spexcelaccount                            => $spexcelaccount,
    spexcelpassword                           => $spexcelpassword,

  ## Log
    logcompress                               => $logcompress,
    iislogspath                               => $iislogspath,
    ulslogspath                               => $ulslogspath,
    usagelogspath                             => $usagelogspath,

  ###DefaultWebApp
    removedefaultwebapp                       => $removedefaultwebapp,
    webappurl                                 => $webappurl,
    applicationPool                           => $applicationPool,
    webappname                                => $webappname,
    webappport                                => $webappport,
    webappdatabasename                        => $webappdatabasename,

  ##DefaultSiteCol
    siteurl                                   => $siteurl,
    sitecolname                               => $sitecolname,
    sitecoltemplate                           => $sitecoltemplate,
    sitecoltime24                             => $sitecoltime24,
    sitecollcid                               => $sitecollcid,
    sitecollocale                             => $sitecollocale,
    sitecolowner                              => $sitecolowner,

    spversion                                 => $spversion,
    computername                              => $computername,
  }
  anchor{'windows_sharepoint::begin':} -> Class["windows_sharepoint::prepsp"] -> Class["windows_sharepoint::install"] -> anchor{'windows_sharepoint::end':}
}
