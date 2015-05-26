---
title: "tree: A package for modelling plant TRait Ecology & Evolution: _Approximating system dynamics using the EBT_"
csl: ../downloads/style.csl
bibliography: ../refs.bib
---

# Introduction

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

The density of individuals at the boundary can be solved by integrating along characteristics ([see Appendix for details](#IntegrationAlongCharacteristics)) to give:

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
