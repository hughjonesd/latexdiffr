

context("Basic tests")

test_that("All 3 file types compile", {
  files1 <- c("foo-prerendered.tex", "foo-rnw.Rnw", "foo-rmd.Rmd")
  files2 <- c("bar-prerendered.tex", "bar-rnw.Rnw", "bar-rmd.Rmd")

  for (f1 in files1) for (f2 in files2) {
    expect_error(latexdiff(f1, f2, open = FALSE), regexp = NA,
          label = sprintf("File 1: %s, file 2: %s", f1, f2))
    expect_true(file.exists("diff.pdf"))
    if (file.exists("diff.pdf")) file.remove("diff.pdf")
  }
})

test_that("Wrong file extension gives error", {
  expect_error(latexdiff("bad.txt", "foo-rmd.Rmd"))
})
