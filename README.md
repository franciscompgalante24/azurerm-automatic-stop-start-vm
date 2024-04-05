# Automatic Stop-Start Azure Virtual Machines

This Terraform module is intended to create a schedule for stopping and starting your Azure Virtual Machine. Initially designed for weekend application, its flexible design allows for adaptation to any day of the week according to your needs. 

## Benefits

Utilizing this Terraform module to manage the schedule for stopping and starting Azure Virtual Machines offers several advantages:

1. **Cost Savings**: Automatically stopping VMs during off-hours can significantly reduce Azure costs.
2. **Resource Optimization**: Dynamically starting and stopping VMs based on schedule helps in optimizing resource utilization.
3. **Automation**: It automates the process, removing the need for manual intervention and reducing the risk of human error.
4. **Scalability**: Easy to apply across multiple VMs, making it efficient to manage large or growing Azure environments.
5. **Flexibility**: Offers the ability to customize the schedule based on specific business needs or workload patterns.
6. **Consistency**: Ensures that all VMs follow the same schedule, maintaining operational consistency across the infrastructure.
7. **Infrastructure as Code (IaC)**: Leverages Terraform's IaC capabilities, allowing for version control, repeatability, and easy integration into CI/CD pipelines.

## Example of Module Usage
```
module "automatic_stop_start_vm" {
  source = "https://github.com/franciscompgalante24/azurerm-automatic-stop-start-vm
  resource_group_name = var.resource_group_name
  location = var.location
  automation_account_name = var.automation_account_name
  automation_account_sku  = var.automation_account_sku
  stop_vm_runbook_name = var.stop_vm_runbook_name
  start_vm_runbook_name = var.start_vm_runbook_name
  stop_vm_schedule = var.stop_vm_schedule
  start_vm_schedule = var.start_vm_schedule
  tags = var.tags
}
```

The `stop_vm_schedule` and `start_vm_schedule` should be defined like the following example:

```
stop_vm_schedule = {
  name        = "automation-schedule-stop-vm-sandbox"
  description = "Run on Pre-Early Saturday"
  frequency   = "Week"
  interval    = 1
  timezone    = "Europe/Lisbon"
  week_days   = ["Saturday"]
  start_hour  = 02
}

start_vm_schedule = {
  name        = "automation-schedule-start-vm-sandbox"
  description = "Run on Sunday Night"
  frequency   = "Week"
  interval    = 1
  timezone    = "Europe/Lisbon"
  week_days   = ["Sunday"]
  start_hour  = 22
}
```

In this example, the virtual machine will be stopped during Saturday at 2am and will be running again on Sunday at 22pm.

## Azure services and resources used

- Azure Automation Account

## Author Information
Francisco Galante
