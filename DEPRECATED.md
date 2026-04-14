# Deprecated Features

## Traditional Authentication (Deprecated)

**⚠️ This authentication method is deprecated and may not work reliably in VM environments.**

### Why Deprecated?

- **VM Compatibility Issues**: Traditional interactive authentication often fails in restricted VM environments
- **JavaScript Dependencies**: Relies on browser features that may be disabled in secure environments
- **Connection Reliability**: Web authentication provides more consistent connection establishment

### Recommended Alternative

Use **Web Authentication** instead:

```r
library(fabricConnectAD)

# Connect using web-based authentication (recommended)
fabric_endpoint <- "your-endpoint.datawarehouse.fabric.microsoft.com"
con <- fabric_connect_web(fabric_endpoint, authentication_method = "ActiveDirectoryPassword")

# List all available databases
databases <- fabric_list_databases(con)
print(databases)

# Choose a database and connect to it
fabric_disconnect(con)
target_db <- databases$database_name[1]
con_db <- fabric_connect_web(fabric_endpoint, database_name = target_db)

# Work with tables
tables <- fabric_list_tables(con_db)
data <- fabric_read_table(con_db, tables[1], limit = 100)

# Clean up
fabric_disconnect(con_db)
```

### Legacy Traditional Authentication (Not Recommended)

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

### Migration Guide

To migrate from traditional to web authentication:

1. **Replace `fabric_connect_ad()` with `fabric_connect_web()`**
2. **Remove `store_credentials` parameter** (web auth handles this automatically)
3. **Use `authentication_method = "ActiveDirectoryPassword"`**
4. **Remove `clear_fabric_credentials()` calls** (not needed for web auth)

### Benefits of Web Authentication

- ✅ **VM Compatible**: Works in restricted environments
- ✅ **No JavaScript Dependencies**: Pure HTML form submission
- ✅ **Reliable Connections**: Consistent authentication flow
- ✅ **Secure**: Encrypted credential handling
- ✅ **User-Friendly**: Browser-based credential entry

---

*Last updated: April 2026*
