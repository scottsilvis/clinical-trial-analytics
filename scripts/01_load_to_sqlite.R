# Load raw CSVs into SQLite and apply schema.

library(DBI)
library(RSQLite)
library(readr)

stopifnot(
  dir.exists("sql"),
  dir.exists("data")
)
message("Working directory: ", getwd())
message("Folders /sql and /data found")

# ---- Paths ----
  
db_path <- "clinical_trial.db"
schema_paths <- c(
  file.path("sql", "01_sites.sql"),
  file.path("sql", "02_patients.sql"),
  file.path("sql", "03_visits.sql"),
  file.path("sql", "04_outcomes.sql"),
  file.path("sql", "05_notes.sql")
)

data_dir <- file.path("data")  

files <- list(
  sites    = file.path(data_dir, "sites.csv"),
  patients = file.path(data_dir, "patients.csv"),
  visits   = file.path(data_dir, "visits.csv"),
  outcomes = file.path(data_dir, "outcomes.csv"),
  notes    = file.path(data_dir, "notes.csv")
)

message("paths created")

stopifnot(all(file.exists(schema_paths)))
stopifnot(all(file.exists(unlist(files))))

message("paths validated")
# ---- Connect ----
  
conn <- dbConnect(RSQLite::SQLite(), db_path)
dbExecute(conn, "PRAGMA foreign_keys = ON;")
message("connected to SQLite: ", db_path)

# ---- create schema ----
  
# NOTE: This drops existing tables if you rerun.

tables <- c("notes", "outcomes", "visits", "patients", "sites")
for (t in tables) dbExecute(conn, paste0("DROP TABLE IF EXISTS ", t, ";"))

stopifnot(all(file.exists(schema_paths)))
for (p in schema_paths) {
  message("Applying schema: ", p)
  sql <- paste(readLines(p, warn = FALSE), collapse = "\n")
  dbExecute(conn, sql)
} 

message("schema created. tables: ", paste(dbListTables(conn), collapse = ", "))

# ---- Load data ----
  
# Sites first (patients references sites; visits references both)

for (tbl in c("sites", "patients", "visits", "outcomes", "notes")) {
  message("Loading: ", tbl, " from ", files[[tbl]])
  df <- read_csv(files[[tbl]], show_col_types = FALSE)
  dbWriteTable(conn, tbl, df, append = TRUE)
}

message("data loaded")

# ---- Basic verification ----
  
row_counts <- sapply(names(files), function(tbl) {
  dbGetQuery(conn, paste0("SELECT COUNT(*) AS n FROM ", tbl, ";"))$n
})
message("raw counts: ")
print(row_counts)

# ---- Spot-check relationships ----
  
# 1) Any visits missing a patient?
missing_patients <- dbGetQuery(conn, "
  SELECT COUNT(*) AS n_missing
  FROM visits v
  LEFT JOIN patients p ON p.patient_id = v.patient_id
  WHERE p.patient_id IS NULL;
")

# 2) Any patients missing a site?
missing_sites <- dbGetQuery(conn, "
  SELECT COUNT(*) AS n_missing
  FROM patients p
  LEFT JOIN sites s ON s.site_id = p.site_id
  WHERE s.site_id IS NULL;
")

message("Unmatched records:")
message("  visits -> patients: ", missing_patients$n_missing)
message("  patients -> sites : ", missing_sites$n_missing)

dbDisconnect(conn)
message('Done. SQLite DB created at: ', db_path)

