##
# This ressource can add and remove webapplication on sharepoint
# 
##
define windows_sharepoint::webapplication(
  $ensure                 = 'present',
  $url                    = '',
  $applicationpoolname    = '',
  $webappname             = '',
  $databasename           = '',
  $applicationpoolaccount = '',
  $usessl                 = true,
  $webappport             = 443,
){
  validate_re($ensure, '^(present|absent)$', 'valid values for mode are \'present\' or \'absent\'')
  validate_bool($usessl)
  if(empty($url)){
    fail('You need to specify the url for the webapplication')
  }
  if(empty($applicationpoolname)){
    fail('You need to specify the application pool for the webapplication')
  }  
  if(empty($webappname)){
    fail('You need to specify the name for the webapplication')
  }
 if($ensure == present){
    exec{"WebApp - Create - ${webappname}":
      command => "Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;if('${databasename}' -eq ''){New-SPWebApplication -Url '${url}' -SecureSocketsLayer:\$${usessl} -Name '${webappname}' -ApplicationPool '${applicationpoolname}' -ApplicationPoolAccount (Get-SPManagedAccount \"$env:userdomain\\${applicationpoolaccount}\") -Port ${webappport}}else{New-SPWebApplication -Url '${url}' -DatabaseName '${databasename}' -SecureSocketsLayer:\$${usessl} -Name '${webappname}' -ApplicationPool '${applicationpoolname}' -ApplicationPoolAccount (Get-SPManagedAccount \"\$env:userdomain\\${applicationpoolaccount}\") -Port ${webappport}}",
      provider => "powershell",
      onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){exit 1;}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;\$getSPWebApplication = Get-SPWebApplication | Where-Object {\$_.DisplayName -eq '${webappname}'};if(\$getSPWebApplication -eq \$null){}else{exit 1;}}}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;\$getSPWebApplication = Get-SPWebApplication | Where-Object {\$_.DisplayName -eq '${webappname}'};if(\$getSPWebApplication -eq \$null){}else{exit 1;}}",
      timeout  => "1200",
    }
  }else{
    exec{"WebApp - Remove - ${webappname}":
      command => "Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;Remove-SPWebApplication '${webappname}' -Confirm:\$false -DeleteIISSite -RemoveContentDatabases",
      provider => "powershell",
      onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){exit 1;}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;\$getSPWebApplication = Get-SPWebApplication | Where-Object {\$_.DisplayName -eq '${webappname}'};if(\$getSPWebApplication -eq \$null){exit 1;}}}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;\$getSPWebApplication = Get-SPWebApplication | Where-Object {\$_.DisplayName -eq '${webappname}'};if(\$getSPWebApplication -eq \$null){exit 1;}}",
      timeout  => "600",
    }
  }
}