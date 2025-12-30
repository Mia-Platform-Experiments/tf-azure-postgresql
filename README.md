# Azure PostgreSQL Flexible Server Terraform Module

This Terraform module provisions an Azure PostgreSQL Flexible Server with automated performance configurations, including storage, backup retention, and high availability settings.

## Features

- **Performance Profiles**: Choose from `sandbox`, `development`, or `production` profiles with automatically configured SKU, storage, backups, and HA
- **Flexible Server**: Uses Azure PostgreSQL Flexible Server for enhanced performance and flexibility
- **Automatic Database Creation**: Creates a database with UTF-8 encoding
- **High Availability**: Automatic zone-redundant HA configuration for production tier
- **Backup Management**: Configurable backup retention based on performance profile
- **Tagged Resources**: Automatic tagging for environment tracking and management

## Performance Profile Mapping

The module automatically maps performance profiles to Azure PostgreSQL configurations:

| Performance Profile | SKU | Storage | Backup Retention | High Availability |
|---------------------|-----|---------|------------------|-------------------|
| `sandbox` | B_Standard_B1ms (Burstable) | 32 GB | 7 days | Disabled |
| `development` | GP_Standard_D2s_v3 (General Purpose) | 128 GB | 14 days | Disabled |
| `production` | MO_Standard_E4s_v3 (Memory Optimized) | 512 GB | 35 days | Enabled (Zone Redundant) |

## Usage

```hcl
module "postgresql" {
  source = "./tf-azure-postgresql"

  service_name           = "payment-service"
  resource_group_name    = "rg-myapp"
  location               = "eastus"
  performance_profile    = "production"
  postgres_version       = "14"
  database_name          = "payments_db"
  administrator_login    = "pgadmin"
  administrator_password = var.db_password  # Store securely, never hardcode
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Inputs

| Name | Description | Type | Required | Sensitive | Validation |
|------|-------------|------|----------|-----------|------------|
| `service_name` | The name of the service (e.g., payment-service). Used for resource naming. | `string` | Yes | No | - |
| `resource_group_name` | The name of the existing Resource Group in Azure. | `string` | Yes | No | - |
| `location` | The Azure region to deploy to. | `string` | Yes | No | - |
| `performance_profile` | The performance tier selected by the developer. Storage size, backup retention, and high availability are automatically configured. | `string` | Yes | No | Must be one of: `sandbox`, `development`, `production` |
| `postgres_version` | The PostgreSQL version to deploy (e.g., "11", "12", "13", "14", "15"). | `string` | Yes | No | - |
| `database_name` | The name of the database to create. | `string` | Yes | No | - |
| `administrator_login` | The administrator username for the PostgreSQL server. | `string` | Yes | No | - |
| `administrator_password` | The administrator password for the PostgreSQL server. | `string` | Yes | Yes | - |

## Outputs

| Name | Description |
|------|-------------|
| `server_id` | The ID of the PostgreSQL Flexible Server. |
| `server_name` | The name of the PostgreSQL Flexible Server. |
| `server_fqdn` | The fully qualified domain name of the PostgreSQL Flexible Server. |
| `database_name` | The name of the created database. |
| `administrator_login` | The administrator login username. |

## Resources Created

- `azurerm_postgresql_flexible_server`: PostgreSQL Flexible Server with performance-based configuration
- `azurerm_postgresql_flexible_server_database`: Database with UTF-8 encoding

## Example with Terraform Variables

```hcl
# variables.tf
variable "db_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

# main.tf
module "postgresql" {
  source = "./tf-azure-postgresql"

  service_name           = "api-service"
  resource_group_name    = "rg-production"
  location               = "westeurope"
  performance_profile    = "production"
  postgres_version       = "15"
  database_name          = "api_db"
  administrator_login    = "dbadmin"
  administrator_password = var.db_password
}

# Output the connection information
output "db_connection_string" {
  value     = "postgresql://${module.postgresql.administrator_login}@${module.postgresql.server_fqdn}:5432/${module.postgresql.database_name}"
  sensitive = true
}
```

## Example with Multiple Databases

```hcl
# Development database
module "dev_db" {
  source = "./tf-azure-postgresql"

  service_name           = "app"
  resource_group_name    = "rg-dev"
  location               = "eastus"
  performance_profile    = "development"
  postgres_version       = "14"
  database_name          = "app_dev"
  administrator_login    = "devadmin"
  administrator_password = var.dev_db_password
}

# Production database with HA
module "prod_db" {
  source = "./tf-azure-postgresql"

  service_name           = "app"
  resource_group_name    = "rg-prod"
  location               = "eastus"
  performance_profile    = "production"
  postgres_version       = "14"
  database_name          = "app_prod"
  administrator_login    = "prodadmin"
  administrator_password = var.prod_db_password
}
```

## SKU Tier Details

### Burstable (B_Standard_B1ms)
- Best for: Development, testing, low-traffic applications
- vCores: 1
- Memory: 2 GiB
- Cost-effective with burstable performance

### General Purpose (GP_Standard_D2s_v3)
- Best for: Most production workloads
- vCores: 2
- Memory: 8 GiB
- Balanced compute and memory

### Memory Optimized (MO_Standard_E4s_v3)
- Best for: Memory-intensive applications
- vCores: 4
- Memory: 32 GiB
- High memory-to-core ratio

## Security Best Practices

1. **Never hardcode passwords**: Use environment variables, Azure Key Vault, or Terraform Cloud variables
2. **Network Security**: Configure firewall rules separately (not included in this module)
3. **SSL/TLS**: PostgreSQL Flexible Server enforces SSL connections by default
4. **Managed Identity**: Consider using Azure Managed Identity for application authentication

## Notes

- The PostgreSQL server is named using the pattern: `psql-{service_name}`
- The database uses UTF-8 encoding with `en_US.utf8` collation
- The module ignores changes to the `zone` attribute to avoid conflicts with Azure's automatic zone management
- High availability (HA) is only enabled for the production profile and uses zone-redundant configuration
- All resources are tagged with environment, managed_by, and service metadata

## Connection String Example

```bash
# Connection string format
postgresql://{administrator_login}@{server_fqdn}:5432/{database_name}?sslmode=require

# Example
postgresql://pgadmin@psql-payment-service.postgres.database.azure.com:5432/payments_db?sslmode=require
```

## License

See the main project LICENSE file for details.
