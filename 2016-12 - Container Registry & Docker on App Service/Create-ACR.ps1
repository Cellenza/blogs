<#
.SYNOPSIS
    Create a container registry.
.DESCRIPTION
    Deploy an Azure Container Registry in the specified subscription and resource group.
    If the resource group does not exist, this script will create it.
.PARAMETER SubscriptionId
    Azure Subscription Identifier.
.PARAMETER ResourceGroupName
    Resource Group where Container Registry will be deployed.
.PARAMETER ContainerRegistryName
    Name of your container registry. Between 5 and 50 caracters.
.EXAMPLE
    C:\PS> .\Create-ACR.ps1 -SubscriptionId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX -ResourceGroupName "<name of your resource group>" -ContainerRegistryName "<registry name>"
    Create a container registry in Subscription XXXXX and the specified resource group.
.NOTES
    Author: Matthieu Klotz
    Date:   December 19, 2016    
#>


[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$SubscriptionId,

    [Parameter(Mandatory=$True)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$True)]
    [string]$ContainerRegistryName
)


$deploymentName = $resourceGroupName + $(Get-Date).ToString("yyyyMMddHHmm")
Login-AzureRmAccount | out-null
Select-AzureRmSubscription -SubscriptionId $SubscriptionId | out-null
$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction Ignore
if($rg -eq $null)
{
    $rg = New-AzureRmResourceGroup -Name $ResourceGroupName -Location WestUS
}

$result = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $rg.ResourceGroupName -TemplateUri "https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/101-container-registry/azuredeploy.json" -TemplateParameterObject @{ acrName=$ContainerRegistryName; acrAdminUserEnabled=$true } 
Get-AzureRmResource -ResourceName $ContainerRegistryName -ResourceGroupName $rg.ResourceGroupName -ExpandProperties