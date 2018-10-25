
#' Produce a diff of two Rmd files using latexdiff
#'
#' @param path1 Path to the first file
#' @param path2 Path to the second file
#' @param output Path to the output, without the file extension.
#' @param open Logical. Automatically open the resulting PDF?
#' @param clean Logical. Clean up intermediate TeX files?
#' @return
#' Invisible NULL.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' latexdiff("file1.Rmd", "file2.Rmd")
#' }
latexdiff <- function (path1, path2, output = "diff", open = interactive(), clean = TRUE) {
  out_fmt <- rmarkdown::latex_document()

  paths <- c(path1, path2)
  tex_paths <- rep(NA_character_, 2)
  for (idx in 1:2) {
    tex_paths[idx] <- if (grepl("\\.tex", paths[idx])) {
            paths[idx]
          } else if (grepl("\\.Rmd$", paths[idx])) {
            rmarkdown::render(paths[idx], output_format = out_fmt)
          } else if (grepl("\\.Rnw$", paths[idx])) {
            knit(paths[idx])
          } else {
            stop("Unrecognized file extension for '", paths[idx], "'")
          }
  }

  diff_tex_path <- paste0(output, ".tex")
  ld_ret <-system2("latexdiff", tex_paths, stdout = diff_tex_path)
  if (ld_ret != 0L) stop("latexdiff command returned an error")

  if (requireNamespace("tinytex", quietly = TRUE)) {
    tinytex::latexmk(diff_tex_path, clean = clean)
  } else {
    tools::texi2pdf(diff_tex_path, clean = clean)
  }

  if (clean) file.remove(tex_paths)

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

