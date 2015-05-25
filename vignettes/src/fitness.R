## ---
## title: "tree: A package for modelling plant TRait Ecology & Evolution: _fitness_"
## ---

library(tree)

## Start by setting a few parameters; this is the base set of
## parameters we'll use.
p0 <- ebt_base_parameters()
p0$control$equilibrium_nsteps <- 30
p0$control$equilibrium_solver_name <- "hybrid"
p0$disturbance_mean_interval <- 30.0

## First, compute the space that any strategy can exist along the
## "lma" axis:
bounds <- viable_fitness(bounds_infinite("lma"), p0)
bounds

## Generate a set of trait values across this range and compute the
## fitness landscape:
lma <- trait_matrix(seq_log_range(bounds, 101), "lma")
w0 <- fitness_landscape(lma, p0)

plot(lma, w0, type="l", log="x", las=1, ylab="Fitness (empty environment)")
abline(h=0, col="grey")

## Any trait value along this point can persist, so start with random sample
## (Set seed for random number generator so that get same results when rerun)
set.seed(5)
lma1 <- sort(sample(lma, 4))

## This function takes an lma value, introduces it to the community,
## runs that out to equilibrium seed rain:
add_eq <- function(x, p) {
  p <- expand_parameters(trait_matrix(x, "lma"), p, mutant=FALSE)
  equilibrium_seed_rain(p)
}

p1 <- lapply(lma1, add_eq, p0)

## Then compute fitness landscapes for each of these:
w1 <- sapply(p1, function(p) fitness_landscape(lma, p))

matplot(lma, w1, lty=1, type="l", log="x", ylim=c(-5, max(w1)))
abline(h=0, col="grey")
points(lma1, rep(0, 4), col=1:4, pch=19)

## For this system, there is an evolutionary attractor around
## lma 0.08:
lma_b <- 0.08
p1b <- add_eq(lma_b, p0)
lma_detail <- seq_log(lma_b * 0.95, lma_b * 1.05, 51)

w1b <- fitness_landscape(lma, p1b)
w1b_detail <- fitness_landscape(lma_detail, p1b)

plot(lma, w1b, log="x", type="l")
abline(h=0, col="grey")
points(lma_b, 0, pch=19)

plot(lma_detail, w1b_detail, log="x", type="l")
abline(h=0, col="grey")
points(lma_b, 0, pch=19)
