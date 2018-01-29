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

## ---- eval=F, include=TRUE-----------------------------------------------
#  # import io
#  # import csv
#  # from jsontableschema import infer
#  # #
#  filepath = 'inst/extdata/data.csv'
#  # #
#  # # with io.open(filepath) as stream:
#  #     headers = read.csv(filepath,sep = ",")
#  #     values = read.csv(filepath,sep = ",")
#  # #     schema = infer(headers, values)
#  #     dp.descriptor['resources'] = [
#  #         {
#  #             'name': 'data',
#  #             'path': filepath,
#  #             'schema': schema
#  #         }
#  #     ]

## ---- eval=F, include=TRUE-----------------------------------------------
#  # with open('datapackage.json', 'w') as f:
#  #   f.write(dp.to_json())

## ---- eval=TRUE, include=TRUE--------------------------------------------
# datapackage

