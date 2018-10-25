
#' Produce a diff of two Rmd files using latexdiff
#'
#' @param path1 Path to the first file
#' @param path2 Path to the second file
#' @param output Path to the output, without the ".tex" file extension.
#' @param open Logical. Automatically open the resulting PDF?
#' @return
#' Invisible NULL.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' latexdiff("file1.Rmd", "file2.Rmd")
#' }
latexdiff <- function (path1, path2, output = "diff", open = interactive()) {
  out_fmt <- rmarkdown::latex_document()
  tex_path1 <- rmarkdown::render(path1, output_format = out_fmt)
  tex_path2 <- rmarkdown::render(path2, output_format = out_fmt)

  diff_tex_path <- paste0(output, ".tex")
  ld_ret <-system2("latexdiff", c(tex_path1, tex_path2), stdout = diff_tex_path)
  if (ld_ret != 0L) stop("latexdiff command returned an error")

  if (requireNamespace("tinytex", quietly = TRUE)) {
    tinytex::latexmk(diff_tex_path)
  } else {
    tools::texi2pdf(diff_tex_path)
  }

  if (open) {
    diff_pdf_path <- paste0(output, ".pdf")
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

