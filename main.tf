# ---------------------------------------------------------
# MAIN.TF
# ---------------------------------------------------------

# Load Resource Group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Check next saturday for stopping the virtual machine
data "external" "next_saturday" {
  program = ["python3", "${path.module}/python/next_saturday.py"]
}

# Check next sunday for starting the virtual machine
data "external" "next_sunday" {
  program = ["python3", "${path.module}/python/next_sunday.py"]
}

# Get variables of stop-start times to pass in azurerm_automation_schedule
locals {
  # Extract only the date from the full start_time string -> "YYYY-MM-DD"
  start_date_stop_vm  = substr(data.external.next_saturday.result["start_time"], 0, 10)
  start_date_start_vm = substr(data.external.next_sunday.result["start_time"], 0, 10)
  # Append user-provided schedule hour to the start_date -> "YYYY-MM-DDT18:00:00+00:00")
  custom_start_time_stop_vm  = format("%sT%02d:00:00+00:00", local.start_date_stop_vm, var.stop_vm_schedule.start_hour)
  custom_start_time_start_vm = format("%sT%02d:00:00+00:00", local.start_date_start_vm, var.start_vm_schedule.start_hour)
}

# -----------------------------------------------------------------------------
# Stop and Start Scripts into Automation Account
# -----------------------------------------------------------------------------

# Powershell script to Stop the VM
data "local_file" "stop_vm" {
  filename = "${path.module}/powershell/stop_vm.ps1"
}

# Powershell script to Start the VM
data "local_file" "start_vm" {
  filename = "${path.module}/powershell/start_vm.ps1"
}

# Create Automation Account
resource "azurerm_automation_account" "automation_account" {
    name                = var.automation_account_name
    location            = var.location != "" ? var.location : data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name
    sku_name            = var.automation_account_sku
    identity {
        type = "SystemAssigned"
    }
    tags = var.tags
}

# Assign Role to Automation Account for logging in to AZ-Powershell via Managed Identity
resource "azurerm_role_assignment" "automation_account_role" {
   scope                = data.azurerm_resource_group.resource_group.id
   role_definition_name = "Virtual Machine Contributor"
   principal_id         = azurerm_automation_account.automation_account.identity[0].principal_id
   depends_on           = [azurerm_automation_account.automation_account]
}

# Resource Group Name in scope -> passed as input to Powershell Script
resource "azurerm_automation_variable_string" "automation_account_rg_variable" {
  name                    = "StopStartRGScope"
  resource_group_name     = data.azurerm_resource_group.resource_group.name
  automation_account_name = azurerm_automation_account.automation_account.name
  value                   = jsonencode(var.resource_group_name)
  encrypted               = true

  depends_on = [azurerm_automation_account.automation_account]
}

# Create an Azure Automation Stop VM Runbook -> Powershell script content
resource "azurerm_automation_runbook" "stop_vm_runbook" {
  name                    = var.stop_vm_runbook_name
  location                = data.azurerm_resource_group.resource_group.location
  resource_group_name     = data.azurerm_resource_group.resource_group.name
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Runbook for Stopping the Virtual Machine"
  runbook_type            = "PowerShell"
  content                 = data.local_file.stop_vm.content

  depends_on = [data.local_file.stop_vm,
  azurerm_automation_variable_string.automation_account_rg_variable]

  tags = var.tags
}

# Create an Azure Automation Start VM Runbook -> Powershell script content
resource "azurerm_automation_runbook" "start_vm_runbook" {
  name                    = var.start_vm_runbook_name
  location                = data.azurerm_resource_group.resource_group.location
  resource_group_name     = data.azurerm_resource_group.resource_group.name
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Runbook for Starting the Virtual Machine"
  runbook_type            = "PowerShell"
  content                 = data.local_file.start_vm.content

  depends_on = [data.local_file.start_vm,
  azurerm_automation_variable_string.automation_account_rg_variable]

  tags = var.tags
}

# Create an Automation Account Schedule
resource "azurerm_automation_schedule" "stop_vm_schedule" {
  name                    = var.stop_vm_schedule.name
  resource_group_name     = data.azurerm_resource_group.resource_group.name
  automation_account_name = azurerm_automation_account.automation_account.name
  description             = var.stop_vm_schedule.description
  frequency               = var.stop_vm_schedule.frequency
  interval                = var.stop_vm_schedule.interval
  timezone                = var.stop_vm_schedule.timezone
  week_days               = var.stop_vm_schedule.week_days
  start_time              = local.custom_start_time_stop_vm
}

resource "azurerm_automation_schedule" "start_vm_schedule" {
  name                    = var.start_vm_schedule.name
  resource_group_name     = data.azurerm_resource_group.resource_group.name
  automation_account_name = azurerm_automation_account.automation_account.name
  description             = var.start_vm_schedule.description
  frequency               = var.start_vm_schedule.frequency
  interval                = var.start_vm_schedule.interval
  timezone                = var.start_vm_schedule.timezone
  week_days               = var.start_vm_schedule.week_days
  start_time              = local.custom_start_time_start_vm
}

# Associate Automation Account Schedule to Runbook -> Powershell script to Stop VM During Weekends
resource "azurerm_automation_job_schedule" "automation_schedule_stop_vm" {
  resource_group_name     = data.azurerm_resource_group.resource_group.name
  automation_account_name = azurerm_automation_account.automation_account.name
  schedule_name           = azurerm_automation_schedule.stop_vm_schedule.name
  runbook_name            = azurerm_automation_runbook.stop_vm_runbook.name

  depends_on = [azurerm_automation_runbook.stop_vm_runbook,
  azurerm_automation_schedule.stop_vm_schedule]
}

# Associate Automation Account Schedule to Runbook -> Powershell script to Start VM During Weekends
resource "azurerm_automation_job_schedule" "automation_schedule_start_vm" {
  resource_group_name     = data.azurerm_resource_group.resource_group.name
  automation_account_name = azurerm_automation_account.automation_account.name
  schedule_name           = azurerm_automation_schedule.start_vm_schedule.name
  runbook_name            = azurerm_automation_runbook.start_vm_runbook.name

  depends_on = [azurerm_automation_runbook.start_vm_runbook,
  azurerm_automation_schedule.start_vm_schedule]
}
