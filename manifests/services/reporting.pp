define windows_sharepoint::services::reporting(
  $ensure          = present,
  $servicename     = 'SQL Server Reporting Service Application',
  $proxyname       = 'SQL Server Reporting Service Application Proxy',
  $apppoolname     = 'ReportingServicesAppPool',
  $databasename    = 'ReportingService_Content',
  $databaseserver  = '',
  $serviceaccount  = '',
  $defaultsrvgrp   = true,
){
validate_re($ensure, '^(present|absent)$', 'valid values for ensure are \'present\' or \'absent\'')
validate_bool($defaultsrvgrp)

if(empty($serviceaccount)){
  fail('You need to provide a serviceaccount name wihtout domain')
}
if(empty(databaseserver)){
  fail('You need to provide a database server')
}

  if($ensure == 'present'){
    exec{"Service-Install-$servicename":
      provider => powershell,
      command  => "Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;Install-SPRSService;Install-SPRSServiceProxy;get-spserviceinstance -all |where {\$_.TypeName -like 'SQL Server Reporting*'} | Start-SPServiceInstance",
      timeout  => 600,
      onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){exit 1;}else{Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;\$service = get-spserviceinstance -all | where {\$_.TypeName -like 'SQL Server Reporting*'};if(\$service -eq \$null){exit 0}else{exit 1;}}}else{Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;\$service = get-spserviceinstance -all | where {\$_.TypeName -like 'SQL Server Reporting*'};if(\$service -eq \$null){exit 0}}",
    }

    exec{"Service-Configure-$servicename":
      provider => powershell,
      command  => "Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;\$acct = Get-SPManagedAccount \"\$env:userdomain\\${serviceaccount}\";\$appPoolName = new-spserviceapplicationpool -Name '${apppoolname}' -account \$acct;\$serviceapp = New-SPRSServiceApplication -Name '${servicename}' -ApplicationPool '${apppoolname}' -DatabaseName '${databasename}' -DatabaseServer '${databaseserver}';\$serviceAppProxy = New-SPRSServiceApplicationProxy '${proxyname}' -ServiceApplication \$serviceapp;if('${defaultsrvgrp}' -eq 'true'){Get-SPServiceApplicationProxyGroup -default | Add-SPServiceApplicationProxyGroupMember -Member \$serviceAppProxy;}",
      timeout  => 600,
      onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){exit 1;}else{Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;if((Get-SPRSServiceApplication -Name '${servicename}') -eq \$null){exit 0;}else{exit 1;}}}else{Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;if((Get-SPRSServiceApplication -Name '${servicename}') -eq \$null){exit 0;}else{exit 1;}}",
    }
    Exec["Service-Install-$servicename"] -> Exec["Service-Configure-$servicename"]
  }else{
    exec{"Service-Remove-$servicename":
      provider => powershell,
      command  => "Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;Remove-SPRSServiceApplication -Identity '${servicename}'",
      timeout  => 600,
      onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){exit 1;}else{Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;if((Get-SPRSServiceApplication -Name '${servicename}') -eq \$null){exit 1;}else{exit 0;}}}else{Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;if((Get-SPRSServiceApplication -Name '${servicename}') -eq \$null){exit 1;}else{exit 0;}}",
    }
  }
}