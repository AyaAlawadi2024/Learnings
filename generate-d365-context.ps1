Write-Host "Updating powerapps CLI tool"
dotnet tool update -g Microsoft.PowerApps.CLI.Tool --add-source https://api.nuget.org/v3/index.json --ignore-failed-sources

Write-Host "Authentication for crm context"
pac auth create --environment https://klfieldservicedev.crm4.dynamics.com/ --name FSDev

Write-Host "Generate code for crm context"
pac modelbuilder build `
  --outdirectory ../KL.IoT.D365.ServiceClient.Contracts `
  --serviceContextName XrmContext `
  --namespace KL.IoT.D365.ServiceClient.Contracts `
  --entitynamesfilter "account;msdyn_iotdevice;msdyn_iotproviderinstance;environmentvariabledefinition;environmentvariablevalue;kl_integrationmapping;kl_integrationaccountdeliveryaddress;msdyn_iotdevicecategory;msdyn_iotalert;msdyn_iotpropertydefinition;kl_iottelemetry;kl_iotaddressidentifier"

# Due to naming conflict between the entity kl_Integrationmapping and the option set kl_integrationmapping we have to rename the optionset file/Enum
$scriptPath = (Get-Location).Path
$optionSetPath = Join-Path -Path $scriptPath -ChildPath "../KL.IoT.D365.ServiceClient.Contracts\OptionSets"
$fileToRename = "kl_integrationmapping.cs"
$newFileName = "kl_integrationmappingEnum.cs"

Set-Location -Path $optionSetPath

if (Test-Path $fileToRename) {

  if (Test-Path $newFileName) {
    Remove-Item -Path $newFileName -Force
  }

  Rename-Item -Path $fileToRename -NewName $newFileName

  $fileContent = Get-Content -Path $newFileName

  $updatedContent = $fileContent -replace "enum kl_integrationmapping", "enum kl_integrationmappingEnum"

  Set-Content -Path $newFileName -Value $updatedContent
}

Set-Location -Path $scriptPath
