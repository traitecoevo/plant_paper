---
title: "tree: A package for modelling plant TRait Ecology & Evolution: _Plant physiological model_"
csl: ../downloads/style.csl
bibliography: ../refs.bib
---

The core job of the physiological model is to take a plant's current size, light
environment and physiological parameters as inputs, and to return growth rate,
mortality and fecundity as outputs, based on well understood physiology. All of these 
outcomes are derived from the rate of biomass accumulation by the plant (Fig. \ref{fig:schematic-phys)}).

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{../output/schematic-phys.pdf}
\caption{Physiological model in TREE, giving 
demographic rates on the basis of its traits, size and light environment.}
\label{fig:schematic-phys}
\end{figure}


# Standard model for mass production

We begin with a standard model for the amount of biomass available for
growth, $\textrm{d}b / \textrm{d}t$, given by the difference between income
(total photosynthesis) and losses (respiration and turnover) within the
plant [@Makela-1997; @Thornley-2000; @Falster-2011]:
\begin{equation}\label{eq:dbdt}
\underbrace{\strut \frac{\textrm{d}b}{\textrm{d}t}}_\textrm{net biomass production}
  = \underbrace{\strut y}_\textrm{yield}
    \big( \underbrace{\strut a_\textrm{l} \, p}_\textrm{photosynthesis} -
     \underbrace{\strut \,\sum_\textrm{i=l,b,s,r}{m_\textrm{i} \, r_\textrm{i}}}_\textrm{respiration}\big)
    - \underbrace{\strut \sum_\textrm{i=l,b,s,r}{m_\textrm{i} \, k_\textrm{i}}}_\textrm{turnover}.
\end{equation}
Here, $m,r$, and $k$ refer to the mass, respiration rate, and
turnover rate of different tissues, denoted by subscripts $l$=leaves,
$b$=bark, $s$=sapwood and $r$=roots. $A$ is the assimilation
rate of CO$_2$ per leaf area and $y$ is yield: the fraction of
assimilated carbon fixed in biomass (the remaining fraction being lost
as growth respiration) (see Table \ref{tab:params} for units and
definitions). Photosynthesis is proportional to leaf area,
$a_\textrm{l} = m_\textrm{l} / \phi$, where $\phi$ is leaf mass per area.
The total mass of living tissues $m_\textrm{a}=m_\textrm{l}+m_\textrm{b}+m_\textrm{s}+m_\textrm{r}.$

# Height growth rate 

To model growth in  height requires that account not just for mass production, but also for the costs of building new tissues, allocation to reproduction, and architectural layout. Mathematically, height growth can be decomposed into a product of physiologically relevant terms [@Falster-2011]:
\begin{equation} \label{eq:dhdt}
\underbrace{\strut\frac{\textrm{d}h}{\textrm{d}t}}_\textrm{height growth rate}= \underbrace{\strut\frac{\textrm{d}h}{\textrm{d}a_\textrm{l}}}_\textrm{architecture}
\times \underbrace{\strut\frac{\textrm{d}a_\textrm{l}}{\textrm{d}m_\textrm{a}}}_\textrm{marginal leaf deployment}
\times \underbrace{\strut\frac{\textrm{d}m_\textrm{a}}{\textrm{d}b}}_\textrm{allocation to growth}
\times \underbrace{\strut\frac{\textrm{d}b}{\textrm{d}t}}_\textrm{mass production}.
\end{equation}

The first term on the right of eq \ref{eq:dhdt},
$\textrm{d}h / \textrm{d}a_\textrm{l}$, is the growth in plant height
per unit growth in total leaf area -- accounting for the architectural
strategy of the plant. Some species tend to leaf out more than grow
tall, while other species emphasise vertical
extension.

The second term, $\textrm{d}a_\textrm{l} / \textrm{d}m_\textrm{a}$,
accounts for the marginal cost of deploying an additional unit of leaf
area, including construction of the leaf itself and various support
structures. As such, $\textrm{d}a_\textrm{l} / \textrm{d}m_\textrm{a}$
can itself be expressed as a sum of construction costs per unit leaf
area:
\begin{equation}\label{eq:daldmt}
\frac{\textrm{d}a_\textrm{l}}{\textrm{d}m_\textrm{a}}
= \big(\phi
 + \frac{\textrm{d}m_\textrm{s}}{\textrm{d}a_\textrm{l}} + \frac{\textrm{d}m_\textrm{b}}{\textrm{d}a_\textrm{l}} + \frac{\textrm{d}m_\textrm{r}}{\textrm{d}a_\textrm{l}}\big)^{-1}.
\end{equation}

The third term in eq \ref{eq:dhdt},
$\textrm{d}m_\textrm{a} / \textrm{d}m_\textrm{b}$, gives the fraction of net
biomass production (eq. \ref{eq:dbdt}) that is allocated to growth
rather than reproduction or storage.

# A functional-balance model for allocation

Here we describe an allometric model linking the various size dimensions
of a plant required by most ecologically realistic vegetation models
(i.e. =mass of leaves, mass of sapwood, mass of bark, mass of fine
roots) to a plant height. 

## Leaf area

Based on empirically observed allometry (see main text), we assume an
allometric log-log scaling relationship between the accumulated leaf
area of a plant and its height:
\begin{equation}\label{eq:ha}
a_\textrm{l}=\alpha_1 \, h^{\beta_1}.
\end{equation}

Note, scaling relationship reversed from [@Falster-2011].

## Mass of sapwood

We follow the model of @Yokozawa-1995 describing the
vertical distribution of leaf area within the crowns of individual
plants. This model can account for a variety of canopy profiles through
a single parameter $\eta$. Setting $\eta=1$ results in a conical
canopy, as seen in many conifers, while higher values, e.g. $\eta=12$
, gives a top-weighted canopy profile similar to those seen among
angiosperms. Let $S(z,h)$ be the sapwood area at height $z$ for a
plant with top height $h$. Following @Yokozawa-1995 we
assume a relationship between $S(z,h)$ and height such that
\begin{equation}\label{eq:crown1}
\frac{S(z,h)}{S(0,h)}= \big(1-\big(\frac{z}{h}\big)^\eta\big)^2.
\end{equation}

We also assume that each unit of sapwood area supports a fixed area of
leaf [the pipe model @Shinozaki-1964], so that the total
canopy area of a plant relates to basal sapwood area $S(0,h)$:
\begin{equation}\label{eq:crown2}
\frac{m_\textrm{l}}{\phi}= \theta \, S(0,h).
\end{equation}

Integrating $S(z,h)$ gives a solution for the total mass of sapwood in
the plant:
\begin{equation}\label{eq:ms1}
m_\textrm{s}=\rho \, \int_0^h \, S(z,h) \, \textrm{d}z= \rho \, S(0,h) \, h \, \eta_c, \end{equation}
where
$\eta_c=1-\frac{2}{1+\eta} + \frac{1}{1+2\eta}$ [@Yokozawa-1995].
Substituting from eq. \ref{eq:crown2} into eq. \ref{eq:ms1} gives an
expression for sapwood mass as a function leaf area and height:
\begin{equation}\label{eq:ms2}
m_\textrm{s}=\rho \, \eta_c \, \theta \, a_\textrm{l} \, h.
\end{equation}

## Bark mass

Bark and phloem tissue are modelled using an analogue of the pipe model,
leading to a similar equation as that for sapwood mass (eq.
\ref{eq:ms2}). Cross sectional-area of bark per unit leaf area is
assumed to be a constant fraction $b$ of sapwood area per unit leaf
area such that
\begin{equation}\label{eq:mb}
m_\textrm{b}=b m_\textrm{s}.
\end{equation}

## Root mass

Also consistent with pipe-model assumption, we assume a fixed ratio of
root mass per unit leaf area
\begin{equation}\label{eq:mr}
m_\textrm{r}=\alpha_3 \, a_\textrm{l}.
\end{equation}

Even though nitrogen and water uptake are not modelled explicitly,
imposing a fixed ratio of root mass to leaf area ensures that
approximate costs of root production are included in calculations of
carbon budget.

# Seed production

# Mortality

# References
