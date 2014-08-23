##
# This class put files and directory in basepath/Puppet-SharePoint
# 
##
class windows_sharepoint::prepsp(
  $basepath          = $basepath,
  $languagepackspath = $languagepackspath,
  $updatespath       = $updatespath,
  $sppath            = $sppath,
  $spversion         = $spversion,
){
  validate_re($spversion, '^(Foundation|Standard|Entreprise)$', 'valid values for mode are \'Foundation\' or \'Standard\' or \'Entreprise\'')
  if(empty($sppath)){
    fail('You need to specify the sharepoint installation path')
  }
  if(!defined(File["${basepath}\\Puppet-SharePoint\\"])){
    file{["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"]:
      ensure => "directory",
    }
  }
  if(!empty($languagepackspath)){
    exec{'copy language packs':
      command => "\$lps = get-item '${languagepackspath}\\*';\$base = '$basepath\\Puppet-SharePoint\\2013\\LanguagePacks';foreach(\$lp in \$lps){\$destination = \$base + '\\' + \$lp.Name;\$source = \$lp.FullName + '/*';if((test-path \$destination) -eq \$false){New-Item -Path \$base -Name \$lp.Name -type Directory;Copy-Item -Path \$source -Destination \$destination -Force -Recurse;}}",
      provider => "powershell",
      onlyif   => "\$lps = get-item '${languagepackspath}\\*';\$base = '$basepath\\Puppet-SharePoint\\2013\\LanguagePacks';\$exist='false';foreach(\$lp in \$lps){\$destination = \$base + '\\' + \$lp.Name;\$source = \$lp.FullName + '/*';if((test-path \$destination) -eq \$true){\$exist = 'true'}}if(\$exist -eq 'true'){exit 1;}",
      timeout  => "600",
    }
  }
  file{"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1":
    source => "puppet:///modules/windows_sharepoint/scripts/AutoSPInstallerFunctions.ps1",
    source_permissions => ignore,
  }
  file{"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1":
    source => "puppet:///modules/windows_sharepoint/scripts/AutoSPInstallerMain.ps1",
    source_permissions => ignore,
  }
  file{"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat":
    source => "puppet:///modules/windows_sharepoint/scripts/AutoSPInstallerLaunch.bat",
    source_permissions => ignore,
  }
  file{"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml":
    source => "puppet:///modules/windows_sharepoint/scripts/AutoSPInstallerInput.xml",
    source_permissions => ignore,
    replace            => false,
  }
  file{"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1":
    source => "puppet:///modules/windows_sharepoint/scripts/AutoSPInstallerFunctionsCustom.ps1",
    source_permissions => ignore,
  }
  file{"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerConfigureRemoteTarget.ps1":
    source => "puppet:///modules/windows_sharepoint/scripts/AutoSPInstallerConfigureRemoteTarget.ps1",
    source_permissions => ignore,
  }

  if(!empty($updatespath)){
    exec{'copy updates':
      command => "",
      provider => "powershell",
      onlyif   => "if(\$true -ne \$false){exit 1}",
      timeout  => "600",
    }
  }
  if($spversion == 'Foundation'){
    exec{'extract SP':
      command => "Start-Process '${sppath}' -ArgumentList '/extract:C:/Puppet-SharePoint/2013/SharePoint /q' -Wait",
      provider => "powershell",
      onlyif   => "if((test-path '${basepath}\\Puppet-SharePoint\\2013\\SharePoint\\setup.exe') -eq \$true){exit 1}",
      timeout  => "600",
    }
  }elsif($spversion == 'Standard'){
    fail('Only Foundation version is supported at the moment')
  }elsif($spversion == 'Entreprise'){
    fail('Only Foundation version is supported at the moment')
  }
  
  if(!empty($languagepackspath)){
    if(!empty($updatespath)){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy language packs'] -> Exec['copy updates'] -> Exec['extract SP']
    }else{
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"]  -> Exec['copy language packs'] -> Exec['extract SP']
    }
  }
  elsif(!empty($updatespath)){
    if(!empty($languagepackspath)){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy language packs'] -> Exec['copy updates'] -> Exec['extract SP']
    }else{
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy updates'] -> Exec['extract SP']
    }
  }else{
    File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['extract SP']
  }
}