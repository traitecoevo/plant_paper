table_plant_parameters <- function(filename, dest){
  tab <- read.csv(filename, stringsAsFactors=FALSE,
                  check.names=FALSE, comment.char="#")

  to_bold <- tab$Symbol == ""
  tab$Description[to_bold] <- sprintf("\\textbf{%s}", tab$Description[to_bold])

  to_math <- tab$Symbol != ""
  tab$Symbol[to_math] <- sprintf("$%s$", tab$Symbol[to_math])

  to_math <- grepl("[_^]", tab$Units)
  tab$Units[to_math] <-
    sprintf("$%s$",
            gsub("(kg|m|yr)", "\\\\mathrm{\\1}", tab$Units[to_math]))
  tab$Units[to_math] <-
            gsub(" ", "\\,", tab$Units[to_math], fixed =TRUE)

  to_code <- tab[["\\plant"]] != ""
  code <- tab[["\\plant"]][to_code]

  s <- FFW16_Strategy()
  val <- s[code]
  err <- sapply(val, is.null)
  if (any(err)) {
    stop("Missing parameters: ", paste(code[err], collapse=", "))
  }

  oo <- options(scipen=999)
  on.exit(options(oo))
  tab$Value[to_code] <- prettyNum(unlist(val))

  tab[["\\plant"]][to_code] <- sprintf("\\texttt{%s}",
                                      gsub("_", "\\\\_", code))

  x <- xtable(tab,
              hline.after=c(1),
              align='lp{7cm}llll')
  y <- print(x, sanitize.text.function=as.character,
             include.rownames=FALSE, floating=FALSE,
             print.results=FALSE)
  cat(y, file=dest)
}
