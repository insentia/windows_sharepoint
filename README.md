windows_sharepoint

This is the windows_sharepoint module.

##Module Description

This module allow you to manage user and group in SharePoint 2013


This module use the [AutoSPInstaller Project](http://autospinstaller.codeplex.com/) to install and configure SharePoint. v3.96 (6 July 2014)

All password will be automatically fill if you use Windows AD module and his XML file

The account used for installing SharePoint must be Admin local at least, and SQL sysdbo
Only SharePoint Foundation have been tested with that module. All others versions are not supported.

this module is only compatible with SharePoint 2013.
Only tested wiht puppet agent 3.6.2, Windows Server 2012 R2, SharePoint Foundation 2013 SP1.


##Last Fix/Update
V 0.0.2 :
 - Install SharePoint Foundation 2013 SP1
 - Default webapp/site collection is created
 - Add / Remove Web application
 - Add / Remove Site Collection
 - Fix ordering issue
 
###Setup Requirements
Depends on the following modules:
['puppetlabs/powershell', '>=1.0.2'](https://forge.puppetlabs.com/puppetlabs/powershell),
['puppetlabs/stdlib', '>= 4.2.1'](https://forge.puppetlabs.com/puppetlabs/stdlib)

##Usage

##SharePointInstall
Class windows_sharepoint :
Permit installation of SharePoint

	class{'windows_sharepoint':
	  languagepackspath     => "C:\\source\\LanguagePacks",
	  updatespath    		=> "C:\\source\\Updates",
	  sppath             	=> "C:\\source\\sharepoint.exe",
	  dbserver           	=> "SQL_ALIAS",
	  dbaliasinstance 		=> "COMPUTERNAME",
	  setupaccountpassword  => "P@ssw0rd",
	  spfarmaccount         => "spfarm",
	  spapppoolaccount      => "spapppool",
	  spservicesaccount     => "spservices",
	  spsearchaccount       => "spsearch",
	  spcrawlaccount        => "spcrawl",
	  spsuperreaderaccount  => "spsuperreader",
	  spsuperuseraccount    => "spsuperuser",
	  key                   => "SYOUR-PRODU-CTKEY-OFSPS-2012S",
	  passphrase            => "spsuperuser",
	  webappurl             => "https://localhost/",
	  applicationPool       => "Default AppPool",
	  webappname            => "WebApp",
	  webappport            => 443,
	  webappdatabasename    => "Default_ContentDB",
	  siteurl   		    => "https://localhost/",
	  sitecolname  		    => "Home",
	  sitecollcid			=> "1033",
	  sitecollocale 		=> "en-us",
	  sitecolowner  		=> "spfarm",
	}
	
##webapplication
Ressource windows_sharepoint::webapplication :
Permit installation of SharePoint

	windows_sharepoint::webapplication{"default - $webappname":
	  url                    => "http://localhost",
	  applicationpoolname    => "AppPool_TestPuppet",
	  webappname             => "Test Puppet",
	  databasename           => "SP2013_Content_TestPuppet",
	  applicationpoolaccount => "s-spapppool",
	  ensure                 => present,
	  usessl                 => false,
	  webappport             => 6789,
	}

##user
Resource: windows_sharepoint::user

	windows_sharepoit{'SQLServer':
	  username   => "Jerome",
	  login      => 'jre',
	  group      => "JRE Owners",
	  weburl     => 'https://sharepoint/sites/jre',
	  admin      => true,
	}

Parameters:
```
	$username         # Fullname of the user
	$login            # SamAccountName
	$weburl           # URL of the site where we want to add user
	$group            # Group name where we want put the user
	$admin            # Is SiteColAdmin ? Default : false
```

License
-------
Apache License, Version 2.0

Contact
-------
[Jerome RIVIERE](https://github.com/ninja-2)

Support
-------
Please log tickets and issues at [Github site](https://github.com/insentia/windows_sharepoint/issues)
