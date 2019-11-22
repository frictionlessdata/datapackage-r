## ---- eval=FALSE, include=TRUE------------------------------------------------
#  # Install devtools package if not already
#  install.packages("devtools")

## ---- eval=FALSE, include=TRUE------------------------------------------------
#  install.packages("datapackage.r")
#  # or install the development package
#  devtools::install_github("frictionlessdata/datapackage.r")

## ---- eval=TRUE, include=TRUE-------------------------------------------------
library(datapackage.r)

## ---- eval=TRUE, include=TRUE-------------------------------------------------
dataPackage <- Package.load()
dataPackage$descriptor['name'] <- 'period-table'
dataPackage$descriptor['title'] <- 'Periodic Table'
# commit the changes to Package class
dataPackage$commit()

## ---- echo=FALSE, results='asis'----------------------------------------------
url <- 'https://raw.githubusercontent.com/frictionlessdata/datapackage-r/master/vignettes/exampledata/data.csv'
pt_data <- read.csv2(url, sep = ',')
knitr::kable(head(pt_data, 10), align = 'c')

## ---- eval=TRUE, include=TRUE-------------------------------------------------
filepath <- 'https://raw.githubusercontent.com/frictionlessdata/datapackage-r/master/vignettes/exampledata/data.csv'

schema <- tableschema.r::infer(filepath)

## ---- eval=FALSE, include=TRUE------------------------------------------------
#  # define resources using json text
#  resources <- helpers.from.json.to.list(
#    '[{
#  	"name": "data",
#  	"path": "filepath",
#  	"schema": "schema"
#    }]'
#  )
#  resources[[1]]$schema <- schema
#  resources[[1]]$path <- filepath

## ---- eval=TRUE, include=TRUE-------------------------------------------------
# or define resources using list object
resources <- list(list(
  name = "data",
  path = filepath,
  schema = schema
  ))

## ---- eval=TRUE, include=TRUE-------------------------------------------------
dataPackage$descriptor[['resources']] <- resources
dataPackage$commit()

## ---- eval=FALSE, include=TRUE------------------------------------------------
#  resources <- list(list(
#    name = "data",
#    path = filepath,
#    schema = schema
#    ))
#  
#  dataPackage$addResource(resources)

## ---- eval=FALSE, include=TRUE------------------------------------------------
#  dataPackage$save('exampledata')

## ---- eval=TRUE, include=TRUE-------------------------------------------------
jsonlite::prettify(helpers.from.list.to.json(dataPackage$descriptor))

