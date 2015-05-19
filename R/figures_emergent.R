make_emergent_data <- function() {
  p0 <- ebt_base_parameters()
  p0$disturbance_mean_interval <- 30.0
  p1 <- expand_parameters(trait_matrix(0.08, "lma"), p0, FALSE)
  p1 <- build_schedule(p1)
  run_ebt_collect(p1, TRUE)
}

figure_emergent <- function(data) {
  closest <- function(t, time) {
    which.min(abs(time - t))
  }
  last <- function(x) {
    x[[length(x)]]
  }

  species <- data$species[[1]]
  height <- t(species["height", , ])
  log_density <- t(species["log_density", , ])
  density <- exp(log_density)

  times <- c(5, 10, 20, 40, last(data$time))
  i <- vapply(times, closest, integer(1), data$time)
  blues <- c("#DEEBF7", "#C6DBEF", "#9ECAE1", "#6BAED6",
             "#4292C6", "#2171B5", "#08519C", "#08306B")
  cols <- colorRampPalette(blues[-(1:2)])(length(i))

  ## Then leaf area.  That requires a little more work because we don't
  ## have leaf areas for all the species.
  tmp <- lapply(seq_along(data$time), ebt_patch, data)
  xxx <- lapply(tmp, function(x) x$species[[1]]$area_leafs)
  leaf_area <- do.call("cbind", tree:::pad_matrix(xxx))

  xxx <- lapply(tmp, function(x) matrix(x$species[[1]]$ode_rates, 4)[1, ])
  growth_rate <- do.call("cbind", tree:::pad_matrix(xxx))

  op <- par(mfrow=c(3, 1), mar=c(2.1, 4.1, .5, .5), oma=c(2, 0, 0, 0))
  on.exit(par(op))
  ## First panel: density vs height:
  xlim <- c(0, max(height, na.rm=TRUE) * 1.05)
  matplot(height, density, type="l", lty=1, col="lightgrey",
          xlim=xlim, xlab="Height (m)", ylab="Density (1 / m / m2)", las=1,
          xaxt="n", log="y")
  axis(1, labels=FALSE)
  matlines(height[, i], density[, i], col=cols, lty=1, type="l")
  points(height[1, i], density[1, i], pch=19, col=cols)
  text(height[1, i] + strwidth("x"), density[1, i],
       paste0(round(times), c(" years", rep("", length(times) - 1))),
       adj=c(0, 0))
  label_panel(1)

  matplot(height, leaf_area, type="l", lty=1, col="lightgrey",
          xlim=xlim, xlab="Height (m)",
          ylab="Leaf area density (m2 / m2 / m)", las=1,
          xaxt="n")
  axis(1, labels=FALSE)
  matlines(height[, i], leaf_area[, i], col=cols, lty=1, type="l")
  points(height[1, i], leaf_area[1, i], pch=19, col=cols)
  text(height[1, i] + strwidth("x"), leaf_area[1, i],
       paste0(round(times), c(" years", rep("", length(times) - 1))),
       adj=c(0, 0))
  label_panel(2)

  matplot(height, growth_rate, type="l", lty=1, col="lightgrey",
          xlim=xlim, xlab="Height (m)",
          ylab="Height growth rate (m / year)", las=1)
  matlines(height[, i], growth_rate[, i], col=cols, lty=1, type="l")
  points(height[1, i], growth_rate[1, i], pch=19, col=cols)
  text(height[1, i] + strwidth("x"), growth_rate[1, i],
       paste0(round(times), c(" years", rep("", length(times) - 1))),
       adj=c(0, 0))
  label_panel(3)
  mtext("Height (m)", 1, 3, xpd=NA, cex=.75)
}
