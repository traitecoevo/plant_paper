## Eventually, this will be part of a vignette showing how to drive
## `tree` at the plant level.  Unfortunately, there's a lot of
## book-keeping to keep track of, so it's not that nice at this
## point.

## First, growth trajectories of plants
default_parameters <- function() {
  p <- ebt_base_parameters()
  p$disturbance_mean_interval <- 30.0
  p$strategy_default <- FFW16_Strategy(hmat = 30.0)
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
  res <- grow_plant_to_size(FFW16_PlantPlus(strategy),
                            heights, "height", env,
                            time_max, warn=FALSE, filter=TRUE)
  res$info <- do.call("rbind", lapply(res$plant, extract_plant_info, env))
  res
}

## Given vectors of heights and openness, lets do it all.
height_dt_openness <- function(height, openness, strategy) {
  pl <- FFW16_PlantPlus(strategy)
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
  p <- ebt_base_parameters()
  p$disturbance_mean_interval <- 30.0
  ## NOTE: These lma values; 0.08 and 0.267 are the equilibrium values
  ## in the fitness figure (see attractor2).
  s1 <- strategy(trait_matrix(0.08,  "lma"), p)
  s2 <- strategy(trait_matrix(0.267, "lma"), p)
  env1 <- fixed_environment(1.0)
  env2 <- fixed_environment(0.5)

  ## Generate most of the data here:
  heights1 <- seq(FFW16_PlantPlus(s1)$height, s1$hmat, length.out=100L)
  heights2 <- seq(FFW16_PlantPlus(s2)$height, s2$hmat, length.out=100L)
  data <- list("1_1"=run_plant_to_heights(heights1, s1, env1),
               "2_1"=run_plant_to_heights(heights2, s2, env1),
               "1_2"=run_plant_to_heights(heights1, s1, env2),
               "2_2"=run_plant_to_heights(heights2, s2, env2))

  ## And then the LCP data
  hmax <- s1$hmat / 2
  h1 <- seq_log(FFW16_PlantPlus(s1)$height, hmax, 2)
  h2 <- seq_log(FFW16_PlantPlus(s2)$height, hmax, 2)
  openness <- seq(0, 1, length.out=51)
  d1 <- lapply(h1, height_dt_openness, openness, s1)
  d2 <- lapply(h2, height_dt_openness, openness, s2)

  ## TODO: I think these should actually get rerun to a common time;
  ## at the moment they run off the RHS because they're run to a
  ## common *height*.

  cols_light <- c("black", "red")
  cols_height <- c("grey60", "black")
  cols_part <- c("black", "blue")

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
    ## seed=x$info[, "fraction_allocation_reproduction"])
  }
  alloc_h <- lapply(data, f)
  plot(NA, xlim=c(0, s1$hmat), ylim=c(0, 1), type="l",
       ylab="Fractional allocation", xlab="Height (m)", las=1)
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
  ylim <- range(sapply(dhdt_h, function(x) range(x[, 2])), 0)
  plot(dhdt_h[["1_1"]], ylim=ylim, lty=1, col=cols_light[[1]],
       type="l", las=1, xlab="Height (m)", ylab="d height / d t")
  lines(dhdt_h[["2_1"]], type="l", lty=2, col=cols_light[[1]])
  lines(dhdt_h[["1_2"]], type="l", lty=1, col=cols_light[[2]])
  lines(dhdt_h[["2_2"]], type="l", lty=2, col=cols_light[[2]])
  label_panel(3)
  legend("bottomleft",
         c("High light", "Low light"), lty=1, col=cols_light,
         bty="n")

  ## Panel d: wplcp
  plot(NA, xlim=c(0, 1), ylim=ylim, las=1,
       xlab="Canopy openness (%)", ylab="d height / d t")
  label_panel(4)
  for (i in seq_along(d1)) {
    lines(d1[[i]], lty=1, col=cols_height[[i]])
  }
  for (i in seq_along(d2)) {
    lines(d2[[i]], lty=2, col=cols_height[[i]])
  }
  points(c(env1$canopy_openness(0), env2$canopy_openness(0)),
         c(0, 0), pch=19, col=1:2)
  legend("topright", c("Seedling", "Adult"), lty=1, col=cols_height, bty="n")
}
