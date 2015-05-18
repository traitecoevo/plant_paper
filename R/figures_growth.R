make_growth_data <- function() {
  p0 <- ebt_base_parameters()
  p0$control$equilibrium_nsteps <- 30
  p0$control$equilibrium_solver_name <- "hybrid"
  p0$disturbance_mean_interval <- 30.0
  ## NOTE: These lma values; 0.08 and 0.267 are the equilibrium values
  ## in the fitness figure (see attractor2).
  p2 <- expand_parameters(trait_matrix(c(0.08, 0.267), "lma"), p0, FALSE)
  p2_eq <- equilibrium_seed_rain(p2)
  run_ebt_collect(p2_eq, TRUE)
}

figure_growth <- function(data) {
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

  col1 <- matrix(make_transparent("red", rd1), nrow(d1))
  col2 <- matrix(make_transparent("blue", rd2), nrow(d2))

  ## col1 <- matrix(mix_colours("red", "white", rd1), nrow(d1))
  ## col2 <- matrix(mix_colours("blue", "white", rd2), nrow(d2))
  ## col1[rd1 < 0.05] <- NA
  ## col2[rd2 < 0.05] <- NA

  op <- par(mfrow=c(3, 1), mar=c(1.1, 4.1, .5, .5), oma=c(3.1, 0, 0, 0))
  on.exit(par(op))
  matplot(t, h1, type="l", col="#ff000055", lty=1,
          las=1, xlab="Time (years)", ylab="Cohort height (m)", xaxt="n")
  matlines(t, h2, col="#0000ff55", lty=1)
  label_panel(1)
  axis(1, labels=FALSE)

  ## TODO: trimming the over-plotting artefact here is hard, but would
  ## be easier if I used 'mix' rather than make_transparent; that has
  ## other artefacts though (plotting order *really* matters)
  n <- length(t)
  x <- matrix(rep(t, ncol(h1)), nrow(h1))
  plot(NA, xlim=range(t), ylim=range(h1, na.rm=TRUE),
       las=1, xlab="Time (years)", ylab="Cohort height (m)", xaxt="n")
  segments(x[-1, ], h2[-1, ], x[-n, ], h2[-n, ], col=col2[-n, ])
  segments(x[-1, ], h1[-1, ], x[-n, ], h1[-n, ], col=col1[-n, ])
  label_panel(2)
  axis(1, labels=FALSE)

  ## Then, the total leaf area.
  matplot(t, data$area_leaf, lty=1, col=c("red", "blue"), type="l",
          xlab="Time (years)", ylab="Leaf area index")
  label_panel(3)
  mtext("Time (years)", 1, 3, cex=.6)
}
