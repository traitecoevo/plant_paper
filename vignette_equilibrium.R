library(tree)
library(parallel)

run <- function(seed_rain_in, p) {
  p$seed_rain <- seed_rain_in
  run_ebt(p)$seed_rains
}

run_new_schedule <- function(seed_rain_in, p) {
  p$seed_rain <- seed_rain_in
  res <- build_schedule(p)
  attr(res, "seed_rain_out")
}

cobweb <- function(m, ...) {
  lines(rep(m[,1], each=2), c(t(m)), ...)
}

## Try to establish what the equilubrium seed rain is.
p0 <- ebt_base_parameters()
p <- expand_parameters(trait_matrix(0.08, "lma"), p0, FALSE)

## Some output seed rains, given an input seed rain:
run(1.0, p)
run(10.0, p)
run(50.0, p)

## # 1: Approach to equilibrium:
p_eq <- equilibrium_seed_rain(p)

## Equilibrium seed rain
p_eq$seed_rain

## From a distance, these both hone in nicely on the equilibrium, and
## rapidly, too.
##+ equilibrium_approach
approach <- attr(p_eq, "progress")
r <- range(approach)
plot(approach, type="n", las=1, xlim=r, ylim=r)
abline(0, 1, lty=2, col="grey")
cobweb(approach, pch=19, cex=.5, type="o")

## Zoom in on the last few points:
##+ equilibrium_approach_detail
r <- p_eq$seed_rain + c(-1, 1) * 0.03
plot(approach, type="n", las=1, xlim=r, ylim=r)
abline(0, 1, lty=2, col="grey")
cobweb(approach, pch=19, cex=.5, type="o")

## # 2: Near the equilibrium point:

## Then, in the vinicity of the root we should look at what the curve
## actually looks like, without adaptive refinement.
dr <- 2 # range of input to vary (plus and minus this many seeds)
seed_rain_in <- seq(p_eq$seed_rain - dr,
                    p_eq$seed_rain + dr, length.out=31)
seed_rain_out <- unlist(mclapply(seed_rain_in, run, p_eq))

## Here is input seeds vs output seeds:
##+ seeds_in_seeds_out
plot(seed_rain_in, seed_rain_out, xlab="Incoming seed rain",
     ylab="Outgoing seed rain", las=1, type="l", asp=5)
abline(0, 1, lty=2, col="grey")
cobweb(approach)

## # 4. Global function shape
seed_rain_in_global <- seq(1, max(approach), length.out=51)

## This takes quite a while to compute.
##+ cache=TRUE
seed_rain_out_global <-
  unlist(mclapply(seed_rain_in_global, run_new_schedule, p))

## This is pretty patchy, which is due to incompletely refining the
## cohort schedule, I believe.  Tighten `schedule_eps` to make the
## curve smoother, at the cost of potentially a lot more effort.
##+ seeds_in_seeds_out_global
plot(seed_rain_in_global, seed_rain_out_global,
     las=1, type="l",
     xlab="Incoming seed rain", ylab="Outgoing seed rain")
abline(0, 1, lty=2, col="grey")
abline(fit,  lty=2)
cobweb(approach, lty=3)

## # 5. Multiple species at once:
p2 <- expand_parameters(trait_matrix(c(0.08, 0.15), "lma"), p0, FALSE)

p2_eq <- equilibrium_seed_rain(p2)
## TODO: This is not the correct format here:
approach <- attr(p2_eq, "progress")

## From a distance, these both hone in nicely on the equilibrium, and
## rapidly, too.
##+ approach_two_species
r <- range(unlist(approach))
plot(approach[[1]], type="n", las=1, xlim=r, ylim=r, xlab="in", ylab="out")
abline(0, 1, lty=2, col="grey")
cols <- c("black", "red")
for (i in 1:2) {
  cobweb(approach[, i + c(0, 2)], pch=19, cex=.5, type="o", col=cols[[i]])
}
abline(v=p2_eq$seed_rain, col=1:2, lty=3)

## In theory, we could create a vector field showing the overall
## approach...
