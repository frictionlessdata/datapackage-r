## ---- eval=FALSE, include=TRUE------------------------------------------------
#  # Install devtools package if not already
#  install.packages("devtools")

## ---- eval=FALSE, include=TRUE------------------------------------------------
#  install.packages("datapackage.r")
#  # or install the development package
#  devtools::install_github("frictionlessdata/datapackage.r")

## ---- eval=TRUE, include=TRUE-------------------------------------------------
library(datapackage.r)

## ---- echo=TRUE, results='asis'-----------------------------------------------
path <- 'exampledata/data.csv' # or use url <- 'https://raw.githubusercontent.com/frictionlessdata/datapackage-r/master/vignettes/exampledata/data.csv'
pt_data <- read.csv2(path, sep = ',')
knitr::kable(head(pt_data, 5), align = 'c')

## ---- eval=TRUE, include=TRUE-------------------------------------------------
path <- 'exampledata/package.json' # or use url <- 'https://raw.githubusercontent.com/frictionlessdata/datapackage-r/master/vignettes/exampledata/package.json'
datapackage <- Package.load(path)
datapackage$resources[[1]]$descriptor$profile <- 'tabular-data-resource' # tabular resource descriptor profile 
datapackage$resources[[1]]$commit() # commit changes

## ---- eval=TRUE, include=TRUE-------------------------------------------------
datapackage$descriptor$title

## ---- eval=TRUE, include=TRUE-------------------------------------------------
table <- datapackage$resources[[1]]$table
periodic_table_data <- table$read()

## ---- eval=FALSE, include=TRUE------------------------------------------------
#  install.packages(c("DBI","RSQLite"))

## ---- eval=TRUE, include=TRUE-------------------------------------------------
library(DBI)
library(RSQLite)

## ---- eval=TRUE, include=TRUE-------------------------------------------------
dp.database <- dbConnect(RSQLite::SQLite(), "") # temporary database

## ---- eval=TRUE, include=TRUE-------------------------------------------------
# install data.table package if not already
# install.packages("data.table")

periodic_table_sql <- data.table::rbindlist(periodic_table_data)
periodic_table_sql <- setNames(periodic_table_sql,unlist(datapackage$resources[[1]]$headers))

## ---- eval=TRUE, include=TRUE-------------------------------------------------
dbWriteTable(dp.database, "periodic_table_sql", periodic_table_sql)
# show remote tables accessible through this connection
dbListTables(dp.database)

## ---- eval=TRUE, include=TRUE-------------------------------------------------
dbGetQuery(dp.database, 'SELECT * FROM periodic_table_sql LIMIT 5')

## ---- eval=TRUE, include=TRUE-------------------------------------------------
dbGetQuery(dp.database, 'SELECT * FROM periodic_table_sql WHERE "atomic number" < 10')

