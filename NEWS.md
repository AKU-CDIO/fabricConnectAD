# fabricConnectAD

Version 0.1.0 (2026-04-13)
========================

* First release of fabricConnectAD
* Connect to Microsoft Fabric Data Engineering Lakehouse endpoints
* Username/password authentication with secure credential storage
* Database discovery functionality to list all accessible databases
* Interactive prompting for missing credentials
* Support for multiple databases within a single Fabric endpoint
* Table listing and data reading capabilities
* Custom SQL query execution
* Secure credential management with encryption
* Machine-specific credential binding for security

## New Functions

* `fabric_connect_ad()` - Connect to Fabric endpoint with authentication
* `fabric_list_databases()` - List all accessible databases
* `fabric_list_tables()` - List tables in connected database
* `fabric_read_table()` - Read data from tables with optional filtering
* `fabric_execute_query()` - Execute custom SQL queries
* `fabric_disconnect()` - Close database connections
* `clear_fabric_credentials()` - Remove stored credentials

## Features

* Secure password storage using XOR encryption
* Machine-specific credential binding
* Environment variable storage (no files written to disk)
* Interactive credential prompting
* Multiple installation methods
- CRAN installation (remotes::install_github)
- Azure DevOps installation
- Direct file download
