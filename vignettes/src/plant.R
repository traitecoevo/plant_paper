## ---
## title: "tree: A package for modelling plant TRait Ecology & Evolution: _plant level traits_"
## ---

## This vignette covers the sort of analysis in the plant figure in
## the manuscript.  It also shows some of the features of working
## with plant components of the model.
library(tree)

## Plants are constructed with the `FFW16_Plant` function.  That
## function takes as its only argument a "strategy" object; the
## default is `FFW16_Strategy`, but alternative strategies can be
## provided (see below)
pl <- FFW16_Plant()

## Plants are an [R6](https://github.com/wch/R6) class, and have a
## number of elements and fields that can be accessed:
pl

## Things labelled 'active binding' are "fields" and can be read from
## and (sometimes) set:
pl$height
pl$height <- 10
pl$height

pl$fecundity
pl$mortality

## Height, fecundity and mortality are the three key variables
## propagated by the system of differential equations:
pl$ode_state

## To compute rates of change for these variables we need a light
## environment.  The function `fixed_environment` creates an
## environment that has the same light level (here 100%) at all
## heights.  The plant *does not affect* this light environment.
env <- fixed_environment(1.0)

## The `compute_vars_phys` method computes whole-plant assmilation for
## the plant, and from that growth rates:
pl$ode_rates
pl$compute_vars_phys(env)
pl$ode_rates

## Some internals from the calculations are available in the
## `internals` field:
names(pl$internals)

## Height growth rate
pl$internals$height_dt

## Leaf area (m^2)
pl$internals$area_leaf

## There's not actually that much that can be done with Plant
## objects; they're designed to be small and light to work well with
## the larger simulation code that does not particularly care about
## most of the internal calculations.
##
## Because of this, we have a "PlantPlus" object that exposes more of
## a strategy (NOTE: a little more than this because it also includes
## stem diameter growth)
pp <- FFW16_PlantPlus(pl$strategy)
pp$compute_vars_phys(env)
names(pp$internals)

## Some of the internals require `compute_vars_internals` to be run:
pp$compute_vars_growth()
zapsmall(unlist(pp$internals))

## This PlantPlus object also includes diameter and heartwood as two
## more variables for the ODE system (this might move into Plant
## soon -- see [this issue](https://github.com/traitecoevo/tree/issues/139)).
pp$ode_names

## Plants are a type of *reference object*.  They are different to
## almost every other R object you regularly interact with in that
## they do not make copies when you rename them.  So changes to one
## will be reflected in another.
pl2 <- pl
pl2$height <- 1
pl2$height
pl$height # also 1!

## # Growing plants

## Rather than setting plant physical sizes to given values, it will
## often be required to *grow* them to a size.  This is required to
## compute seed output (integrated over the plant's lifetime)
## diameter, mortality risk, etc; basically everything except for
## height.
##
## It's possible to directly integrate the equations exposed by the
## plant, using the `ode_state` field, `compute_vars_phys` method and
## `ode_rates` field.  For example, for use with `deSolve`:
derivs <- function(t, y, plant, env) {
  plant$ode_state <- y
  plant$compute_vars_phys(env)
  list(plant$ode_rates)
}
pl <- FFW16_Plant()
tt <- seq(0, 50, length.out=101)
y0 <- setNames(pl$ode_state, pl$ode_names)
yy <- deSolve::lsoda(y0, tt, derivs, pl, env=env)
plot(height ~ time, yy, type="l")

## Alternatively, it might desirable to grow a plant to a particular
## size.  We could interpolate from the previous results easily
## enough.  E.g., to find a plant with height of 15 m:
h <- 15.0

## that happened approximately here:
t <- spline(yy[, "height"], yy[, "time"], xout=h)$y

## Interpolate to find the state:
y <- apply(yy[, -1], 2, function(y) spline(yy[, "time"], y, xout=t)$y)

pl2 <- FFW16_Plant()
pl2$ode_state <- y
pl2$compute_vars_phys(env)
## Plant is expected height:
pl2$height
## And at this height, here is the total seed production:
pl2$fecundity

res <- grow_plant_to_time(FFW16_PlantPlus(FFW16_Strategy()), tt, env)

## Here is the results, plotted against the `deSolve` results from
## before:
plot(height ~ tt, res$state, type="l", las=1,
     xlab="Time (years)", ylab="Height (m)")
points(height ~ time, yy, col="grey", cex=.5)

## Completing the set, `tree` also provides a function for growing
## plants to a particular size; `grow_plant_to_size`.  This takes
## *any* size measurement in the plant and can grow the plant to that
## size.  So, for height:

pl <- FFW16_PlantPlus(FFW16_Strategy())
heights <- seq(pl$height, pl$strategy$hmat, length.out=20)
res <- grow_plant_to_size(pl, heights, "height", env)

## This returns a vector of times; this is when the heights were
## achieved
res$time

## A matrix of state:
head(res$state)

## And a list of plants
res$plant[[10]]
res$plant[[10]]$height
heights[[10]]

## Also included is `trajectory`; the points that the ODE stepper used
## with the system state at those times.

## There is a conveinence function `run_plant_to_heights` that
## achieves the same thing.  Alternatively, and variable within
## `plant$internals` can be used, so long as it increases
## monotonically with respect to time.
pl <- FFW16_PlantPlus(FFW16_Strategy())
mass <- seq_log(pl$internals$mass_above_ground + 1e-8, 1000, length.out=21)
res_mass <- grow_plant_to_size(pl, mass, "mass_above_ground", env,
                               time_max=100, warn=FALSE)
## (this seems on the low side - see [this
## issue](https://github.com/traitecoevo/tree/issues/142).
plot(res_mass$time, mass)

## With all these bits in place, let's look at growth trajectories of
## two species that differ in their LMA values.

p <- ebt_base_parameters()
## Low LMA ("fast growth") species
s1 <- strategy(trait_matrix(0.08,  "lma"), p)
## High LMA ("low growth") species
s2 <- strategy(trait_matrix(0.267, "lma"), p)

## Note that we're using an alternative way of specifying strategies
## here, to trigger our "hyperparametrisation" approach.  This may be
## simplified in future, but currently it resides on the `p` object.

## Then, generate a sequence of heights to collect information at
pl1 <- FFW16_PlantPlus(s1)
pl2 <- FFW16_PlantPlus(s2)

## (they are different for the two plants because they have different
## starting heights due to some allometric scalings)
heights1 <- seq(pl1$height, s1$hmat, length.out=100L)
heights2 <- seq(pl2$height, s2$hmat, length.out=100L)

dat1 <- grow_plant_to_height(pl1, heights1, env,
                             time_max=100, warn=FALSE, filter=TRUE)
dat2 <- grow_plant_to_height(pl2, heights2, env,
                             time_max=100, warn=FALSE, filter=TRUE)

plot(dat1$trajectory[, "time"], dat1$trajectory[, "height"],
     type="l", lty=1,
     las=1, xlab="Time (years)", ylab="Height (m)")
lines(dat2$trajectory[, "time"], dat2$trajectory[, "height"], lty=2)
legend("bottomright", c("Low LMA", "High LMA"), lty=1:2, bty="n")

## Similarly, growing the plants under lower light:
env_low <- fixed_environment(0.5)
dat1_low <- grow_plant_to_height(pl1, heights1, env_low,
                                 time_max=100, warn=FALSE, filter=TRUE)
dat2_low <- grow_plant_to_height(pl2, heights2, env_low,
                                 time_max=100, warn=FALSE, filter=TRUE)

cols <- c("black", "#31a354")
plot(dat1$trajectory[, "time"], dat1$trajectory[, "height"],
     type="l", lty=1,
     las=1, xlab="Time (years)", ylab="Height (m)")
lines(dat2$trajectory[, "time"], dat2$trajectory[, "height"], lty=2)
lines(dat1_low$trajectory[, "time"], dat1_low$trajectory[, "height"],
      lty=1, col=cols[[2]])
lines(dat2_low$trajectory[, "time"], dat2_low$trajectory[, "height"],
      lty=2, col=cols[[2]])
legend("bottomright",
       c("High light", "Low light"), lty=1, col=cols,
       bty="n")

## Alternative strategies:
##
## 1. Different parameters
## 2. Different hyperparameters
## 3. Different strategies
