
#' Produce a diff of two files using latexdiff
#'
#' `latexdiff()` uses the external utility `latexdiff` to create a PDF file
#' showing differences between two Rmd, Rnw or TeX files.
#'
#' @param path1 Path to the first file.
#' @param path2 Path to the second file.
#' @param output Path to the output, without the file extension.
#' @param open Logical. Automatically open the resulting PDF?
#' @param clean Logical. Clean up intermediate TeX files?
#' @param quiet Logical. Suppress printing? Passed to `render` and/or `knit`.
#' @param output_format An rmarkdown output format for Rmd files, probably
#'   [rmarkdown::latex_document()]. The default uses the options defined in the Rmd files.
#'   YAML front matter.
#'
#' @details
#' File types are determined by extension,which should be one of `.tex`, `.Rmd`
#' or `.rnw`. Rmd files are processed by [rmarkdown::render()]. Rnw files
#' are processed by [knitr::knit()].
#'
#' `latexdiff` is not perfect. Some changes will confuse it. In particular:
#'
#' * Changing the document title may cause failures.
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
        output = "diff",
        open = interactive(),
        clean = TRUE,
        quiet = TRUE,
        output_format = NULL
      ) {
  force(quiet)
  paths <- c(path1, path2)
  tex_paths <- rep(NA_character_, 2)

  basenames <- sub("(.*)\\.[^\\.]+$", "\\1", paths)
  if (basenames[1] == basenames[2]) {
    warning("Input paths have similar filenames, ",
         "resources may get overwritten during compilation")
  }

  extensions <- tolower(sub(".*\\.([^\\.]+)$", "\\1", paths))
  if (! all(extensions %in% c("rmd", "rnw", "tex"))) {
    stop(sprintf("Unrecognized file types: %s, %s. Files must end in '.Rmd', '.Rnw' or '.tex'",
      basename(paths[1]), basename(paths[2])))
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
              doc_opts <- rmarkdown::default_output_format(paths[idx])$options
              doc_opts$keep_tex <- NULL # needed
              output_format <- do.call(rmarkdown::latex_document, doc_opts)
            }
            rmarkdown::render(paths[idx], output_format = output_format, quiet = quiet)
          }
  }

  diff_tex_path <- paste0(output, ".tex")
  ld_ret <- system2("latexdiff", shQuote(tex_paths), stdout = diff_tex_path)
  if (ld_ret != 0L) stop("latexdiff command returned an error")

  if (requireNamespace("tinytex", quietly = TRUE)) {
    tinytex::latexmk(diff_tex_path, clean = clean)
  } else {
    tools::texi2pdf(diff_tex_path, clean = clean)
  }

  if (clean) {
    file.remove(setdiff(tex_paths, paths))
    file.remove(diff_tex_path)
  }

  diff_pdf_path <- paste0(output, ".pdf")
  if (open) {
    auto_open(diff_pdf_path)
  }

  return(invisible(NULL))
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

