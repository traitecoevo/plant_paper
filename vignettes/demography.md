---
title: "tree: A package for modelling plant TRait Ecology & Evolution: _Modelling demography of plants, patches and metapopulations_"
csl: ../downloads/style.csl
bibliography: ../refs.bib
---

# Introduction

This vignette outlines methods used to model demography in the TREE package, using methods from  @Deroos-1997; @Kohyama-1993; @Moorcroft-2001, @Falster-2011; and @Falster-2015. We  first outline the system dynamics and then describe the numerical techniques used to solve the equations.

# System dynamics

## Individual plants

Consider the dynamics of an individual plant. Throughout we refer to a plant as having traits $x$ and size $h$,  notionally it's  height. The plant grows in an environment $E$, a function giving the distribution of light with respect to height. Ultimately $E$ depends on the composition of the patch at age $a$. To indicate this dependence we write $E_a$.  
Now let the functions $g(x,h,E_a)$, $d(x,h,E_a)$ and $f(x,h,E_a)$ denote the growth, death, and fecundity rates of the plant. Then,
\begin{equation} \label{eq:size}
  h(x, a_0, a) = h_0 + \int_{a_0}^{a} g(x, h(x, a_0, a^\prime),E_{a^\prime}) \, \rm{d}a^\prime
\end{equation} is the trajectory of plant height,
\begin{equation} \label{eq:survivalIndividual}
  S_{\rm I} (x, a_0, a) = \pi_1 (x,h_0, E_{a_0}) \, \exp\left(- \int_{a_0}^{a} d(x,h(x, a_0, a^\prime), E_{a^\prime}) \, {\rm d} a^\prime \right)
\end{equation}
is the probability of survival $S_{\rm I}$ within the patch, and 
\begin{equation} \label{eq:tildeR1}
  \tilde{R}(x, a_0, a) =\int_{a_0}^{a} f(x, h(x, a_0, a^\prime), E_{a^\prime}) \, S_{\rm I} (x, a_0, a^\prime) {\rm d} a^\prime
\end{equation}
is the cumulative seed output for the plant from its birth at age $a=a_0 \rightarrow a$, and where the term $\pi_1 (x,h_0, E_{a_0})$ denotes survival through germination.

The notational complexity required in Eqs. \ref{eq:size} - \ref{eq:tildeR1} potentially obscures an important point: Eqs. \ref{eq:size} - \ref{eq:tildeR1} are general, non-linear solutions to integrating growth, mortality and fecundity functions over time.


## Patches of competing plants / Size-structured populations

Let us now consider a patch of competing plants. At any age $a$, the patch is described by the density-distribution $n(x,h,a)$ of plants with traits $x$ and height $h$. In a finite-sized patch, $n$ is a collection of delta-peaks, whereas as in a very (infinitely) large patch $n$ is a continuous distribution. In either case, the demographic behaviour of the plants within the patch is given by Eqs. \ref{eq:size} - \ref{eq:tildeR1}. Integrating the dynamics over time is complicated by two other factors: i) plants interact, thereby altering $E_a$ with age; and (ii) new individuals may establish, expanding the the system of equations.  

In the current version of TREE plants interact by shading one another. Following standards biophysical principles, we let canopy openness $E(z,a)$ at height $z$ in a patch of age $a$ decline exponentially with the total amount of leaf area above $z$, i.e. 
\begin{equation} \label{eq:light}
  E(z,a) = \exp \left(-c_{ext}  \sum_{i=1}^{N} \int_{0}^{\infty} \phi(h) \, L(z, h) \, n(x_i,h,a) \, dm \right),
\end{equation}
where $\phi(h)$ is total leaf area and $L(z, h(m))$ is fraction of this leaf area held above height $z$ for plants size $h$, $c_{ext}$ is the light extinction coefficient, and $N$ is the number of species.

Assuming patches are large, the dynamics of $n$ can be modelled deterministically via the following Partial Differential Equation (PDE) [@Kohyama-1993; @Deroos-1997; @Moorcroft-2001]:
\begin{equation} \label{eq:PDE} 
  \frac{\partial }{\partial a} n(x,h,a)= -d(x,h, E_a) \; n(x,h,a)-\frac{\partial }{\partial m} \left[g(x,h,E_a) \; n(x,h,a)\right].
\end{equation}
(See appendix XXX.)

Eq. $\ref{eq:PDE}$ has two boundary conditions. The first links the flux of individuals across the lower bound $(h_0)$ of the size distribution to the rate at which seeds arrive in the patch, $y_x$:
\begin{equation} \label{eq:BC1}
  n(x,h_0,a_0)  = \left\{
  \begin{array}{ll}   \frac{y_x  \pi_1 (x^\prime,h_0, E_{a_0}) }{ g(x,h_0, E_{a_0}) }  & \textrm{if } g(x,h_0, E_{a_0}) > 0 \\
  0 & \textrm{otherwise.}
  \end{array} \right.
\end{equation}

The function $\pi_1 (x^\prime,h_0, E_{a_0})$ denotes survival through germination and must be chosen such that 
$\pi_1 (x^\prime,h_0, E_{a_0}) / g(x,h_0, E_{a_0}) \rightarrow 0$ as $g(x,h_0, E_{a_0}) \rightarrow 0$  to ensure a smooth decline in initial density as conditions deteriorate [@Falster-2011]. The function has that property
\begin{equation} \label{eq:pi1}
  pi_1 (x^\prime,h_0, E_{a_0}) = XXXX.
\end{equation}

The second boundary condition of Eq. $\ref{eq:PDE}$ gives the size distribution for patches when $a=0$. Throughout we consider only situations where we start with an empty patch, i.e. 
\begin{equation} \label{eq:BC2} n\left(x,h,0\right) =0,
\end{equation}
although non--zero distributions could be specified [e.g @Moorcroft-2001].

## Age-structured distribution of patches

Let us now consider the abundance of patches age $a$ in the landscape. Let $a$ be time since last disturbance, $p(a)$  be the frequency-density of patches age $a$, and $\gamma(a)$ be the age-dependent probability that a patch of age $a$ is transformed into a patch of age 0 by a disturbance event. Here we focus on the situation where the age structure has reached an equilibrium state, which causes the PDE to reduce to an ordinary differential equation (ODE) with respect to patch age. (See appendix XXX for derivation and non-equilibrium case and derivation). The dynamics of $p$ are given by [@Vonfoerster-1959; @Mckendrick-1926]:
\begin{equation} \label{eq:agepde}
\frac{{\rm d}}{{\rm d} a} p(a)  = -\gamma(a) \, p(a) ,
\end{equation}
with boundary condition
\begin{equation}  p(0)  = \int_0^\infty \gamma(a) \, p(a) \; {\rm d} a.
\end{equation}
The probability a patch remains undisturbed from $a_0$ to $a$ is then
\begin{equation} \label{eq:survivalPatch}
  S_{\rm P} (a_0,a) = \exp\left(-\int_{a_0}^{a} \gamma(a^\prime) \, {\rm d} a^\prime \right).
\end{equation}

The above equations lead to an equilibrium distribution of patch-ages
\begin{equation} p(a) = p(0) S_{\rm P} (0,a),
\end{equation}
where
\begin{equation}
  p(0) = \frac1{\int_0^\infty S_{\rm P} (0,a) {\rm d}a},
\end{equation}
is the average lifespan of a patch and the frequency-density of patches age $0$.

## Trait-, size- and patch-structured metapopulations

Consider a large area of habitat where: i) disturbances (such as fires, storms, landslides, floods, or disease outbreaks) strike patches of the habitat on a stochastic basis, killing individuals within affected patches; ii) individuals compete for resources within patches, but the spatial scale of competitive interaction means interactions among individuals in adjacent patches are negligible; and iii) there is high connectivity via dispersal between all patches in the habitat, allowing empty patches to be quickly re-colonised. Such a system can be modelled as a metapopulation (sometimes called metacommunity for multiple species). The dynamics of this metapopulation are described by PDES in Eqs. \ref{eq:agepde} and \ref{eq:PDE}.

The seed rain of each species in the metapopulation is given by rate at which seeds are produced across all patches,
\begin{equation}  \label{eq:seed_rain} 
  y_x = \int_0^{\infty} p(a)  \int_0^{\infty}  \pi_0 f(x,h,E_a) \; n(x,h,a)\,{\rm d} m \, {\rm d} a,
\end{equation}
where $\pi_0$ is the average survival of seeds during dispersal.

A convenient feature of Eqs. $\ref{eq:PDE}$ - $\ref{eq:BC2}$ is that the dynamics of a single patch scale up to give the dynamics of the entire metapopulation. Note that the rate offspring arrive from the disperser pool, $y_x$, is constant for a metapopulation at equilibrium. Combined with the assumption that all patches have the same initial (empty) size distribution, the assumption of constant seed rain ensures all patches show the same temporal behaviour, the only difference between them being the ages at which they are disturbed.

To model the temporal dynamics of an archetypal patch, we need only a value for $y_x$. The numerical challenge is therefore to find the right value for $y_x$, by solving in Eqs. \ref{eq:BC1} and \ref{eq:seed_rain} as simultaneous equations.

## Emergent properties of metapopulation

Summary statistics of the metapopulation are obtained by integrating over the density distribution, weighting by patch abundance $p(a)$. The total number of individuals in the metapopulation is given by
\begin{equation}
  \hat{n}(x) = \int_{0}^{\infty} \int_{0}^{\infty}p(a) \; n(x,h,a) \, {\rm d}a \, {\rm d}h;
\end{equation}
and the average density of plants size $h$ by
\begin{equation}
  \bar{n}(x,h) = \int_{0}^{\infty}p(a) \; n(x,h,a) \, {\rm d}a.
\end{equation}

Average values for other quantities can also be calculated. Let $\phi(x, h, E_a)$ be a demographic quantity of interest, such as growth rate, mortality rate, light environment, or size. The average value of $\phi$ across the metapopulation is
\begin{equation}
  \hat{\phi}(x) = \frac1{\hat{n}(x) }\int_{0}^{\infty} \int_{0}^{\infty} p(a) \; n(x,h,a) \phi(x,h,E_a) \, {\rm d}a \, {\rm d}h,
\end{equation}
while the average  value of $\phi$ for plants size $h$ is
\begin{equation}\bar{\phi}(x,h) = \frac1{\bar{n}(x,h) }\int_{0}^{\infty}p(a)  n(x,h,a) \phi(x,h,E_a)\, {\rm d}a.
\end{equation}

When calculating average mortality rate, one must decide whether mortality due patch disturbance is included. Non-disturbance mortality is obtained by setting $\phi(x,h, E_a) = d(x,h,E_a)$, while total mortality due to growth processes and disturbance is obtained by setting $\phi(x,h, E_a) = d(x,h,E_a)+ \gamma(a) S_{\rm P}(0,a).$


## Invasion fitness

Let us now consider how we can estimate the fitness of a rare individual with traits $x^\prime$ growing in the environment of a resident community with traits $x$. We will focus on the phenotypic components of fitness -- i.e. the consequences of a given set of traits for growth, fecundity and mortality -- taking into account the non-linear effects of competition on individual success, but ignoring the underlying genetic basis for the trait determination. We also adhere to the standard conventions in such analyses in assuming that the mutant is sufficiently rare to have a negligible effect on the environment where it is growing.

Invasion fitness is most correctly defined as the long-term per capita growth rate of a rare mutant population growing in the environment determined by the resident strategy [@Metz-1992]. Calculating per-capita growth rates, however, is particularly challenging in a structured metapopulation model [@Gyllenberg-2001; @Metz-2001]. As an alternative measure of fitness, we can use the basic reproduction ratio, which gives the expected number of new dispersers arising from a single dispersal event. Evolutionary inferences made using the basic reproduction ratio will be similar to those made using per-capita growth rates for metapopulations at demographic equilibrium [@Gyllenberg-2001; @Metz-2001].

Let $R\left(x^\prime,x\right)$ be the basic reproduction ratio of individuals with traits $x^\prime$ growing in the competitive environment of the resident traits $x$. Recalling that patches of age $a$ have density $p(a)$ in the landscape, it follows that any seed of $x^\prime$ has probability $p(a)$ of landing in a patch age $a$. The basic reproduction ratio for individuals with traits $x^\prime$ is then:
\begin{equation} \label{eq:InvFit}
  R\left(x^\prime,x\right)=\int _0^{\infty }p\left(a\right)\tilde{R}\left(x^\prime,a, \infty \right)\; {\rm d}a ,
\end{equation}
where $\tilde{R}\left(x^\prime,a_0,a \right)$ is the expected number of dispersing offspring produced by a single dispersing seed arriving in a patch of age $a_0$ up until age $a$ [@Gyllenberg-2001; @Metz-2001]. $\tilde{R}\left(x^\prime,a,\infty\right)$ is calculated by integrating an individual's fecundity over the expected lifetime the patch, taking into account competitive shading from residents with traits $x$, the individual's probability of surviving, and its traits via the equation:

\begin{equation} \label{eq:tildeR}
  \tilde{R}(x^\prime, a_0, a) =\int_{a_0}^{a}  \pi_0f(x^\prime, h(x^\prime, a_0, a^\prime), E_{a^\prime}) \, S_{\rm I} (x^\prime, a_0, a^\prime) \, S_{\rm P} (a_0,a^\prime)  {\rm d} a^\prime.
\end{equation}


# Approximating system dynamics using the escalator boxcar train (EBT)

Our approach for solving the trait-, size- and patch-structured population dynamics described by Eqs. \ref{eq:size} - \ref{eq:tildeR} is based on the Escalator Boxcar Train technique  (EBT) [@Deroos-1997; @Deroos-1992; @Deroos-1988]. The EBT solves the PDE describing development of $n(x,h,a)$ (Eq. $\ref{eq:PDE}$) by approximating the density function with a collection of cohorts spanning the size spectrum. Following a disturbance, a series of cohorts are introduced into each patch. These cohorts are then transported along the characteristics of Eq. $\ref{eq:PDE}$ according to the individual-level growth function. Characteristics are curves along which Eq. $\ref{eq:PDE}$  becomes an ordinary differential equation (ODE); biologically, these are the growth trajectories of individuals, provided they do not die.

The original EBT [@Deroos-1997; @Deroos-1992; @Deroos-1988] proceeds by approximating the first and second moments of the density distribution $n \left( x,h,a \right)$ within a series of "cohorts", represented by $\lambda_i$ and $\mu_i$, these being the total number and mean size of individuals within the cohort respectively. Under this assumption, the rates of change $\frac{\rm d} {{\rm d}a} \lambda_i$ and $\frac{\rm d} {{\rm d}a} \mu_i$ can be approximated given by two ODEs, which can in turn be approximated by first-order closed-form solutions. Eq. $\ref{eq:PDE}$ is thereby reduced to a family of ODEs, which can be stepped using an appropriate ODE solver with an adaptive step size. The size distribution $n(x,h,a)$ is then approximated by a series of point masses with position and amplitude given by $\lambda_i$ and $\mu_i$.

In the current implementation we use a slightly different approach for approximating the size distribution $n(x,h,a)$. Instead of tracking the first and second moments of the size-distribution within cohorts, we track a point mass estimate of $n$ situated on the characteristic corresponding to cohort boundary. By integrating along characteristics, the density of individuals with time of birth $a_{0}$ is given by [@Deroos-1997]:
\begin{equation}\label{eq:boundN}
  n(x, m, a)  =n(x,h_0 ,a_0) 
   \exp \left(-\int _{a_0}^{a} \left[\frac{\partial g(x,h(x, a_0, a^\prime),E_{a^\prime})}{\partial h} +d(x,h(x, a_0, a^\prime),E_{a^\prime})\right] {\rm d}a^\prime \right).
\end{equation}
Eq. \ref{eq:boundN} states that the density $n$ at a specific time is a product of density at the origin adjusted for changes through development and mortality. Density decreases through time because of mortality, as in a standard typical survival equation, but also changes due to growth. If growth is slowing with size, (i.e. $\partial g / \partial h  < 0$), then density increases as the characteristics compress, or density increases if $\partial g / \partial h  > 0$.

If $\left[h_0, h_+ \right)$ represents the entire state-space attainable by any individual, the EBT algorithm proceeds by sub-dividing this space into a series of cohorts with boundaries $h_0 < h_1 < \ldots < h_k$. These cohorts are then transported along the characteristics of Eq. $\ref{eq:PDE}$. The location of cohort boundaries is controlled indirectly, via the schedule of time sat which new cohorts are initialised into the population. We then track the demography of a hypothetical individual located at each  cohort boundary. 

The equations below outline how to solve for the size, survival, seed output and abundance of individuals located on the cohort boundaries. Each of these problems is formulated as an Initial-Value ODE Problem (IVP), which can then be solved using an ODE stepper.

## Size

The size of individual located on the boundary is obtained via Eq.  \ref{eq:size}, which is solved via the IVP:
$$\frac{dy}{dt} = g(x,y,t),$$
$$ y(0) = h_0.$$

## Survival

The probability of an individual located on the boundary surviving from  $a_0 \rightarrow a$  is obtained via Eq. \ref{eq:survivalIndividual}, which is solved via the IVP:
$$\frac{dy}{dt} = d(x,h_i(a^\prime), E_{a^\prime}),$$
$$ y(0) = - \ln\left(\pi_1 (x^\prime,h_0, E_{a_0})\right) .$$

Survival is then
$$ S_{\rm I} (x, a_0, a) = \exp\left(- y(a) \right).$$


## Seed production

The lifetime seed production of individuals located on the boundary is obtained via Eq. \ref{eq:tildeR}, which is solved via the IVP:
$$\frac{dy}{dt} = \pi_0 \,f(x, m_i(a^\prime), E_{a^\prime}) \, S_{\rm I} (x, a_0, a^\prime) \, S_{\rm P} (a_0,a^\prime),$$
$$ y(0) = 0,$$
where $S_{\rm I}$ is individual survival (defined above) and
$S_{\rm P}$ is calculated as in Eq. $\ref{eq:survivalPatch}$.


## Density of individuals

The density of individuals located on the boundary is obtained via Eq. \ref{eq:boundN}, which is solved via the IVP:
$$\frac{dy}{dt} = \frac{\partial g(x,h_i(a^\prime), E_{a^\prime})}{\partial h} +d(x,h_i(a^\prime),E_{a^\prime}),$$
$$ y(0) = -\ln\left(n(x,h_0 ,a_0) \, \pi_1 (x^\prime,h_0, E_{a_0}) \right).$$

Density is then given by
$$n(x,h_0 ,a_0) =\exp(-y(a)).$$

# Controlling error in the TREE model

In this section we outline how to control the error of the solution estimated to the system described in the previous two sections. Numerical solutions are required to solve a variety of problems. To estimate the amount of light at a given height in a patch requires that we integrate over the size-distribution within that patch. Calculating assimilation for a plant in turn requires that we integrate photosynthesis over this light profile. Approximating patch dynamics requires that identify a vector of times where new cohorts are introduced, then step the equations for each cohort forward in time to estimate their size, survival and fecundity at different time points.  Root solving is required to solve the initial height of a plant given it's seed mass, and the equilibrium seed rains across the metapopulation. As with all numerical techniques, the solutions are accurate only up to some specified level. These levels are controlled via parameters found within the `control` object. Below we provide a brief overview of the different numerical routines being applied and how error tolerance can be increased or decreased, as desired. For examples illustrating how the error controls are adjusted, see vignette XXXXX.

## Initial height of plants

When a seed germinates it produces a seedling of a given height. The height of these seedlings is assumed to vary with the seed mass; however, because there is no analytical solution relating height to seed mass -- at least using the default physiological model -- we must solve this height numerically. The calculation is performed by the function `height_seed` within the strategy description, using the Boost library's 1-D `bisect` routine [@Schaling-2014; @Eddelbuettel-2015]. The accuracy of the solution is controlled by the parameter `plant_seed_tol`.

## Approximation of size-density distribution via the EBT 

Errors in the EBT approximation to $n$ can arise from two sources: i) poor spacing of cohorts in the size dimension, and ii) when stepping cohorts through time.

The first factor controlling the accuracy with which cohorts are stepped through time is the accuracy of the ODE stepper being used. TREE uses the embedded Runge-Kutta Cash-Karp 4-5 algorithm [@Cash-1990], with code ported directivity from the [GNU Scientific Library](http://www.gnu.org/software/gsl/) [@Galassi-2009]. Accuracy of the solver is controlled by two control parameters for relative and absolute accuracy: `ode_tol_rel` and `ode_tol_abs`.

A second factor controlling the accuracy with which cohorts are stepped through time is the accuracy of the derivative calculation in eq. \ref{eq:boundN}, calculated via standard finite differencing [@Abramowitz-2012]. When the parameter `cohort_gradient_richardson` is TRUE a Richardson Extrapolation [@Stoer-2002] is used to refine the estimate, up to depth `cohort_gradient_richardson`.  The overall accuracy of the derivative is controlled by `cohort_gradient_eps`.

The primary factor controlling the spacing of cohorts is the schedule of cohort introduction times  -- a vector of times indicating times at which a new cohort is initialised. Because the system is deterministic, the schedule of cohort introduction times determines the spacing of cohorts through the entire development of the patch.  Poor cohort spacing introduces error because various emergent properties -- such as total leaf area, biomass or seed output -- are estimated by integrating over the size distribution. The accuracy of these integrations declines directly with the spacing of cohorts. Thus we aim to build an appropriately refined schedule, which allows required integrations to be performed within the desired accuracy at every time point. At the same time, we want as few cohorts as possible to maintain for computational efficiency.

A suitable schedule is found using the function `build_schedule`. As there was no prior existing method for estimating a suitable schedule of introduction times, we implemented the following new technique. The `build_schedule` function takes an initial vector of introduction times, then looks at each cohort and asks whether removing that cohort would cause the error introduced when integrating two specified functions over the size distribution to jump over the allowable error threshold `schedule_eps`. This calculation is repeated for every time step in the development of the patch. A new cohort is introduced immediately prior to any cohort failing the above tests (See fig XXX). The dynamics of the patch are then simulated again and the process repeated, until all integrations at all time points have error below the tolerable limit `schedule_eps`. Decreasing `schedule_eps` demands higher accuracy from the solver and thus increases the number of cohorts being introduced. Note we are asking whether removing an existing cohort would cause error to jump above the threshold limit, and using this to decide whether an extra cohort -- in addition to the one used in the test -- should be introduced (See fig XXX). Thus the actual error is likely to be lower than but at most equal to `schedule_eps`.

To determine the error associated with a specified cohort, we integrate two different functions over the size distribution, within the function `run_ebt_error`. We then asses how much removing the focal cohort would increase the error in the two integrations. The first integration, performed by the function `area_leaf_error`, asks how much removal of the focal cohort would increase error in the estimate of total leaf area in the patch. The second integration, performed by the function `seed_rain_error`, asks how much removal of the focal cohort would increase error in the total seed produced from the patch. The relative error in each integration is then calculated using the `local_error_integration` function. 

TODO: Figure XXXX illustrating progressive refinement of schedule

TODO: Figure XXXX illustrating `local_error_integration` routine

## Calculation of light environment and influence on assimilation

To progress the system of ODE's requires that we calculate the amount of shading on each of the cohort boundaries, from all other plants in the patch. 

Calculating canopy openness at a given height $E(z,a)$ requires that we integrate over the size distribution (eq. \ref{eq:light}). This integration is performed using the trapezium rule, within the function `area_leaf_above` in `species.h`. The main factor controlling the accuracy of the integration is the spacing of cohorts. As outlined in the section above, cohort introduction times control the spacing of cohorts and are refined so that the integration of leaf area is within some specified limit. Thus the simple trapezium integration within the `area_leaf_above` function *is* refined adaptively via the  `build_schedule` function.

The cost of calculating $E(z,a)$ increases linearly with the number of cohorts in the system.  But the same calculation must then be repeated many times (multiple heights for every cohort), so the overall CPU cost of stepping the system increases  as to $O(k^2)$, where $k$ is the total number of cohorts across all species. This disproportionate increase in CPU cost with the number of cohorts is highly undesirable.

We reduced the computational cost of the continuous competitive feedback from $O(k^2) \rightarrow O(k)$, by approximating the $E(z,a)$ with a spline. Biologically, eq. \ref{eq:light} is a simple monotonically increasing function of size (Fix XXX). This function is easily approximated using a piece-wise continuous spline fitted to a limited number of points. Once fitted, the spline can be used to estimate any additional evaluations of competitive effect, and since spline evaluations are cheaper than integrating over the size distribution, this approach reduces the overall cost of stepping the resident population. A new spline is then constructed at the next time step.

The accuracy of the spline interpolation depends on the number of points used in its construction and their location along the size axis. We select the location and number of points via an adaptive algorithm.  Starting with an initial set of 33 points, we assess how much each point contributes to the accuracy of the spline fit at the location of each cohort first via exact calculation, and second by linearly interpolating from adjacent cohorts. The absolute difference in these values is compared to the control parameter `environment_light_tol`. If the error value is greater than this value, the interval is bisected and process repeated.  For full details see `adaptive_interpolator.h`.

## Integrating over light environment

Plants have leaf area distributed over a range of heights; estimating assimilation of a plant at each time step thus requires us to integrate leaf-level rates over the plant. The integration is performed using Gaussian quadrature, using the QUAD PACK routines [@Piessens-1983], adapted from the [GNU Scientific Library](http://www.gnu.org/software/gsl/)[@Galassi-2009] (see `qag.h` for further details). If the control parameter `plant_assimilation_adaptive` is TRUE, the integration is performed using adaptive refinement with accuracy controlled by the  parameter `plant_assimilation_tol`.

## Solving demographic seed rain

For a single species, solving for $y_x$ is a straightforward one-dimensional root-finding problem, which can be solved with accuracy `equilibrium_eps` using XXXX. 

Expand here XXX.

# Appendices

## Derivation of PDE describing age-structured dynamics

Consider patches of habitat which are subject to some intermittent disturbance and where the age of a patch is corresponds to the time since the last disturbance. Let $p(a,t)$ be the frequency-density of patches age $a$ at time $t$ and let $\gamma(a)$ be the age-dependent probability that a patch of age $a$ is transformed into a patch of age $0$ through disturbance. Then according to the Von Foerster equation for age-structured population dynamics [@Vonfoerster-1959], the dynamics of $p(a,t)$ are given by
$$ \frac{\partial }{\partial t} p(a,t)=-\frac{\partial }{\partial a} p(a,t)-\gamma(a,t)p(a,t),$$
with boundary condition
$$ p(0,t)=\int^{\infty}_{0}\gamma(a,t)p(a,t)\,{\rm d}a.$$

The frequency of patches with $a < x$ is given by $\int_{0}^{x}p(a,t) \, {\rm d}a$, with $\int_{0}^{\infty} p(a,t) \, {\rm d}a =1$. If $\frac{\partial}{\partial t}\gamma(a,t)=0$, then $p(a)$ will approach an equilibrium solution given by
$$p(a) = p(0) \Pi(a),$$
where
$$\Pi(a) = \exp \left( \int_{0}^{a}-\gamma(\tau)\,{\rm d}\tau\right)$$
is the probability that a local population will remain undisturbed for at least $a$ years (patch survival function),
and
$$p(0) = \frac1{ \int_{0}^{\infty}\Pi(a) \,{\rm d}a}$$
is the frequency-density of patches age 0. The rate of disturbance for patches age $a$ is given by $\frac{\partial (1-\Pi(a))}{\partial a} = \frac{-\partial \Pi(a)}{\partial a}$,
 while the expected lifetime for patches is $\int_0^\infty - a \frac{\partial}{\partial a} \Pi(a) \, {\rm d} a = \int_0^\infty \Pi(a) \, {\rm d} a = \frac1{p(0)}$ (2$^{nd}$ step made using integration by parts).

An equilibrium patch age distribution may be achieved under a variety of conditions, for example if $\gamma(a,t)$ depends on patch age but the this probability is constant over time. The probability of disturbance may also depend on features of the vegetation (rather than age *per se*), in which case  an equilibrium is still possible, provided the vegetation is also assumed to be at equilibrium.

### Exponential distribution

If the probability of patch disturbance is constant with respect to patch age ($=\lambda$), then rates at which patches age $a$ are disturbed follow an exponential distribution: $-\partial \Pi(a)/ \partial a = \lambda e^{-\lambda a}$. The patch age distribution is then given by:
$$ \Pi(a) = \exp\left(-\lambda a\right), p(0) = \lambda.$$

### Weibull distribution

If the probability of patch disturbance changes as a function of time, with $\gamma(a) = \lambda \psi  a^{\psi-1}$, then rates at which patches age $a$ are disturbed follow a Weibull distribution: $-\partial \Pi(a)/ \partial a = \lambda \psi a^{\psi -1}e^{-\lambda a^\psi}$. Values of $\psi>1$ imply probability of disturbance increases with patch age; $\psi<1$ implies probability of disturbance decreases with age. When $\psi=1$ we obtain the exponential distribution, a special case of the Weibull. The Weibull distribution results in following for the patch age distribution:
$$\Pi(a) = e^{-\lambda a^\psi}, p(0) =  \frac{\psi \lambda^{\frac1{\psi}}}{\Gamma\left(\frac1{\psi}\right)},$$
where $\Gamma(x)$ is the gamma function $\left(\Gamma(x) = \int_{0}^{\infty}e^{-t}t^{x-1}\, dt\right)$. We can also specify the distribution by its mean return time $\bar{a}  = \frac1{p(0)}$.  Then, calculate relevant value for $\lambda =  \left(\frac{\Gamma\left(\frac1{\psi}\right)}{\psi \bar{a}}\right)^{\psi}$.

### Variable distributions

The probability of patch disturbance might also be vary with properties of the vegetation. In this case, we cannot prescribe a known distribution to $p(a)$, it must be solved numerically. Patch survival can be calculated numerically as
$$\Pi(a) = \exp \left( \int_{0}^{a}-\gamma(\tau)\,{\rm d}\tau\right).$$
For calculations of fitness, we want to integrate over some fraction $q$ of the patch age distribution (i.e. ignoring the long tail of the distributions). Thus we want to find the point  $x$ which satisfies $\int_{0}^{x} p(a)\,{\rm d}a =q$.Locating $x$ requires knowledge of $p(0)$, which in turn requires us to approximate the tail of the integral  $\int_{0}^{\infty} \Pi(a)\,{\rm d}a$. For $a > x$, let $\Pi(a)$ be approximated by
$$\Pi(a) \approx \Pi(x) \exp\left( - (x-a) \gamma(x)\right).$$ Then
$$p(0)^{-1} =\int_{0}^{\infty} \Pi(a)\,{\rm d}a \approx \int_{0}^{x} \Pi(a)\,{\rm d}a + \int_{x}^{\infty } \Pi(a)\,{\rm d}a$$
$$ = \int_{0}^{x} \Pi(a)\,{\rm d}a + \frac{\Pi(x)}{\gamma(x)}. $$
Substituting into $\int_{0}^{x} p(a)\,{\rm d}a =q$, we obtain
$$q=  p(0) \int_{0}^{x} \Pi(a) \, {\rm d}a = \frac{\int_{0}^{x} \Pi(a) \, {\rm d}a}{\int_{0}^{x} \Pi(a)\,{\rm d}a + \frac{\Pi(x)}{\gamma(x)}}$$
$$\Rightarrow  \frac{\Pi(x)}{\gamma(x)} = \frac{1-q}{q} \int_{0}^{x} \Pi(a) \, {\rm d}a.$$
Thus by monitoring $\Pi(x), \gamma(x),  \int_{0}^{x} \Pi(a) \, {\rm d}a$ we can evaluate when a sufficient range of the patch age distribution has been incorporated.


## Derivation of PDE describing size-structured dynamics

To model the population we use a PDE describing the dynamics for a thin slice $\Delta m$. Assuming that all rates are constant within the interval $\Delta h$, the total number of individuals within the interval spanned by $[h-0.5\Delta h,h+0.5\Delta h)$ is $n(h,a)\Delta h$ . The flux of individuals in and out of the size class can be expressed as
\begin{equation}\begin{array}{ll} J(h,a)=&g(h-0.5 \Delta h,a) \; n(h-0.5 \Delta h,a)-g(h+0.5 \Delta h,a) \; n(h+0.5 \Delta h,a) \\ &-d (h,a) \; n(h,a)\Delta h\\ \end{array}.
\end{equation}
The first two terms describe the flux in and out of the size class through growth; the last term describes lossed due through mortality. The change in number of individuals within the interval across a time step \textit{$\Delta $t} is thus:
\begin{equation}
  \begin{array}{ll} n(h,a+\Delta a)\Delta h-n(h,a)\Delta h= &g(h-0.5 \Delta h,a) \; n(h-0.5 \Delta h,a)\Delta a \\ &-g(h+0.5 \Delta h,a) \; n(h+0.5 \Delta h,a)\Delta a\\&-d (h,a) \; n(h,a)\Delta h\Delta a.
  \end{array}
\end{equation}
Rearranging,
\begin{equation}
  \begin{array}{ll}
  \frac{n(h,a+\Delta a)-n(h,a)}{\Delta a} = &-d (h,a) \; n(h,a) \\
  &-\frac{g(h+0.5 \Delta h,a) \; n(h+0.5 \Delta h,a)-g(h-0.5 \Delta h,a) \; n(h-0.5 \Delta h,a)}{\Delta h}.
  \end{array}
\end{equation}
The LHS is corresponds to the derivative of $n$ as $\Delta a\to 0$. For thin slices, $\Delta h \sim 0$, we obtain
\begin{equation} \label{eq:PDE-app}
  \frac{\partial }{\partial t} n(h,a)=-d (h,a) \; n(h,a)-\frac{\partial }{\partial h} (g(h,a) \; n(h,a)).
\end{equation}

To complete the model, the PDE must be supplemented with boundary conditions that specify the density at the lower end of $n(h_{0},a)$ for all $t$ as well as the the initial distribution when $t=0$, $n(h,0)$.  The former is derived by integrating the PDE with respect to $h$ over the interval $(h_{0},h_{\infty })$, yielding

\begin{equation}\frac{\partial }{\partial t} \int _{h_{0} }^{h_{\infty } }n(h,a) \partial h=g(h_{0} ,a) \; n(h_{0} ,a)-g(h_{\infty } ,a) \; n(h_{\infty } ,a)-\int _{h_{0} }^{h_{\infty } }d (h,a) \; n(h,a) \partial h.
\end{equation}

The LHS of this relationship is evidently the rate of change of total numbers of individual in the population, while the right-hand-term is the total population death rate. Further, $n(h_{\infty } ,a)=0$. Thus to balance total births and deaths, $g(h_{0} ,a) \; n(h_{0} ,a)$ must equal the birth rate $B(x, a)$. Thus the boundary condition is given by
\begin{equation}g(h_{0} ,a) \; n(h_{0} ,a)=B(x, a).
\end{equation}


## Converting density from one size unit to another

Population density is explicitly modelled in relation to a given size unit (Eq. $\ref{eq:PDE}$). But what if we want to express density in relation to another size unit? A relation between the two can be derived by noting that the total number of individuals within a given size range must be equal. So let's say density is expressed in units of size $m$, but we want density in units of size $h$. First we require a one-to-one function which h for a given $m$: $h = \hat{h}(m)$. Then the following must hold
\begin{equation} \label{eq:n_conversion} \int_{m_1}^{m_2} n(x,m,a) \; \textrm{d}m =  \int_{\hat{h}(m_1)}^{\hat{h}(m_2)} n^\prime(x,m,a) \; \textrm{d}h
\end{equation}

For very small size intervals, this equation is equivalent to
\begin{equation} \left(m_2- m_1 \right) \; n(x,m_1,a) = \left( \hat{h}(m_2) - \hat{h}(m_1)\right) \; n^\prime(x, \hat{h}(m_1),a).
\end{equation}

Rearranging gives
\begin{equation}  n^\prime(x, \hat{h}(m_1),a) = n(x, m_1,a) \; \frac{m_2- m_1}{\hat{h}(m_2) - \hat{h}(m_1)}
\end{equation}

Noting that the second term on the RHS is simply the definition of $\frac{\delta m}{\delta h}$ evaluated at $m_1$, we have
\begin{equation} \label{eq:n_conversion2} n^\prime(x, h, a) = n(x, m,a) \; \frac{\delta m}{\delta h}.
\end{equation}


# References