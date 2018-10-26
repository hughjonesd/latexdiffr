# latexdiffr

latexdiffr is a small library that uses the `latexdiff` command
to create a diff of two Rmarkdown files.

## Installation

``` r
remotes::install_github("hughjonesd/latexdiffr")
```

You will also need `latexdiff` installed on your system, from e.g. CTAN.

## Example


``` r
library(latexdiffr)
latexdiff("file1.Rmd", "file2.Rmd")

```

