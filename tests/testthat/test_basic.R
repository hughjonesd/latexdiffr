

context("Basic tests")

check_and_remove <- function (path) {
  expect_true(file.exists(path), label = sprintf("file.exists('%s')", path))
  if (file.exists(path)) file.remove(path)
}


test_that("All 3 file types compile", {
  files1 <- c("foo-prerendered.tex", "foo-rnw.Rnw", "foo-rmd.Rmd")
  files2 <- c("bar-prerendered.tex", "bar-rnw.Rnw", "bar-rmd.Rmd")

  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("knitr")

  for (f1 in files1) for (f2 in files2) {
    expect_error(latexdiff(f1, f2, open = FALSE), regexp = NA,
          label = sprintf("File 1: %s, file 2: %s", f1, f2))
    check_and_remove("diff.pdf")
  }
})


test_that("Can compile when in different directory", {
  make_tmp_dir <- function() {
    tmpdir <- tempfile()
    dir.create(tmpdir)
    normalizePath(tmpdir)
  }
  files <- c("foo-rmd.Rmd", "bar-rmd.Rmd")

  tmpdir <- make_tmp_dir()
  file.copy(files, tmpdir)
  paths <- file.path(tmpdir, files)
  expect_warning(latexdiff(paths[1], paths[2], output = "diff", open = FALSE), regexp = "--flatten")
  check_and_remove("diff.pdf")

  tmpdir <- make_tmp_dir()
  file.copy(files, tmpdir)
  paths <- file.path(tmpdir, files)
  out_path <- file.path(tmpdir, "diff")
  expect_error(latexdiff(paths[1], paths[2], output = out_path, open = FALSE), regexp = NA)
  check_and_remove(file.path(tmpdir, "diff.pdf"))

  tmpdir <- character(2)
  paths <- character(2)
  for (idx in 1:2) {
    tmpdir[idx] <- make_tmp_dir()
    file.copy(files[idx], tmpdir[idx])
    paths[idx] <- file.path(tmpdir[idx], files[idx])
  }
  latexdiff(paths[1], paths[2], open = FALSE)
  check_and_remove(file.path(tmpdir[1], "diff.pdf"))
})


test_that("Wrong file extension gives error", {
  expect_error(latexdiff("bad.txt", "foo-rmd.Rmd"))
})


test_that("git_latexdiff works", {
  skip_on_cran()
  skip_on_travis()

  root <- rprojroot::is_git_root
  in_git <- try({
    rprojroot::find_root_file("", criterion = root)
  }, silent = TRUE)
  skip_if(inherits(in_git, "try-error"), "Not in git")
  expect_error(git_latexdiff("git-changes.Rmd", "0ae84d"), regexp = NA)
})
