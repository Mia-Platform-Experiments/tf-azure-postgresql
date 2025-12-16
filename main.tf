# Map performance profiles to PostgreSQL configurations
locals {
  performance_config = {
    sandbox = {
      sku_name              = "B_Standard_B1ms"  # Burstable - economic for demos
      storage_mb            = 32768              # 32 GB
      backup_retention_days = 7
      ha_enabled            = false
    }
    development = {
      sku_name              = "GP_Standard_D2s_v3"  # General Purpose
      storage_mb            = 131072                # 128 GB
      backup_retention_days = 14
      ha_enabled            = false
    }
    production = {
      sku_name              = "MO_Standard_E4s_v3"  # Memory Optimized
      storage_mb            = 524288                # 512 GB
      backup_retention_days = 35
      ha_enabled            = true
    }
  }
}

# Create PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "psql-${var.service_name}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  version                = var.postgres_version
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  
  sku_name   = local.performance_config[var.performance_profile].sku_name
  storage_mb = local.performance_config[var.performance_profile].storage_mb
  
  backup_retention_days = local.performance_config[var.performance_profile].backup_retention_days

  # Enable high availability only for production
  dynamic "high_availability" {
    for_each = local.performance_config[var.performance_profile].ha_enabled ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }

  tags = {
    environment = var.performance_profile
    managed_by  = "terraform"
    service     = var.service_name
  }
  
  lifecycle {
    ignore_changes = [
      zone  # Let Azure manage zone assignment to avoid conflicts
    ]
  }
}

# Create Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
