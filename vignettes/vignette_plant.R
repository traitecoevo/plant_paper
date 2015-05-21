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
## environment.  The function \code{fixed_environment} creates an
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
## soon).
pp$ode_names

## Plants are a type of *reference object*.  They are different to
## almost every other R object you regularly interact with in that
## they do not make copies when you rename them.  So changes to one
## will be reflected in another.
pl2 <- pl
pl2$height <- 1
pl2$height
pl$height # also 1!

## Alternative strategies:
##
## 1. Different parameters
## 2. Different hyperparameters
## 3. Different strategies
