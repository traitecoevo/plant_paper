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
* TREE can be used to address fundamental questions on how functional traits
influence the growth of individual plants, whole patches
and assembly of ecological communities.

# Key-words:
*(maximum of 10 keywords or phrases, avoid overlap with the title)*

# Introduction

Plant growth and demography is fundamentally size- and trait- structured [@Harper-1977; @Westoby-2002; @Ruger-2011; @Wright-2010]. Size influences dynamics over time-scales ranging from instantaneous physiological effects to long-term evolutionary outcomes. As individual increase their leaf area, their potential to generate photosynthetic also increases. Yet increasing fractions of this income must also be diverted towards building and maintaining unproductive support tissues [@Givnish-1988; @Enquist-1999]. A larger share of energy is also allocated to reproduction [@Thomas-2011]. Consequently at the population level, rates of growth and mortality change systemically with size [@Muller-2006; @Thomas-2011]. The traits of a species also interact with size to shape its demography. Traits such as leaf construction costs or wood density affect growth rates [@Wright-2010], while other traits such as seed size and height at maturation determine the start and end points of ontogenetic trajectory [@Westoby-2002]. Over longer time-frames, natural selection favours traits making plants more competitive such as faster growth, larger seeds, taller height [@Falster-2003]. Selective forces thus potentially amplify size-related effects on demography. Accounting for the effects of size and traits in models therefore seems like an key step in developing theory for the structure and dynamics of the biosphere [@Purves-2008; @Moorcroft-2001; @Falster-2003].

Although the importance of size-structure for vegetation function and demography has been widely recognised for some time [@Hara-1984; @Shugart-1980; @Huston-1987; @Moorcroft-2001; @Kohyama-1993; @Enquist-1999; @Pacala-1996; @Coomes-2007], most large-scale, mechanistic models of plant growth either omit it entirely, or include only coarse approximations [@Cramer-2001; @Sitch-2003]. A likely cause for this omission are the computational challenges of modelling size-structured dynamics. During the 1980s and early 1990s, size-structured (a.k.a. "gap") models were widely used [e.g. @Huston-1987; @Shugart-1980]. However, while gap models did a reasonable job of simulating demography, they did a poor job of simulating carbon fluxes. Consequently, the next generation of models focussed more on physiology and, presumably  for computational reasons, sacrificed details demography in order to achieve global coverage [eg. @Haxeltine-1996]. We have thereby ended up in the comical situation where all but a couple [e.g. @Moorcroft-2001; @Smith-2014] of the leading vegetation models used lack size-structure [@Cramer-2001; @Dekauwe-2014; @Sitch-2003; @Kelley-2013]. As such, the models may be useful for modelling carbon fluxes, but say almost nothing about demography within a system.

Interestingly, most of the models used in theoretical ecology to explore questions about species coexistence also lack size-structured dynamics [e.g. @MacArthur-1967; @Levin-1974; @Leimar-2013; @Geritz-1995; @Calcagno-2006; @Tilman-1985]. It is common to assume a competitive hierarchy based on a trait such as adult offspring size, but detailed size-structured demography is rarely considered, at least for plant models [for animal examples, see @Deroos-1992; @Deroos-1988].

In this note, we describe the `TREE` package for R [@R-2015], a mechanistic framework for studying the effects of size structure and trait variation on the demography of individual plants, of patches of competing plants, and of meta-populations structured by a prevailing disturbance regime.  Below, we describe the general approach of the package and then a series of use cases, focussing of different levels of biological organisation. Each section includes a short description of the required methods, design considerations, and then some worked examples illustrating potential use cases and design features.

# The methods

TREE is a mechanistic model, meaning the dynamics of the system arise from rules specifying on how individuals grow and interact. In ecology, there is a long history of using simple mechanistic models (such as Lotka-Volterra systems) to understand biological phenomena. TREE was developed with this style of analysis in mind, while also allowing for a richer set of ecological dynamics than is possible in the unstructured population models. The package implements methods for physiological, population, and adaptive dynamics (Fig. \ref{fig:schematic}) following methods described by @Falster-2011 and @Falster-2015. The core rules in TREE are about the short-term physiological functioning of an individual plant and how these are influenced by its traits, size and light environment. Dynamics at higher levels of organisation then arise as emergent properties of the system, driven by physiology, competition for light and disturbance. Demographic phenomena can be studied at three different levels: individual plants, stands of competing plants, and entire metapopulations. TREE thus offers a series of nested use-cases (Fig. \ref{fig:schematic}). There are surely other ways to extend the core physiological and demographic models than those presented here, which reflect our strong interest in modelling evolutionary dynamics.

TREE was developed using a combination of C++ and R. To maximise speed, the core physiological and demographic components of TREE are written in C++, using templated types that allow the demographic and evolutionary components to be driven by alternative physiological models. The core functions are then made accessible in R, so that users can drive the model with their own scripts and explore results interactively.

TREE makes use of much existing software, including the programming language C++; the R computational environment [@R-2015]; the R packages `BH` [@Eddelbuettel-2015], `Rcpp` [@Eddelbuettel-2011; @Eddelbuettel-2013],  `R6`[Chang-2014], and `testhat` [@Wickham-2011]; the GNU Scientific Library [@Gough-2009]; and the Boost Library for C++ [@Schaling-2014]. Source code is hosted at github.com/traitecoevo/tree.

# Effects of size, trait and environment on demography of individual plants

The  core of TREE is a model for plant physiological function (Fig. \ref{fig:schematic}a).  This sub-model estimates rate of biomass production for a plant, given its size, light environment, and the supplied physiological constants. Assimilation is estimated from total leaf area and the light distribution across the plant's canopy.  The costs of tissue respiration and turnover are then subtracted. The remaining biomass is then allocated between growth and reproduction.

The core job of the physiological model is to take size, light environment and parameters as inputs, and return growth rate, mortality, fecundity as outputs. A full description of the default model used in TREE is available in the [Appendix](#sec:FFW16).

## Design features

TREE includes a default physiological model, however a feature of the package is that alternative physiologies can be used. The parameters of each model can also be altered. Trait differences can then be accounted for by altering relevant parameters. This example shows how to establish a new plant with height of 5m, and estimate its physiological and demographic rates in the given light environment.

```
# Example illustrating use of individual plant, all the outputs from plant internals
```

## Use cases and examples

With above functionality, TREE can be used to estimate three core aspects of demography (Fig. \ref{fig:trajectories})

1. Sensitivity of growth rate to changes in trait values (LMA, wood density).
  - plot height vs height growth rate, using arrows to indicate sensitivity to changes in traits at several points along line
  - recovers known hump-shaped curve in growth.
  - tendency for growth rate to change with size
2. Sensitivity of growth rate to light
  - whole plant light compensation point
3. Change in allocation with size (plot amount invested in tissue versus height)
  - recognised need to better understand how allocation varies

# Plants competing in a patch

Integrating the functions for growth, mortality and fecundity for a plant with given traits, starting size, and light environment yields trajectories of growth, survival and cumulative reproductive output over time  for that individual (see [Appendix](#sec:demography) for equations, or **possibly include here**?). This is essentially what is TREE does when modelling a patch of competing plants, with the added complexities that i) plants arrive (germinate) at different times during the development of a patch, and ii) that established plants affect interact (i.e. affect each others vital rates) by altering the availability of resources. In the `FFW16` physiological model, we consider only the effect of shading on biomass production, although competition for other resources such as nitrogen or water could also be considered.

## Design features

When modelling a patch, we are interested in modelling changes in the size-distribution $n(h,t)$ of individuals height $h$ within the patch over time $t$. We assume that patches are large and are vertically but not spatially-structured within the patch. Similar assumptions are found in many models simulating size-structured dynamics [].Under these assumptions, the dynamics of $n$ behave deterministically and can thus be approximated via a Partial Differential Equation (PDE) (see [Appendix](#sec:demography)). Interestingly, the same PDE is has been shown to capture the average behaviour across a large number of small patches [@Moorcroft-2001].

Our approach for modelling solving size-structured population dynamics is based on the Escalator Boxcar Train technique  (EBT) [@Deroos-1997; @Deroos-1992; @Deroos-1988]. The EBT solves the PDE describing development of $n$ by approximating the density function with a collection of cohorts spanning the size spectrum. Following a disturbance, a series of cohorts are introduced into each patch. These cohorts are then transported along the characteristics of the PDE -- biologically, these are the growth trajectories of individuals, provided they do not die.

We introduce two extensions to the EBT: i) a new method for estimating the size-density distribution, and ii) a technique for handling strong size-asymmetric competitive feedbacks, such as occur under strong competition for light. The original EBT [@Deroos-1997; @Deroos-1992; @Deroos-1988] proceeds by approximating the first and second moments of the density distribution $n$ within each cohort. In TREE we use a different but equally valid approach: instead of tracking the first and second moments of the size-distribution within cohorts, we track a point mass estimate of $n$ along the trajectories corresponding to the boundary of each cohort. We found this approach preferable because it does not require us to maintain a separate set of equations for the smallest cohort [@Deroos-1997].

The second extension involves adaptive refining of time points at which new cohorts are introduced into the population. Under strong size-asymmetric competition, the growth trajectories of individuals born at similar times can diverge substantially over time (Fig. \ref{fig:characteristics}a). This is can become a problem later during patch development because much of the population can be located between widely-spaced cohorts, implying low numerical precision. To maintain numerical precision we use an iterative algorithm to adaptively refine the cohort spacing until the trajectories of adjacent cohorts remain adequately resolved throughout development of the patch (Fig. \ref{fig:characteristics}b; see [Appendix](#sec:demography) for details).

## Use cases and examples

Modelling of size-structured dynamics via solving of a deterministic PDE enables multiple phenomena to be investigated.

Firstly, TREE can simulate patterns of stand development after disturbance, including self-thinning behaviours and  successional replacement. Whereas previous approaches for modelling self-thinning limited to researchers to a single species, TREE is easily able to accommodate multiple different species with different traits (Fig. \ref{fig:schematic}b).

Second, TREE allows for the effects of competition and succession on productivity and biomass accumulation within a stand to be investigated [@Falster-2011]. Researchers have long been fascinated by tendency for rates of biomass production to decrease with stand age. Such changes can come about via a combination of physiological and structural changes [@Binkley-2002; @Smith-2001]. TREE enables the effects of competitive feedbacks to be incorporated, in addition to any intrinsic physiological factors. Moreover, TREE allows for the contributions of different species to be mapped (Fig. \ref{fig:patch}).

# Trait, size and patch structured vegetation

Most vegetation is subject to a disturbance regime, such that patches of the landscape are cleared at some rate, by either fire, cyclone, landslide, or disease outbreak [@Chambers-2013; @Bormann-1979; @Clark-1991; @Coomes-2007]. The vegetation thus comprises a collection of patches differing in time since last disturbance and linked via seed dispersal (Fig. \ref{fig:schematic}a). Such a system is often refereed to as a structured metapopulation [@Gyllenberg-2001].

## Design features

Having simulated a single patch, it is mercifully easy to scale up from a single patch to an entire metapopulation, at least for the  situation of metapopulations at demographic equilibrium and where disturbances remove all established vegetation. To scale from single patch to metapopulation we require the frequency-density $p(a)$ of patches age $a$ in the landscape. Assuming there are a large number of patches means the dynamics of $p$ behave deterministically and can be approximated via a second PDE [@Vonfoerster-1959; @Mckendrick-1926] (see [Appendix](#sec:demography) for details). The scaling from patch to metapopulation is then achieved by weighting the temporal dynamics of a single patch by $p(a)$ -- the relative abundance of patches age $a$ in the metapopulation.

The main numerical challenge in stepping from single patch to metapopulation is to identify the equilibrium seed rain of the metapopulation. This equilibrium is finding the seed rain that would produce an equivalent number of seeds across the metapopulation (Fig. \ref{fig:seed_rain}).

## Use cases and examples

A notable feature of the size-structured metapopulation concept implemented here is that it reconciles equilibrium and non-equilibrium approaches to modelling ecological dynamics [@Levin-1974; @Bormann-1979; @Connell-1978; @Coomes-2007]. An equilibrium may be approached at the level of metapopulation, meaning the seed rain and size structure across the entire metapopulation is approximately stable. Yet, the structure of vegetation within individual patches is constantly in flux: patches continue to move through their life-cycle before being disturbed and starting afresh.

Beyond its conceptual appeal, this idea of a dynamic equilibrium allows us to close the demographic feedback loop and thereby create a self-regulating system. The equilibrium seed rain for multi-species communities is approached demographically, incorporating the combined effects of the model's physiological rules, species traits, competitive interactions and the prevailing disturbance regime on the size-distributions of plants within a metapopulation of patches. Unlike some vegetation models, there is no need to set the density of seeds or seedlings, these arise as outputs from the model. Characteristics of the vegetation such as total leaf area, biomass, productivity and allocation like arise as emergent properties (Fig. \ref{fig:patch}). Similarly, we can observe emergent patterns for size-distribution, growth and mortality  (Fig. \ref{fig:emergent}).

# Invasion fitness

With the extension to metapopulation, we are modelling demography across the entire life cycle and are thus in a position to estimate the fitness of different types. Invasion fitness quantifies the ability of a rare individual with particular traits to establish in a community of established residents at their equilibrium densities. Invasion fitness is ideally calculated as the long-term per capita growth rate of the new type; however, in structured metapopulations, the most convenient indicator of per-capita growth rate is given by the logarithm of the basic reproduction ratio [@Gyllenberg-2001; @Metz-2001]. The basic reproduction ratio $R$ is simply the total seed output of the new type, averaged across the metapopulation. The new type can invade when $R > 1$.

## Use cases and examples

With fitness defined, it becomes possible to model the adaptive dynamics of community. This includes both adaptation within species and community assembly[@Dieckmann-2007; @Geritz-1998]. The reproductive success of individuals in the size- and patch structured metapopulation is both frequency- and density-dependent, meaning the shape of the fitness landscape depends on the traits and densities of species in the current resident community. In such circumstances, evolution tends to favour different trait mixtures to models optimising some feature of the community, such as total biomass or carbon production, or even seed production in the absence of competition.

Frequency-dependence is a necessary but not sufficient condition for the stable coexistence of different types. The underlying model physiological and demographic model must also include the possibility of niche differentiation. Figure \ref{fig:landscape} shows a fitness landscape for LMA.... assembly.

Identifying the conditions promoting trait diversity is perhaps one the most important use-cases for TREE. It is now well established that coexisting plant species differ in a range of physiological traits, yet the conditions allowing for these different types to coexist in face of competition for a common set of resources remain largely unknown.

# Closing comments

Lists of unexplored research questions

- adaptation to climate change
- tradeoffs promoting diversity
- competition for other resources
- questions about complementarity

Structured metapopulations

- Although these assumptions make the system a somewhat simplified version of real vegetation, it still represents a substantial advance over the completely unstructured populations used in most vegetation models.



# Acknowledgements

DS Falster was supported by an ARC discovery grant (DP110102086). RG FitzJohn was supported by the Science and Industry Endowment Fund (RP04-174).

# Supplementary material

## Default physiological model for TREE {#sec:FFW16}

see attached file [tree_physiology.pdf](tree_physiology.pdf)

##  Modelling demography in the TREE package {#sec:demography}

see attached file [tree_demography.pdf](tree_demography.pdf)

\newpage

# Figures

\begin{figure}[h!]
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

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Growth trajectories.} Sensitivity of height growth rate to trait variation across size.
\label{fig:trajectories}}
\end{figure}

\newpage

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Patterns of leaf area and biomass accumulation within a patch, showing contribution of different species. Overlay single line showing average for metapopulation.}
\label{fig:patch}}
\end{figure}

\newpage

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Example fitness landscape for LMA, showing potential for coexistence of multiple types}
\label{fig:landscape}}
\end{figure}


\newpage


# Supplementary figures

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Adpative cohort spacing solves problem of diverging characteristics}
\label{fig:characteristics}}
\end{figure}

\newpage

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Approach for solving equilibrium seed rain across the metapopulation}
\label{fig:seed_rain}}
\end{figure}

\newpage

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Emergent size-distributions across metapopulation}
\label{fig:emergent}}
\end{figure}

# References
