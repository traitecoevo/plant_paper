## First, growth trajectories of plants
default_parameters <- function() {
  p <- scm_base_parameters()
  p$disturbance_mean_interval <- 30.0
  p$strategy_default <- FF16_Strategy(hmat = 30.0)
  p
}

## This ensures that the plants are up-to-date with the environment
## (that's not guaranteed by the running function) and extracts a ton
## of data about them.
extract_plant_info <- function(p, env) {
  p$compute_vars_phys(env)
  p$compute_vars_growth()
  x <- unlist(p$internals)

  ## Relative growth methods (= d(y)/dt / y)
  v <- c("height", "area_stem", "diameter_stem", "mass_above_ground")
  x[sprintf("%s_dt_relative", v)] <- x[sprintf("%s_dt", v)] / x[v]
  x
}

## Small wrapper around grow_plant_to_size that collects information
## about plants.
run_plant_to_heights <- function(heights, strategy, env,
                                 time_max=100) {
  res <- grow_plant_to_size(FF16_PlantPlus(strategy),
                            heights, "height", env,
                            time_max, warn=FALSE, filter=TRUE)
  res$info <- do.call("rbind", lapply(res$plant, extract_plant_info, env))
  res
}

## Given vectors of heights and openness, lets do it all.
height_dt_openness <- function(height, openness, strategy) {
  pl <- FF16_PlantPlus(strategy)
  pl$height <- height
  min <- lcp_whole_plant(pl)
  openness <- c(min, openness[openness > min])
  f <- function(x) {
    env <- fixed_environment(x)
    pl$compute_vars_phys(env)
    pl$internals$height_dt
  }
  cbind(openness=openness,
        height_dt=sapply(openness, f))
}

figure_plant <- function() {
  ## Everything will be done against two strategies (differing in LMA)
  ## and against two light environments (with the exception of the LCP
  ## plot).
  p <- scm_base_parameters()
  p$disturbance_mean_interval <- 30.0
  ## NOTE: These lma values; 0.08 and 0.267 are the equilibrium values
  ## in the fitness figure (see attractor2).
  s1 <- strategy(trait_matrix(0.08,  "lma"), p)
  s2 <- strategy(trait_matrix(0.267, "lma"), p)
  env1 <- fixed_environment(1.0)
  env2 <- fixed_environment(0.5)

  ## Generate most of the data here:
  heights1 <- seq(FF16_PlantPlus(s1)$height, s1$hmat, length.out=100L)
  heights2 <- seq(FF16_PlantPlus(s2)$height, s2$hmat, length.out=100L)
  data <- list("1_1"=run_plant_to_heights(heights1, s1, env1),
               "2_1"=run_plant_to_heights(heights2, s2, env1),
               "1_2"=run_plant_to_heights(heights1, s1, env2),
               "2_2"=run_plant_to_heights(heights2, s2, env2))

  ## And then the LCP data
  hmax <- s1$hmat / 2
  h1 <- seq_log(FF16_PlantPlus(s1)$height, hmax, 2)
  h2 <- seq_log(FF16_PlantPlus(s2)$height, hmax, 2)
  openness <- seq(0, 1, length.out=51)
  d1 <- lapply(h1, height_dt_openness, openness, s1)
  d2 <- lapply(h2, height_dt_openness, openness, s2)

  ## TODO: I think these should actually get rerun to a common time;
  ## at the moment they run off the RHS because they're run to a
  ## common *height*.

  cols_light <- c("black", "#e34a33")
  cols_height <- c("#31a354", "black")
  cols_part <- c("black", "#045a8d")

  op <- par(mfrow=c(2, 2), mar=c(3.6, 4.1, .5, .5), mgp=c(2.2, 1, 0))
  on.exit(par(op))
  ## Panel a: height vs time
  f <- function(x) {
    cbind(time=x$trajectory[, "time"], height=x$trajectory[, "height"])
  }
  h_t <- lapply(data, f)
  plot(h_t[["1_1"]], type="l", lty=1, col=cols_light[[1]],
       las=1, xlab="Time (years)", ylab="Height (m)")
  lines(h_t[["2_1"]], type="l", lty=2, col=cols_light[[1]])
  lines(h_t[["1_2"]], type="l", lty=1, col=cols_light[[2]])
  lines(h_t[["2_2"]], type="l", lty=2, col=cols_light[[2]])
  label_panel(1)

  legend("bottomright",
         c("High light", "Low light"), lty=1, col=cols_light,
         bty="n")

  ## Panel b: fractions of biomass over time
  f <- function(x) {
    cbind(height=x$info[, "height"],
          leaf=x$info[, "mass_leaf"] / x$info[, "mass_live"],
          sapwood=x$info[, "mass_sapwood"] / x$info[, "mass_live"])
  }
  alloc_h <- lapply(data, f)
  plot(NA, xlim=c(0, s1$hmat), ylim=c(0, 1), type="l",
       ylab="Fraction of biomass", xlab="Height (m)", las=1)
  label_panel(2)
  matlines(alloc_h[["1_1"]][, 1],
           alloc_h[["1_1"]][, -1],
           lty=1, col=cols_part)
  matlines(alloc_h[["2_1"]][, 1],
           alloc_h[["2_1"]][, -1],
           lty=2, col=cols_part)
  legend("topright", c("Sapwood", "Leaf"), lty=1, col=rev(cols_part), bty="n")

  ## Panel c: d(height)/dt vs height
  f <- function(x) {
    cbind(h=x$info[, "height"], dhdt=x$info[, "height_dt"])
  }
  dhdt_h <- lapply(data, f)
  ymax_dhdt <- max(sapply(dhdt_h, function(x) max(x[, 2])), 0)
  ylim_dhdt <- c(-0.05 * ymax_dhdt, ymax_dhdt)

  plot(dhdt_h[["1_1"]], ylim=ylim_dhdt, lty=1, col=cols_light[[1]],
       type="l", las=1, xlab="Height (m)", ylab=expression("Height growth rate"~~(m~yr^-1)))
  lines(dhdt_h[["2_1"]], type="l", lty=2, col=cols_light[[1]])
  lines(dhdt_h[["1_2"]], type="l", lty=1, col=cols_light[[2]])
  lines(dhdt_h[["2_2"]], type="l", lty=2, col=cols_light[[2]])
  label_panel(3)
  legend("topright",
         c("High light", "Low light"), lty=1, col=cols_light,
         bty="n")

  ## Panel d: wplcp
  plot(NA, xlim=c(0, 1), ylim=ylim_dhdt, las=1,
       xlab="Canopy openness (%)", ylab=expression("Height growth rate"~~(m~yr^-1)))
  abline(h=0)
  label_panel(4)
  for (i in seq_along(d1)) {
    lines(d1[[i]], lty=1, col=cols_height[[i]])
  }
  for (i in seq_along(d2)) {
    lines(d2[[i]], lty=2, col=cols_height[[i]])
  }
  points(c(env1$canopy_openness(0), env2$canopy_openness(0)),
         c(0, 0), pch="|", col=cols_light)
  legend("topright", c("Seedling", "Adult"), lty=1, col=cols_height, bty="n")

  first <- function(x) x[[1]]
  x1 <- sapply(d1, first)
  x2 <- sapply(d2, first)
  y1 <- rep(par("usr")[[3]] * 1 / 3, length(x1))
  y2 <- rep(par("usr")[[3]] * 2 / 3, length(x2))
  p <- 0.25
  z1 <- sum(x1 * c(p, 1 - p))
  z2 <- sum(x2 * c(p, 1 - p))

  points(x1, y1, col=cols_height, pch=19)
  points(x2, y2, col=cols_height, pch=1)
  arrows(x1[1], y1[1], z1, y1[2], length=0.05, col=cols_height[[1]])
  arrows(x2[1], y2[1], z2, y2[2], length=0.05, col=cols_height[[1]])
}
