## ---- eval=FALSE, include=TRUE-------------------------------------------
#  # Install devtools package if not already
#  install.packages("devtools")

## ---- eval=FALSE, include=TRUE-------------------------------------------
#  devtools::install_github("frictionlessdata/datapackage.r")

## ---- eval=FALSE, include=TRUE-------------------------------------------
#  library(datapackage.r)

## ------------------------------------------------------------------------
# dataPackage = Package.load()
# dataPackage$descriptor['name'] = 'period-table'
# dataPackage$descriptor['title'] = 'Periodic Table'

## ------------------------------------------------------------------------
# import io
# import csv
# from jsontableschema import infer
# 
# filepath = './data.csv'
# 
# with io.open(filepath) as stream:
#     headers = stream.readline().rstrip('\n').split(',')
#     values = csv.reader(stream)
#     schema = infer(headers, values)
#     dp.descriptor['resources'] = [
#         {
#             'name': 'data',
#             'path': filepath,
#             'schema': schema
#         }
#     ]

## ------------------------------------------------------------------------
# with open('datapackage.json', 'w') as f:
#   f.write(dp.to_json())

## ------------------------------------------------------------------------
# datapackage

