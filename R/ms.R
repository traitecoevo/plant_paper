pandoc_build <- function(file, template, toc=FALSE, engine="xelatex" ){
  args <- list(sprintf('--template=%s',template), "--listings", sprintf('--latex-engine=%s', engine))
  if(toc){
    args[[length(args) +1]] <- "--toc"
  }
  pandoc_convert(file, output= paste0(tools::file_path_sans_ext(file), ".pdf"),
    citeproc = TRUE, options = args, verbose = TRUE)
}

ms_deps_timestamp <- function(filename) {
  writeLines(as.character(Sys.time()), filename)
}