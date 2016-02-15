make_fitness_data <- function() {
  p0 <- scm_base_parameters("FF16")
  p0$control$equilibrium_nsteps <- 30
  p0$control$equilibrium_solver_name <- "hybrid"
  p0$disturbance_mean_interval <- 30.0

  bounds <- bounds_infinite("lma")

  bounds <- viable_fitness(bounds, p0)
  bounds <- check_bounds(bounds)

  ## Communities:
  ## NOTE: If updating attractor2, update in
  ## figures_growth.R:make_growth_data() and
  ## figures_plant.R:figure_plant()
  communities <-
    list(first      = 0.2,           # first individual
         attractor1 = 0.0825,           # first branching point
         second1    = c(0.0825, 0.355),  # ~= the max fitness
         second2    = c(0.0825, 0.2878),  # ~= the max fitness
         attractor2 = c(0.0825, 0.2625)) # stable

  lma_mutant <- seq_log_range(bounds, 101)

  lma_detail <- seq_log_range(communities$attractor1 * c(0.95, 1.05), 14)

  lma <- sort(c(unique(unlist(communities)), lma_mutant, lma_detail))

  ## TODO: First strategy should be at 0.1 so that we see an example
  ## that is out of equilibrium...

  f <- function(x, p) {
    equilibrium_seed_rain(expand_parameters(trait_matrix(x, "lma"), p, FALSE))
  }
  pp <- lapply(communities, f, p0)
  ww <- lapply(pp, fitness_landscape, trait_matrix=trait_matrix(lma, "lma"))

  list(communities=communities,
       lma=lma,
       lma_detail=lma_detail,
       p=pp,
       w=ww)
}

figure_fitness_landscape <- function(data) {
  communities <- data$communities
  lma <- data$lma
  w <- data$w

  ## Start the plots:
  xlim <- c(0.05, 2.00)
  ylim <- c(-2, max(unlist(w)))

  op <- par(mfrow=c(2, 1), mar=c(1.1, 4.1, .5, .5), oma=c(3.1, 0, 0, 0))
  on.exit(par(op))
  plot(lma, w$first, type="l", lty=2,
       log="x", xlim=xlim, ylim=ylim, ylab="Fitness", las=1, xaxt="n")
  label_panel(1)
  axis(1, labels=FALSE)
  lines(lma, w$attractor1)
  abline(h=0, col="grey")
  points(communities$first, 0, pch=1)
  points(communities$attractor1, 0, pch=19)

  r <- par("pin")[[1]] / par("pin")[[2]]
  dx <- 0.02
  dy <- dx * r
  px <- grconvertX(c(1 - 0.2, 1) - dx, from="npc", to="ndc")
  py <- grconvertY(c(1 - 0.2, 1) - dy, from="npc", to="ndc")

  i <- lma > 0.1
  plot(lma[i], w$second1[i], type="l", lty=2,
       log="x", xlim=xlim, ylim=ylim, ylab="Fitness", las=1)
  label_panel(2)
  mtext(expression("Leaf mass per unit leaf area"~("LMA;"~kg~m^-2)), 1, 3, cex=1)
  lines(lma[i], w$second2[i], lty=3)
  lines(lma, w$attractor2)
  abline(h=0)
  points(communities$attractor2[[1]], 0, pch=19)
  points(communities$attractor2[[2]], 0, pch=19)
  points(communities$second1[[2]], 0)
  points(communities$second2[[2]], 0, col="grey")

  ## TODO: Would be nice to scale the spacing automatically.
  par(fig=c(px, py), mar=rep(0, 4), new=TRUE)
  i <- lma >= min(data$lma_detail) & lma <= max(data$lma_detail)
  ylim2 <- c(-0.25, 0.25)
  plot(lma[i], w$attractor1[i], type="l", ylim=ylim2, axes=FALSE)
  box()
  abline(h=0, col="grey")
  points(communities$attractor1, 0, pch=19)
}
