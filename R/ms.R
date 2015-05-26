## This works around the (frankly) weird misbehaviour of
## rmarkdown::pandoc_convert's wd argument.  I may be misusing it, but
## it seems basically not to work to me.  So instead we'll do the
## chdir ourselves.
pandoc_build2 <- function(file, template=NULL, format="pdf", ...) {
  if (!grep("\\.md$", file)) {
    stop("Expected a markdown input")
  }

  if (!is.null(template)) {
    template <- normalizePath(template, mustWork=TRUE)
  }
  owd <- setwd(dirname(file))
  on.exit(setwd(owd))

  file_local <- basename(file)
  file_out   <- sub("\\.md$", paste0(".", format), file_local)

  ## Simplify the call a bit, if possible.
  if (is.null(template)) {
    args <- NULL
  } else {
    wd <- getwd()
    if (substr(template, 1, nchar(wd)) == wd) {
      template <- sub("^/+", "",
                      substr(template, nchar(wd) + 1, nchar(template)))
    }
    args <- list(sprintf("--template=%s", template))
  }
  pandoc_convert(file_local, output=file_out, options=args, verbose=FALSE, ...)
}

ms_deps_timestamp <- function(filename) {
  writeLines(as.character(Sys.time()), filename)
}
