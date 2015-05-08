
pandoc_build <- function(file, template, engine="xelatex" ){
  args <- list(sprintf('--template=%s',template), "--listings", sprintf('--latex-engine=%s', engine))
  pandoc_convert(file, output= paste0(tools::file_path_sans_ext(file), ".pdf"),
    citeproc = TRUE, options = args, verbose = TRUE)
}
