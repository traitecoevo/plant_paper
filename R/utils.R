label <- function(text, px=0.03, py=NULL, ..., adj=c(0, 1)) {
  if (is.null(py)) {
    fin <- par("fin")
    r <- fin[[1]] / fin[[2]]
    if (r > 1) { # x is longer.
      py <- 1 - px
      px <- (1 - py) / r
    } else {
      py <- 1 - px * r
    }
  }
  usr <- par("usr")
  x <- usr[1] + px*(usr[2] - usr[1])
  y <- usr[3] + py*(usr[4] - usr[3])

  ## NOTE: base 10 log:
  if (par("xlog")) {
    x <- 10^x
  }
  if (par("ylog")) {
    y <- 10^y
  }

  text(x, y, text, adj=adj, ...)
}

label_panel <- function(i, ...) {
  label(sprintf("%s)", letters[i]), ...)
}
