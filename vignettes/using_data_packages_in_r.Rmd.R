## ---- eval=FALSE, include=TRUE-------------------------------------------
#  # Install devtools package if not already
#  install.packages("devtools")

## ---- eval=FALSE, include=TRUE-------------------------------------------
#  devtools::install_github("frictionlessdata/datapackage.r")

## ---- eval=TRUE, include=TRUE--------------------------------------------
library(datapackage.r)

## ---- echo=FALSE, results='asis'-----------------------------------------
url = 'https://raw.githubusercontent.com/okgreece/datapackage-r/master/vignettes/example_data/data.csv'
pt_data = read.csv2(url, sep = ',')
knitr::kable(head(pt_data, 5), align = 'c')

## ------------------------------------------------------------------------
url = helpers.from.json.to.list('https://raw.githubusercontent.com/okgreece/datapackage-r/master/vignettes/example_data/package.json')
datapackage = Package.load(url)
# resource = Resource.load(url,basePath = 'https://raw.githubusercontent.com/frictionlessdata/example-data-packages/master/periodic-table' )
# resource$read()

## ------------------------------------------------------------------------
# datapackage$resources[[1]]$read(keyed= TRUE)

## ------------------------------------------------------------------------
datapackage$descriptor$resources[[1]]$path
def = tableschema.r::Table.load('https://raw.githubusercontent.com/okgreece/datapackage-r/master/vignettes/example_data/data.csv')
table=def$value()
periodic_table_data = table$read(keyed = TRUE)
str(periodic_table_data)

