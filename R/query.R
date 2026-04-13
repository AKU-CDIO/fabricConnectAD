#' List All Available Databases in Fabric
#'
#' Retrieves a list of all databases the user has access to in the Fabric endpoint
#'
#' @param con A DBI connection object (connected to master database)
#'
#' @return A data frame with database information
#' @export
#'
#' @examples
#' \dontrun{
#' # Connect to endpoint (no database specified)
#' con <- fabric_connect_ad("your-endpoint.datawarehouse.fabric.microsoft.com")
#' 
#' # List all databases
#' databases <- fabric_list_databases(con)
#' print(databases)
#' 
#' fabric_disconnect(con)
#' }
fabric_list_databases <- function(con) {
  if (!inherits(con, "DBIConnection")) {
    stop("con must be a DBI connection object", call. = FALSE)
  }
  
  tryCatch({
    # Query to get all databases
    sql <- "
      SELECT 
        name as database_name,
        database_id,
        create_date,
        compatibility_level,
        state_desc as state
      FROM sys.databases 
      WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
      ORDER BY name
    "
    
    databases <- DBI::dbGetQuery(con, sql)
    message("Found ", nrow(databases), " accessible databases")
    return(databases)
  }, error = function(e) {
    stop("Failed to list databases: ", e$message)
  })
}

#' List Tables in Fabric Database
#'
#' Retrieves a list of all tables in the connected Fabric database
#'
#' @param con A DBI connection object
#'
#' @return A character vector of table names
#' @export
#'
#' @examples
#' \dontrun{
#' tables <- fabric_list_tables(con)
#' print(tables)
#' }
fabric_list_tables <- function(con) {
  if (!inherits(con, "DBIConnection")) {
    stop("con must be a DBI connection object", call. = FALSE)
  }
  
  tryCatch({
    tables <- DBI::dbListTables(con)
    message("Found ", length(tables), " tables in the database")
    return(tables)
  }, error = function(e) {
    stop("Failed to list tables: ", e$message)
  })
}

#' Read Table Data
#'
#' Reads data from a specified table in the Fabric database
#'
#' @param con A DBI connection object
#' @param table_name Name of the table to read
#' @param limit Maximum number of rows to return (default: 1000)
#' @param where Optional WHERE clause filter (without WHERE keyword)
#'
#' @return A data frame containing the table data
#' @export
#'
#' @examples
#' \dontrun{
#' # Read all data (up to limit)
#' data <- fabric_read_table(con, "my_table")
#' 
#' # Read with filter
#' filtered_data <- fabric_read_table(con, "my_table", where = "column_name > 100")
#' }
fabric_read_table <- function(con, table_name, limit = 1000, where = NULL) {
  if (!inherits(con, "DBIConnection")) {
    stop("con must be a DBI connection object", call. = FALSE)
  }
  
  if (missing(table_name) || is.null(table_name) || table_name == "") {
    stop("table_name is required and cannot be empty")
  }
  
  # Build SQL query
  sql <- sprintf("SELECT TOP %d * FROM %s", as.integer(limit), table_name)
  
  # Add WHERE clause if provided
  if (!is.null(where) && where != "") {
    sql <- paste(sql, "WHERE", where)
  }
  
  tryCatch({
    data <- DBI::dbGetQuery(con, sql)
    message("Read ", nrow(data), " rows from table: ", table_name)
    return(data)
  }, error = function(e) {
    stop("Failed to read table '", table_name, "': ", e$message)
  })
}

#' Execute Custom SQL Query
#'
#' Executes a custom SQL query on the Fabric database
#'
#' @param con A DBI connection object
#' @param sql SQL query string to execute
#'
#' @return A data frame with query results
#' @export
#'
#' @examples
#' \dontrun{
#' # Execute custom query
#' results <- fabric_execute_query(con, "SELECT COUNT(*) as total FROM my_table")
#' print(results)
#' }
fabric_execute_query <- function(con, sql) {
  if (!inherits(con, "DBIConnection")) {
    stop("con must be a DBI connection object", call. = FALSE)
  }
  
  if (missing(sql) || is.null(sql) || sql == "") {
    stop("SQL query is required and cannot be empty")
  }
  
  tryCatch({
    result <- DBI::dbGetQuery(con, sql)
    message("Query executed successfully, returned ", nrow(result), " rows")
    return(result)
  }, error = function(e) {
    stop("Failed to execute query: ", e$message)
  })
}
