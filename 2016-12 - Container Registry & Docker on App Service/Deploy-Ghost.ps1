<#
.SYNOPSIS
    Deploy ghost on App Service on Linux.
.DESCRIPTION
    Deploy an ghost blog in an App Service on Linux in the specified subscription and resource group.
.PARAMETER ResourceGroupName
    Resource Group where Container Registry will be deployed.
.PARAMETER ContainerRegistryName
    Name of your container registry. Between 5 and 50 caracters.
.PARAMETER ContainerRegistryPassword
    Access password for ACR
.PARAMETER AppServiceHostingPlanName
    Name of the App Service Hosting Plan. 
.EXAMPLE
    C:\PS> .\Deploy-Ghost.ps1 -ResourceGroupName "<name of your resource group>" -ContainerRegistryName "<registry name>" -ContainerRegistryPassword "XXX" -AppServiceHostingPlanName "<name of your plan>"
    Create a container registry in Subscription XXXXX and the specified resource group.
.NOTES
    Author: Matthieu Klotz
    Date:   December 20, 2016    
#>

$loginServer = $ContainerRegistryName + "-on.azurecr.io"
$dockerImage =  $loginServer  + "/ghost:latest"
docker login $loginServer -u $ContainerRegistryName -p $ContainerRegistryPassword
docker pull ghost
docker tag ghost $loginServer/ghost:latest
docker push $dockerImage

$deploymentName = "ghostdeploy-" + $(Get-Date).ToString("yyyyMMddHHmm")
New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $ResourceGroupName \
    -TemplateFile ".\ghostdeploy.json" \
    -TemplateParameterObject @{ acrName=$ContainerRegistryName; acrAdminPassword=$ContainerRegistryPassword; hostingPlanName=$AppServiceHostingPlanName } 