## This works around the (frankly) weird misbehaviour of
## rmarkdown::pandoc_convert's wd argument.  I may be misusing it, but
## it seems basically not to work to me.  So instead we'll do the
## chdir ourselves.
pandoc_build <- function(file, template=NULL, format="pdf", ...) {
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

## TODO: move this into callr
run_system <- function(command, args, env=character()) {
  res <- suppressWarnings(system2(command, args,
                                  env=env, stdout=TRUE, stderr=TRUE))
  ok <- attr(res, "status")
  if (!is.null(ok) && ok != 0) {
    cmd <- paste(c(env, shQuote(command), args), collapse = " ")

    msg <- sprintf("Running command:\n  %s\nhad status %d", cmd, ok)
    errmsg <- attr(cmd, "errmsg")
    if (!is.null(errmsg)) {
      msg <- c(msg, sprintf("%s\nerrmsg: %s", errmsg))
    }

    sep <- paste(rep("-", getOption("width")), collapse="")
    msg <- c(msg, "Program output:", sep, res, sep)
    stop(paste(msg, collapse="\n"))
  }
  invisible(res)
}

## TODO: move this into remake
## TODO: options for saying what command is being run
latex_build <- function(filename, bibliography=NULL,
                        chdir=TRUE, interaction="nonstopmode",
                        max_attempts=5L, clean=FALSE) {
  latex <- Sys.which("pdflatex")
  if (latex == "") {
    stop("latex not found in $PATH")
  }

  if (chdir && dirname(filename) != "") {
    owd <- setwd(dirname(filename))
    on.exit(setwd(owd))
    filename <- basename(filename)
  }

  args <- c(paste0("-interaction=", interaction),
            "-halt-on-error",
            filename)
  res <- run_system(latex, args)
  if (!is.null(bibliography)) {
    run_system(Sys.which("bibtex"), sub(".tex$", "", filename))
    res <- run_system(latex, args)
  }

  pat <- c("Rerun to get cross-references right",
           "Rerun to get citations correct")
  isin <- function(p, x) {
    any(grepl(p, x))
  }
  for (i in seq_len(max_attempts)) {
    if (any(vapply(pat, isin, logical(1), res))) {
      res <- run_system(latex, args)
    } else {
      break
    }
  }

  if (clean) {
    latex_clean(filename)
  }

  invisible(NULL)
}

latex_clean <- function(filename) {
  filebase <- sub(".tex$", "", filename)
  exts <- c(".log", ".aux", ".bbl", ".blg", ".fls", ".out", ".snm",
            ".nav", ".tdo", ".toc")
  aux <- paste0(filebase, exts)
  file.remove(aux[file.exists(aux)])
}
