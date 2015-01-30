##
# This ressource can add and remove sitecollection on sharepoint
# 
##
define windows_sharepoint::sitecollection(
  $ensure                 = 'present',
  $sitecolurl             = '',
  $sitecolname            = '',
  $sitecoltemplate        = 'STS#0',
  $owneralias             = '',
  $lcid                   = '1033',
  $contentdatabase        = '',
  $description            = 'SiteCol Description',
){
  validate_re($ensure, '^(present|absent)$', 'valid values for mode are \'present\' or \'absent\'')
  if(empty($sitecolurl)){
    fail('You need to specify an url for the sitecollection')
  }
  if(empty($sitecolname)){
    fail('You need to specify a name for the sitecollection')
  }
  if(empty($owneralias)){
    fail('You need to specify the owneralias for the sitecollection')
  }
  if(empty($description)){
    fail('You need to specify a description for the sitecollection')
  }
 if($ensure == present){
    exec{"SiteCol - Create - ${sitecolname}":
      command => "Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;if('${contentdatabase}' -eq ''){New-SPSite -Name '${sitecolname}' -Url '${sitecolurl}' -OwnerAlias '${owneralias}' -Description '${description}' -template '${sitecoltemplate}'}else{New-SPSite -Name '${sitecolname}' -Url '${sitecolurl}' -OwnerAlias '${owneralias}' -ContentDatabase '${contentdatabase}' -Description '${description}' -template '${sitecoltemplate}'}",
      provider => "powershell",
      onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){exit 1;}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;\$getspsite = Get-SPSite -Identity '${sitecolurl}' -erroraction silentlycontinue;if(\$getspsite -eq \$null){exit 0;}else{exit 1;}}}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;\$getspsite = Get-SPSite -Identity '${sitecolurl}' -erroraction silentlycontinue;if(\$getspsite -eq \$null){exit 0;}else{exit 1;}}",
      timeout  => "1200",
    }
  }else{
    exec{"SiteCol - Remove - ${sitecolname}":
      command => "Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;Remove-SPSite -Identity '${sitecolurl}' -Confirm:\$false -GradualDelete",
      provider => "powershell",
      onlyif   => "if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true){if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1'){exit 1;}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;\$getspsite = Get-SPSite -Identity '${sitecolurl}' -erroraction silentlycontinue;if(\$getspsite -eq \$null){exit 1;}}}else{Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;\$getspsite = Get-SPSite -Identity '${sitecolurl}' -erroraction silentlycontinue;if(\$getspsite -eq \$null){exit 1;}}",
      timeout  => "600",
    }
  }
}