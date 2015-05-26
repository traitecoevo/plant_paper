---
title: "tree: A package for modelling plant TRait Ecology & Evolution: _patch level dynamics_"
csl: ../downloads/style.csl
bibliography: ../refs.bib
---

# Introduction

This vignette outlines methods used to model demography in the TREE package, following @Falster-2011; @Falster-2015; @Moorcroft-2001; @Kohyama-1993; @Deroos-1997. We outline first the system dynamics, and then describe the numerical techniques used to solve the equations in XXX.


# Individual plants

Consider the dynamics of an individual plant. Throughout we will refer to a plant as having traits $x$ and size $h$,  notionally it's  height. The plant lives in an `environment` $E$, which describes by the availability of resources to the plant. Ultimately the structure of this environment will depend on the composition of the forest at that time point. However, to simplify notation throughout the document we will refer to the environment as simply depending on the age $a$ of the particular patch where it grows, i.e. $E(a)$. This allows for $E$ to change with time. Moreover, it is important to note that $E$ represents a distribution of resources, specifically light-levels, with respect to to plant height.  

Now let the functions $g(x,h,a)$, $d(x,h,a)$ and $f(x,h,a)$ denote the growth, death, and fecundity rates of the plant. Then,
\begin{equation} \label{eq:size}
  h(x, a_0, a) = h_0 + \int_{a_0}^{a} g(x, h(x, a_0, a^\prime),a^\prime) \, \rm{d}a^\prime
\end{equation}
is the trajectory of plant height,
\begin{equation} \label{eq:survivalIndividual}
  S_{\rm I} (x, a_0, a) = \pi_1 (x,h_0, a_0) \, \exp\left(- \int_{a_0}^{a} d(x,m_i(x, a_0 ,a^\prime), a^\prime) \, {\rm d} a^\prime \right)
\end{equation}
is the probability of survival $S_{\rm I}$ within the patch, and 
\begin{equation} \label{eq:tildeR1}
  \tilde{R}(x, a_0, a) =\int_{a_0}^{a} f(x, h(x, a_0, a^\prime), a^\prime) \, S_{\rm I} (x, a_0, a^\prime) {\rm d} a^\prime.
\end{equation}
is the cumulative seed output for the plant from its birth at age $a=a_0$ up to age $a$, where the term $\pi_1 (x,h_0, a_0)$ is survival through germination.

The notational complexity required for a general, non-linear solutions potentially obscure an otherwise simple point: Eqs. \ref{eq:size} - \ref{eq:tildeR1} are simply standard integrals of the growth, mortality and fecundity functions over time.


# Patches of competing plants / Size-structured populations

Let us now consider a patch of competing plants. At any age $a$, the patch can be described the density-distribution $n(x,h,a)$ of plants with traits $x$ and height $h$. In a finite-sized patch, $n$ will be a collection of delta-peaks, whereas as in a very (infinitely) large patch $n$ will be a continuous distribution. In either case, the demographic behaviour of the plants already within the patch is given by Eqs. \ref{eq:size} - \ref{eq:tildeR}. However, modelling patch dynamics is complicated by two factors: (i) plants interact via their influence on the availability of resources, so the variable $E$ is constantly changing; and (ii) new individuals may be germinating and entering the population.  

In the current version of TREE plants only interact by shading one another. Following well-established principles, we let the the amount of canopy openness $E(z,a)$ at height $z$ in a patch of age $a$ declines exponentially with the amount of leaf area above, i.e. 
\begin{equation} \label{eq:light}
  E(z,a) = \exp \left(-c_{ext}  \sum_{i=1}^{N} \int_{0}^{\infty} \phi(h) \, L(z, h) \, n(x_i,h,a) \, dm \right),
\end{equation}
where $\phi(h)$ is total leaf area and $L(z, h(m))$ is fraction of this leaf area held above height $z$ for plants size $h$, and $c_{ext}$ is the light extinction coefficient.

Assuming patches are large, the dynamics of the plants within the patch can be modelled deterministically via the following Partial Differential Equation (PDE) [@Kohyama-1993; @Deroos-1997; @Moorcroft-2001]:
\begin{equation} \label{eq:PDE} 
  \frac{\partial }{\partial a} n(x,h,a)= -d(x,h, a) \; n(x,h,a)-\frac{\partial }{\partial m} \left[g(x,h,a) \; n(x,h,a)\right].
\end{equation}
(See appendix XXX.)

Eq. $\ref{eq:PDE}$ has two boundary conditions. The first,
\begin{equation}  \label{eq:BC1} \frac{n(x,h_0,a)g(x,h_0 , a)}{\pi_1(x,h_0 ,a)} = y_x
\end{equation}
links the flux of individuals across the lower bound $(h_0)$ of the size distribution to the rate at which seeds arrive in the patch, $y_x$.

The second boundary condition of Eq. $\ref{eq:PDE}$ gives the size distribution for patches when $a=0$. Throughout we consider only situations where we start with an empty patch, i.e. 
\begin{equation} \label{eq:BC2} n\left(x,h,0\right) =0,
\end{equation}
although non--zero distributions could be specified [e.g @Moorcroft-2001].

# Age-structured populations 

Let us now consider the abundance of patches age $a$ in the landscape. Let $a$ be time since last disturbance, $p(a)$  be the frequency-density of patches age $a$, and $\gamma(a)$ be the age-dependent probability that a patch of age $a$ is transformed into a patch of age 0 by a disturbance event. Here we focus on the situation where the age structure has reached an equilibrium state, which causes the PDE to reduce to an ordinary differential equation (ODE) with respect to patch age. (See appendix XXX for derivation and non-equilibrium case and derivation). The dynamics of $p$ are given by [@Vonfoerster-1959; @Mckendrick-1926]:

\begin{equation} \label{eq:agepde}
\frac{{\rm d}}{{\rm d} a} p(a)  = -\gamma(a) \, p(a) ,
\end{equation}
with boundary condition
\begin{equation}  p(0)  = \int_0^\infty \gamma(a) \, p(a) \; {\rm d} a.
\end{equation}

The probability of a patch remains undisturbed from $a_0$ to $a$ is then
\begin{equation} \label{eq:survivalPatch}
  S_{\rm P} (a_0,a) = \exp\left(-\int_{a_0}^{a} \gamma(a^\prime) \, {\rm d} a^\prime \right).
\end{equation}

The above equations lead to a solution for the equilibrium distribution of patch-ages
\begin{equation} p(a) = p(0) S_{\rm P} (0,a),
\end{equation}
where
\begin{equation}
  p(0) = \frac1{\int_0^\infty S_{\rm P} (0,a) {\rm d}a},
\end{equation}
is the average lifespan of a patch and the frequency-density of patches age $0$.

# Trait-, size- and patch-structured metapopulations

Consider a large area of habitat where:

- Disturbances (such as fires, storms, landslides, floods, or disease outbreaks) strike patches of the habitat on a stochastic basis, killing individuals within affected patches;
- Individuals compete for resources within patches, but the spatial scale of competitive interaction means interactions among individuals in adjacent patches are negligible;
- There is high connectivity via dispersal between all patches in the habitat, allowing empty patches to be quickly re-colonised;

Such a system can be modelled as a metapopulation (sometimes called metacommunity for multiple species). The dynamics of this metapopulation are described by PDES in Eqs. \ref{eq:agepde} and \ref{eq:PDE}.

The equilibrium seed rain of each species in the metapopulation is given by rate at which arriving seeds are produced in the metapopulation,
\begin{equation}  \label{eq:seed_rain} 
  y_x = \int_0^{\infty} p(a)  \int_0^{\infty}  \pi_0 f(x,h,a) \; n(x,h,a)\,{\rm d} m \, {\rm d} a,
\end{equation}
where $\pi_0$ is the average survival of seeds during dispersal.

A convenient feature of Eqs. $\ref{eq:PDE}$ - $\ref{eq:BC2}$ is that the dynamics of a single patch scale up to give the dynamics of the entire metapopulation. Note that the rate offspring arrive from the disperser pool, $y_x$, is constant for a metapopulation at equilibrium. Combined with the assumption that all patches have the same initial (empty) size distribution, this feature ensures that all patches show the same temporal behaviour, the only difference between them being the ages at which they are disturbed.

To model the temporal dynamics of an archetypal patch, we need only a value for $y_x$. The numerical challenge is therefore to find the solution for $y_x$ in the simultaneous Eqs. \ref{eq:seed_rain} and \ref{eq:BC1}. at the highest level, solving for $y_x$ is a straightforward one-dimensional root-finding problem, yet calculating Eq. \ref{eq:seed_rain} requires  information about $n(x,h,a)$, which in turn requires a solution for Eq. $\ref{eq:PDE}$.

# Emergent properties of metapopulation

Summary statistics of the metapopulation are obtained by integrating over the density distribution, weighting by patch abundance $p(a)$. Firstly, the total number of individuals in the metapopulation is given by
\begin{equation}
  \hat{n}(x) = \int_{0}^{\infty} \int_{0}^{\infty}p(a) \; n(x,h,a) \, {\rm d}a \, {\rm d}h,
\end{equation}
and the average density of plants size $h$ by
\begin{equation}
  \bar{n}(x,h) = \int_{0}^{\infty}p(a) \; n(x,h,a) \, {\rm d}a.
\end{equation}

Average values for other quantities can also be calculated. Let $\phi(x, h, a)$ be a demographic quantity of interest, such growth rate, mortality rate, light environment, or size. The average value of $\phi$ across the metapopulation is
\begin{equation}
  \hat{\phi}(x) = \frac1{\hat{n}(x) }\int_{0}^{\infty} \int_{0}^{\infty} p(a) \; n(x,h,a) \phi(x,h,a) \, {\rm d}a \, {\rm d}h,
\end{equation}
while the average  value of $\phi$ for plants size $h$ is
\begin{equation}\bar{\phi}(x,h) = \frac1{\bar{n}(x,h) }\int_{0}^{\infty}p(a)  n(x,h,a) \phi(x,h,a)\, {\rm d}a.
\end{equation}

 When calculating average mortality rate, a choice must be made as to whether mortality due patch disturbance is included. Non-disturbance mortality is obtained by setting $\phi(x,h, a) = d(x,h,a)$, while total mortality due to growth processes and disturbance is obtained by setting $\phi(x,h, a) = d(x,h,a)+ \gamma(a)\Phi(x).$)


# Invasion fitness

Let us now consider how we can estimate the fitness of a rare individual with traits $x^\prime$ growing in the environment of a resident community with traits $x$. We will focus on the phenotypic components of fitness -- i.e. the consequences of a given set of traits for growth, fecundity and mortality -- only, taking into account the non-linear effects of competition on individual success, but ignoring the underlying genetic basis for the trait determination. We also adhere to the standard conventions in such analyses in assuming that the mutant is sufficiently rare to have a negligible effect on the environment where it is growing.

Invasion fitness is most correctly defined as the long-term per capita growth rate of a rare mutant population growing in the environment determined by the resident strategy [@Metz-1992]. Calculating per-capita growth rates, however, can be particularly challenging in a structured metapopulation model [@Gyllenberg-2001; @Metz-2001]. As an alternative measure of fitness, we can use the basic reproduction ratio, which gives the expected number of new dispersers arising from a single dispersal event. Evolutionary inferences made using the basic reproduction ratio will be similar to those made using per-capita growth rates for metapopulations at demographic equilibrium [@Gyllenberg-2001; @Metz-2001].

Let $R\left(x^\prime,x\right)$ be the basic reproduction ratio of individuals with traits $x^\prime$ growing in the competitive environment of the resident traits $x$. Recalling that patches of age $a$ have density $p(a)$ in the landscape, it follows that any seed of $x^\prime$ has probability $p(a)$ of landing in a patch age $a$. The basic reproduction ratio for individuals with traits $x^\prime$ is then:
\begin{equation} \label{eq:InvFit}
  R\left(x^\prime,x\right)=\int _0^{\infty }p\left(a\right)\tilde{R}\left(x^\prime,a, \infty \right)\; {\rm d}a ,
\end{equation}
where $\tilde{R}\left(x^\prime,a_0,a \right)$ is the expected number of dispersing offspring produced by a single disperser arriving in a patch of age $a_0$ up until age $a$ [@Gyllenberg-2001; @Metz-2001]. $\tilde{R}\left(x^\prime,a,\infty\right)$ is calculated by integrating an individual's fecundity over the expected lifetime the patch, taking into account competitive shading from residents with traits $x$, the individual's probability of surviving, and its traits via the equation:

\begin{equation} \label{eq:tildeR}
  \tilde{R}(x^\prime, a_0, a) =\int_{a_0}^{a}  \pi_0f(x^\prime, h(x^\prime, a_0, a^\prime), a^\prime) \, S_{\rm I} (x^\prime, a_0, a^\prime) \, S_{\rm P} (a_0,a^\prime)  {\rm d} a^\prime.
\end{equation}


# Approximating system dynamics using the escalator boxcar train (EBT)

Our approach for modelling solving size-structured population dynamics is based on the Escalator Boxcar Train technique  (EBT) [@Deroos-1997; @Deroos-1992; @Deroos-1988]. The EBT solves the PDE describing development of $n(x,h,a)$ (Eq. $\ref{eq:PDE}$) by approximating the density function with a collection of cohorts spanning the size spectrum. Following a disturbance, a series of cohorts are introduced into each patch. These cohorts are then transported along the characteristics of Eq. $\ref{eq:PDE}$ according to the individual-level growth function. (Characteristics are curves along which Eq. $\ref{eq:PDE}$  becomes an ordinary differential equation (ODE); biologically, these are the growth trajectories of individuals, provided they do not die).

The original EBT [@Deroos-1997; @Deroos-1992; @Deroos-1988] proceeds by approximating the first and second moments of the density distribution $n \left( x,h,a \right)$ within sub-domains $\Omega_i$, represented by $\lambda_i$ and $\mu_i$, these being the total number and mean size of individuals within $\Omega_i$ respectively. Under this assumption, the rates of change $\frac{\rm d} {{\rm d}a} \lambda_i$ and $\frac{\rm d} {{\rm d}a} \mu_i$ can be approximated given by two ODEs, which can in turn be approximated by first-order closed-form solutions. Eq. $\ref{eq:PDE}$ is thereby reduced to a family of ODEs, which can be stepped using an appropriate ODE solver with an adaptive step size. The size distribution $n(x,h,a)$ is then approximated by a series of point masses with position and amplitude given by $\lambda_i$ and $\mu_i$.

In the current implementation we use a different approach for approximating the size distribution $n(x,h,a)$. Instead of tracking the first and second moments of the size-distribution within cohorts, we track a point mass estimate of $n$ along the characteristics corresponding to cohort boundary. By integrating along characteristics, the PDE can be solved to yield the a general solution for the density of individuals with time of birth $a_{0}$ [@Deroos-1997]:
\begin{equation}\label{eq:boundN}
 \begin{array}{ll}
  n(x, m, a) & =n(x,h_0 ,a_0) \times \\
  & \exp \left(-\int _{a_0}^{a} \left[\frac{\partial g(x,h(x, a_0, a^\prime),a^\prime)}{\partial h} +d(x,h(x, a_0, a^\prime),a^\prime)\right] {\rm d}a^\prime \right),
  \end{array}
\end{equation}
Eq. \ref{eq:boundN} states that the density $n$ at a specific time is a product of density at the origin adjusted for changes through development and mortality. Density decreases through time because of mortality, as in a standard typical survival equation. Here, however, growth also contributes to changes in density. If growth is slowing with size, (i.e. $\frac{\partial g(h,E)}{\partial h}  <0$), then density increases because the characteristics converge on one another. In cases where the environment is constant and time-independent, it may be possible to further simplify Eq. \ref{eq:n1} to give an analytical solution  for $n$ (see page 153 of @Deroos-1997 for proof).  In most cases involving interesting ecological feedback, however, Eq. \ref{eq:boundN} must be solved numerically.

TODO: XXXXX Rework text below.

Let $\Omega = \left[h_0, h_+ \right)$ represent the entire state-space attainable by any individual and let the interior of $\Omega$ be subdivided into $k$ sub-domains  $$\Omega_i(a) = \left[h_{i=1}(a),h_i(a) \right) $$ , with $i=1,\dots, k$ and $h_0 < h_1<	\ldots<h_k = h_+$. These sub-domains will then be transported along the characteristics of Eq. $\ref{eq:PDE}$.

# Size

From equation  $\ref{eq:size}$, the boundary develops as
\begin{equation} \label{eq:boundSize}
  h_i(x, a_0, a) = h_0 + \int_{a_0}^{a} g(x,h_i(x, a_0, a^\prime),a^\prime) \, \rm{d}a^\prime.
\end{equation}

*Numerical technique:* Equation $\ref{eq:boundSize}$ can be expressed as an initial-value ODE problem (IVP) and solved using an ODE stepper:
$$\frac{dy}{dt} = g(x,y,t),$$
$$ y(0) = h_0.$$

# Survival
From equation  $\ref{eq:survivalIndividual}$, the survival of the individuals at the boundary individuals is

\begin{equation} \label{eq:boundSurv} S_{\rm I} (x, a_0, a) =  \pi_1 (x^\prime,h_0, a_0)  \exp\left(- \int_{a_0}^{a} d(x,h_i(x, a_0 ,a^\prime), a^\prime) \, {\rm d} a^\prime \right).
\end{equation}

*Numerical technique:* To solve equations $\ref{eq:boundSurv}$ we solve the IVP problem:
$$\frac{dy}{dt} = d(x,h_i(a^\prime), a^\prime ),$$
$$ y(0) = - \ln\left(\pi_1 (x^\prime,h_0, a_0)\right) .$$

Survival is then
$$ S_{\rm I} (x, a_0, a) = \exp\left(- y(a) \right).$$

# Density of individuals

The density of individuals at the boundary can be solved by integrating along characteristics (see Appendix XXX for details) to give:

\begin{equation} \label{eq:boundN}
  \begin{array}{ll}
  n(x, m, a) & =n(x,h_0 ,a_0) \times \\
  & \exp \left(-\int _{a_0}^{a} \left[\frac{\partial g(x,h(x, a_0, a^\prime),a^\prime)}{\partial m} +d(x,h(x, a_0, a^\prime),a^\prime)\right] {\rm d}a^\prime \right),
  \end{array}
\end{equation}

where
\begin{equation} \label{eq:boundN2}
  n(x,h_0,a_0)  = \left\{
  \begin{array}{ll}   \frac{y_x  \pi_1 (x^\prime,h_0, a_0) }{ g(x,h_0, a_0) }  & \textrm{if } g(x,h_0, a_0) > 0 \\
  0 & \textrm{otherwise.}
  \end{array} \right.
\end{equation}

*Numerical technique:* To solve Eq. $\ref{eq:boundN}$ we need to solve the IVP:
$$\frac{dy}{dt} = \frac{\partial g(x,h_i(a^\prime), }{\partial m} +d(x,h_i(a^\prime),a^\prime),$$
$$ y(0) = -\ln\left(n(x,h_0 ,a_0) \, \pi_1 (x^\prime,h_0, a_0) \right).$$

Density is then given by

$$n(x,h_0 ,a_0) =\exp(-y(a)).$$

*Test case:* In cases where the environment and seed rain are constant and time-independent (i.e $g(x,h,a) = g(x,h)$, $d(x,h,a) = d(x,h)$  for all $a_0, a^\prime$),  it is possible to further simplify Eq. \ref{eq:boundN} to:

\begin{equation}\label{eq:boundN3}
	n(x,h,a)=\frac{y_x}{ g(x,h) } \exp \bigg(-\int _{m_{0} }^{m}\frac{d(x , m^\prime) }{g(x, m^\prime)} \, \textrm{d}m^\prime \bigg).
\end{equation}
(for a proof, see [@Deroos-1997] page 153). Note also, that the integral on the RHS of $\ref{eq:boundN3}$ is simply the survival of individuals from $a_0 \rightarrow a$ describd in equation $\ref{eq:boundSurv}$
\begin{equation} \exp \bigg(-\int _{m_{0} }^{m}\frac{d(x, m^\prime)}{g(x, m^\prime)}  \textrm{d} m^\prime \bigg) = \exp \bigg(-\int _{a_{0} }^{a}d(x, h(a^\prime)) \textrm{d}{a^\prime} \bigg) = S_{\rm I} (x, a_0, a).
\end{equation}

Thus,
\begin{equation}\label{eq:boundN4}
	n(x,h,a)=\frac{y_x}{ g(x,h) } S_{\rm I} (x, a_0, a).
\end{equation}
For some functions of $g$ and $d$, equation $\ref{eq:boundN4}$ might yield an analytical solution to density.

# Seed production

The lifetime seed production of boundary individuals  is calculated according to Eq. $\ref{eq:tildeR}$ as
\begin{equation}
  \begin{array}{ll}
  \tilde{R}(x, a_0, \infty) = \int_{a_0}^{\infty}  &\pi_0 \, f(x, m_i( a^\prime), a^\prime)\times\\ \, &S_{\rm I} (x, a_0, a^\prime) \, S_{\rm P} (a_0,a^\prime)  {\rm d} a^\prime,\\
  \end{array}
\end{equation}
where $S_{\rm I}$ is individual survival (defined above) and
$S_{\rm P}$ is calculated as in Eq. $\ref{eq:survivalPatch}$.

*Numerical technique:* To solve equation \ref{eq:tildeR} we need solve the IVP:
$$\frac{dy}{dt} = \pi_0 \,f(x, m_i(a^\prime), a^\prime) \, S_{\rm I} (x, a_0, a^\prime) \, S_{\rm P} (a_0,a^\prime),$$
$$ y(0) = 0.$$

# Invasion fitness

To scale up seed production for the metapopulation need to integrate Eq. $\ref{eq:boundR}$ across all possible seed-arrival times (as defined in Eq. \ref{eq:InvFit}):
\begin{equation} R(x) = \int_0^{\infty}  p(a) \, \tilde{R}(x, a, \infty) \, {\rm d}a.
\end{equation}

*Numerical technique:*  Note that we have individual's introduced at a series of patch ages, and an estimate for $\tilde{R}(x, a, \infty)$ for each of these (see Eq. $\ref{eq:boundR}$). These points can then be integrated using a quadrature routine, e.g.

# Environmental feedback

The estimated density function  (Eq. \ref{eq:boundN4}) is used to calculate the amount of shading on each individual from other individuals in the patch, as described in Eq. \ref{eq:light}.

*Numerical technique:*  $E(z,a)$ is estimated by integrating  Eq. \ref{eq:light} using the numerical estimate for $n(x,h,a)$ obtained from Eq. \ref{eq:boundN4} via trapezoidal rule with uneven grid (Eq. \ref{trap_uneven}), taking the cohort boundaries as the knots in the integration.

# Controlling error in the EBT

Errors in the EBT approximation to $n$ can arise from two sources: (i) poor spacing of cohorts in the size dimension, and (ii) when stepping cohorts through time. Error of the latter type is effectively controlled using a suitable ODE solver and is not considered further here. However, there is no existing method to control error arising from poor spacing of cohorts. Poor cohort spacing introduces error both because the equations governing cohort dynamics are only accurate up to second order, and because any integrals over the size distribution (e.g. total offspring production, competitive effect) may be poorly resolved.

TODO: describe approaches used.

# References
