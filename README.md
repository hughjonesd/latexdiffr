# latexdiffr

[![Travis build status](https://travis-ci.org/hughjonesd/latexdiffr.svg?branch=master)](https://travis-ci.org/hughjonesd/latexdiffr)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/latexdiffr?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/latexdiffr)
[![Coverage status](https://codecov.io/gh/hughjonesd/latexdiffr/branch/master/graph/badge.svg)](https://codecov.io/github/hughjonesd/latexdiffr?branch=master)

latexdiffr is a small library that uses the `latexdiff` command
to create a diff of two Rmarkdown, .Rnw or TeX files.

## Installation

``` r
remotes::install_github("hughjonesd/latexdiffr")
```

You will also need `latexdiff` installed on your system:

``` bash
# on MacOS:
brew install latexdiff

# on Linux:
sudo apt install latexdiff 
```

## Example


``` r
library(latexdiffr)
latexdiff("file1.Rmd", "file2.Rmd")

```

This produces output like:

![latexdiff screenshot](https://raw.githubusercontent.com/hughjonesd/latexdiffr/master/diff-screenshot.png)

`git_latexdiff()` allows you to compare different revisions of a file in git:

```r
# 3 revisions ago:
git_latexdiff("my-file.Rmd", "HEAD~3") 
```
