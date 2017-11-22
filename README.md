<img src="okgr.png" align="right" width=130px /><img src="oklabs.png" align="right" width=130px /><br><br/><img src="frictionlessdata.png" align="left" width=60 />rictionless Data - <br/> Data Package
================

[![Build Status](https://travis-ci.org/okgreece/datapackage-r.svg?branch=master)](https://travis-ci.org/okgreece/datapackage-r) [![Coverage Status](https://coveralls.io/repos/github/okgreece/datapackage-r/badge.svg?branch=master)](https://coveralls.io/github/okgreece/datapackage-r?branch=master) [![Github Issues](http://githubbadges.herokuapp.com/okgreece/datapackage-r/issues.svg)](https://github.com/okgreece/datapackage-r/issues) [![Pending Pull-Requests](http://githubbadges.herokuapp.com/okgreece/datapackage-r/pulls.svg)](https://github.com/okgreece/datapackage-r/pulls) [![Project Status: Inactive – The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](http://www.repostatus.org/badges/latest/inactive.svg)](http://www.repostatus.org/#inactive) [![packageversion](https://img.shields.io/badge/Package%20version-0.0.0.9000-orange.svg?style=flat-square)](commits/master) [![minimal R version](https://img.shields.io/badge/R%3E%3D-3.1-6666ff.svg)](https://cran.r-project.org/) [![Licence](https://img.shields.io/badge/licence-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Description
===========

R library for working with [Data Package](http://frictionlessdata.io/specs/data-package).

Getting started
===============

Installation
------------

In order to install the latest distribution of [R software](https://www.r-project.org/) to your computer you have to select one of the mirror sites of the [Comprehensive R Archive Network](https://cloud.r-project.org/), select the appropriate link for your operating system and follow the wizard instructions.

For windows users you can:

1.  Go to CRAN
2.  Click download R for Windows
3.  Click Base (This is what you want to install R for the first time)
4.  Download the latest R version
5.  Run installation file and follow the instrustions of the installer.

(Mac) OS X and Linux users may need to follow different steps depending on their system version to install R successfully and it is recommended to read the instructions on CRAN site carefully.

Even more detailed installation instructions can be found in [R Installation and Administration manual](https://cran.r-project.org/doc/manuals/R-admin.html).

To install [RStudio](https://www.rstudio.com/), you can download [RStudio Desktop](https://www.rstudio.com/products/rstudio/download/) with Open Source License and follow the wizard instructions:

1.  Go to [RStudio](https://www.rstudio.com/products/rstudio/)
2.  Click download on RStudio Desktop
3.  Download on RStudio Desktop free download
4.  Select the appropriate file for your system
5.  Run installation file

To install the `datapackage` library it is necessary to install first `devtools` library to make installation of github libraries available.

``` r
# Install devtools package if not already
install.packages("devtools")
```

Install `datapackage.r`

``` r
# And then install the development version from github
devtools::install_github("okgreece/datapackage.r")
```

Load library
------------

``` r
# load the library using
library(datapackage.r)
```

    ## 
    ## Attaching package: 'datapackage.r'

    ## The following object is masked from 'package:stats':
    ## 
    ##     profile

Changelog - News
----------------

In [NEWS.md](https://github.com/okgreece/datapackage-r/blob/master/NEWS.md) described only breaking and the most important changes. The full changelog could be found in nicely formatted [commit](https://github.com/okgreece/datapackage-r/commits/master) history.

Contributing
============

The project follows the [Open Knowledge International coding standards](https://github.com/okfn/coding-standards). There are common commands to work with the project.Recommended way to get started is to create, activate and load the library environment. To install package and development dependencies into active environment:

``` r
devtools::install_github("okgreece/datapackage-r", dependencies=TRUE)
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

    ## No tests: no files in C:\Users\Kleanthis-Okf\Documents\datapackage-r/tests/testthat match '^test.*\.[rR]$'

more detailed information about how to create and run tests you can find in [testthat package](https://github.com/hadley/testthat)

Github
======

-   <https://github.com/okgreece/datapackage-r>

<img src="okgr.png" align="right" width=120px /><img src="oklabs.png" align="right" width=120px />
