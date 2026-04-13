# fabricConnectAD Connection Diagnostic Tool
# Run this script to diagnose connection issues

cat("=== fabricConnectAD Connection Diagnostic ===\n\n")

# Load required packages
if (!requireNamespace("odbc", quietly = TRUE)) {
  stop("odbc package is required")
}

# Check ODBC drivers
cat("1. Checking ODBC Drivers:\n")
drivers <- odbc::odbcListDrivers()
fabric_driver <- drivers[grepl("ODBC Driver 1[8-9] for SQL Server", names(drivers), ignore.case = TRUE), ]

if (length(fabric_driver) > 0) {
  cat("   OK: ODBC Driver 18+ found\n")
  cat("   Available drivers:\n")
  for (driver_name in names(fabric_driver)) {
    cat("   -", driver_name, "\n")
  }
} else {
  cat("   ERROR: ODBC Driver 18+ not found\n")
  cat("   Available drivers:\n")
  for (driver_name in names(drivers)) {
    if (grepl("SQL Server", driver_name, ignore.case = TRUE)) {
      cat("   -", driver_name, "\n")
    }
  }
  cat("\n   SOLUTION: Install ODBC Driver 18 for SQL Server\n")
  cat("   Download from: https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server\n")
}

# Test basic connectivity
cat("\n2. Testing Basic Connectivity:\n")
fabric_endpoint <- "fis5jjpzajqe5fxqs4z3vlsjde-zgopmz6jacoezkc3hd6da52lpm.datawarehouse.fabric.microsoft.com"

# Test DNS resolution
tryCatch({
  result <- system2("ping", c("-n", "1", fabric_endpoint), stdout = TRUE, stderr = TRUE)
  if (any(grepl("Reply", result))) {
    cat("   OK: Endpoint is reachable\n")
  } else {
    cat("   WARNING: Endpoint may not be reachable\n")
  }
}, error = function(e) {
  cat("   ERROR: Cannot test endpoint reachability\n")
})

# Test connection with minimal parameters
cat("\n3. Testing Minimal Connection:\n")
tryCatch({
  test_con <- odbc::odbc()
  cat("   OK: ODBC interface available\n")
  
  # Test connection string construction
  conn_string <- paste0(
    "Driver={ODBC Driver 18 for SQL Server};",
    "Server=", fabric_endpoint, ";",
    "Database=master;",
    "Encrypt=yes;",
    "TrustServerCertificate=yes;"
  )
  cat("   Connection string constructed\n")
  
}, error = function(e) {
  cat("   ERROR: ODBC interface issue -", e$message, "\n")
})

# Test authentication methods
cat("\n4. Authentication Check:\n")
cat("   Testing with your credentials...\n")

# Get credentials securely
if (requireNamespace("getPass", quietly = TRUE)) {
  email <- getPass::getPass("Enter email: ")
  password <- getPass::getPass("Enter password: ")
} else {
  email <- readline("Enter email: ")
  password <- readline("Enter password: ")
}

# Test different connection approaches
test_results <- list()

# Test 1: Basic connection
cat("\n   Test 1: Basic Connection\n")
tryCatch({
  con1 <- DBI::dbConnect(
    odbc::odbc(),
    Driver = "ODBC Driver 18 for SQL Server",
    Server = fabric_endpoint,
    Database = "master",
    UID = email,
    PWD = password,
    Encrypt = "yes",
    TrustServerCertificate = "yes",
    Timeout = 10
  )
  test_results$basic <- "SUCCESS"
  DBI::dbDisconnect(con1)
  cat("      SUCCESS: Basic connection works\n")
}, error = function(e) {
  test_results$basic <- paste("FAILED:", e$message)
  cat("      FAILED:", e$message, "\n")
})

# Test 2: With different database
cat("\n   Test 2: Different Database Parameters\n")
tryCatch({
  con2 <- DBI::dbConnect(
    odbc::odbc(),
    Driver = "ODBC Driver 18 for SQL Server",
    Server = fabric_endpoint,
    Database = "master",
    UID = email,
    PWD = password,
    Encrypt = "yes",
    TrustServerCertificate = "no",
    Timeout = 10
  )
  test_results$trust_cert <- "SUCCESS"
  DBI::dbDisconnect(con2)
  cat("      SUCCESS: Works with TrustServerCertificate=no\n")
}, error = function(e) {
  test_results$trust_cert <- paste("FAILED:", e$message)
  cat("      FAILED:", e$message, "\n")
})

# Test 3: Alternative driver
cat("\n   Test 3: Alternative Driver\n")
tryCatch({
  con3 <- DBI::dbConnect(
    odbc::odbc(),
    Driver = "ODBC Driver 17 for SQL Server",
    Server = fabric_endpoint,
    Database = "master",
    UID = email,
    PWD = password,
    Encrypt = "yes",
    TrustServerCertificate = "yes",
    Timeout = 10
  )
  test_results$alt_driver <- "SUCCESS"
  DBI::dbDisconnect(con3)
  cat("      SUCCESS: Works with ODBC Driver 17\n")
}, error = function(e) {
  test_results$alt_driver <- paste("FAILED:", e$message)
  cat("      FAILED:", e$message, "\n")
})

# Summary and recommendations
cat("\n=== Diagnostic Summary ===\n")
if (all(grepl("SUCCESS", test_results))) {
  cat("All connection tests passed! The issue might be in fabricConnectAD parameters.\n")
  cat("Try using these connection settings:\n")
  cat("- Use ODBC Driver 18 for SQL Server\n")
  cat("- Set TrustServerCertificate=yes\n")
  cat("- Use timeout=30 or higher\n")
} else {
  cat("Connection issues detected:\n")
  for (test_name in names(test_results)) {
    cat("- ", test_name, ": ", test_results[[test_name]], "\n")
  }
  
  cat("\nCommon solutions:\n")
  cat("1. Install/Update ODBC Driver 18 for SQL Server\n")
  cat("2. Check Fabric workspace permissions\n")
  cat("3. Verify SQL endpoint is enabled in Fabric\n")
  cat("4. Try different authentication method\n")
  cat("5. Check network/firewall settings\n")
}

cat("\n=== Next Steps ===\n")
cat("1. If basic connection works, the issue is in fabricConnectAD\n")
cat("2. If all tests fail, check Fabric permissions and network\n")
cat("3. Try connecting from SQL Server Management Studio first\n")
cat("4. Contact your Fabric administrator for workspace access\n")

cat("\nDiagnostic complete!\n")
