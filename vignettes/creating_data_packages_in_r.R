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
# commit the changes to Package class
dataPackage$commit()

