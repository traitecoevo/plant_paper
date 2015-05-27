
table_tree_parameters <- function(filename, dest){

  xx <- read.csv(filename, stringsAsFactors=FALSE)

  to_bold <- which(xx$Symbol =="" )

  xx$Description[to_bold] <- sprintf("\\textbf{%s}", xx$Description[to_bold])

  x <- xtable(xx,
              hline.after=c(1),
              align='lp{5cm}lll')
  y <- print(x, sanitize.text.function=as.character,
             include.rownames=FALSE, floating=FALSE,
             print.results=FALSE)
  cat(y, file=dest)
}
