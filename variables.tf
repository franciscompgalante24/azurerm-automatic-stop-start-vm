# ---------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------

variable "tags" {
  description = "Tags for the Automatic Stop-Start VM"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure Location of the Resource Group"
  type        = string
}

variable "automation_account_name" {
  description = "Name of the Automation Account"
  type        = string
}

variable "automation_account_sku" {
  description = "Sku of the Automation Account"
  type        = string
}

variable "stop_vm_runbook_name" {
  description = "Name of the Automation Runbook that stops the vm"
  type        = string
}

variable "start_vm_runbook_name" {
  description = "Name of the Automation Runbook that starts the vm"
  type        = string
}

variable "stop_vm_schedule" {
  description = "Details about the Stop VM Schedule"
  type = object({
    name        = string
    description = string
    frequency   = string
    interval    = number
    timezone    = string
    week_days   = list(string)
    start_hour  = number
  })
}

variable "start_vm_schedule" {
  description = "Details about the Start VM Schedule"
  type = object({
    name        = string
    description = string
    frequency   = string
    interval    = number
    timezone    = string
    week_days   = list(string)
    start_hour  = number
  })
}
