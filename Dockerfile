FROM islasgeci/base:0.7.0
COPY . /workdir
RUN Rscript -e "install.packages(c('covr', 'devtools', 'lintr', 'roxygen2', 'styler', 'testthat'), repos='http://cran.rstudio.com')"
RUN Rscript -e "devtools::install_github('frictionlessdata/datapackage-r', dependencies=TRUE)"