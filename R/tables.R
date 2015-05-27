
table_tree_parameters <- function(filename, dest){

  tree_parameters <- read.csv(filename, stringsAsFactors=FALSE)
  x <- xtable(tree_parameters,
              hline.after=c(1),
              align='lp{5cm}lll')
  y <- print(x, sanitize.text.function=as.character,
             include.rownames=FALSE, floating=FALSE,
             print.results=FALSE)
  cat(y, file=dest)
}
