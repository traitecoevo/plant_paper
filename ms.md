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

Population dynamics in forest communities are strongly size-structured: larger
plants shade smaller plants while also expending proportionately more energy
on building and maintaining woody stems. Although the importance of size-
structure for demography is widely recognised, many mechanistic models either
omit it entirely, or include only coarse approximations. In this paper we
outline an extensible framework and package (called TREE, for TRait Ecology
and Evolution) for modelling plant demography across the entire life cycle,
via a mechanistic model of plant function. At its core, TREE is an
individual-based model, wherein plants are modelled as a system of coupled
differential equations. Individuals from multiple species can be grown in
isolation, in patches of competing plants, or in  metapopulations under a
prevailing disturbance regime. The dynamics within patches of competing plants
are resolved using either novels extensions
of the Escalator Boxcar Train technique. The combined effects of trait-, size-
and patch-structured dynamics can then be integrated into a population level
estimate of reproductive fitness. The core of TREE is programmed in C++ with
wrappers allowing both interactive and scripted use from R. Moreover, we allow
for alternative physiologies and hyper-parametrisation on the basis of plant
functional traits. A detailed test suite is provided to ensure accuracy. We
discuss how the methods outlined can be used to address fundamental questions
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

Argue that size-structure essential for modelling many problems in ecology and evolution, especially anything regarding ecology and evolution of traits.

- Size is key in evolutionary context,
- Fitness cannot occur without demography.
  - most models not demographic- thus limited ability to link with traits, or allow for species coexistence
- demography cannot occur without physiology -- because trade-offs expressed at physiological level.
- Thus size

In this note, we describe the `TREE` package for R [@R-2015]. TREE implements methods for .... Below, we describe the general approach of the package and then series of use cases, focussing of different levels of biological organisation (individual plant, patch of competing plants, metapopulation). Each section includes short description of methods, design elements, examples.


# The methods

- Methods described in @Falster-2011, @Falster-2015.
- Series of nested uses
  - overview Fig. \ref{fig:schematic}
  - each level has multiple possible spin-offs, we highlight some ways of extended
  - Each step down is just one way of extending thing above

Design

- core in C++, R interface
  - Possible to drive core from C++ (with minimal modification), and thereby interfacing other languages


TREE makes use of much existing software, including the programming language C++; the R computational environment [@R-2015]; the R packages `BH` [@Eddelbuettel-2015], `Rcpp` [@Eddelbuettel-2011; @Eddelbuettel-2013],  `R6`[Chang-2014], and `testhat` [@Wickham-2011]; the GNU Scientific Library [@Gough-2009]; and the Boost Library for C++ [@Schaling-2014]. Source code is hosted at github.com/traitecoevo/tree.

# Effects of size, trait and environment on demography of individual plants

how traits, size and environment influence vital rates in given environment.

- Vital rates are growth rate, mortality, fecundity.
- physiology model enhanced from Falster et al, expanded from upcoming publication
- trait effects

## Design features

- multiple models physiological models possible
  - link to SI material
- hyper-parametrisation with respect to traits

## Example

Figure \ref{fig:trajectories} - sensitivity to diameter growth rate.






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

## Examples

multi-species self-thinning

Successional dynamics





# Trait, size and patch structured vegetation

- Scaling to vegetation involves monitoring of multiple patches
- emergent behaviours -- integrating over entire vegetation

## Design features

- Assuming large number, demographics become deterministic

## Examples

- seed rain to stability?
- Emergent mortality, growth, size distributions
- allocation at level of community?
- effects of disturbance on recruitment, standing carbon?


# Invasion fitness

- calculate fitness for new type
- growth rate of seed rain

## Design features

- simplify by calculating at demographic equilibrium -- R0

## Example

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
\caption{\textbf{Schematic.} Similar to Figure 1 of Falster et al. 2011.
\label{fig:schematic}}
\end{figure}

\newpage

\begin{figure}[ht]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Growth trajectories.} Sensitivity of diameter growth rate to trait variation across size.
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


# References
