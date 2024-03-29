
#' @import assertthat
NULL


#' Produce a diff of two files using latexdiff
#'
#' `latexdiff()` uses the external utility `latexdiff` to create a PDF file
#' showing differences between two Rmd, qmd, Rnw or TeX files.
#'
#' @param path1 Path to the first file.
#' @param path2 Path to the second file.
#' @param output File name of the output, without the `.tex` extension.
#' @param compile Logical. Compile the diff from tex to pdf?
#' @param open Logical. Automatically open the resulting pdf?
#' @param clean Logical. Clean up intermediate TeX files?
#' @param quiet Logical. Suppress printing? Passed to `render` and `knit`, and hides standard error
#'   of `latexdiff` itself.
#' @param output_format An rmarkdown output format for Rmd files, probably
#'   [rmarkdown::latex_document()]. The default uses the options defined in the Rmd files.
#'   YAML front matter.
#' @param ld_opts Character vector of options to pass to `latexdiff`. The
#'   default avoids some problems with Rmd files.
#'
#' @details
#'
#' You will need the `latexdiff` utility installed on your system:
#'
#' ```
#' # on MacOS:
#' brew install latexdiff
#'
#' # on Linux:
#' sudo apt install latexdiff
#' ```
#'
#' For more details see [CTAN](https://www.ctan.org/pkg/latexdiff) or
#' [github](https://github.com/ftilmann/latexdiff). You'll need a working
#' `perl` installation.
#'
#' You can set the path to `latexdiff` in the environment variable
#' `"LATEXDIFF_PATH"`, using [Sys.setenv()] or via the command line. If this is
#' unset, it is assumed to be `"latexdiff"`.
#'
#' File types are determined by extension,which should be one of `.tex`, `.Rmd`,
#' `.qmd` or `.rnw`. Rmd files are processed by [rmarkdown::render()]. Rnw files
#' are processed by [knitr::knit()]. qmd files are processed by
#' [quarto::quarto_render()].
#'
#' `latexdiff` is not perfect. Some changes will confuse it. In particular:
#'
#' * If input and output files are in different directories, the `"diff.tex"`
#'   file may have incorrect paths for e.g. included figures. `latexdiff`
#'   will add the `--flatten` option in this case, but things still are
#'   not guaranteed to work.
#' * Sometimes the `"diff.tex"` file fails to compile to pdf. If so,
#'   set `compile = FALSE` and try editing the tex file manually.
#'
#' @return
#' Invisible NULL.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' latexdiff("file1.Rmd", "file2.Rmd")
#' }
latexdiff <- function (
        path1,
        path2,
        output        = "diff",
        compile       = TRUE,
        open          = interactive(),
        clean         = TRUE,
        quiet         = TRUE,
        output_format = NULL,
        ld_opts       = "--replace-context2cmd=\"none\""
      ) {
  assert_that(is.string(path1), is.string(path2), is.string(output),
                is.string(ld_opts))
  assert_that(is.flag(compile), is.flag(open), is.flag(clean), is.flag(quiet))

  force(quiet)
  paths <- c(path1, path2)
  tex_paths <- rep(NA_character_, 2)

  file_roots <- fs::path_ext_remove(paths)
  if (file_roots[1] == file_roots[2]) {
    warning("Input paths have similar filenames, ",
         "resources may get overwritten during compilation")
  }

  dirs <- fs::path_real(fs::path_dir(c(paths, output)))

  if (length(unique(dirs)) > 1) {
    warning("Some input/output files are in different directory. Using latexdiff --flatten option.\n",
          "Errors may still occur.")
    ld_opts <- c(ld_opts, "--flatten")
  }

  extensions <- tolower(fs::path_ext(paths))
  if (! all(extensions %in% c("rmd", "rnw", "tex", "qmd"))) {
    stop(sprintf("Unrecognized file types: %s, %s.",
            fs::path_file(path1),
            fs::path_file(path2)),
          "Files must end in '.Rmd', '.qmd', '.Rnw' or '.tex'")
  }

  for (idx in 1:2) {
    tex_paths[idx] <- if (extensions[idx] == "tex") {
            paths[idx]
          } else if (extensions[idx] == "rnw") {
            loadNamespace("knitr")
            knitr::knit(paths[idx], quiet = quiet)
          } else if (extensions[idx] == "rmd") {
            loadNamespace("rmarkdown")
            if (missing(output_format)) {
              def_out_fmt <- rmarkdown::default_output_format(paths[idx])
              if (def_out_fmt$name == "pdf_document") {
                doc_opts <- def_out_fmt$options
                doc_opts$keep_tex <- NULL # needed
              } else {
                doc_opts <- list()
              }
              output_format <- do.call(rmarkdown::latex_document, doc_opts)
            }
            rmarkdown::render(paths[idx], output_format = output_format, quiet = quiet)
          } else if (extensions[idx] == "qmd") {
            loadNamespace("quarto")
            tex_file <- fs::path_ext_set(paths[idx], "tex")
            tex_file <- fs::path_file(tex_file)
            quarto::quarto_render(paths[idx], output_format = "latex",
                                  output_file = tex_file, quiet = quiet)
            tex_file
          }
  }
  on.exit({
    if (clean) file.remove(setdiff(tex_paths, paths))
  })

  diff_tex_path <- paste0(output, ".tex")
  latexdiff_path <- Sys.getenv("LATEXDIFF_PATH", unset = "latexdiff")
  latexdiff_stderr <- if (quiet) FALSE else ""

  ld_ret <- if (identical(.Platform$OS.type, "windows")) {
              system2("perl",
                c(latexdiff_path, ld_opts, shQuote(tex_paths)),
                stdout = diff_tex_path,
                stderr = latexdiff_stderr
              )
            } else {
              system2(latexdiff_path,
                c(ld_opts, shQuote(tex_paths)),
                stdout = diff_tex_path,
                stderr = latexdiff_stderr
              )
            }

  if (ld_ret != 0L) stop("latexdiff command returned an error")

  if (compile) {
    old_wd <- getwd()
    setwd(fs::path_dir(diff_tex_path))
    on.exit(setwd(old_wd))
    diff_tex_file <- fs::path_file(diff_tex_path)
    pdf_start_time <- Sys.time()
    tryCatch({

        if (requireNamespace("tinytex", quietly = TRUE)) {
          tinytex::latexmk(diff_tex_file, clean = clean)
        } else {
          tools::texi2pdf(diff_tex_file, clean = clean)
        }
      },
      error = function (e) {
        warning("PDF creation gave an error:\n\t", e$message,
              "\nSometimes PDF creation still worked, so let's continue.")
      },
      finally = setwd(old_wd)
    )

    if (clean) {
      file.remove(diff_tex_path)
    }

    diff_pdf_path <- paste0(output, ".pdf")
    if (! fs::file_exists(diff_pdf_path) ||
          ! fs::file_info(diff_pdf_path)$modification_time >= pdf_start_time) {
      stop("Failed to create PDF.")
    }
    if (open) {
      auto_open(diff_pdf_path)
    }
  }

  return(invisible(NULL))
}

#' Call latexdiff on git revisions
#'
#' `git_latexdiff()` checks out a previous version of a file and calls latexdiff
#'  on it.
#'
#' @param path File path to diff
#' @param revision Revision, specified in a form that `git` understands. See
#'   `man gitrevisions`
#' @param clean Clean up intermediate files, including the checked out file?
#' @param ... Arguments passed to [latexdiff()]
#'
#' @return The result of `latexdiff`.
#'
#' @details
#' `git_latexdiff` only checks out the specific file in `path`. If your Rmd file depends on external
#' resources which have also changed, you will need to checkout the old revision as a whole and
#' create the tex file manually.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' git_latexdiff("file1.Rmd", "HEAD^")
#' git_latexdiff("file1.Rmd", "master@{7 days ago}")
#' }
git_latexdiff <- function (path, revision, clean = TRUE, ...) {
  assert_that(is.string(path), is.string(revision), is.flag(clean))

  dir <- fs::path_dir(path)
  cur_file <- fs::path_file(path)
  cur_filebase <- fs::path_ext_remove(cur_file)
  cur_fileext  <- paste0(".", fs::path_ext(cur_file))
  tmp_filepath <- fs::file_temp(pattern = cur_filebase, ext = cur_fileext,
        tmp_dir = dir)

  root <- rprojroot::is_git_root
  git_path <- fs::path_rel(path,
        rprojroot::find_root_file("", criterion = root))
  # only double quotes work on some systems:
  show_arg <- sprintf('"%s:%s"', revision, git_path)

  if (clean) {
    on.exit({
      if (fs::file_exists(tmp_filepath)) fs::file_delete(tmp_filepath)
    })
  }
  res <- system2("git", c("show", show_arg), stdout = tmp_filepath,
        stderr = FALSE)
  if (res != 0) {
    warning(sprintf("`git show %s` returned %s", show_arg, res))
  }

  if (! fs::file_exists(tmp_filepath)) {
    stop("Could not check revision out of git.")
  }

  latexdiff(tmp_filepath, path, clean = clean, ...)
}

auto_open <-function (path) {
  sysname <- Sys.info()["sysname"]
  switch(sysname,
        Darwin = system2("open", path),
        Windows = system2("start",  path),
        Linux = system2("xdg-open", path),
        warning("Could not determine OS to open document automatically")
      )
}

