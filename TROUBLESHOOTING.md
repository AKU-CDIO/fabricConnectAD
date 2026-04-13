# fabricConnectAD Authentication Troubleshooting Guide

## Common Authentication Issues and Solutions

### Issue 1: "Login failed" or Authentication Errors

**Error Message:**
```
Authentication failed. Please check:
1. Email and password are correct
2. Account has access to this Fabric workspace
3. Multi-factor authentication is not blocking access
4. Account is not locked or expired
```

**Solutions:**
1. **Verify Credentials**: Double-check email and password
2. **Fabric Access**: Ensure your account has access to the Fabric workspace
3. **MFA Issues**: If you have MFA enabled, you may need to use an App Password
4. **Account Status**: Check if your account is locked or expired

### Issue 2: Server Connection Problems

**Error Message:**
```
Server connection failed. Please check:
1. Fabric endpoint URL is correct
2. Network connectivity to Microsoft Fabric
3. Firewall is not blocking the connection
4. ODBC Driver 18 is properly installed
```

**Solutions:**
1. **Endpoint URL**: Verify the Fabric endpoint URL is correct
2. **Network**: Check internet connectivity to Microsoft services
3. **Firewall**: Ensure port 1433 is open for SQL connections
4. **ODBC Driver**: Install ODBC Driver 18 for SQL Server

### Issue 3: Connection Timeout

**Error Message:**
```
Connection timeout. Please check:
1. Network connectivity
2. Fabric endpoint is accessible
3. Increase timeout parameter if needed
```

**Solutions:**
1. **Network**: Check network stability
2. **Endpoint**: Test if the endpoint is accessible
3. **Timeout**: Increase timeout parameter in connection function

### Issue 4: Password Input Security

**Problem**: Password is visible when typing

**Solution**: Install the getPass package for secure password input:
```r
install.packages("getPass")
```

After installing getPass, passwords will be hidden during input.

## Testing Authentication

### Step 1: Test Basic Connection
```r
library(fabricConnectAD)

# Test with your endpoint
fabric_endpoint <- "fis5jjpzajqe5fxqs4z3vlsjde-zgopmz6jacoezkc3hd6da52lpm.datawarehouse.fabric.microsoft.com"

# Try connection (will prompt for credentials)
con <- fabric_connect_ad(fabric_endpoint, store_credentials = TRUE)
```

### Step 2: Check ODBC Driver
```r
# Check if ODBC driver is available
odbc::odbcListDrivers()
```

### Step 3: Test with Different Parameters
```r
# Try with increased timeout
con <- fabric_connect_ad(
  fabric_endpoint = fabric_endpoint,
  timeout = 60  # Increase timeout to 60 seconds
)
```

## Fabric Workspace Access Requirements

### Required Permissions:
1. **Fabric Workspace Access**: Your account needs access to the Fabric workspace
2. **Lakehouse Access**: Permission to access the specific Lakehouse
3. **SQL Endpoint**: The SQL endpoint must be enabled for the Lakehouse

### How to Check Access:
1. Go to Fabric Portal: https://fabric.microsoft.com
2. Navigate to your workspace
3. Check if you can see the Lakehouse
4. Verify the SQL endpoint is enabled

## Common Fabric Endpoint Issues

### Endpoint URL Format:
- Correct: `your-endpoint.datawarehouse.fabric.microsoft.com`
- Incorrect: `https://your-endpoint.datawarehouse.fabric.microsoft.com` (no https://)

### Finding Your Endpoint:
1. In Fabric Portal, go to your Lakehouse
2. Click on "SQL endpoint" in the toolbar
3. Copy the endpoint URL (without https://)

## ODBC Driver Installation

### Windows:
1. Download ODBC Driver 18 for SQL Server
2. Install with administrator privileges
3. Restart R/RStudio

### Verification:
```r
# Check installed drivers
odbc::odbcListDrivers()

# Should show "ODBC Driver 18 for SQL Server"
```

## Multi-Factor Authentication (MFA)

### Issue: MFA Blocks Connection
If your account has MFA enabled, standard password authentication may fail.

### Solutions:
1. **App Password**: Create an app password in your Microsoft account
2. **Service Account**: Use a service account without MFA
3. **Access Token**: Use Azure AD token authentication (future feature)

## Network and Firewall Issues

### Required Ports:
- Port 1433: SQL Server connection
- Port 443: HTTPS (for some operations)

### Firewall Rules:
Ensure your firewall allows outbound connections to:
- *.datawarehouse.fabric.microsoft.com
- *.fabric.microsoft.com

## Getting Help

### Debug Information:
```r
# Enable detailed error messages
options(error = recover)

# Test connection with debugging
con <- fabric_connect_ad(
  fabric_endpoint = fabric_endpoint,
  timeout = 60
)
```

### Contact Support:
If issues persist, provide:
1. Full error message
2. Fabric endpoint URL (without sensitive data)
3. ODBC driver version
4. R version and platform

## Quick Checklist

Before contacting support, verify:

- [ ] ODBC Driver 18 is installed
- [ ] Fabric endpoint URL is correct
- [ ] Account has Fabric workspace access
- [ ] Network connectivity to Microsoft services
- [ ] Password is correct (test with Fabric Portal)
- [ ] No firewall blocking port 1433
- [ ] getPass package installed (for secure password input)

This guide should help resolve most authentication issues with fabricConnectAD.
