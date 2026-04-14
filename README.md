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

#### Step 1: Discover Available Tables
```r
# Connect via web authentication
con <- fabric_connect_web(fabric_endpoint, authentication_method = "ActiveDirectoryPassword")

# List all available tables
tables <- fabric_list_tables(con)
print("Available tables:")
print(tables)
```

#### Step 2: Query Fitbit Daily Steps Data
```r
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

#### Step 3: Query Qualtrics Survey Data (Key Dimensions)
```r
# Query Qualtrics survey data with key dimensions only
qualtrics_data <- dbGetQuery(con, "
SELECT [UniqueID],
    [ResponseID],
    [RecipientEmail],
    [Finished],
    [Status],
    [ADHD_sum],
    [ADHD_weightedAvg],
    [ADHD_weightedStdDev],
    [DEP_CRIT_1a_sum],
    [DEP_CRIT_1a_weightedAvg],
    [DEP_CRIT_1a_weightedStdDev],
    [DEP_CRIT_1b_sum],
    [DEP_CRIT_1b_weightedAvg],
    [DEP_CRIT_1b_weightedStdDev],
    [DEP_CRIT_2_sum],
    [DEP_CRIT_2_weightedAvg],
    [DEP_CRIT_2_weightedStdDev],
    [DEP_CRIT_3_sum],
    [DEP_CRIT_3_weightedAvg],
    [DEP_CRIT_3_weightedStdDev],
    [GAD_CRIT_1_sum],
    [GAD_CRIT_1_weightedAvg],
    [GAD_CRIT_1_weightedStdDev],
    [GAD_CRIT_2_sum],
    [GAD_CRIT_2_weightedAvg],
    [GAD_CRIT_2_weightedStdDev],
    [BIP_CRIT_1_sum],
    [BIP_CRIT_1_weightedAvg],
    [BIP_CRIT_1_weightedStdDev],
    [BIP_CRIT_2_sum],
    [BIP_CRIT_2_weightedAvg],
    [BIP_CRIT_2_weightedStdDev],
    [BIP_CRIT_3a_sum],
    [BIP_CRIT_3a_weightedAvg],
    [BIP_CRIT_3a_weightedStdDev],
    [BIP_CRIT_3b_sum],
    [BIP_CRIT_3b_weightedAvg],
    [BIP_CRIT_3b_weightedStdDev],
    [BIP_CRIT_3c_sum],
    [BIP_CRIT_3c_weightedAvg],
    [BIP_CRIT_3c_weightedStdDev],
    [BIP_CRIT_3d_sum],
    [BIP_CRIT_3d_weightedAvg],
    [BIP_CRIT_3d_weightedStdDev],
    [BIP_CRIT_3e_sum],
    [BIP_CRIT_3e_weightedAvg],
    [BIP_CRIT_3e_weightedStdDev],
    [ALC_CRIT_1_sum],
    [ALC_CRIT_1_weightedAvg],
    [ALC_CRIT_1_weightedStdDev],
    [ALC_CRIT_2_sum],
    [ALC_CRIT_2_weightedAvg],
    [ALC_CRIT_2_weightedStdDev],
    [ALC_CRIT_3_sum],
    [ALC_CRIT_3_weightedAvg],
    [ALC_CRIT_3_weightedStdDev],
    [ALC_CRIT_4_sum],
    [ALC_CRIT_4_weightedAvg],
    [ALC_CRIT_4_weightedStdDev],
    [ALC_CRIT_5_sum],
    [ALC_CRIT_5_weightedAvg],
    [ALC_CRIT_5_weightedStdDev],
    [ALC_CRIT_6_sum],
    [ALC_CRIT_6_weightedAvg],
    [ALC_CRIT_6_weightedStdDev],
    [ALC_CRIT_7_sum],
    [ALC_CRIT_7_weightedAvg],
    [ALC_CRIT_7_weightedStdDev],
    [ALC_CRIT_8_sum],
    [ALC_CRIT_8_weightedAvg],
    [ALC_CRIT_8_weightedStdDev],
    [DRUG_CRIT_1_sum],
    [DRUG_CRIT_1_weightedAvg],
    [DRUG_CRIT_1_weightedStdDev],
    [DRUG_CRIT_2_sum],
    [DRUG_CRIT_2_weightedAvg],
    [DRUG_CRIT_2_weightedStdDev],
    [G1G2_CRIT_sum],
    [G1G2_CRIT_weightedAvg],
    [G1G2_CRIT_weightedStdDev],
    [H3_CRIT_sum],
    [H3_CRIT_weightedAvg],
    [H3_CRIT_weightedStdDev],
    [PAN_CRIT_1_sum],
    [PAN_CRIT_1_weightedAvg],
    [PAN_CRIT_1_weightedStdDev],
    [PAN_CRIT_2_sum],
    [PAN_CRIT_2_weightedAvg],
    [PAN_CRIT_2_weightedStdDev],
    [PAN_CRIT_3_sum],
    [PAN_CRIT_3_weightedAvg],
    [PAN_CRIT_3_weightedStdDev],
    [PAN_CRIT_4_sum],
    [PAN_CRIT_4_weightedAvg],
    [PAN_CRIT_4_weightedStdDev],
    [PAN_CRIT_5_sum],
    [PAN_CRIT_5_weightedAvg],
    [PAN_CRIT_5_weightedStdDev],
    [CBLS_SCOR_1_sum],
    [CBLS_SCOR_1_weightedAvg],
    [CBLS_SCOR_1_weightedStdDev],
    [Q_TotalDuration],
    [CBLS_SCOR_1],
    [CBLS1],
    [CBLS2],
    [CBLS3],
    [CBLS4],
    [CBLS5],
    [CBLS6],
    [CBLS7],
    [CBLS8],
    [CBLS9],
    [CBLS10],
    [CBLS11],
    [CBLS12],
    [CBLS13],
    [CBLS14],
    [TRT_FLG_ADHD],
    [TRT_FLG_Depr],
    [TRT_FLG_Anx],
    [TRT_FLG_Panic],
    [TRT_FLG_Bip],
    [TRT_FLG_Anger],
    [TRT_FLG_PTSD],
    [TRT_FLG_SocAnx],
    [TRT_FLG_Binge],
    [TRT_FLG_Purge],
    [TRT_FLG_Alc],
    [TRT_FLG_Drug],
    [TRT_FLG_Ideat_Freq30day],
    [TRT_FLG_Ideat_12mActOn],
    [TRT_FLG_NSSI],
    [ADHD_SCOR],
    [GroupAssign],
    [E1_TEXT],
    [DEP_CRIT_2],
    [DEP_CRIT_3],
    [DEP_CRIT_1a],
    [DEP_CRIT_1b],
    [E3],
    [POS1],
    [POS2],
    [E4_TEXT],
    [GAD_CRIT_1],
    [GAD_CRIT_2],
    [PAN_INTRO],
    [POS_PAN],
    [PAN_CRIT_1],
    [PAN_CRIT_2],
    [PAN_CRIT_3],
    [PAN_FILL_MonWorry],
    [PAN_FILL_MonChgAct],
    [PAN_FILL_E20],
    [PAN_FILL_E21],
    [PAN_FILL_E22],
    [PAN_FILL_Num30d],
    [PAN_CRIT_4],
    [PAN_CRIT_5],
    [E21_TEXT],
    [BIP_CRIT_1],
    [BIP_CRIT_2],
    [BIP_CRIT_3a],
    [BIP_CRIT_3b],
    [BIP_CRIT_3c],
    [BIP_CRIT_3d],
    [BIP_CRIT_3e],
    [EAT_FILL_Purge_Ever],
    [EAT_FILL_Purge_Num12m],
    [ALC_FILL_Binge],
    [ALC_CRIT_1],
    [ALC_CRIT_2],
    [ALC_CRIT_3],
    [ALC_CRIT_4],
    [ALC_CRIT_5],
    [ALC_CRIT_6],
    [ALC_CRIT_7],
    [ALC_CRIT_8],
    [F7_TEXT],
    [F8_TEXT],
    [DRUG_CRIT_1],
    [DRUG_CRIT_2],
    [G1G2_CRIT],
    [G1G2_Fill],
    [G1G2_Fill2],
    [G1G2_Fill3],
    [G4a_fix],
    [G4a_TEXT],
    [H3_CRIT],
    [CBLS_TOT],
    [V3_LENGTH],
    [SocLif_FreqTlkFILL],
    [SocSup_FreqConf_FILL],
    [L1_GOTO],
    [Welcome_to_survey],
    [Screening],
    [Consent1],
    [Consent2],
    [Consent3],
    [Consent4],
    [emailaddress],
    [telephonenumber],
    [Consent5],
    [Consent6_FILE_ID],
    [Consent6_FILE_NAME],
    [Consent6_FILE_SIZE],
    [Consent6_FILE_TYPE],
    [Consent6],
    [ProceededtoNextYear],
    [Yearsemester],
    [ReasonNotProceeding],
    [ReasonNotProceeding_TEXT],
    [university],
    [degreeprogram],
    [homecounty],
    [YearofBirth],
    [GenderBirth],
    [GenderIdent],
    [GenderIdent_TEXT],
    [StudStatus],
    [StudStatus_TEXT],
    [InterStud],
    [PhysH_Rate],
    [MentH_Rate],
    [HlthLim_1],
    [HlthLim_2],
    [MentImp12m_1],
    [MentImp12m_2],
    [PhysHProb_1],
    [PhysHProb_2],
    [PhysHProb_3],
    [PhysHProb_4],
    [MentHProb_1],
    [MentHProb_2],
    [MentHProb_3],
    [PhysMent_Inter],
    [Hlth30d_1],
    [Hlth30d_2],
    [Hlth30d_3],
    [Hlth30d_6],
    [Hlth30d_7],
    [Hlth30d_8],
    [Pain_Inter],
    [EmoProbEver_EmoProbEver_1],
    [EmoProbEver_EmoProbEver_2],
    [EmoProbEver_EmoProbEver_3],
    [EmoProbEver_EmoProbEver_4],
    [EmoProbEver_EmoProbEver_5],
    [ADHD_Freq],
    [ADHD6mSxs_1],
    [ADHD6mSxs_2],
    [ADHD6mSxs_3],
    [ADHD6mSxs_4],
    [ADHD6mSxs_5],
    [ADHD6mSxs_6],
    [ADHD_Onset],
    [DeprLTCritA1_1],
    [DeprLTCritA1_2],
    [DeprLTCritA1_3],
    [DeprLTCritA1_4],
    [DeprLTCritA2_5],
    [DeprLTCritA2_6],
    [DeprLTCritA2_7],
    [DeprLTCritA2_8],
    [DeprLTCritA2_9],
    [DeprLTCritA2_10],
    [DeprLTCritA2_11],
    [Depr_Onset],
    [Depr_NumYrs],
    [Depr_Num12m],
    [Depr30d_1],
    [Depr30d_2],
    [Depr30d_3],
    [Depr30d_4],
    [AnxLTCritA_1],
    [AnxLTCritA_2],
    [AnxLTCritA_3],
    [AnxLTCritA_4],
    [AnxLTCritA_13],
    [AnxLTCritC_6],
    [AnxLTCritC_7],
    [AnxLTCritC_8],
    [AnxLTCritC_9],
    [AnxLTCritC_10],
    [AnxLTCritC_11],
    [AnxLTCritC_12],
    [Anx_Onset],
    [Anx_NumYrs],
    [Anx_Num12m],
    [Anx30d_1],
    [Anx30d_2],
    [Anx30d_3],
    [Anx30d_4],
    [Panic_NumAtt],
    [PanicLTCritA_1],
    [PanicLTCritA_2],
    [PanicLTCritA_3],
    [PanicLTCritA_4],
    [PanicLTCritA_5],
    [PanicLTCritA_6],
    [PanicLTCritA_7],
    [PanicLTCritA_8],
    [PanicLTCritA_9],
    [PanicLTCritA_10],
    [PanicLTCritA_11],
    [PanicLTCritA_12],
    [PanicLTCritA_13],
    [PanicLTCritA_14],
    [Panic_OutBlue],
    [Panic_NumOutBlue],
    [Panic_MonWorry],
    [Panic_MonChgAct],
    [Panic_Onset],
    [Panic_NumYrs],
    [Panic_Num12m],
    [Panic_Num30d],
    [Bip_Ever],
    [BipLTCritA1_1],
    [BipLTCritA1_2],
    [BipLTCritA1_3],
    [BipLTCritA2_8],
    [BipLTCritA2_9],
    [BipLTCritA2_10],
    [BipLTCritA2_11],
    [BipLTCritA2_12],
    [BipLTCritB_4],
    [BipLTCritB_5],
    [BipLTCritB_6],
    [BipLTCritB_7],
    [BipLTCritB_13],
    [Bip_Onset],
    [Bip_NumYrs],
    [Bip_LongEpi],
    [Bip_Inter],
    [Bip_OthNotice],
    [Bip_Hosp],
    [Bip_Num12m],
    [Bip_30day],
    [Anger_Ever],
    [Anger_Num12m],
    [Anger_30day],
    [PTSD_Ever],
    [PTSDLTSxs_1],
    [PTSDLTSxs_2],
    [PTSDLTSxs_3],
    [PTSDLTSxs_4],
    [PTSD_Onset],
    [PTSD_NumYrs],
    [PTSD_Num12m],
    [PTSD_30day],
    [SocAnx_Ever],
    [SocAnx_Avoid],
    [SocAnx_Inter],
    [SocAnx_Num12m],
    [SocAnx_30day],
    [Binge_Ever],
    [Binge_Num12m],
    [Binge_30day],
    [Purge_Ever],
    [Purge_Num12m],
    [Purge_30day],
    [Alc_Freq],
    [Alc_Quan],
    [Alc_Binge],
    [Alc12mSxs_2],
    [Alc12mSxs_3],
    [Alc12mSxs_4],
    [Alc12mSxs_5],
    [Alc12mSxs_6],
    [Alc_AnyInjury],
    [Alc_AnyConcern],
    [Alc_Onset],
    [Alc_NumYrs],
    [Alc_Num12m],
    [Alc_30day],
    [DrugType_1],
    [DrugType_2],
    [DrugType_3],
    [DrugType_4],
    [DrugLTCritA1_1],
    [DrugLTCritA1_2],
    [DrugLTCritA1_3],
    [DrugLTCritA1_4],
    [DrugLTCritA1_5],
    [DrugLTCritA2_6],
    [DrugLTCritA2_7],
    [DrugLTCritA2_8],
    [DrugLTCritA2_9],
    [DrugLTCritA2_10],
    [DrugLTCritA2_11],
    [Drug_Onset],
    [Drug_NumYrs],
    [Drug_Num12m],
    [Drug_30day],
    [Ideat_PassEver],
    [Ideat_ActEver],
    [Ideat_Onset],
    [Ideat_NumYrs],
    [Ideat_Num12m],
    [Ideat_Freq30day],
    [SuiPlan_Ever],
    [SuiPlan_Onset],
    [SuiPlan_NumYrs],
    [SuiPlan_Num12m],
    [Ideat_12mActOn],
    [Ideat_NumDayWrst],
    [Ideat_LongLast],
    [Ideat_CntrlTho],
    [Ideat_TemptFate],
    [SuiAtt_Ever],
    [SuiAtt_Onset],
    [SuiAtt_NumLT],
    [SuiAtt_Num12m],
    [NSSI_Ever],
    [NSSI_Onset],
    [NSSI_NumLT],
    [NSSI_Num12m],
    [TxtTypeEver_TxtTypeEver_1],
    [TxtTypeEver_TxtTypeEver_2],
    [TxtTypeEver_TxtTypeEver_3],
    [Txt_Onset],
    [Txt_Num12m],
    [Txt_Recency],
    [Txt_CurrentTxt],
    [Txt_Willingness],
    [Txt_Need12m],
    [TxtNotSeek_1],
    [TxtNotSeek_2],
    [TxtNotSeek_3],
    [TxtNotSeek_4],
    [TxtNotSeek_5],
    [TxtNotSeek_6],
    [TxtNotSeek_7],
    [TxtNotSeek_8],
    [TxtNotSeek_9],
    [TxtNotSeek_10],
    [TxtNotSeek_10_TEXT],
    [Parent_Educ],
    [ChildhExp1_1],
    [ChildhExp1_2],
    [ChildhExp1_3],
    [ChildhExp1_4],
    [ChildhExp1_5],
    [ChildhExp1_6],
    [ChildhExp2_7],
    [ChildhExp2_8],
    [ChildhExp2_9],
    [ChildhExp2_10],
    [ChildhExp2_11],
    [ChildhExp3_12],
    [ChildhExp3_13],
    [ChildhExp3_14],
    [ChildhExp3_15],
    [ChildhExp3_16],
    [ChildhExp3_17],
    [ChildhBully_12],
    [ChildhBully_13],
    [ChildhBully_14],
    [ChildhBully_15],
    [ChildhBully_16],
    [ChildhBully_17],
    [StrExpOth_1],
    [StrExpOth_2],
    [StrExpOth_3],
    [StrExpOth_4],
    [StrExpOth_5],
    [StrExpOth_6],
    [StrExpYou_1],
    [StrExpYou_2],
    [StrExpYou_3],
    [StrExpYou_4],
    [StrExpYou_8],
    [StrExpYou_9],
    [StrExpYou_11],
    [StrExpYou_12],
    [StrExpYou_8_TEXT],
    [SevStress_1],
    [SevStress_2],
    [SevStress_9],
    [SevStress_3],
    [SevStress_4],
    [SevStress_5],
    [SevStress_6],
    [SevStress_7],
    [SevStress_8],
    [SocLif_SocMedia],
    [SocLif_FreqTlk],
    [SocLif_TimeTlk],
    [SocLif_NumTlk],
    [SocLif_FreqHang],
    [SocLif_NumHang],
    [SocLif_FreqGrp],
    [SocSup_Loved],
    [SocSup_Depend],
    [SocSup_Understnd],
    [SocSup_Concern],
    [SocSup_Demand],
    [SocSup_Argue],
    [SocSup_NumConf],
    [SocSup_FreqConf],
    [SocSup_FreqLonely],
    [SocSup_SevLonely],
    [SexOrient],
    [SexOrient_TEXT],
    [SexAttr_Women],
    [SexAttr_Men],
    [SexPartGender],
    [MaritalStatus],
    [RelatStatus],
    [LongPers1_1],
    [LongPers1_2],
    [LongPers1_3],
    [LongPers1_4],
    [LongPers1_5],
    [LongPers1_6],
    [LongPers2_1],
    [LongPers2_2],
    [LongPers2_3],
    [LongPers2_4],
    [LongPers2_5],
    [LongPers2_6],
    [LongPers3_1],
    [LongPers3_2],
    [LongPers3_3],
    [LongPers3_4],
    [LongPers3_5],
    [LongPers3_6],
    [LongPers4_1],
    [LongPers4_2],
    [LongPers4_3],
    [LongPers4_4],
    [LongPers4_5],
    [LongPers4_6],
    [LongPers4_7],
    [ShrtPers1_1],
    [ShrtPers1_2],
    [ShrtPers1_4],
    [ShrtPers1_5],
    [ShrtPers1_6],
    [ShrtPers2_1],
    [ShrtPers2_2],
    [ShrtPers2_3],
    [ShrtPers2_4],
    [ShrtPers2_5],
    [Attachment_1],
    [Attachment_2],
    [Attachment_3],
    [Attachment_4],
    [religiousactivity],
    [homeresidence],
    [homeresidence_TEXT],
    [residenceschool],
    [residenceschool_TEXT],
    [discrimination],
    [citizenship],
    [employment],
    [employment_TEXT],
    [monthlyincome],
    [IncentivePhoneNumber],
    [RO_BR_FL_18],
    [RO_BR_FL_150],
    [RO_BR_FL_145],
    [RO_BR_FL_129],
    [RO_BR_FL_126],
    [Institution],
    [SurveyID]
FROM [Qualtrics].[dbo].[survey_responses_2026]")

# Display first few rows
print(head(qualtrics_data, 5))

# Get survey metadata
print("Qualtrics dataset info:")
print(dim(qualtrics_data))
print(names(qualtrics_data))
```

#### Step 4: Query Participant Dimensions
```r
# Query enrolled participant dimensions
participants_data <- dbGetQuery(con, "
SELECT [ParticipantIdentifier],
    [Gender],
    [DateOfBirth],
    [SecondaryIdentifier],
    [PostalCode],
    [EventDates],
    [CustomFields],
    [TimeZone],
    [PreferredLanguage],
    [EnrollmentDate],
    [Skey],
    [Age],
    [HashCol_dw]
FROM [uzima_db_backup].[dbo].[_vw_dimenrolledparticipants]")

# Display first few rows
print(head(participants_data, 5))

# Get participant metadata
print("Participant dataset info:")
print(dim(participants_data))
print(names(participants_data))
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
