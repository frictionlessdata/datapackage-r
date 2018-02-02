Using Data Packages in R
========================

This tutorial will show you how to install the R libraries for working
with Tabular Data Packages and demonstrate a very simple example of
loading a Tabular Data Package from the web and pushing it directly into
a local SQL database and send query to retrieve results.

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

Reading Basic Metadata
----------------------

In this case, we are using an example Tabular Data Package containing
the periodic table stored on
[GitHub](https://github.com/frictionlessdata/example-data-packages/tree/master/periodic-table)
([datapackage.json](https://raw.githubusercontent.com/frictionlessdata/example-data-packages/master/periodic-table/datapackage.json),
[data.csv](https://raw.githubusercontent.com/frictionlessdata/example-data-packages/master/periodic-table/data.csv)).
This dataset includes the atomic number, symbol, element name, atomic
mass, and the metallicity of the element. Here are the first five rows:

    url = 'https://raw.githubusercontent.com/okgreece/datapackage-r/master/vignettes/example_data/data.csv'
    pt_data = read.csv2(url, sep = ',')
    knitr::kable(head(pt_data, 5), align = 'c')

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
</tbody>
</table>

Data Packages can be loaded either from a local path or directly from
the web.

    url = 'https://raw.githubusercontent.com/okgreece/datapackage-r/master/vignettes/example_data/package.json'
    datapackage = Package.load(url)
    datapackage$resources[[1]]$descriptor$profile = 'tabular-data-resource' # tabular resource descriptor profile 
    datapackage$resources[[1]]$commit() # commit changes

    ## [1] TRUE

At the most basic level, Data Packages provide a standardized format for
general metadata (for example, the dataset title, source, author, and/or
description) about your dataset. Now that you have loaded this Data
Package, you have access to this `metadata` using the metadata dict
attribute. Note that these fields are optional and may not be specified
for all Data Packages. For more information on which fields are
supported, see [the full Data Package
standard](https://frictionlessdata.io/specs/data-package/).

    datapackage$descriptor$title

    ## [1] "Periodic Table"

Reading Data
------------

Now that you have loaded your Data Package, you can read its data. A
Data Package can contain multiple files which are accessible via the
`resources` attribute. The `resources` attribute is an array of objects
containing information (e.g. path, schema, description) about each file
in the package.

You can access the data in a given resource in the `resources` array by
reading the `data` attribute.

    table = datapackage$resources[[1]]$table
    periodic_table_data = table$read()

You can further manipulate list objects in R by using
[purrr](https://cran.r-project.org/package=purrr),
[rlist](https://cran.r-project.org/package=rlist) packages.

Loading into an SQL database
----------------------------

[Tabular Data
Packages](https://frictionlessdata.io/specs/tabular-data-package/)
contains schema information about its data using [Table
Schema](https://frictionlessdata.io/specs/table-schema/). This means you
can easily import your Data Package into the SQL backend of your choice.
In this case, we are creating an [SQLite](http://sqlite.org/) database.

To create a new SQLite database and load the data into SQL we will need
[DBI](https://cran.r-project.org/package=DBI) package and
[RSQLite](https://cran.r-project.org/package=RSQLite) package, which
contains [SQLite](https://www.sqlite.org/) (no external software is
needed).

You can install and load them by using:

    install.packages(c("DBI","RSQLite"))

    library(DBI)
    library(RSQLite)

To create a new SQLite database, you simply supply the filename to
`dbConnect()`:

    dp.database = dbConnect(RSQLite::SQLite(), "") # temporary database

We will use data.table package to convert the list object with the data
to a data frame in order to copy them to database table.

    # install data.table package if not already
    # install.packages("data.table")

    periodic_table_sql = data.table::rbindlist(periodic_table_data)
    periodic_table_sql = setNames(periodic_table_sql,unlist(datapackage$resources[[1]]$headers))

You can easily copy an R data frame into a SQLite database with
dbWriteTable():

    dbWriteTable(dp.database, "periodic_table_sql", periodic_table_sql)
    # show remote tables accessible through this connection
    dbListTables(dp.database)

    ## [1] "periodic_table_sql"

The data are already to the database.

We can further issue queries to hte database:

Return first 5 elements:

    dbGetQuery(dp.database, 'SELECT * FROM periodic_table_sql LIMIT 5')

    ##   atomic number symbol      name atomic mass   metal or nonmetal?
    ## 1             1      H  Hydrogen    1.007940             nonmetal
    ## 2             2     He    Helium    4.002602            noble gas
    ## 3             3     Li   Lithium    6.941000         alkali metal
    ## 4             4     Be Beryllium    9.012182 alkaline earth metal
    ## 5             5      B     Boron   10.811000            metalloid

Return all elements with an atomic number of less than 10:

    dbGetQuery(dp.database, 'SELECT * FROM periodic_table_sql WHERE "atomic number" < 10')

    ##   atomic number symbol      name atomic mass   metal or nonmetal?
    ## 1             1      H  Hydrogen    1.007940             nonmetal
    ## 2             2     He    Helium    4.002602            noble gas
    ## 3             3     Li   Lithium    6.941000         alkali metal
    ## 4             4     Be Beryllium    9.012182 alkaline earth metal
    ## 5             5      B     Boron   10.811000            metalloid
    ## 6             6      C    Carbon   12.010700             nonmetal
    ## 7             7      N  Nitrogen   14.006700             nonmetal
    ## 8             8      O    Oxygen   15.999400             nonmetal
    ## 9             9      F  Fluorine   18.998403              halogen

More about using databases, SQLite in R you can find in vignettes of
[DBI](https://cran.r-project.org/package=DBI) and
[RSQLite](https://cran.r-project.org/package=RSQLite) packages.
