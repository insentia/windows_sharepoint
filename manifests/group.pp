##
## Microsoft SharePoint Group Resource
## Tested with SharePoint 2013
##

define windows_sharepoint::group(
  $ensure          = present,
  $groupname       = '',
  $ownername       = '',
  $member          = '',
  $description     = '',
  $weburl          = '',
  $permissionlevel = '',
  $farmaccount     = 'Administrator',
  #$farmpassword    = '',
){
validate_re($ensure, '^(present|absent)$', 'valid values for ensure are \'present\' or \'absent\'')
validate_re($permissionlevel, '^(Full Control|Edit|Contribute|Read|Design)$', 'valid values for ensure are \'Full Control\', \'Edit\', \'Contribute\', \'Read\', \'Design\' ')

if(empty($groupname)){
  fail('Group name can\'t be empty')
}
if(empty($ownername)){
  fail('Owner name can\'t be empty')
}
if(empty($weburl)){
  fail('SPWeb URL need to be provide')
}
#if(empty($farmpassword)){
#  fail('You need to fill the farm password')
#}

  if($ensure == 'present'){
    exec{"Add SPGroup - $groupname":
      provider => powershell,
      command  => "Add-PSSnapin Microsoft.SharePoint.PowerShell -ea SilentlyContinue;\$member=\$null;\$description=\$null;\$ownername=\"\$env:userdomain\\${ownername}\";\$web = Get-SPWeb '${weburl}';\$web.AllowUnsafeUpdates = \$true;\$permissionlevel = '${permissionlevel}';if(('${member}' -eq \$null) -or ('${member}' -eq '')){\$member = \$null};if(('${description}' -eq \$null) -or ('${description}' -eq '')){\$description = \$null};\$owner = \$web | Get-SPUser -identity \$ownername;\$web.SiteGroups.Add('${groupname}',\$owner,\$member,\$description);\$group = \$web.SiteGroups['${groupname}'];\$web.RoleAssignments.Add(\$group);\$roleAssignment = new-object Microsoft.SharePoint.SPRoleAssignment(\$group);\$roleDefinition = \$web.Site.RootWeb.RoleDefinitions[\$permissionLevel];\$roleAssignment.RoleDefinitionBindings.Add(\$roleDefinition);\$web.RoleAssignments.Add(\$roleAssignment);\$web.Update();\$web.Dispose();\$web.AllowUnsafeUpdates = \$false;",
      timeout  => 900,
      onlyif   => "Add-PSSnapin Microsoft.SharePoint.PowerShell -ea SilentlyContinue;\$site = Get-SPSite '${weburl}' -ErrorAction SilentlyContinue;\$url = \$site.url; if(\$url -eq '${weburl}'){if(\$site.RootWeb.Groups['${groupname}'] -ne \$null){exist 1;}}",
    }
  }
  elsif($ensure == 'absent'){

  }
}
