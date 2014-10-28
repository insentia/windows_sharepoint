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
  validate_re($spversion, '^(Foundation|Standard|Enterprise)$', 'valid values for mode are \'Foundation\' or \'Standard\' or \'Enterprise\'')
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
      onlyif   => "\$lps = get-item '${languagepackspath}\\*';if(\$lps -ne \$null){\$base = '$basepath\\Puppet-SharePoint\\2013\\LanguagePacks';\$exist='false';foreach(\$lp in \$lps){\$destination = \$base + '\\' + \$lp.Name;\$source = \$lp.FullName + '/*';if((test-path \$destination) -eq \$true){\$exist = 'true'}}if(\$exist -eq 'true'){exit 1;}}else{exit 1;}",
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
      command => "\$source = '${updatespath}\\*';\$destination = '${basepath}\\Puppet-SharePoint\\2013\\Updates';Copy-Item -Path \$source -Destination \$destination -Force -Recurse;",
      provider => "powershell",
      onlyif   => "\$lps = get-item '${updatespath}\\*';if(\$lps -ne \$null){\$base = '${basepath}\\Puppet-SharePoint\\2013\\Updates';\$exist='false';foreach(\$lp in \$lps){\$destination = \$base + '\\' +\$lp.Name;if((test-path \$destination) -eq \$true){\$exist = 'true'; }}if(\$exist -eq 'true'){exit 1;}}else{exit 1;}",
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
  }elsif($spversion == 'Standard' or $spversion == 'Enterprise'){
    windows_isos{'SPStandard':
      ensure   => present,
      isopath  => $sppath,
      xmlpath  => "${basepath}\\Puppet-SharePoint\\isos.xml",
    } -> 
    file{"$basepath\\Puppet-SharePoint\\spcopy.ps1":
      content => template('windows_sharepoint/prepsp-server.erb'),
    } ->
    exec{'extract SP':
      command => "$basepath\\Puppet-SharePoint\\spcopy.ps1;",
      provider => "powershell",
      onlyif   => "if((test-path '${basepath}\\Puppet-SharePoint\\2013\\SharePoint\\setup.exe') -eq \$true){exit 1}",
      timeout  => "600",
    }
  }
  
  if(!empty($languagepackspath)){
    if(!empty($updatespath) and $spversion == 'Foundation'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy language packs'] -> Exec['copy updates'] -> Exec['extract SP']
    }elsif(!empty($updatespath) and $spversion == 'Standard'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy language packs'] -> Exec['copy updates'] -> Windows_isos["SPStandard"]
    }elsif(!empty($updatespath) and $spversion == 'Enterprise'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"]  -> Exec['copy language packs']
    }elsif(empty($updatespath) and $spversion == 'Foundation'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"]  -> Exec['copy language packs'] -> Exec['extract SP']
    }elsif(empty($updatespath) and $spversion == 'Standard'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"]  -> Exec['copy language packs'] -> Windows_isos["SPStandard"]
    }elsif(empty($updatespath) and $spversion == 'Enterprise'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"]  -> Exec['copy language packs']
    }
  }
  elsif(!empty($updatespath)){
    if(!empty($languagepackspath) and $spversion == 'Foundation'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy language packs'] -> Exec['copy updates'] -> Exec['extract SP']
    }elsif(!empty($languagepackspath) and $spversion == 'Standard'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy language packs'] -> Exec['copy updates'] -> Windows_isos["SPStandard"]
    }elsif(!empty($languagepackspath) and $spversion == 'Enterprise'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy language packs'] -> Exec['copy updates']
    }elsif(empty($languagepackspath) and $spversion == 'Foundation'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy updates'] -> Exec['extract SP']
    }elsif(empty($languagepackspath) and $spversion == 'Standard'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy updates'] -> Windows_isos["SPStandard"]
    }elsif(empty($languagepackspath) and $spversion == 'Enterprise'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['copy updates']
    }
  }else{
    if($spversion == 'Foundation'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] -> Exec['extract SP']
    }
    elsif($spversion == 'Standard'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"] ->  Windows_isos["SPStandard"]
    }
    elsif($spversion == 'Enterprise'){
      File["$basepath\\Puppet-SharePoint","$basepath\\Puppet-SharePoint\\AutoSPInstaller","$basepath\\Puppet-SharePoint\\2013","$basepath\\Puppet-SharePoint\\2013\\Updates","$basepath\\Puppet-SharePoint\\2013\\SharePoint","$basepath\\Puppet-SharePoint\\2013\\LanguagePacks"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctionsCustom.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerFunctions.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerMain.ps1"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerLaunch.bat"] -> File["${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml"]
    }
  }
}