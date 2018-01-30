## ---- eval=FALSE, include=TRUE-------------------------------------------
#  # Install devtools package if not already
#  install.packages("devtools")

## ---- eval=FALSE, include=TRUE-------------------------------------------
#  devtools::install_github("frictionlessdata/datapackage.r")

## ---- eval=TRUE, include=TRUE--------------------------------------------
library(datapackage.r)

## ---- eval=TRUE, include=TRUE--------------------------------------------
dataPackage = Package.load()
dataPackage$descriptor['name'] = 'period-table'
dataPackage$descriptor['title'] = 'Periodic Table'
dataPackage$commit()

## ---- eval=TRUE, include=TRUE--------------------------------------------
filepath = 'https://raw.githubusercontent.com/frictionlessdata/example-data-packages/master/periodic-table/data.csv'

schema = tableschema.r::infer(filepath)

## ---- eval=TRUE, include=TRUE--------------------------------------------
# define resources using json text 
resources = helpers.from.json.to.list(
  '[{
	"name": "data",
	"path": "filepath",
	"schema": "schema"
  }]'
)
resources[[1]]$schema = schema
resources[[1]]$path = filepath

# define resources using list object
resources = list(
  list( name = "data",
  path = filepath,
  schema = schema
  ))


## ---- eval=TRUE, include=TRUE--------------------------------------------
dataPackage$descriptor['resources'] = resources

## ---- eval=FALSE, include=TRUE-------------------------------------------
#  dataPackage$save(getwd())

## ---- eval=TRUE, include=TRUE--------------------------------------------
jsonlite::toJSON(dataPackage$descriptor, pretty = TRUE)

