
First release. This package requires the latexdiff utility, which
I assume is not available on CRAN. So, most tests are turned off.

* Resubmission in response to a manual check. I have added the line
  on.exit(setwd(old_wd)) immediately after changing directory.
  Changing directory is necessary for texi2pdf to work right.

## Test environments

* local OS X install, R 4.0.3
* github actions, r-devel and r-release on MacOS and Linux
* rhub, r-devel and r-release on Windows and Linux
* win-builder did not respond

## R CMD check results

0 errors | 0 warnings | 0 notes

One "New submission" note on some platforms.
