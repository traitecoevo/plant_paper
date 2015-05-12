---
title: "TREE: A package for modelling plant TRait Ecology and Evolution"
author: "Daniel Falster, Rich FitzJohn, Mark Westoby"
affiliation: Biological sciences, Macquarie University NSW 2109
output: pdf_document
csl: downloads/style.csl
bibliography: refs.bib
---
A manuscript in consideration as a research paper for publication in MEE as part of the Special Feature Demography beyond the Population

# Abstract
*(max 350 words; rework into points 1: set the context and purpose
for the work;  2: indicate the approach and methods used;  3: outline the main
results;  4: identify the conclusions, the wider implications and the
relevance to management or policy.)*

* Population dynamics in forest communities are strongly size-structured: larger
plants shade smaller plants while also expending proportionately more energy
on building and maintaining woody stems. Although the importance of size-
structure for demography is widely recognised, many mechanistic models either
omit it entirely, or include only coarse approximations. Here we introduce the
TREE (for TRait Ecology and Evolution) package, an extensible framework for
modelling plant demography across the entire life cycle,
via a mechanistic model of plant function.
* At its core, TREE is an individual-based model, wherein plants are modelled as a system of coupled
differential equations. Individuals from multiple species can be grown in
isolation, in patches of competing plants, or in  metapopulations under a
prevailing disturbance regime. The dynamics within patches of competing plants
are resolved using either novels extensions of the Escalator Boxcar Train technique. The combined effects of trait-, size-
and patch-structured dynamics can then be integrated into a population level
estimate of reproductive fitness. The core of TREE is programmed in C++ with
wrappers allowing both interactive and scripted use from R. Moreover, we allow
for alternative physiologies and hyper-parametrisation on the basis of plant
functional traits. A detailed test suite is provided to ensure accuracy.
* We provide several worked examples, showing illustrating how TREE can be used to ...XXXX.
* TREE can be used to address fundamental questions
on how functional traits influence the growth of individual plants, whole patches
and assembly of ecological communities.

# Key-words:
*(maximum of 10 keywords or phrases, avoid overlap with the title)*

# Introduction

Plant growth and demography is markedly size-structured.

- Physiological
  - photosynthesis
  - support costs
- Demographic
  - growth rates change with size
  - mortality- U shaped
- Evolutionary
  - arms race
- Accounting for size thus essential .... (bring in traits)

Although the importance of size-structure for demography is widely recognised, many mechanistic models either omit it entirely, or include only coarse approximations.

- Early phase where size central: gap-models, solutions based on PDEs
- Gave way to DGVMs where role of size sidelined, mainly for computational reasons
- Confusing situation where majority of models of carbon cycle do not include size structure.
- Signs pendulum starting to swing again, importance of representing individuals explicitly recognised in at least two models, also noted in recent analyses.
- But even so, models geared very, much

We argue that size-structured dynamics are essential for modelling many problems in ecology and evolution, especially those regarding ecology and evolution of traits.

- Size is key in evolutionary context,
- Fitness cannot occur without demography
  - most models not demographic- thus limited ability to link with traits, or allow for species coexistence
- demography cannot occur without physiology -- because trade-offs expressed at physiological level.
- Thus size....

In this note, we describe the `TREE` package for R [@R-2015], a mechanistic framework for studying the effects of trait-variation and and size-structure on the demography of individual plants, of patches of competing plants, and of meta-populations structured by a prevailing disturbance regime.  Below, we describe the general approach of the package and then a series of use cases, focussing of different levels of biological organisation. Each section includes a short description of the required methods, design considerations, and then some worked examples illustrating potential use cases and design features.

# The methods

TREE is a mechanistic model, meaning the dynamics of the system arise from rules specifying on how individuals grow and interact. In ecology, there is a long history of using simple mechanistic models (such as Lotka-Volterra systems) to understand biological phenomena. TREE was developed with this style of analysis in mind, but allowing for a richer set of ecological dynamics than is possible in the unstructured population models that are widespread in theoretical ecology. The package implements methods for physiological, population, and adaptive dynamics Fig. \ref{fig:schematic} described in @Falster-2011 and @Falster-2015. In TREE, the key rules are for the short-term physiological functioning within an individual plant and how these are influenced by its traits, size and environment. Dynamics at higher levels of organisation then arise as emergent properties of the system, driven by physiology, competition for light and disturbance. Demographic phenomena can be studied at three different levels: individual plants, stands of competing plants, and entire metapopulations. TREE thus offers a series of nested use-cases (Fig. \ref{fig:schematic}). There are surely other ways to extend the core physiological and demographic models than those presented here, which reflect our strong interest in modelling evolutionary dynamics.

TREE was developed using a combination of C++ and R. To maximise speed, the core physiological and demographic components of TREE are written in C++, using templated types so that demographic component can be driven by alternative physiological models. The core C++ functions are then made accessible in R, so that users can drive the model with their own scripts and explore results interactively.

TREE makes use of much existing software, including the programming language C++; the R computational environment [@R-2015]; the R packages `BH` [@Eddelbuettel-2015], `Rcpp` [@Eddelbuettel-2011; @Eddelbuettel-2013],  `R6`[Chang-2014], and `testhat` [@Wickham-2011]; the GNU Scientific Library [@Gough-2009]; and the Boost Library for C++ [@Schaling-2014]. Source code is hosted at github.com/traitecoevo/tree.

# Effects of size, trait and environment on demography of individual plants

The  core of TREE is a model for plant physiological function (Fig. \ref{fig:schematic}a).  This sub-model estimates rate of biomass production for a plant, given its size, light environment, and the supplied physiological constants. Assimilation is estimated from total leaf area and the light distribution across the plant's canopy.  The costs of tissue respiration and turnover are then subtracted. The remaining biomass is then allocated between growth and reproduction.

The core job of the physiological model is to take size, light environment and parameters as inputs, and provide growth rate, mortality, fecundity as outputs. See appendix {#sec:FFW16} for full description of the default model used in TREE.

## Design features

TREE includes a default physiological model, however a feature of the package is that alternative physiologies can be used. The parameters of each model can also be altered. Trait differences can then be accounted for by altering relevant parameters. This example shows how to establish a new plant with heigh of 5m, and estimate its physiological and demographic rates in the given light environment.

```
# Example illustrating use of individual plant, all the outputs from plant internals
```

## Use cases and examples

With above functionality, TREE can be used to estimate three core aspects of demography (Fig. \ref{fig:trajectories})

a. Sensitivity of growth rate to changes in trait values (LMA, wood density).
  - plot height vs height growth rate, using arrows to indicate sensitivity to changes in traits at several points along line
  - recovers known hump-shaped curve in growth.
  - tendency for growth rate to change with size
b. Sensitivity of growth rate to light
  - whole plant light compensation point
c. Change in allocation with size (plot amount invested in tissue versus height)
  - recognised need to better understand how allocation varies

# Plants competing in a patch


Integrate physiology over time to get growth trajectory, prob of survival, cumulative fecundity -- life table for individual.

Competition requires that account for feedback from other plants

- primarily light, via size-asymmetric shading
- Assume homogeneous within patch
- but might be extended to include other feedbacks.
  - de Roos suggest 3 types of feedback

## Design features

Our approach for modelling solving size-structured population dynamics is based on the Escalator Boxcar Train technique  (EBT) [@Deroos-1997; @Deroos-1992]. We introduce two extensions for the EBT: i) a new method for estimating the size-density distribution, and ii) a technique for handling strong size-asymmetric competitive feedbacks, such as occur under strong competition for light.

- Integration along characteristics. Solution to PDE. Core of EBT.
  - density via point estimates rather than averages across cohorts
  - In original EBT, total number of individuals constrained through formation of a
  cohort, but only via first-order approximation. Here estimates of n is exact,
  but could be error in total number of individuals.
  - not sure if better than original EBT but simpler
    - at present don't have cohort mean implemented, but could easily enough [RF ~ 2 days] -->  need this is wanted to make any claims about one method being better
- Adaptive refining of cohort boundaries
  - Problem of diverging characteristics
  - possible figure to illustrate
- links to SI material

## Use cases and examples

multi-species self-thinning

Successional dynamics





# Trait, size and patch structured vegetation

- Scaling to vegetation involves monitoring of multiple patches
- emergent behaviours -- integrating over entire vegetation

## Design features

- Assuming large number, demographics become deterministic

## Use cases and examples

- seed rain to stability?
- Emergent mortality, growth, size distributions
- allocation at level of community?
- effects of disturbance on recruitment, standing carbon?


# Invasion fitness

- calculate fitness for new type
- growth rate of seed rain

## Design features

- simplify by calculating at demographic equilibrium -- R0

## Use cases and examples

Fitness landscape

enables: community assembly, evolution, adaptation

- Fundamental versus realised niche
- Niche differentiation and evolved neutrality
- Evolutionary responses to environmental change

# Closing comments

Lists of unexplored research questions

- questions about complementarity

List of possible extensions

- other resources
- physiology

# Acknowledgements

DS Falster was supported by an ARC discovery grant (DP110102086). RG FitzJohn was supported by the Science and Industry Endowment Fund (RP04-174).

\newpage

# Figures

\begin{figure}[ht]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/schematic}
\caption{\textbf{Overview of processes included in TREE package,
including physiological dynamics, population dynamics, and evolutionary
dynamics.} \textbf{a,} An individual's vital rates are jointly
determined by its light environment, height, and traits. \textbf{b,} A
metapopulation consists of a distribution of patches linked by seed
dispersal. Disturbances occasionally remove all vegetation within a
patch. Competitive hierarchies within developing patches are modelled by
tracking the height distribution of individuals across multiple species
(distinguished by colours) as patches age after a disturbance. The
intensity of shading indicates the density of individuals at a given
height. \textbf{c,} The traits of the resident species determine the
shading environment across the metapopulation, which in turn determines
fitness landscapes. Resident traits adjust through directional selection
up the fitness landscape and through the introduction of new species
where the fitness landscape is positive. Adapted from Falster *et al.* (2015).
\label{fig:schematic}}
\end{figure}

\newpage

\begin{figure}[ht]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Growth trajectories.} Sensitivity of height growth rate to trait variation across size.
\label{fig:trajectories}}
\end{figure}

\newpage

\begin{figure}[ht]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Adpative cohort spacing solves problem of diverging characteristics}
\label{fig:characteristics}}
\end{figure}

\newpage

\begin{figure}[ht]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Example fitness landscape for LMA, showing potential for coexistence of multiple types}
\label{fig:landscape}}
\end{figure}


\newpage

# Supplementary material

## Default physiological model for TREE {#sec:FFW16}

Here we provide a derivation for the default physiological model in TREE, called `FFW16`. Models are named according to the surnames of the corresponding authors and year of publication.


# References
