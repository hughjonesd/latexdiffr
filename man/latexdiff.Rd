% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/latexdiff.R
\name{latexdiff}
\alias{latexdiff}
\title{Produce a diff of two files using latexdiff}
\usage{
latexdiff(
  path1,
  path2,
  output = "diff",
  compile = TRUE,
  open = interactive(),
  clean = TRUE,
  quiet = TRUE,
  output_format = NULL,
  ld_opts = "--replace-context2cmd=\\"none\\""
)
}
\arguments{
\item{path1}{Path to the first file.}

\item{path2}{Path to the second file.}

\item{output}{File name of the output, without the \code{.tex} extension.}

\item{compile}{Logical. Compile the diff from tex to pdf?}

\item{open}{Logical. Automatically open the resulting pdf?}

\item{clean}{Logical. Clean up intermediate TeX files?}

\item{quiet}{Logical. Suppress printing? Passed to \code{render} and \code{knit}, and hides standard error
of \code{latexdiff} itself.}

\item{output_format}{An rmarkdown output format for Rmd files, probably
\code{\link[rmarkdown:pdf_document]{rmarkdown::latex_document()}}. The default uses the options defined in the Rmd files.
YAML front matter.}

\item{ld_opts}{Character vector of options to pass to \code{latexdiff}. The
default avoids some problems with Rmd files.}
}
\value{
Invisible NULL.
}
\description{
\code{latexdiff()} uses the external utility \code{latexdiff} to create a PDF file
showing differences between two Rmd, qmd, Rnw or TeX files.
}
\details{
You will need the \code{latexdiff} utility installed on your system:

\if{html}{\out{<div class="sourceCode">}}\preformatted{# on MacOS:
brew install latexdiff

# on Linux:
sudo apt install latexdiff
}\if{html}{\out{</div>}}

For more details see \href{https://www.ctan.org/pkg/latexdiff}{CTAN} or
\href{https://github.com/ftilmann/latexdiff}{github}. You'll need a working
\code{perl} installation.

You can set the path to \code{latexdiff} in the environment variable
\code{"LATEXDIFF_PATH"}, using \code{\link[=Sys.setenv]{Sys.setenv()}} or via the command line. If this is
unset, it is assumed to be \code{"latexdiff"}.

File types are determined by extension,which should be one of \code{.tex}, \code{.Rmd},
\code{.qmd} or \code{.rnw}. Rmd files are processed by \code{\link[rmarkdown:render]{rmarkdown::render()}}. Rnw files
are processed by \code{\link[knitr:knit]{knitr::knit()}}. qmd files are processed by
\code{\link[quarto:quarto_render]{quarto::quarto_render()}}.

\code{latexdiff} is not perfect. Some changes will confuse it. In particular:
\itemize{
\item If input and output files are in different directories, the \code{"diff.tex"}
file may have incorrect paths for e.g. included figures. \code{latexdiff}
will add the \code{--flatten} option in this case, but things still are
not guaranteed to work.
\item Sometimes the \code{"diff.tex"} file fails to compile to pdf. If so,
set \code{compile = FALSE} and try editing the tex file manually.
}
}
\examples{
\dontrun{
latexdiff("file1.Rmd", "file2.Rmd")
}
}
