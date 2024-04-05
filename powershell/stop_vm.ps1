# Log in to Azure Powershell
Connect-AzAccount -Identity

# Retrieve the resource group names from the Azure Automation variable
$resourceGroupsJson = Get-AutomationVariable -Name 'AutomationAccountScope'

# Convert the JSON string back into an array of resource group names
$resourceGroups = $resourceGroupsJson | ConvertFrom-Json

# Iterate over each resource group
foreach ($resourceGroup in $resourceGroups) {
    # Get all VMs in the resource group
    $vms = Get-AzVM -ResourceGroupName $resourceGroup

    # Iterate over each VM
    foreach ($vm in $vms) {
        # Run Azure CLI commands for stopping the virtual machines in the resource group
        Stop-AzVM -ResourceGroupName $resourceGroup -Name $vm.Name -Force
    }
}
