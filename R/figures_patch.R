make_patch_data <- function() {
  p0 <- scm_base_parameters()
  p0$control$equilibrium_nsteps <- 30
  p0$control$equilibrium_solver_name <- "hybrid"
  p0$disturbance_mean_interval <- 30.0
  ## NOTE: These lma values; 0.0825 and 0.2625 are the equilibrium values
  ## in the fitness figure (see attractor2).
  p2 <- expand_parameters(trait_matrix(c(0.0825, 0.2625), "lma"), p0, FALSE)
  p2_eq <- equilibrium_seed_rain(p2)
  run_scm_collect(p2_eq, TRUE)
}

figure_patch <- function(data) {
  t <- data$time
  h1 <- data$species[[1]]["height", , ]
  h2 <- data$species[[2]]["height", , ]

  d1 <- data$species[[1]]["log_density", , ]
  d2 <- data$species[[2]]["log_density", , ]
  ## Arbitrarily clamp this at -4 and convert to relative 0/1

  rel <- function(x, xmin) {
    x[x < xmin] <- xmin
    xmax <- max(x, na.rm=TRUE)
    (x - xmin) / (xmax - xmin)
  }

  rd1 <- rel(d1, -4)
  rd2 <- rel(d2, -4)

  cols <- c("#e34a33", "#045a8d")

  col1 <- matrix(make_transparent(cols[[1]], rd1), nrow(d1))
  col2 <- matrix(make_transparent(cols[[2]], rd2), nrow(d2))

  ## col1 <- matrix(mix_colours("red", "white", rd1), nrow(d1))
  ## col2 <- matrix(mix_colours("blue", "white", rd2), nrow(d2))
  ## col1[rd1 < 0.05] <- NA
  ## col2[rd2 < 0.05] <- NA

  op <- par(mfrow=c(3, 1), mar=c(1.0, 3.6, .5, 3), oma=c(2.6, 0, 0, 0),
            mgp=c(2.3, 1, 0))
  on.exit(par(op))
  matplot(t, h1, type="l", col=make_transparent(cols[[1]], 0.5), lty=1,
          las=1, xlab="Time (years)", ylab="Height (m)", xaxt="n")
  matlines(t, h2, col=make_transparent(cols[[2]], 0.5), lty=1)
  label_panel(1)
  axis(1, labels=FALSE)

  ## TODO: trimming the over-plotting artefact here is hard, but would
  ## be easier if I used 'mix' rather than make_transparent; that has
  ## other artefacts though (plotting order *really* matters)
  n <- length(t)
  x <- matrix(rep(t, ncol(h1)), nrow(h1))
  plot(NA, xlim=range(t), ylim=range(h1, na.rm=TRUE),
       las=1, xlab="Time (years)", ylab="Height (m)", xaxt="n")
  segments(x[-1, ], h2[-1, ], x[-n, ], h2[-n, ], col=col2[-n, ], lend="butt")
  segments(x[-1, ], h1[-1, ], x[-n, ], h1[-n, ], col=col1[-n, ], lend="butt")
  label_panel(2)
  axis(1, labels=FALSE)

  ## Then, the total leaf area.
  cols <- c("black", cols)
  lty <- c(3, 1, 1)
  y <- cbind(total=rowSums(data$area_leaf), data$area_leaf)
  matplot(t, y, lty=lty, col=cols, type="l",
          xlab="Time (years)", ylab="Leaf area index", las=1)
  label_panel(3)
  mtext("Time (years)", 1, 2.2, cex=.7)

  # find average value over metapopulation
  y_av <- apply(y, 2, function(x) plant:::trapezium(t, x*data$patch_density))
  for(i in seq_len(3)) {
    axis(4, at=y_av[i], labels=sprintf("%0.2f",y_av[i]), tck=0.1, col.ticks=cols[i], lty = lty[i], las=1)
  }
  axis(1, at=108, labels="Average")
}
