<img src="okgr.png" align="right" width=130px /><img src="oklabs.png" align="right" width=130px /><br><br/><img src="frictionlessdata.png" align="left" width=60 />rictionless
Data - <br/> Data Package
================

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/datapackage.r)](https://cran.r-project.org/package=datapackage.r)
[![Build
Status](https://travis-ci.org/frictionlessdata/datapackage-r.svg?branch=master)](https://travis-ci.org/frictionlessdata/datapackage-r)
[![Coverage
Status](https://coveralls.io/repos/github/frictionlessdata/datapackage-r/badge.svg?branch=master)](https://coveralls.io/github/frictionlessdata/datapackage-r?branch=master)<!-- [![Coverage Status](https://img.shields.io/codecov/c/github/frictionlessdata/datapackage-r/master.svg)](https://codecov.io/github/frictionlessdata/datapackage-r?branch=master) -->
[![Github
Issues](http://githubbadges.herokuapp.com/frictionlessdata/datapackage-r/issues.svg)](https://github.com/frictionlessdata/datapackage-r/issues)
[![Pending
Pull-Requests](http://githubbadges.herokuapp.com/frictionlessdata/datapackage-r/pulls.svg)](https://github.com/frictionlessdata/datapackage-r/pulls)
[![Project Status: Active – The project has reached a stable, usable
state but is no longer being actively developed; support/maintenance
will be provided as time
allows.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![minimal R
version](https://img.shields.io/badge/R%3E%3D-3.1-6666ff.svg)](https://cran.r-project.org/)
[![Rdoc](http://www.rdocumentation.org/badges/version/datapackage.r)](http://www.rdocumentation.org/packages/datapackage.r)
[![](http://cranlogs.r-pkg.org/badges/grand-total/datapackage.r)](http://cran.rstudio.com/web/packages/datapackage.r/index.html)
[![Licence](https://img.shields.io/badge/licence-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/frictionlessdata/chat)

# Description

R package for working with [Frictionless Data
Package](http://frictionlessdata.io/specs/data-package).

## Features

  - `Package` class for working with data packages
  - `Resource` class for working with data resources
  - `Profile` class for working with profiles
  - `validate` function for validating data package descriptors
  - `infer` function for inferring data package descriptors

# Getting started

## Installation

In order to install the latest distribution of [R
software](https://www.r-project.org/) to your computer you have to
select one of the mirror sites of the [Comprehensive R Archive
Network](https://cran.r-project.org//), select the appropriate link for
your operating system and follow the wizard instructions.

For windows users you can:

1.  Go to CRAN
2.  Click download R for Windows
3.  Click Base (This is what you want to install R for the first time)
4.  Download the latest R version
5.  Run installation file and follow the instrustions of the installer.

(Mac) OS X and Linux users may need to follow different steps depending
on their system version to install R successfully and it is recommended
to read the instructions on CRAN site carefully.

Even more detailed installation instructions can be found in [R
Installation and Administration
manual](https://cran.r-project.org/doc/manuals/R-admin.html).

To install [RStudio](https://www.rstudio.com/), you can download
[RStudio Desktop](https://www.rstudio.com/products/rstudio/download/)
with Open Source License and follow the wizard instructions:

1.  Go to [RStudio](https://www.rstudio.com/products/rstudio/)
2.  Click download on RStudio Desktop
3.  Download on RStudio Desktop free download
4.  Select the appropriate file for your system
5.  Run installation file

To install the `datapackage` package it is necessary to install first
[devtools package](https://cran.r-project.org/package=devtools) to make
installation of github packages available.

``` r
# Install devtools package if not already
install.packages("devtools")
```

Install `datapackage.r`

``` r
# And then install the development version from github
devtools::install_github("frictionlessdata/datapackage-r")
```

## Load package

``` r
# load the package using
library(datapackage.r)
```

# Examples

Code examples in this readme requires R 3.3 or higher, You could see
even more
[examples](https://github.com/frictionlessdata/datapackage-r/tree/master/vignettes)
in vignettes directory.

``` r
descriptor <- '{
  "resources": [
    {
      "name": "example",
      "profile": "tabular-data-resource",
      "data": [
        ["height", "age", "name"],
        [180, 18, "Tony"],
        [192, 32, "Jacob"]
      ],
      "schema":  {
        "fields": [
          {"name": "height", "type": "integer" },
          {"name": "age", "type": "integer" },
          {"name": "name", "type": "string" }
        ]
      }
    }
  ]
}'

dataPackage <- Package.load(descriptor)
dataPackage
```

    ## <Package>
    ##   Public:
    ##     addResource: function (descriptor) 
    ##     clone: function (deep = FALSE) 
    ##     commit: function (strict = NULL) 
    ##     descriptor: active binding
    ##     errors: active binding
    ##     getResource: function (name) 
    ##     infer: function (pattern) 
    ##     initialize: function (descriptor = list(), basePath = NULL, strict = FALSE, 
    ##     profile: active binding
    ##     removeResource: function (name) 
    ##     resourceNames: active binding
    ##     resources: active binding
    ##     save: function (target, type = "json") 
    ##     valid: active binding
    ##   Private:
    ##     basePath_: C:/Users/kleanthis-okfngr/Documents/datapackage-r
    ##     build_: function () 
    ##     currentDescriptor_: list
    ##     currentDescriptor_json: NULL
    ##     descriptor_: NULL
    ##     errors_: list
    ##     nextDescriptor_: list
    ##     pattern_: NULL
    ##     profile_: Profile, R6
    ##     resources_: list
    ##     resources_length: NULL
    ##     strict_: FALSE

``` r
resource <- dataPackage$getResource('example')
# convert to json and add indentation with jsonlite prettify function
jsonlite::prettify(helpers.from.list.to.json(resource$read()))
```

    ## [
    ##     [
    ##         180,
    ##         18,
    ##         "Tony"
    ##     ],
    ##     [
    ##         192,
    ##         32,
    ##         "Jacob"
    ##     ]
    ## ]
    ## 

# Documentation

Json objects are not included in R base data types. [Jsonlite
package](https://CRAN.R-project.org/package=jsonlite) is internally used
to convert json data to list objects. The input parameters of functions
could be json strings, files or lists and the outputs are in list format
to easily further process your data in R environment and exported as
desired. The examples below show how to use jsonlite package to convert
the output back to json adding indentation whitespace. More details
about handling json you can see jsonlite documentation or vignettes
[here](https://CRAN.R-project.org/package=jsonlite).

## Working with Package

A class for working with data packages. It provides various capabilities
like loading local or remote data package, inferring a data package
descriptor, saving a data package descriptor and many more.

Consider we have some local `csv` files in a `data` directory. Let’s
create a data package based on this data using a `Package` class:

> inst/extdata/readme\_example/cities.csv

``` csv
city,location
london,"51.50,-0.11"
paris,"48.85,2.30"
rome,"41.89,12.51"
```

> inst/extdata/readme\_example/population.csv

``` csv
city,year,population
london,2017,8780000
paris,2017,2240000
rome,2017,2860000
```

First we create a blank data package:

``` r
dataPackage <- Package.load()
```

Now we’re ready to infer a data package descriptor based on data files
we have. Because we have two csv files we use glob pattern `csv`:

``` r
jsonlite::toJSON(dataPackage$infer('csv'), pretty = TRUE)
```

    ## {
    ##   "profile": ["tabular-data-package"],
    ##   "resources": [
    ##     {
    ##       "path": ["cities.csv"],
    ##       "profile": ["tabular-data-resource"],
    ##       "encoding": ["utf-8"],
    ##       "name": ["cities"],
    ##       "format": ["csv"],
    ##       "mediatype": ["text/csv"],
    ##       "schema": {
    ##         "fields": [
    ##           {
    ##             "name": ["city"],
    ##             "type": ["string"],
    ##             "format": ["default"]
    ##           },
    ##           {
    ##             "name": ["location"],
    ##             "type": ["string"],
    ##             "format": ["default"]
    ##           }
    ##         ],
    ##         "missingValues": [
    ##           [""]
    ##         ]
    ##       }
    ##     },
    ##     {
    ##       "path": ["population.csv"],
    ##       "profile": ["tabular-data-resource"],
    ##       "encoding": ["utf-8"],
    ##       "name": ["population"],
    ##       "format": ["csv"],
    ##       "mediatype": ["text/csv"],
    ##       "schema": {
    ##         "fields": [
    ##           {
    ##             "name": ["city"],
    ##             "type": ["string"],
    ##             "format": ["default"]
    ##           },
    ##           {
    ##             "name": ["year"],
    ##             "type": ["integer"],
    ##             "format": ["default"]
    ##           },
    ##           {
    ##             "name": ["population"],
    ##             "type": ["integer"],
    ##             "format": ["default"]
    ##           }
    ##         ],
    ##         "missingValues": [
    ##           [""]
    ##         ]
    ##       }
    ##     }
    ##   ]
    ## }

``` r
jsonlite::toJSON(dataPackage$descriptor, pretty = TRUE)
```

    ## {
    ##   "profile": ["tabular-data-package"],
    ##   "resources": [
    ##     {
    ##       "path": ["cities.csv"],
    ##       "profile": ["tabular-data-resource"],
    ##       "encoding": ["utf-8"],
    ##       "name": ["cities"],
    ##       "format": ["csv"],
    ##       "mediatype": ["text/csv"],
    ##       "schema": {
    ##         "fields": [
    ##           {
    ##             "name": ["city"],
    ##             "type": ["string"],
    ##             "format": ["default"]
    ##           },
    ##           {
    ##             "name": ["location"],
    ##             "type": ["string"],
    ##             "format": ["default"]
    ##           }
    ##         ],
    ##         "missingValues": [
    ##           [""]
    ##         ]
    ##       }
    ##     },
    ##     {
    ##       "path": ["population.csv"],
    ##       "profile": ["tabular-data-resource"],
    ##       "encoding": ["utf-8"],
    ##       "name": ["population"],
    ##       "format": ["csv"],
    ##       "mediatype": ["text/csv"],
    ##       "schema": {
    ##         "fields": [
    ##           {
    ##             "name": ["city"],
    ##             "type": ["string"],
    ##             "format": ["default"]
    ##           },
    ##           {
    ##             "name": ["year"],
    ##             "type": ["integer"],
    ##             "format": ["default"]
    ##           },
    ##           {
    ##             "name": ["population"],
    ##             "type": ["integer"],
    ##             "format": ["default"]
    ##           }
    ##         ],
    ##         "missingValues": [
    ##           [""]
    ##         ]
    ##       }
    ##     }
    ##   ]
    ## }

An `infer` method has found all our files and inspected it to extract
useful metadata like profile, encoding, format, Table Schema etc. Let’s
tweak it a little bit:

``` r
dataPackage$descriptor$resources[[2]]$schema$fields[[2]]$type <- 'year'
dataPackage$commit()
```

    ## [1] TRUE

``` r
dataPackage$valid
```

    ## [1] TRUE

Because our resources are tabular we could read it as a tabular data:

``` r
jsonlite::toJSON(dataPackage$getResource("population")$read(keyed = TRUE),auto_unbox = FALSE,pretty = TRUE)
```

    ## [
    ##   {
    ##     "city": ["london"],
    ##     "year": [2017],
    ##     "population": [8780000]
    ##   },
    ##   {
    ##     "city": ["paris"],
    ##     "year": [2017],
    ##     "population": [2240000]
    ##   },
    ##   {
    ##     "city": ["rome"],
    ##     "year": [2017],
    ##     "population": [2860000]
    ##   }
    ## ]

Let’s save our descriptor on the disk. After it we could update our
`datapackage.json` as we want, make some changes etc:

``` r
dataPackage.save('datapackage.json')
```

To continue the work with the data package we just load it again but
this time using local `datapackage.json`:

``` r
dataPackage <- Package.load('datapackage.json')
# Continue the work
```

It was one basic introduction to the `Package` class. To learn more
let’s take a look on `Package` class API reference.

### Resource

A class for working with data resources. You can read or iterate tabular
resources using the `iter/read` methods and all resource as bytes using
`rowIter/rowRead` methods.

Consider we have some local csv file. It could be inline data or remote
link - all supported by `Resource` class (except local files for
in-brower usage of course). But say it’s `cities.csv` for now:

``` csv
city,location
london,"51.50,-0.11"
paris,"48.85,2.30"
rome,N/A
```

Let’s create and read a resource. We use static `Resource$load` method
instantiate a resource. Because resource is tabular we could use
`resourceread` method with a `keyed` option to get an array of keyed
rows:

``` r
resource <- Resource.load('{"path": "cities.csv"}')
resource$tabular
```

    ## [1] TRUE

``` r
jsonlite::toJSON(resource$read(keyed = TRUE), pretty = TRUE)
```

    ## [
    ##   {
    ##     "city": ["london"],
    ##     "location": ["\"51.50 -0.11\""]
    ##   },
    ##   {
    ##     "city": ["paris"],
    ##     "location": ["\"48.85 2.30\""]
    ##   },
    ##   {
    ##     "city": ["rome"],
    ##     "location": ["\"41.89 12.51\""]
    ##   }
    ## ]

As we could see our locations are just a strings. But it should be
geopoints. Also Rome’s location is not available but it’s also just a
`N/A` string instead of `null`. First we have to infer resource
metadata:

``` r
jsonlite::toJSON(resource$infer(), pretty = TRUE)
```

    ## {
    ##   "path": ["cities.csv"],
    ##   "profile": ["tabular-data-resource"],
    ##   "encoding": ["utf-8"],
    ##   "name": ["cities"],
    ##   "format": ["csv"],
    ##   "mediatype": ["text/csv"],
    ##   "schema": {
    ##     "fields": [
    ##       {
    ##         "name": ["city"],
    ##         "type": ["string"],
    ##         "format": ["default"]
    ##       },
    ##       {
    ##         "name": ["location"],
    ##         "type": ["string"],
    ##         "format": ["default"]
    ##       }
    ##     ],
    ##     "missingValues": [
    ##       [""]
    ##     ]
    ##   }
    ## }

``` r
jsonlite::toJSON(resource$descriptor, pretty = TRUE)
```

    ## {
    ##   "path": ["cities.csv"],
    ##   "profile": ["tabular-data-resource"],
    ##   "encoding": ["utf-8"],
    ##   "name": ["cities"],
    ##   "format": ["csv"],
    ##   "mediatype": ["text/csv"],
    ##   "schema": {
    ##     "fields": [
    ##       {
    ##         "name": ["city"],
    ##         "type": ["string"],
    ##         "format": ["default"]
    ##       },
    ##       {
    ##         "name": ["location"],
    ##         "type": ["string"],
    ##         "format": ["default"]
    ##       }
    ##     ],
    ##     "missingValues": [
    ##       [""]
    ##     ]
    ##   }
    ## }

``` r
# resource$read( keyed = TRUE )
# # Fails with a data validation error
```

Let’s fix not available location. There is a `missingValues` property in
Table Schema specification. As a first try we set `missingValues` to
`N/A` in `resource$descriptor.schema`. Resource descriptor could be
changed in-place but all changes should be commited by
`resource$commit()`:

``` r
resource$descriptor$schema$missingValues <- 'N/A'
resource$commit()
```

    ## [1] TRUE

``` r
resource$valid # FALSE
```

    ## [1] FALSE

``` r
resource$errors
```

    ## [[1]]
    ## [1] "Descriptor validation error:\n            data.schema.missingValues - is the wrong type"

As a good citiziens we’ve decided to check out recource descriptor
validity. And it’s not valid\! We should use an array for
`missingValues` property. Also don’t forget to have an empty string as a
missing value:

``` r
resource$descriptor$schema[['missingValues']] <- list('', 'N/A')
resource$commit()
```

    ## [1] TRUE

``` r
resource$valid # TRUE
```

    ## [1] TRUE

All good. It looks like we’re ready to read our data again:

``` r
jsonlite::toJSON(resource$read( keyed = TRUE ), pretty = TRUE)
```

    ## [
    ##   {
    ##     "city": ["london"],
    ##     "location": ["\"51.50 -0.11\""]
    ##   },
    ##   {
    ##     "city": ["paris"],
    ##     "location": ["\"48.85 2.30\""]
    ##   },
    ##   {
    ##     "city": ["rome"],
    ##     "location": ["\"41.89 12.51\""]
    ##   }
    ## ]

Now we see that: - locations are arrays with numeric lattide and
longitude - Rome’s location is a native JavaScript `null`

And because there are no errors on data reading we could be sure that
our data is valid againt our schema. Let’s save our resource descriptor:

``` r
resource$save('dataresource.json')
```

Let’s check newly-crated `dataresource.json`. It contains path to our
data file, inferred metadata and our `missingValues` tweak:

``` json
{
    "path": "data.csv",
    "profile": "tabular-data-resource",
    "encoding": "utf-8",
    "name": "data",
    "format": "csv",
    "mediatype": "text/csv",
    "schema": {
        "fields": [
            {
                "name": "city",
                "type": "string",
                "format": "default"
            },
            {
                "name": "location",
                "type": "geopoint",
                "format": "default"
            }
        ],
        "missingValues": [
            "",
            "N/A"
        ]
    }
}
```

If we decide to improve it even more we could update the
`dataresource.json` file and then open it again using local file name:

``` r
resource <- Resource.load('dataresource.json')
# Continue the work
```

It was one basic introduction to the `Resource` class. To learn more
let’s take a look on `Resource` class API reference.

### Working with Profile

A component to represent JSON Schema profile from [Profiles
Registry](https://specs.frictionlessdata.io/schemas/registry.json):

``` r
profile <- Profile.load('data-package')
profile$name # data-package
```

    ## [1] "data-package"

``` r
profile$jsonschema # List of JSON Schema contents
```

``` r
valid_errors <- profile$validate(descriptor)
valid <- valid_errors$valid # TRUE if valid descriptor
valid
```

    ## [1] TRUE

### Working with validate

A standalone function to validate a data package descriptor:

``` r
valid_errors <- validate('{"name": "Invalid Datapackage"}')
```

### Working with infer

A standalone function to infer a data package descriptor.

``` r
descriptor <- infer("csv",basePath = '.')
jsonlite::toJSON(descriptor, pretty = TRUE)
```

    ## {
    ##   "profile": ["tabular-data-package"],
    ##   "resources": [
    ##     {
    ##       "path": ["cities.csv"],
    ##       "profile": ["tabular-data-resource"],
    ##       "encoding": ["utf-8"],
    ##       "name": ["cities"],
    ##       "format": ["csv"],
    ##       "mediatype": ["text/csv"],
    ##       "schema": {
    ##         "fields": [
    ##           {
    ##             "name": ["city"],
    ##             "type": ["string"],
    ##             "format": ["default"]
    ##           },
    ##           {
    ##             "name": ["location"],
    ##             "type": ["string"],
    ##             "format": ["default"]
    ##           }
    ##         ],
    ##         "missingValues": [
    ##           [""]
    ##         ]
    ##       }
    ##     },
    ##     {
    ##       "path": ["population.csv"],
    ##       "profile": ["tabular-data-resource"],
    ##       "encoding": ["utf-8"],
    ##       "name": ["population"],
    ##       "format": ["csv"],
    ##       "mediatype": ["text/csv"],
    ##       "schema": {
    ##         "fields": [
    ##           {
    ##             "name": ["city"],
    ##             "type": ["string"],
    ##             "format": ["default"]
    ##           },
    ##           {
    ##             "name": ["year"],
    ##             "type": ["integer"],
    ##             "format": ["default"]
    ##           },
    ##           {
    ##             "name": ["population"],
    ##             "type": ["integer"],
    ##             "format": ["default"]
    ##           }
    ##         ],
    ##         "missingValues": [
    ##           [""]
    ##         ]
    ##       }
    ##     }
    ##   ]
    ## }

### Working with Foreign Keys

The package supports foreign keys described in the [Table
Schema](http://specs.frictionlessdata.io/table-schema/#foreign-keys)
specification. It means if your data package descriptor use
`resources[]$schema$foreignKeys` property for some resources a data
integrity will be checked on reading operations.

Consider we have a data package:

``` r
DESCRIPTOR <- '{
  "resources": [
    {
      "name": "teams",
      "data": [
        ["id", "name", "city"],
        ["1", "Arsenal", "London"],
        ["2", "Real", "Madrid"],
        ["3", "Bayern", "Munich"]
      ],
      "schema": {
        "fields": [
          {"name": "id", "type": "integer"},
          {"name": "name", "type": "string"},
          {"name": "city", "type": "string"}
        ],
        "foreignKeys": [
          {
            "fields": "city",
            "reference": {"resource": "cities", "fields": "name"}
          }
        ]
      }
    }, {
      "name": "cities",
      "data": [
        ["name", "country"],
        ["London", "England"],
        ["Madrid", "Spain"]
      ]
    }
  ]
}'
```

Let’s check relations for a `teams` resource:

``` r
package <- Package.load(DESCRIPTOR)
teams <- package$getResource('teams')
```

``` r
teams$checkRelations()
```

    ## Error: Foreign key 'city' violation in row '4'

``` r
# tableschema.exceptions.RelationError: Foreign key "['city']" violation in row "4"
```

As we could see there is a foreign key violation. That’s because our
lookup table `cities` doesn’t have a city of `Munich` but we have a team
from there. We need to fix it in `cities` resource:

``` r
package$descriptor$resources[[2]]$data <- rlist::list.append(package$descriptor$resources[[2]]$data, list('Munich', 'Germany'))
package$commit()
```

    ## [1] TRUE

``` r
teams <- package$getResource('teams')
teams$checkRelations()
```

    ## [1] TRUE

``` r
# TRUE
```

Fixed\! But not only a check operation is available. We could use
`relations` argument for `resource$iter/read` methods to dereference a
resource relations:

``` r
jsonlite::toJSON(teams$read(keyed = TRUE, relations = FALSE), pretty =  TRUE)
```

    ## [
    ##   {
    ##     "id": [1],
    ##     "name": ["Arsenal"],
    ##     "city": ["London"]
    ##   },
    ##   {
    ##     "id": [2],
    ##     "name": ["Real"],
    ##     "city": ["Madrid"]
    ##   },
    ##   {
    ##     "id": [3],
    ##     "name": ["Bayern"],
    ##     "city": ["Munich"]
    ##   }
    ## ]

Instead of plain city name we’ve got a dictionary containing a city
data. These `resource$iter/read` methods will fail with the same as
`resource$check_relations` error if there is an integrity issue. But
only if `relations = TRUE` flag is passed.

## API Referencer

### Package

Package representation

  - [Package](#Package)
      - *instance*
          - [.valid](#Package+valid) ⇒ <code>Boolean</code>
          - [.errors](#Package+errors) ⇒ <code>Array.\<Error\></code>
          - [.profile](#Package+profile) ⇒ <code>Profile</code>
          - [.descriptor](#Package+descriptor) ⇒ <code>Object</code>
          - [.resources](#Package+resources) ⇒
            <code>Array.\<Resoruce\></code>
          - [.resourceNames](#Package+resourceNames) ⇒
            <code>Array.\<string\></code>
          - [.getResource(name)](#Package+getResource) ⇒
            <code>Resource</code> | <code>null</code>
          - [.addResource(descriptor)](#Package+addResource) ⇒
            <code>Resource</code>
          - [.removeResource(name)](#Package+removeResource) ⇒
            <code>Resource</code> | <code>null</code>
          - [.infer(pattern)](#Package+infer) ⇒ <code>Object</code>
          - [.commit(strict)](#Package+commit) ⇒ <code>Boolean</code>
          - [.save(target, raises, returns)](#Package+save)
      - *static*
          - [.load(descriptor, basePath, strict)](#Package.load) ⇒
            [<code>Package</code>](#Package)

#### package.valid ⇒ <code>Boolean</code>

Validation status

It always `true` in strict mode.

**Returns**: <code>Boolean</code> - returns validation status

#### package.errors ⇒ <code>Array.\<Error\></code>

Validation errors

It always empty in strict mode.

**Returns**: <code>Array.\<Error\></code> - returns validation errors

#### package.profile ⇒ <code>Profile</code>

Profile

#### package.descriptor ⇒ <code>Object</code>

Descriptor

**Returns**: <code>Object</code> - schema descriptor

#### package.resources ⇒ <code>Array.\<Resoruce\></code>

Resources

#### package.resourceNames ⇒ <code>Array.\<string\></code>

Resource names

#### package.getResource(name) ⇒ <code>Resource</code> | <code>null</code>

Return a resource

**Returns**: <code>Resource</code> | <code>null</code> - resource
instance if exists

| Param | Type                |
| ----- | ------------------- |
| name  | <code>string</code> |

#### package.addResource(descriptor) ⇒ <code>Resource</code>

Add a resource

**Returns**: <code>Resource</code> - added resource instance

| Param      | Type                |
| ---------- | ------------------- |
| descriptor | <code>Object</code> |

#### package.removeResource(name) ⇒ <code>Resource</code> | <code>null</code>

Remove a resource

**Returns**: <code>Resource</code> | <code>null</code> - removed
resource instance if exists

| Param | Type                |
| ----- | ------------------- |
| name  | <code>string</code> |

#### package.infer(pattern) ⇒ <code>Object</code>

Infer metadata

| Param   | Type                | Default            |
| ------- | ------------------- | ------------------ |
| pattern | <code>string</code> | <code>false</code> |

#### package.commit(strict) ⇒ <code>Boolean</code>

Update package instance if there are in-place changes in the descriptor.

**Returns**: <code>Boolean</code> - returns true on success and false if
not modified  
**Throws**:

  - <code>DataPackageError</code> raises any error occurred in the
    process

| Param  | Type                 | Description                          |
| ------ | -------------------- | ------------------------------------ |
| strict | <code>boolean</code> | alter `strict` mode for further work |

**Example**

``` r
dataPackage <- Package.load('{
    "name": "package",
    "resources": [{"name": "resource", "data": ["data"]}]
}')
dataPackage$descriptor$name # package
```

    ## [1] "package"

``` r
dataPackage$descriptor$name <- 'renamed-package'
dataPackage$descriptor$name # renamed-package
```

    ## [1] "renamed-package"

``` r
dataPackage$commit()
```

    ## [1] TRUE

#### package.save(target, raises, returns)

Save data package to target destination.

If target path has a zip file extension the package will be zipped and
saved entirely. If it has a json file extension only the descriptor will
be saved.

| Param   | Type                          | Description                       |
| ------- | ----------------------------- | --------------------------------- |
| target  | <code>string</code>           | path where to save a data package |
| raises  | <code>DataPackageError</code> | error if something goes wrong     |
| returns | <code>boolean</code>          | true on success                   |

#### Package.load(descriptor, basePath, strict) ⇒ [<code>Package</code>](#Package)

Factory method to instantiate `Package` class.

This method is async and it should be used with await keyword or as a
`Promise`.

**Returns**: [<code>Package</code>](#Package) - returns data package
class instance  
**Throws**:

  - <code>DataPackageError</code> raises error if something goes wrong

| Param      | Type                                      | Description                                                                                                                                |
| ---------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| descriptor | <code>string</code> | <code>Object</code> | package descriptor as local path, url or object. If ththe path has a `zip` file extension it will be unzipped to the temp directory first. |
| basePath   | <code>string</code>                       | base path for all relative paths                                                                                                           |
| strict     | <code>boolean</code>                      | strict flag to alter validation behavior. Setting it to `true` leads to throwing errors on any operation with invalid descriptor           |

### Resource

Resource representation

  - [Resource](#Resource)
      - *instance*
          - [.valid](#Resource+valid) ⇒ <code>Boolean</code>
          - [.errors](#Resource+errors) ⇒ <code>Array.\<Error\></code>
          - [.profile](#Resource+profile) ⇒ <code>Profile</code>
          - [.descriptor](#Resource+descriptor) ⇒ <code>Object</code>
          - [.name](#Resource+name) ⇒ <code>string</code>
          - [.inline](#Resource+inline) ⇒ <code>boolean</code>
          - [.local](#Resource+local) ⇒ <code>boolean</code>
          - [.remote](#Resource+remote) ⇒ <code>boolean</code>
          - [.multipart](#Resource+multipart) ⇒ <code>boolean</code>
          - [.tabular](#Resource+tabular) ⇒ <code>boolean</code>
          - [.source](#Resource+source) ⇒ <code>Array</code> |
            <code>string</code>
          - [.headers](#Resource+headers) ⇒
            <code>Array.\<string\></code>
          - [.schema](#Resource+schema) ⇒
            <code>tableschema.Schema</code>
          - [.iter(keyed, extended, cast, forceCast, relations,
            stream)](#Resource+iter) ⇒ <code>AsyncIterator</code> |
            <code>Stream</code>
          - [.read(limit)](#Resource+read) ⇒
            <code>Array.\<Array\></code> | <code>Array.\<Object\></code>
          - [.checkRelations()](#Resource+checkRelations) ⇒
            <code>boolean</code>
          - [.rawIter(stream)](#Resource+rawIter) ⇒
            <code>Iterator</code> | <code>Stream</code>
          - [.rawRead()](#Resource+rawRead) ⇒ <code>Buffer</code>
          - [.infer()](#Resource+infer) ⇒ <code>Object</code>
          - [.commit(strict)](#Resource+commit) ⇒ <code>boolean</code>
          - [.save(target)](#Resource+save) ⇒ <code>boolean</code>
      - *static*
          - [.load(descriptor, basePath, strict)](#Resource.load) ⇒
            [<code>Resource</code>](#Resource)

#### resource.valid ⇒ <code>Boolean</code>

Validation status

It always `true` in strict mode.

**Returns**: <code>Boolean</code> - returns validation status

#### resource.errors ⇒ <code>Array.\<Error\></code>

Validation errors

It always empty in strict mode.

**Returns**: <code>Array.\<Error\></code> - returns validation errors

#### resource.profile ⇒ <code>Profile</code>

Profile

#### resource.descriptor ⇒ <code>Object</code>

Descriptor

**Returns**: <code>Object</code> - schema descriptor

#### resource.name ⇒ <code>string</code>

Name

#### resource.inline ⇒ <code>boolean</code>

Whether resource is inline

#### resource.local ⇒ <code>boolean</code>

Whether resource is local

#### resource.remote ⇒ <code>boolean</code>

Whether resource is remote

#### resource.multipart ⇒ <code>boolean</code>

Whether resource is multipart

#### resource.tabular ⇒ <code>boolean</code>

Whether resource is tabular

#### resource.source ⇒ <code>Array</code> | <code>string</code>

Source

Combination of `resource.source` and
`resource.inline/local/remote/multipart` provides predictable interface
to work with resource data.

#### resource.headers ⇒ <code>Array.\<string\></code>

Headers

> Only for tabular resources

**Returns**: <code>Array.\<string\></code> - data source headers

#### resource.schema ⇒ <code>tableschema.Schema</code>

Schema

> Only for tabular resources

#### resource.iter(keyed, extended, cast, forceCast, relations, stream) ⇒ <code>AsyncIterator</code> | <code>Stream</code>

Iterate through the table data

> Only for tabular resources

And emits rows cast based on table schema (async for loop). With a
`stream` flag instead of async iterator a Node stream will be returned.
Data casting can be disabled.

**Returns**: <code>AsyncIterator</code> | <code>Stream</code> - async
iterator/stream of rows: - `[value1, value2]` - base - `{header1:
value1, header2: value2}` - keyed - `[rowNumber, [header1, header2],
[value1, value2]]` - extended  
**Throws**:

  - <code>TableSchemaError</code> raises any error occurred in this
    process

| Param     | Type                 | Description                                                                                                                                                                                                                                                                           |
| --------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| keyed     | <code>boolean</code> | iter keyed rows                                                                                                                                                                                                                                                                       |
| extended  | <code>boolean</code> | iter extended rows                                                                                                                                                                                                                                                                    |
| cast      | <code>boolean</code> | disable data casting if false                                                                                                                                                                                                                                                         |
| forceCast | <code>boolean</code> | instead of raising on the first row with cast error return an error object to replace failed row. It will allow to iterate over the whole data file even if it’s not compliant to the schema. Example of output stream: `[['val1', 'val2'], TableSchemaError, ['val3', 'val4'], ...]` |
| relations | <code>boolean</code> | if true foreign key fields will be checked and resolved to its references                                                                                                                                                                                                             |
| stream    | <code>boolean</code> | return Node Readable Stream of table rows                                                                                                                                                                                                                                             |

#### resource.read(limit) ⇒ <code>Array.\<Array\></code> | <code>Array.\<Object\></code>

Read the table data into memory

> Only for tabular resources; the API is the same as `resource.iter` has
> except for:

**Returns**: <code>Array.\<Array\></code> |
<code>Array.\<Object\></code> - list of rows: - `[value1, value2]` -
base - `{header1: value1, header2: value2}` - keyed - `[rowNumber,
[header1, header2], [value1, value2]]` - extended

| Param | Type                 | Description           |
| ----- | -------------------- | --------------------- |
| limit | <code>integer</code> | limit of rows to read |

#### resource.checkRelations() ⇒ <code>boolean</code>

It checks foreign keys and raises an exception if there are integrity
issues.

> Only for tabular resources

**Returns**: <code>boolean</code> - returns True if no issues  
**Throws**:

  - <code>DataPackageError</code> raises if there are integrity issues

#### resource.rawIter(stream) ⇒ <code>Iterator</code> | <code>Stream</code>

Iterate over data chunks as bytes. If `stream` is true Node Stream will
be returned.

**Returns**: <code>Iterator</code> | <code>Stream</code> - returns
Iterator/Stream

| Param  | Type                 | Description                  |
| ------ | -------------------- | ---------------------------- |
| stream | <code>boolean</code> | Node Stream will be returned |

#### resource.rawRead() ⇒ <code>Buffer</code>

Returns resource data as bytes.

**Returns**: <code>Buffer</code> - returns Buffer with resource data

#### resource.infer() ⇒ <code>Object</code>

Infer resource metadata like name, format, mediatype, encoding, schema
and profile.

It commits this changes into resource instance.

**Returns**: <code>Object</code> - returns resource descriptor

#### resource.commit(strict) ⇒ <code>boolean</code>

Update resource instance if there are in-place changes in the
descriptor.

**Returns**: <code>boolean</code> - returns true on success and false if
not modified  
**Throws**:

  - DataPackageError raises error if something goes wrong

| Param  | Type                 | Description                          |
| ------ | -------------------- | ------------------------------------ |
| strict | <code>boolean</code> | alter `strict` mode for further work |

#### resource.save(target) ⇒ <code>boolean</code>

Save resource to target destination.

> For now only descriptor will be saved.

**Returns**: <code>boolean</code> - returns true on success  
**Throws**:

  - <code>DataPackageError</code> raises error if something goes wrong

| Param  | Type                | Description                   |
| ------ | ------------------- | ----------------------------- |
| target | <code>string</code> | path where to save a resource |

#### Resource.load(descriptor, basePath, strict) ⇒ [<code>Resource</code>](#Resource)

Factory method to instantiate `Resource` class.

This method is async and it should be used with await keyword or as a
`Promise`.

**Returns**: [<code>Resource</code>](#Resource) - returns resource class
instance  
**Throws**:

  - <code>DataPackageError</code> raises error if something goes wrong

| Param      | Type                                      | Description                                                                                                                      |
| ---------- | ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| descriptor | <code>string</code> | <code>Object</code> | resource descriptor as local path, url or object                                                                                 |
| basePath   | <code>string</code>                       | base path for all relative paths                                                                                                 |
| strict     | <code>boolean</code>                      | strict flag to alter validation behavior. Setting it to `true` leads to throwing errors on any operation with invalid descriptor |

### Profile

Profile representation

  - [Profile](#Profile)
      - *instance*
          - [.name](#Profile+name) ⇒ <code>string</code>
          - [.jsonschema](#Profile+jsonschema) ⇒ <code>Object</code>
          - [.validate(descriptor)](#Profile+validate) ⇒
            <code>Object</code>
      - *static*
          - [.load(profile)](#Profile.load) ⇒
            [<code>Profile</code>](#Profile)

#### profile.name ⇒ <code>string</code>

Name

#### profile.jsonschema ⇒ <code>Object</code>

JsonSchema

#### profile.validate(descriptor) ⇒ <code>Object</code>

Validate a data package `descriptor` against the profile.

**Returns**: <code>Object</code> - returns a `{valid, errors}` object

| Param      | Type                | Description                                        |
| ---------- | ------------------- | -------------------------------------------------- |
| descriptor | <code>Object</code> | retrieved and dereferenced data package descriptor |

#### Profile.load(profile) ⇒ [<code>Profile</code>](#Profile)

Factory method to instantiate `Profile` class.

This method is async and it should be used with await keyword or as a
`Promise`.

**Returns**: [<code>Profile</code>](#Profile) - returns profile class
instance  
**Throws**:

  - <code>DataPackageError</code> raises error if something goes wrong

| Param   | Type                | Description                                    |
| ------- | ------------------- | ---------------------------------------------- |
| profile | <code>string</code> | profile name in registry or URL to JSON Schema |

### validate(descriptor) ⇒ <code>Object</code>

This function is async so it has to be used with `await` keyword or as a
`Promise`.

**Returns**: <code>Object</code> - returns a `{valid, errors}` object

| Param      | Type                                      | Description                                           |
| ---------- | ----------------------------------------- | ----------------------------------------------------- |
| descriptor | <code>string</code> | <code>Object</code> | data package descriptor (local/remote path or object) |

### infer(pattern) ⇒ <code>Object</code>

This function is async so it has to be used with `await` keyword or as a
`Promise`.

**Returns**: <code>Object</code> - returns data package descriptor

| Param   | Type                | Description       |
| ------- | ------------------- | ----------------- |
| pattern | <code>string</code> | glob file pattern |

### DataPackageError

Base class for the all DataPackage errors.

### TableSchemaError

Base class for the all TableSchema errors.

# Contributing

The project follows the [Open Knowledge International coding
standards](https://github.com/okfn/coding-standards). There are common
commands to work with the project.Recommended way to get started is to
create, activate and load the package environment. To install package
and development dependencies into active environment:

``` r
devtools::install_github("frictionlessdata/datapackage-r", dependencies=TRUE)
```

To make test:

``` r
  test_that(description, {
    expect_equal(test, expected result)
  })
```

To run tests:

``` r
devtools::test()
```

more detailed information about how to create and run tests you can find
in [testthat package](https://github.com/hadley/testthat)

## Changelog - News

In
[NEWS.md](https://github.com/frictionlessdata/datapackage-r/blob/master/NEWS.md)
described only breaking and the most important changes. The full
changelog could be found in nicely formatted
[commit](https://github.com/frictionlessdata/datapackage-r/commits/master)
history.

# Github

  - <https://github.com/frictionlessdata/datapackage-r>
