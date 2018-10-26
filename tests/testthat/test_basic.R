

context("Basic tests")

test_that("All 3 file types compile", {
  files1 <- c("foo-prerendered.tex", "foo-rnw.Rnw", "foo-rmd.Rmd")
  files2 <- c("bar-prerendered.tex", "bar-rnw.Rnw", "bar-rmd.Rmd")

  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("knitr")

  for (f1 in files1) for (f2 in files2) {
    expect_error(latexdiff(f1, f2, open = FALSE), regexp = NA,
          label = sprintf("File 1: %s, file 2: %s", f1, f2))
    expect_true(file.exists("diff.pdf"))
    if (file.exists("diff.pdf")) file.remove("diff.pdf")
  }
})


test_that("Can compile when in different directory", {
  tmpdir <- normalizePath(tempdir())
  files <- c("foo-prerendered.tex", "bar-prerendered.tex")
  file.copy(files, tmpdir)
  paths <- file.path(tmpdir, files)
  expect_error(latexdiff(paths[1], paths[2], open = FALSE), regexp = NA)
})

test_that("Wrong file extension gives error", {
  expect_error(latexdiff("bad.txt", "foo-rmd.Rmd"))
})
