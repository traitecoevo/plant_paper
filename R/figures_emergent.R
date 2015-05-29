make_emergent_data <- function(hires=TRUE) {
  p0 <- ebt_base_parameters()
  if(hires) {
    p0$control$schedule_eps <- 2e-6
    p0$control$ode_tol_rel <- 1e-6
    p0$control$ode_tol_abs <- 1e-6
  }
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
  splinefun_loglog2 <- function(x,y,xx){
    ret <- splinefun_loglog(x,y)(xx)
    ii <- xx <= max(x, na.rm=TRUE) & xx >= min(x, na.rm=TRUE) 
    ret[!ii] <-0 
    ret
  }

  species <- data$species[[1]]
  height <- t(species["height", , ])
  log_density <- t(species["log_density", , ])
  density <- exp(log_density)

  # times for background grey lines
  j <- seq(1, length(data$time), by=10)

  # time to highlight in blue
  times <- c(5, 10, 20, 40, last(data$time))
  i <- vapply(times, closest, integer(1), data$time)
  blues <- c("#DEEBF7", "#C6DBEF", "#9ECAE1", "#6BAED6",
             "#4292C6", "#2171B5", "#08519C", "#08306B")
  cols <- colorRampPalette(blues[-(1:2)])(length(i))

  ## Then leaf area.  That requires a little more work because we don't
  ## have leaf areas for all the species.
  tmp <- lapply(seq_along(data$time), ebt_patch, data)
  xxx <- lapply(tmp, function(x) x$species[[1]]$area_leafs)
  leaf_area <- do.call("cbind", plant:::pad_matrix(xxx))

  xxx <- lapply(tmp, function(x) matrix(x$species[[1]]$ode_rates, 4)[1, ])
  growth_rate <- do.call("cbind", plant:::pad_matrix(xxx))

  # interpolate density in each patch to common set of heights
  hh <- seq_log_range(range(height, na.rm=TRUE), 500)
  xxx <- lapply(seq_along(data$time), function(i) 
              splinefun_loglog2(height[,i],density[,i], hh))
  n_hh <- do.call("cbind", plant:::pad_matrix(xxx))

  # interpolate leaf area in each patch to common set of heights
  xxx <- lapply(seq_along(data$time), function(i) 
              splinefun_loglog2(height[,i], leaf_area[,i], hh))
  l_hh <- do.call("cbind", plant:::pad_matrix(xxx))
  
  # interpolate growth_rate in each patch to common set of heights
  xxx <- lapply(seq_along(data$time), function(i) 
              splinefun_loglog2(height[,i],growth_rate[,i], hh))
  g_hh <- do.call("cbind", plant:::pad_matrix(xxx))
 
  # find average across patches for each height, 
  # i.e. across rows, weighting by patch abundance 
  metapopulation_average <- function(x) {
    plant:::trapezium(data$time, x*data$patch_density)
  }  
  n_av <- apply(n_hh,      1, metapopulation_average) 
  l_av <- apply(l_hh*n_hh, 1, metapopulation_average) / n_av
  g_av <- apply(g_hh*n_hh, 1, metapopulation_average) / n_av
 
  op <- par(mfrow=c(3, 1), mar=c(2.1, 6.1, .5, .5), oma=c(2, 0.5, 0, 0))
  on.exit(par(op))

  ## First panel: density vs height:
  xlim <- c(0, max(height, na.rm=TRUE) * 1.05)
  matplot(height[, j], density[, j], type="l", lty=1, col="lightgrey",
          xlim=xlim, xlab="Height (m)", ylab=expression("Density"~~("#"~m^-1~m^-2)), las=1,
          xaxt="n", log="y", yaxt="n")
  axis(1, labels=FALSE)
  aty <- zapsmall(log10(axTicks(2)))
  labels <- sapply(aty,function(i) as.expression(bquote(10^ .(i))))
  axis(2,at=10^aty,labels=labels, las=1)
  matlines(height[, i], density[, i], col=cols, lty=1, type="l")
  points(height[1, i], density[1, i], pch=19, col=cols)
  text(height[1, i] + strwidth("x"), density[1, i],
       paste0(round(times), c(" years", rep("", length(times) - 1))),
       adj=c(0, 0))
  label_panel(1)
  points(hh, n_av, col="red", type='l')

  matplot(height[, j], leaf_area[, j], type="l", lty=1, col="lightgrey",
          xlim=xlim, xlab="Height (m)",
          ylab=expression("Leaf area density"~~(m^2~m^-1~m^-2)), las=1,
          xaxt="n")
  axis(1, labels=FALSE)
  matlines(height[, i], leaf_area[, i], col=cols, lty=1, type="l")
  points(height[1, i], leaf_area[1, i], pch=19, col=cols)
  text(height[1, i] + strwidth("x"), leaf_area[1, i],
       paste0(round(times), c(" years", rep("", length(times) - 1))),
       adj=c(0, 0))
  label_panel(2)
  points(hh, l_av, col="red", type='l')

  matplot(height[, j], growth_rate[, j], type="l", lty=1, col="lightgrey",
          xlim=xlim, xlab="Height (m)",
          ylab=expression("Height growth rate"~~(m~yr^-1)), las=1)
  matlines(height[, i], growth_rate[, i], col=cols, lty=1, type="l")
  points(height[1, i], growth_rate[1, i], pch=19, col=cols)
  text(height[1, i] + strwidth("x"), growth_rate[1, i],
       paste0(round(times), c(" years", rep("", length(times) - 1))),
       adj=c(0, 0))
  label_panel(3)
  mtext("Height (m)", 1, 3, xpd=NA, cex=.75)
  points(hh, g_av, col="red", type='l')

}
