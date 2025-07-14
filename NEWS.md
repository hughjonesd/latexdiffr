
# latexdiffr (development version)


- **QMD diffing**: `latexdiff()` now preserves the document’s own Quarto `output_format` (falling back to `"latex"` only if none is supplied), so you can diff QMD files using any PDF format (e.g. `elsevier-pdf`) without losing the injected preamble.
- **Isolated formats per file**: Each input’s format choice is handled independently, preventing a prior file’s format from leaking into the next.
* Use environment variable `LATEXDIFF_PATH` to set the path to the latexdiff
  perl script.

# latexdiffr 0.2.0

* Added a `compile` option to (not) compile the diff.tex file to pdf.
* Added support for quarto files.

# latexdiffr 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* Initial release.
