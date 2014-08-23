define windows_sharepoint::user(
  $ensure          = present,
  $username        = '',
  $login           = '',
  $weburl          = '',
  $group           = '',
  $premissionlevel = '',
  $admin           = false,
){
validate_re($ensure, '^(present|absent)$', 'valid values for ensure are \'present\' or \'absent\'')
validate_bool($admin)
if(!empty($permissionlevel)){
  validate_re($permissionlevel, '^(Full Control|Edit|Contribute|Read|Design)$', 'valid values for ensure are \'Full Control\', \'Edit\', \'Contribute\', \'Read\', \'Design\' ')
}
if(empty($weburl)){
  fail('You need to provide a weburl')
}
if(empty(permissionlevel)){
  fail('You need to provide a permissionlevel')
}
if(empty($login)){
  fail('Login can\'t be empty')
}

if($ensure == 'present'){
  exec{"Add-SPUser - $login - $weburl":
    provider => powershell,
    command  => "Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;if(('${group}' -eq '') -or ('${group}' -eq \$null)){if('${admin}' -eq 'true'){New-SPUser -UserAlias \"\$env:userdomain\\${login}\" -Web '${weburl}' -SiteCollectionAdmin;}else{New-SPUser -UserAlias \"\$env:userdomain\\${login}\" -Web '${weburl}';}\$site = Get-SPSite '${weburl}';\$web.Update();\$web.Dispose(); }else{if('${admin}' -eq 'true' ){New-SPUser -UserAlias \"\$env:userdomain\\${login}\" -Web '${weburl}' -Group '${group}' -SiteCollectionAdmin;}else{New-SPUser -UserAlias \"\$env:userdomain\\${login}\" -Web '${weburl}' -Group '${group}';}\$site = Get-SPSite '${weburl}';\$site.RootWeb.Update();\$site.RootWeb.Dispose();}",
    timeout  => 900,
    onlyif   => "Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue;\$claimslogin=\"i:0#.w|\" + \$env:USERDOMAIN + \"\\${login}\";if(('${group}' -eq '') -or ('${group}' -eq \$null)){\$spuser = Get-SPUser -Web '${weburl}' | Where UserLogin -eq \$claimslogin;}else{\$spuser = Get-SPUser -Web '${weburl}' -Group '${group}'| Where UserLogin -eq \$claimslogin;} if(\$spuser -ne \$null){exit 1}",
  }
}
}