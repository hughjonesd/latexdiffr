

context("Basic tests")

skip_on_cran()
which_cmd <- if (Sys.info()["sysname"] == "Windows") "where" else "which"
skip_if(system2(which_cmd, "latexdiff") != 0)

check_and_remove <- function (path) {
  expect_true(file.exists(path), label = sprintf("file.exists('%s')", path))
  if (file.exists(path)) file.remove(path)
}


in_git <- function () {
  root <- rprojroot::is_git_root
  in_git <- try({
    rprojroot::find_root_file("", criterion = root)
  }, silent = TRUE)
  return(! inherits(in_git, "try-error"))
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
  check_and_remove("diff.pdf")
})


test_that("Works with spaces in filename", {
  file.rename("foo_with_spaces.tex", "foo with spaces.tex") # avoids R CMD check issue
  expect_error(latexdiff("foo-prerendered.tex", "foo with spaces.tex"), regexp = NA)
  check_and_remove("diff.pdf")

  skip_on_cran()
  skip_on_travis()
  skip_if_not(in_git())

  expect_error(git_latexdiff("foo with spaces.tex", "89434f2a"), regexp = NA)
})

teardown({
  try(file.rename("foo with spaces.tex", "foo_with_spaces.tex"), silent = TRUE)
})

test_that("Wrong file extension gives error", {
  expect_error(latexdiff("bad.txt", "foo-rmd.Rmd"))
})


test_that("Gives error when diff.pdf is old", {
  file1 <- "foo-prerendered.tex"
  file2 <- "bar-prerendered.tex"

  tryCatch(
    latexdiff(file1, file2), # should work
    error = function (e) skip("Couldn't create a good diff.pdf")
  )

  # currently, changing the author gives an error
  expect_error(latexdiff(file1, "bar-newauthor-rmd.Rmd"), "Failed to create")
  if (file.exists("diff.pdf")) file.remove("diff.pdf")
})


test_that("git_latexdiff works", {
  skip_on_cran()
  skip_on_travis()
  skip_if_not(in_git())

  expect_error(git_latexdiff("git-changes.Rmd", "0ae84d"), regexp = NA)
})
