# Simple fabricConnectAD Diagnostic
# Run this to check basic connectivity without credentials

cat("=== fabricConnectAD Simple Diagnostic ===\n\n")

# Check ODBC drivers
cat("1. ODBC Drivers Check:\n")
if (requireNamespace("odbc", quietly = TRUE)) {
  drivers <- odbc::odbcListDrivers()
  sql_drivers <- drivers[grepl("SQL Server", names(drivers), ignore.case = TRUE), ]
  
  if (length(sql_drivers) > 0) {
    cat("   Found SQL Server drivers:\n")
    for (driver_name in names(sql_drivers)) {
      cat("   -", driver_name, "\n")
    }
    
    # Check for ODBC Driver 18
    driver_18 <- grepl("ODBC Driver 1[8-9]", names(sql_drivers))
    if (any(driver_18)) {
      cat("   OK: ODBC Driver 18+ available\n")
    } else {
      cat("   WARNING: Only older SQL Server drivers found\n")
      cat("   RECOMMENDATION: Install ODBC Driver 18 for SQL Server\n")
    }
  } else {
    cat("   ERROR: No SQL Server drivers found\n")
    cat("   SOLUTION: Install ODBC Driver 18 for SQL Server\n")
  }
} else {
  cat("   ERROR: odbc package not installed\n")
}

# Test endpoint reachability
cat("\n2. Endpoint Reachability:\n")
fabric_endpoint <- "fis5jjpzajqe5fxqs4z3vlsjde-zgopmz6jacoezkc3hd6da52lpm.datawarehouse.fabric.microsoft.com"

tryCatch({
  # Test DNS resolution
  result <- system2("nslookup", fabric_endpoint, stdout = TRUE, stderr = TRUE)
  if (any(grepl("Address", result))) {
    cat("   OK: Endpoint resolves to IP address\n")
  } else {
    cat("   WARNING: DNS resolution may have issues\n")
  }
}, error = function(e) {
  cat("   ERROR: Cannot test DNS resolution\n")
})

# Test basic connectivity
tryCatch({
  ping_result <- system2("ping", c("-n", "1", fabric_endpoint), stdout = TRUE, stderr = TRUE)
  if (any(grepl("Reply", ping_result))) {
    cat("   OK: Endpoint is reachable\n")
  } else {
    cat("   WARNING: Endpoint may not be reachable\n")
  }
}, error = function(e) {
  cat("   ERROR: Cannot test connectivity\n")
})

# Check fabricConnectAD package
cat("\n3. fabricConnectAD Package Check:\n")
if (requireNamespace("fabricConnectAD", quietly = TRUE)) {
  cat("   OK: fabricConnectAD package is installed\n")
  
  # Check functions
  required_functions <- c("fabric_connect_ad", "fabric_list_databases", "fabric_disconnect")
  for (func in required_functions) {
    if (exists(func, envir = asNamespace("fabricConnectAD"))) {
      cat("   OK:", func, "function available\n")
    } else {
      cat("   ERROR:", func, "function missing\n")
    }
  }
} else {
  cat("   ERROR: fabricConnectAD package not installed\n")
  cat("   SOLUTION: install.packages('remotes'); remotes::install_github('Derekviunza/fabricConnectAD')\n")
}

# Connection string test
cat("\n4. Connection String Test:\n")
tryCatch({
  if (requireNamespace("odbc", quietly = TRUE)) {
    # Test connection string format
    conn_string <- paste0(
      "Driver={ODBC Driver 18 for SQL Server};",
      "Server=", fabric_endpoint, ";",
      "Database=master;",
      "Encrypt=yes;",
      "TrustServerCertificate=yes;"
    )
    cat("   Connection string format: OK\n")
    cat("   Server:", fabric_endpoint, "\n")
    cat("   Database: master\n")
    cat("   Encryption: yes\n")
    cat("   Trust Certificate: yes\n")
  }
}, error = function(e) {
  cat("   ERROR: Cannot create connection string\n")
})

# Recommendations
cat("\n=== Recommendations ===\n")
cat("If you're still getting authentication errors:\n\n")

cat("1. FABRIC ACCESS CHECKS:\n")
cat("   - Go to https://fabric.microsoft.com\n")
cat("   - Verify you can access your workspace\n")
cat("   - Check if SQL endpoint is enabled for your Lakehouse\n")
cat("   - Ensure your account has SQL access permissions\n\n")

cat("2. AUTHENTICATION METHODS:\n")
cat("   - Try without MFA (create App Password if needed)\n")
cat("   - Use your full email address as username\n")
cat("   - Check if password has expired\n\n")

cat("3. NETWORK CHECKS:\n")
cat("   - Ensure port 1433 is open\n")
cat("   - Try from different network/location\n")
cat("   - Check corporate firewall settings\n\n")

cat("4. ALTERNATIVE TESTING:\n")
cat("   - Try connecting with SQL Server Management Studio\n")
cat("   - Test with Azure Data Studio\n")
cat("   - Use different ODBC driver version\n\n")

cat("5. FABRIC SPECIFIC:\n")
cat("   - Verify Lakehouse has SQL endpoint enabled\n")
cat("   - Check workspace capacity limits\n")
cat("   - Ensure Fabric capacity is active\n")

cat("\n=== Test Connection ===\n")
cat("To test with actual credentials, run:\n")
cat("library(fabricConnectAD)\n")
cat("con <- fabric_connect_ad('your-endpoint.datawarehouse.fabric.microsoft.com')\n")

cat("\nDiagnostic complete!\n")
