Creating Data Packages in R
===========================

This tutorial will show you how to install the R library for working
with Data Packages and Table Schema, load a CSV file, infer its schema,
and write a Tabular Data Package.

Setup
-----

For this tutorial, we will need the Data Package R library
([datapackage.r](https://github.com/frictionlessdata/datapackage-r)).

[devtools library](https://cran.r-project.org/package=devtools) is
required to install the datapackage.r library from github.

    # Install devtools package if not already
    install.packages("devtools")

And then install the development version of
[datapackage.r](https://github.com/frictionlessdata/datapackage-r) from
github.

    devtools::install_github("frictionlessdata/datapackage.r")

Load
----

You can start using the library by loading `datapackage.r`.

    library(datapackage.r)

You can add useful metadata by adding keys to metadata dict attribute.
Below, we are adding the required `name` key as well as a human-readable
`title` key. For the keys supported, please consult the full [Data
Package spec](https://frictionlessdata.io/specs/data-package/#metadata).
Note, we will be creating the required `resources` key further down
below.

    dataPackage = Package.load()
    dataPackage$descriptor['name'] = 'period-table'
    dataPackage$descriptor['title'] = 'Periodic Table'
    # commit the changes to Package class
    dataPackage$commit()

    ## [1] TRUE

Infer a CSV Schema
------------------

We will use periodic-table data from remote path:
<https://raw.githubusercontent.com/okgreece/datapackage-r/master/vignettes/example%20data/data.csv>

<table>
<thead>
<tr class="header">
<th align="center">atomic.number</th>
<th align="center">symbol</th>
<th align="center">name</th>
<th align="center">atomic.mass</th>
<th align="center">metal.or.nonmetal.</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">1</td>
<td align="center">H</td>
<td align="center">Hydrogen</td>
<td align="center">1.00794</td>
<td align="center">nonmetal</td>
</tr>
<tr class="even">
<td align="center">2</td>
<td align="center">He</td>
<td align="center">Helium</td>
<td align="center">4.002602</td>
<td align="center">noble gas</td>
</tr>
<tr class="odd">
<td align="center">3</td>
<td align="center">Li</td>
<td align="center">Lithium</td>
<td align="center">6.941</td>
<td align="center">alkali metal</td>
</tr>
<tr class="even">
<td align="center">4</td>
<td align="center">Be</td>
<td align="center">Beryllium</td>
<td align="center">9.012182</td>
<td align="center">alkaline earth metal</td>
</tr>
<tr class="odd">
<td align="center">5</td>
<td align="center">B</td>
<td align="center">Boron</td>
<td align="center">10.811</td>
<td align="center">metalloid</td>
</tr>
<tr class="even">
<td align="center">6</td>
<td align="center">C</td>
<td align="center">Carbon</td>
<td align="center">12.0107</td>
<td align="center">nonmetal</td>
</tr>
<tr class="odd">
<td align="center">7</td>
<td align="center">N</td>
<td align="center">Nitrogen</td>
<td align="center">14.0067</td>
<td align="center">nonmetal</td>
</tr>
<tr class="even">
<td align="center">8</td>
<td align="center">O</td>
<td align="center">Oxygen</td>
<td align="center">15.9994</td>
<td align="center">nonmetal</td>
</tr>
<tr class="odd">
<td align="center">9</td>
<td align="center">F</td>
<td align="center">Fluorine</td>
<td align="center">18.9984032</td>
<td align="center">halogen</td>
</tr>
<tr class="even">
<td align="center">10</td>
<td align="center">Ne</td>
<td align="center">Neon</td>
<td align="center">20.1797</td>
<td align="center">noble gas</td>
</tr>
</tbody>
</table>

We can guess at our CSV's
[schema](https://frictionlessdata.io/guides/table-schema/) by using
`infer` from the Table Schema library. We pass directly the remote link
to the infer function, the result of which is an inferred schema. For
example, if the processor detects only integers in a given column, it
will assign `integer` as a column type.

    filepath = 'https://raw.githubusercontent.com/okgreece/datapackage-r/master/vignettes/example_data/data.csv'

    schema = tableschema.r::infer(filepath)

Once we have a schema, we are now ready to add a `resource` key to the
Data Package which points to the resource path and its newly created
schema. Below we define resources with three ways, using json text
format with usual assignment operator in R list objects and directly
using `addResource` function of `Package` class:

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

    # or define resources using list object
    resources = list(list(
      name = "data",
      path = filepath,
      schema = schema
      ))

And now, add resources to the Data Package:

    dataPackage$descriptor[['resources']] = resources
    dataPackage$commit()

    ## [1] TRUE

Or you can directly add resources using `addResources` function of
`Package` class:

    resources = list(list(
      name = "data",
      path = filepath,
      schema = schema
      ))

    dataPackage$addResource(resources)

Now we are ready to write our `datapackage.json` file to the current
working directory.

    dataPackage$save('example_data')

The `datapackage.json`
([download](https://raw.githubusercontent.com/okgreece/datapackage-r/master/vignettes/example_data/package.json))
is inlined below. Note that atomic number has been correctly inferred as
an `integer` and atomic mass as a `number` (float) while every other
column is a `string`.

    jsonlite::prettify(helpers.from.list.to.json(dataPackage$descriptor))

    ## {
    ##     "profile": "data-package",
    ##     "name": "period-table",
    ##     "title": "Periodic Table",
    ##     "resources": [
    ##         {
    ##             "name": "data",
    ##             "path": "https://raw.githubusercontent.com/okgreece/datapackage-r/master/vignettes/example_data/data.csv",
    ##             "schema": {
    ##                 "fields": [
    ##                     {
    ##                         "name": "atomic number",
    ##                         "type": "integer",
    ##                         "format": "default"
    ##                     },
    ##                     {
    ##                         "name": "symbol",
    ##                         "type": "string",
    ##                         "format": "default"
    ##                     },
    ##                     {
    ##                         "name": "name",
    ##                         "type": "string",
    ##                         "format": "default"
    ##                     },
    ##                     {
    ##                         "name": "atomic mass",
    ##                         "type": "number",
    ##                         "format": "default"
    ##                     },
    ##                     {
    ##                         "name": "metal or nonmetal?",
    ##                         "type": "string",
    ##                         "format": "default"
    ##                     }
    ##                 ],
    ##                 "missingValues": [
    ##                     ""
    ##                 ]
    ##             },
    ##             "profile": "data-resource",
    ##             "encoding": "utf-8"
    ##         }
    ##     ]
    ## }
    ## 

Publishing
----------

Now that you have created your Data Package, you might want to [publish
your data online](https://frictionlessdata.io/guides/publish-online/) so
that you can share it with others.
