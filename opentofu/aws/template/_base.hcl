# Base orchestration configuration
# This file prevents individual module execution and enforces run-all usage

locals {
  # Check if running via orchestrated mode (run-all)
  # Set TERRAGRUNT_ORCHESTRATED=true when using run-all commands
  is_orchestrated = tobool(get_env("TERRAGRUNT_ORCHESTRATED", "false"))

  # Allow individual run only if explicitly permitted
  allow_individual = tobool(get_env("TERRAGRUNT_ALLOW_INDIVIDUAL", "false"))

  # Skip this module if not orchestrated and individual run not allowed
  should_skip = !local.is_orchestrated && !local.allow_individual
}

skip = local.should_skip
