output "server_id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.main.id
}

output "server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.main.name
}

output "server_fqdn" {
  description = "The fully qualified domain name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "The name of the created database."
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "administrator_login" {
  description = "The administrator login username."
  value       = azurerm_postgresql_flexible_server.main.administrator_login
}
