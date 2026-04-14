# fabricConnectAD

A secure R package to connect to Microsoft Fabric using web-based authentication with database discovery capabilities. Designed specifically for VM environments where interactive authentication may be challenging.

## Features

- **Web-Based Authentication**: Browser-based credential entry for VM environments
- **Single Endpoint Connection**: Connect to Fabric endpoint and discover all accessible databases
- **Secure Authentication**: Encrypted password storage with machine-specific keys
- **Database Discovery**: List all databases you have access to
- **Interactive Prompts**: User-friendly email and password prompting
- **Flexible Connection**: Connect to any database after discovery
- **VM Compatible**: Works in restricted environments without JavaScript dependencies

## Installation

### Prerequisites

1. **ODBC Driver 18 for SQL Server** - Must be installed on your system
2. **R (version 3.6.0 or higher)**

### Installation

#### GitHub Installation (Recommended)

```r
# Install from GitHub using remotes
install.packages("remotes")
remotes::install_github("AKU-CDIO/fabricConnectAD")

# Load the package
library(fabricConnectAD)
```

#### Alternative Methods

```r
# Using devtools
install.packages("devtools")
devtools::install_github("AKU-CDIO/fabricConnectAD")

# Git clone method
git clone https://github.com/AKU-CDIO/fabricConnectAD.git
cd fabricConnectAD
install.packages(".", repos=NULL, type='source')
library(fabricConnectAD)
```

## Quick Start

### Web Authentication (Recommended for VM Environments)

```r
library(fabricConnectAD)

# Web-based authentication (opens browser for credentials)
fabric_endpoint <- "your-endpoint.datawarehouse.fabric.microsoft.com"
con_web <- fabric_connect_web(fabric_endpoint, authentication_method = "ActiveDirectoryPassword")

# List all available databases
databases <- fabric_list_databases(con_web)
print(databases)

# Work with data
tables <- fabric_list_tables(con_web)
data <- fabric_read_table(con_web, tables[1], limit = 100)

# Clean up
fabric_disconnect(con_web)
```

### Traditional Authentication

```r
library(fabricConnectAD)

# Connect to Fabric endpoint (will prompt for credentials)
fabric_endpoint <- "your-endpoint.datawarehouse.fabric.microsoft.com"
con <- fabric_connect_ad(fabric_endpoint, store_credentials = TRUE)

# List all available databases
databases <- fabric_list_databases(con)
print(databases)

# Choose a database and connect to it
fabric_disconnect(con)
target_db <- databases$database_name[1]
con_db <- fabric_connect_ad(fabric_endpoint, database_name = target_db)

# Work with tables
tables <- fabric_list_tables(con_db)
data <- fabric_read_table(con_db, tables[1], limit = 100)

# Clean up
fabric_disconnect(con_db)
clear_fabric_credentials()
```

## Functions

### `fabric_connect_web()`
Web-based authentication for VM environments. Opens a local browser for secure credential entry.

**Parameters:**
- `fabric_endpoint` - Fabric endpoint URL (required)
- `database_name` - Database name (optional, defaults to "uzima_db_backup")
- `email` - User email (optional, pre-fills form)
- `password` - User password (optional, pre-fills form)
- `driver` - ODBC driver name (default: "ODBC Driver 18 for SQL Server")
- `port` - Server port (default: 1433)
- `timeout` - Connection timeout in seconds (default: 30)
- `authentication_method` - Authentication method (default: "ActiveDirectoryPassword")
- `web_port` - Local web server port (default: 8765)
- `web_timeout` - Web authentication timeout (default: 300)
- `host` - Local server host (default: "127.0.0.1")

### `fabric_connect_ad()`
Connect to Microsoft Fabric endpoint.

**Parameters:**
- `fabric_endpoint` - Fabric endpoint URL (required)
- `database_name` - Database name (optional, NULL = connect to master for discovery)
- `email` - User email (default: prompts if not provided)
- `password` - User password (optional, prompts if not provided)
- `store_credentials` - Store credentials securely (default: FALSE)
- `prompt_if_missing` - Prompt for missing credentials (default: TRUE)

### `fabric_list_databases(con)`
List all databases you have access to.

### `fabric_list_tables(con)`
List all tables in the connected database.

### `fabric_read_table(con, table_name, limit = 1000, where = NULL)`
Read data from a table with optional filtering.

### `fabric_execute_query(con, sql)`
Execute custom SQL queries.

### `fabric_disconnect(con)`
Close the database connection.

### `clear_fabric_credentials()`
Remove stored credentials securely.

## Usage Examples

### Database Discovery Workflow

```r
library(fabricConnectAD)

# Step 1: Connect to endpoint
con <- fabric_connect_ad("your-endpoint.datawarehouse.fabric.microsoft.com")

# Step 2: Discover databases
databases <- fabric_list_databases(con)
cat("Available databases:\n")
for(db in databases$database_name) {
  cat("-", db, "\n")
}

# Step 3: Connect to specific database
fabric_disconnect(con)
target_db <- databases$database_name[1]
con_db <- fabric_connect_ad("your-endpoint", database_name = target_db)

# Step 4: Work with data
tables <- fabric_list_tables(con_db)
sample_data <- fabric_read_table(con_db, tables[1], limit = 10)
print(sample_data)

# Step 5: Clean up
fabric_disconnect(con_db)
clear_fabric_credentials()
```

### Direct Database Connection

```r
# Connect directly to a known database
con <- fabric_connect_ad(
  fabric_endpoint = "your-endpoint.datawarehouse.fabric.microsoft.com",
  database_name = "your_database"
)

# List tables and read data
tables <- fabric_list_tables(con)
data <- fabric_read_table(con, tables[1], limit = 100)

fabric_disconnect(con)
```

### Custom SQL Queries

```r
con <- fabric_connect_ad("your-endpoint")

# Execute custom query
results <- fabric_execute_query(con, "
  SELECT 
    product_category,
    COUNT(*) as record_count,
    SUM(amount) as total_amount
  FROM sales_data 
  WHERE sale_date >= '2024-01-01'
  GROUP BY product_category
  ORDER BY total_amount DESC
")

print(results)
fabric_disconnect(con)
```

### UZIMA Data Queries

#### Fitbit Daily Steps Data
```r
con <- fabric_connect_web(fabric_endpoint, authentication_method = "ActiveDirectoryPassword")

# Query Fitbit daily steps data for feasibility study participants
df <- dbGetQuery(con, "
SELECT 
    [participantidentifier],
    [date],
    [steps]
FROM [_vw_factfitbitdailydata]
WHERE [participantidentifier] IN (
    SELECT [participantidentifier]
    FROM [_vw_feasibility_study_baseline]
)")

print(head(df, 3))
```

#### Qualtrics Survey Data
```r
# Query all Qualtrics survey data
qualtrics_data <- dbGetQuery(con, "SELECT * FROM Qualtrics")

# Display first few rows
print(head(qualtrics_data, 5))

# Get survey metadata
print("Qualtrics dataset info:")
print(dim(qualtrics_data))
print(names(qualtrics_data))
```

## Security

The package implements enterprise-level security:

- **XOR Encryption**: Passwords encrypted with SHA256-derived keys
- **Machine Binding**: Credentials only work on the same machine
- **Environment Storage**: No files written to disk
- **Key Verification**: Prevents credential tampering
- **Secure Cleanup**: Complete credential removal

## Authentication Flow

1. **First Connection**: Prompts for email and password
2. **Secure Storage**: Encrypts and stores credentials
3. **Subsequent Connections**: Uses stored credentials automatically
4. **Manual Override**: Option to provide credentials directly
5. **Cleanup**: `clear_fabric_credentials()` removes all traces

## Troubleshooting

### Common Issues

1. **ODBC Driver Not Found**
   ```bash
   # Install ODBC Driver 18 for SQL Server
   # Download from: https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server
   ```

2. **Authentication Failed**
   - Verify email and password
   - Check MFA requirements
   - Ensure network connectivity

3. **Connection Timeout**
   ```r
   con <- fabric_connect_ad(endpoint, timeout = 60)
   ```

### Error Messages

- `"fabric_endpoint is required"` - Provide valid endpoint URL
- `"Password is required"` - Enter password when prompted
- `"Failed to connect"` - Check credentials and network

## Repository

### GitHub Repository
- **Repository**: `fabricConnectAD`
- **Owner**: `AKU-CDIO`
- **URL**: https://github.com/AKU-CDIO/fabricConnectAD
- **Installation**: `remotes::install_github("AKU-CDIO/fabricConnectAD")`

## License

MIT License - See LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:
- Create an issue in Azure DevOps
- Check the troubleshooting section
- Review the function documentation
