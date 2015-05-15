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
*(max 350 words; rework into 4 points)*

1. Population dynamics in forest communities are strongly size-structured: larger plants shade smaller plants while also expending proportionately more energy on building and maintaining woody stems. Although the importance of size- structure for demography is widely recognised, many mechanistic models either omit it entirely, or include only coarse approximations.
2. Here we introduce the TREE (for TRait Ecology and Evolution) package, an extensible framework for modelling plant demography across the entire life cycle, via a mechanistic model of plant function. At its core, TREE is an individual-based model, wherein plants are modelled as a system of coupled differential equations. Individuals from multiple species can be grown in isolation, in patches of competing plants, or in  metapopulations under a prevailing disturbance regime. The dynamics within patches of competing plants are resolved using either novels extensions of the Escalator Boxcar Train technique. The combined effects of trait-, size- and patch-structured dynamics can then be integrated into a population level estimate of reproductive fitness.
3. TREE is presented as open source `R` package and is available at [github.com/traitecoevo/tree](https://github.com/traitecoevo/tree). While accessed from R, the core routines in TREE are written in C++. Moreover, we allow for alternative physiologies and hyper-parametrisation on the basis of plant functional traits. A detailed test suite is provided to ensure accuracy.
4. We provide worked examples illustrating how TREE can be used to used  to study how functional traits influence the growth of individual plants, whole patches and assembly of ecological communities.

**Key-words**: demography, emergent property, fitness, growth, physiology, metapopulation, mortality, reproduction, size-structure, trade-off

# Introduction

Plant growth and demography are fundamentally size- and trait- structured, influencing dynamics over time-scales ranging from instantaneous physiological effects to long-term evolutionary outcomes [@Harper-1977; @Westoby-2002]. As an individual increases its leaf area, their potential to generate photosynthetic also increases. Yet increasing fractions of this income must also be diverted towards building and maintaining unproductive support tissues [@Givnish-1988; @Enquist-1999]. A larger share of energy is also allocated to reproduction [@Thomas-2011]. Consequently at the population level, rates of growth and mortality change systemically with size [@Muller-2006; @Thomas-2011; @Ruger-2011;  @Wright-2010]. The traits of a species also interact with size to shape its demography. Traits such as leaf construction costs or wood density affect growth rates [@Wright-2010], while other traits such as seed size and height at maturation determine the start and end points of ontogenetic trajectory [@Westoby-2002]. Over longer time-frames, natural selection favours traits making plants more competitive such as faster growth, larger seeds, taller height [@Falster-2003]. Selective forces thus potentially amplify size-related effects on demography. Accounting for the effects of size and traits in models therefore seems like a key step in developing theory for the structure and dynamics of the biosphere [@Purves-2008; @Moorcroft-2001; @Falster-2003], in particular notable phenomena such as successional dynamics, self thinning, trait evolution and species coexistence.

Although the importance of size-structure for vegetation function and demography has been widely recognised for some time [@Hara-1984; @Shugart-1980; @Huston-1987; @Moorcroft-2001; @Kohyama-1993; @Enquist-1999; @Pacala-1996; @Coomes-2007], most large-scale, mechanistic models of plant growth either omit it entirely, or include only coarse approximations [@Cramer-2001; @Sitch-2003]. A likely cause for this omission are the computational challenges of modelling size-structured dynamics. During the 1980s and early 1990s, size-structured (a.k.a. "gap") models were widely used [e.g. @Huston-1987; @Shugart-1980]. However, while gap models did a reasonable job of simulating demography, they did a poor job of simulating carbon fluxes. Consequently, the next generation of models focussed more on physiology and, presumably  for computational reasons, sacrificed details demography in order to achieve global coverage [eg. @Haxeltine-1996]. We have thereby ended up in the perplexing situation where all but a couple [e.g. @Moorcroft-2001; @Smith-2014] of the leading vegetation models used lack size-structure [@Cramer-2001; @Dekauwe-2014; @Sitch-2003; @Kelley-2013]. As such, these carbon-focussed  models may be useful for modelling fluxes, but say almost nothing about the demographic behaviour within a system, and are thus also unable to account for any non-linear demographic feedbacks that may arise.

Interestingly, most of the models used in theoretical ecology to explore questions about species coexistence also lack size-structured dynamics [e.g. @MacArthur-1967; @Levin-1974; @Leimar-2013; @Geritz-1995; @Calcagno-2006; @Tilman-1985]. It is common to assume a competitive interactions are influenced by size-related traits such as adult and seed size, but detailed size-structured demography is rarely considered, at least for plant models [for animal examples, @Deroos-1988; see @Deroos-1992]. Thus it has been difficult to connect mechanisms described in these simplistic models with filed data and real traits, which inevitably are distinctly size-structured.

In this note, we describe the `TREE` package for R [@R-2015], a mechanistic framework for studying the effects of size structure and trait variation on the demography of individual plants, of patches of competing plants, and of meta-populations structured by a prevailing disturbance regime. The package came about as a way to extend previous work investigating the effect of traits on vegetation properties [@Falster-2011] and the mechanisms facilitating coexistence of trait mixtures [@Falster-2015]. These studies provided the foundation methods needed; here we provide robust and extensible implementations. Below, we describe the general approach of the package and then a series of use cases, focussing of different levels of biological organisation. Each section includes a short description of the required methods, design considerations, and then some worked examples illustrating potential use cases and design features. We have intentionally relegated technical details to [supplementary information](#sec:supp_mat), where detailed technical documents can be found. Updated versions of these technical documents are also available within the TREE package itself.  The particular use cases highlighted reflect our own interests in understanding trait-based demography and community assembly. Yet we expect the methods provided to be useful in other contexts. For example, prior to TREE there was no R package that allowed one to simply grow a plant over time, based on well-understood physiology. Surely this is one of the simplest demographic actions one might hope for, with diverse potential applications in ecology, evolution, forestry, agriculture, and vegetation modelling. It is our hope that the mechanistic platform presented here will compliment the increasingly sophisticated statistical methods that can now be used to analyse size-structured data [e.g. @Metcalf-2013].

# The methods

TREE is a mechanistic model, meaning the dynamics of the system arise from rules specifying on how individuals grow and interact. In ecology, there is a long history of using simple deterministic models [such as Lotka-Volterra population dynamics, e.g. @MacArthur-1967; @Leimar-2013] to understand biological phenomena. TREE was developed with this style of analysis in mind, while also allowing for a richer set of ecological dynamics than is possible in the unstructured population models. The package implements methods for physiological, population, and adaptive dynamics (Fig. \ref{fig:schematic}) following methods described by @Falster-2011 and @Falster-2015. The core rules in TREE are about the short-term physiological functioning of an individual plant and how these are influenced by its traits, size and light environment. Dynamics at higher levels of organisation then arise as emergent properties of the system, driven by physiology, competition for light and disturbance. Demographic phenomena can be studied at three different levels: individual plants, stands of competing plants, and entire metapopulations. TREE thus offers a series of nested use-cases (Fig. \ref{fig:schematic}). There are surely other ways to extend the core physiological and demographic models than those presented here, which arise from our our interest in modelling trait-based community assembly.

TREE is written in the languages C++ and R, using the package `Rcpp` [@Eddelbuettel-2011; @Eddelbuettel-2013]to bridge between the two. To maximise speed, the core physiological and demographic components of TREE are written in C++, using templated types that allow the demographic and evolutionary components to be driven by alternative physiological models. The core functions are then made accessible in R, so that users can drive the model with their own scripts and explore results interactively.

TREE makes use of much existing software, including the programming language C++; the R computational environment [@R-2015]; the R packages `BH` [@Eddelbuettel-2015], `Rcpp` [@Eddelbuettel-2011; @Eddelbuettel-2013],  `R6`[@Chang-2014], and `testhat` [@Wickham-2011]; and the Boost Library for C++ [@Schaling-2014]. Source code is hosted at [github.com/traitecoevo/tree](https://github.com/traitecoevo/tree). Installation instructions are available on the homepage for the package, binary releases are also available at that address.

# Effects of size, trait and environment on demography of individual plants

The  core of TREE is a model for a plant's physiological "strategy" (Fig. \ref{fig:schematic}a).  This sub-model estimates rate of biomass production for a plant, given its size, light environment, and the supplied physiological constants. Assimilation is estimated from total leaf area and the light distribution across the plant's canopy.  The costs of tissue respiration and turnover are then subtracted. The remaining biomass is then allocated between growth and reproduction. The strategy model thus includes a list of physiological rules and associated parameters.

The core job of the physiological model is to take size, light environment and parameters as inputs, and return growth rate, mortality, fecundity as outputs. Additional quantities used to calculate these vital rates are also available, such as total assimilation; and the respiration, turnover, and allocation rates for different tissues.

The default physiological model used in TREE largely reflects that presented in Falster-2011, but with extensions allowing for diameter growth to also be estimated. To properly model trait variation, different parameters in the model are linked via an assumed trade-off. For example, the trait LMA is used to estimate the rate of leaf turnover, based on widely observed scaling relationship from @Wright-2004.

A full description and derivation of the model is available in the Appendix ["Default physiological model for TREE"](#sec:FFW16).

## Design features

TREE includes a default physiological model, however a feature of the package is that alternative physiologies can be used. The parameters of each model can also be altered. Trait differences are accounted for by altering relevant parameters. This example shows how to establish a new plant with height of 5m, and estimate its physiological and demographic rates in the given light environment.

```
# Example illustrating use of individual plant, all the outputs from plant internals
```

## Use cases and examples

With above functionality, TREE can be used to estimate essential demographic rates for individual plants (Fig. \ref{fig:trajectories}). The function `grow_plant_to_size` takes a given strategy and light environment and grows the plant, producing a trajectory of size over time (Fig. \ref{fig:trajectories}a). This is achieved by integrating an Ordinary Differential Equation (ODE) of size-dependent growth rate (Fig. \ref{fig:trajectories}b; see Appendix[demography-section-XXX](#sec:demography) for more details). Fig. \ref{fig:trajectories} shows growth trajectories (panel a) and associated growth rates (panel b) for two different lma strategies under high and low light. Importantly, growth rates respond to both size, light environment and traits.

Panel d in Fig. \ref{fig:trajectories} shows the continuous response of growth rate to light. The point at which growth rate reaches zero is referred to as the Whole-Plant Light Compensation Point (WPLCP). Increasingly, WPLCP is being adopted as measure of measure of a strategies shade tolerance [@Givnish-1988; @Baltzer-2007; @Lusk-2013]. As expected, WPLCP increases with plant size (Fig. \ref{fig:trajectories}d), due to increased costs of building and maintaining stem and leaf tissues [@Givnish-1988]. Likewise, WPLCP decreases with LMA, because high LMA species have lower leaf turnover  [@Baltzer-2007; @Lusk-2013].

Panel c in Fig. \ref{fig:trajectories} shows how allocation to different tissues changes with size. As plants increase in size, the amount of energy allocated to replacing stem increases, as does the amount allocated to leaf. Consequently the amount invested in productive leaf area declines. This shift alone generates a distinctive hump-shaped pattern of growth with size, and equally the widely regarded decline in relative growth rate with size.

# Plants competing in a patch

Within patches of competing plants, competition for light generates strong non-linear feedbacks on growth, survival and reproduction. In the `FFW16` physiological model, we consider only the effect of shading rates of biomass production, although competition for other resources such as nitrogen or water could also be considered.

Modelling the development of a competitive hierarchy within a patch requires  that both the initial size distribution and the inflow of new recruits be specified. We have primarily been interested in dynamics of a patch recovering from disturbance, and have therefore started with an empty patch and constant flow of seeds from a global seed rain (Fig. \ref{fig:schematic}b).

## Design features

When modelling a patch, we are interested in modelling changes in the size-density-distribution $n(h,a)$ over time, i.e. the density of individuals with height $h$ within a patch of age $a$. We assume that patches are large, and are vertically but not spatially-structured. Similar assumptions are found in many models simulating size-structured dynamics [@Moorcroft-2001; @Huston-1987; @Smith-2014]. Under these assumptions, the dynamics of $n$ behave deterministically and can thus be approximated via a Partial Differential Equation (PDE) (see Appendix ["Modelling demography in the TREE package"](#sec:demography)). The same PDE is has been shown to capture the average behaviour across a large number of small patches [@Moorcroft-2001]. Ideally one would also consider full spatial interactions within patches, however such models are very computationally demanding, and also impossible to solve in a deterministic fashion [@Pacala-1996].  Moreover, it remains unclear whether resolving spatial details within a patch would provide further ecological detail, in part because the process of competitive thinning tends to break down spatial clusters [@Strigul-2008]. Thus the shading effect in TREE is taken as a "mean field" effect with respect to spatial layout.

Our approach for modelling solving size-structured population dynamics is based on the Escalator Boxcar Train technique  (EBT) [@Deroos-1997; @Deroos-1992; @Deroos-1988]. The EBT solves the PDE describing development of $n$ by approximating the density function with a collection of cohorts spanning the size spectrum. Following a disturbance, a series of cohorts are introduced into each patch . These cohorts are then transported along the characteristic equations of the PDE -- biologically, these are the growth trajectories of individuals, conditioned on them surviving. Fig. \ref{fig:patch}a illustrates the trajectories of individuals within a patch recovering from disturbance. Fig. \ref{fig:patch}b shows the same trajectories, but with shading indicating the density of plants at that size. (see also Fig. \ref{fig:schematic}b).

We introduce two extensions to the EBT: i) a new method for estimating the size-density distribution, and ii) a technique for handling strong size-asymmetric competitive feedbacks, such as occur under strong competition for light. The original EBT [@Deroos-1997; @Deroos-1992; @Deroos-1988] proceeds by approximating the first and second moments of the density distribution $n$ within each cohort. In TREE we use a different but from a theoretical perspective equally valid approach: instead of tracking the first and second moments of the size-distribution within cohorts, we track a point mass estimate of $n$ along the trajectories corresponding to the boundary of each cohort. We found this approach preferable because it does not require us to maintain a separate set of equations for the smallest cohort [@Deroos-1997].

The second extension involves adaptive refining of time points at which new cohorts are introduced into the population. Under strong size-asymmetric competition, the growth trajectories of individuals born at similar times can diverge substantially over time (Fig. \ref{fig:patch}a). This is can become a problem later during patch development because much of the population can be located between widely-spaced cohorts, implying low numerical precision. To maintain numerical precision we use an iterative algorithm to adaptively refine the cohort spacing until the trajectories of adjacent cohorts remain adequately resolved throughout development of the patch (Fig. \ref{fig:characteristics}b; see Appendix ["Modelling demography in the TREE package"](#sec:demography) for details).

## Use cases and examples

Modelling of size-structured dynamics via solving of a deterministic PDE enables multiple  complex, non-linear demographic phenomena to be investigated.

Firstly, TREE can simulate patterns of stand development after disturbance, including self-thinning behaviours and  successional replacement. Whereas previous approaches for modelling self-thinning limited to researchers to a single species [e.g. @Barnes-2004; @Coomes-2007], TREE is easily able to accommodate multiple different species with different traits (Fig. \ref{fig:schematic}b; Fig. \ref{fig:patch}b).

Second, TREE allows for the effects of competition and succession on productivity and biomass accumulation within a stand to be investigated [@Falster-2011]. Leaf area cover and rates of biomass production tend to vary with stand age; such changes might come about via a combination of physiological and structural changes [@Binkley-2002; @Smith-2001; @Ogawa-2010; @Coomes-2007]. TREE enables the effects of competitive feedbacks to be incorporated, in addition to any intrinsic physiological factors. Moreover, TREE allows for the contributions of different species to be mapped (Fig. \ref{fig:patch}c).

# Trait, size and patch structured vegetation

Most vegetation is subject to a disturbance regime, such that patches of the landscape are cleared at some rate, by either fire, cyclone, landslide, or disease outbreak [@Chambers-2013; @Bormann-1979; @Clark-1991; @Coomes-2007]. The vegetation thus comprises a collection of patches differing in time since last disturbance and linked via seed dispersal (Fig. \ref{fig:schematic}a). Such a system is often refereed to as a structured metapopulation [@Gyllenberg-2001].

## Design features

Having simulated a single patch, it is mercifully easy to scale up from a single patch to an entire metapopulation, at least for the  situation of metapopulations at demographic equilibrium and where disturbances remove all established vegetation. To scale from single patch to metapopulation we require the frequency-density $p(a)$ of patches age $a$ in the landscape. Assuming there are a large number of patches means the dynamics of $p$ behave deterministically and can be approximated via a second PDE [@Vonfoerster-1959; @Mckendrick-1926] (see Appendix [Modelling demography in the TREE package](#sec:demography) for details). The scaling from patch to metapopulation is then achieved by weighting the temporal dynamics of a single patch by $p(a)$ -- the relative abundance of patches age $a$ in the metapopulation.

The main numerical challenge in stepping from single patch to metapopulation is to identify the equilibrium seed rain of the metapopulation. This equilibrium is finding the seed rain that would produce an equivalent number of seeds across the metapopulation (Fig. \ref{fig:seed_rain}).

## Use cases and examples

A notable feature of the size-structured metapopulation concept implemented here is that it reconciles equilibrium and non-equilibrium approaches to modelling ecological dynamics [@Levin-1974; @Bormann-1979; @Connell-1978; @Coomes-2007]. An equilibrium may be approached at the level of metapopulation, meaning the seed rain and size structure across the entire metapopulation is approximately stable. Yet, the structure of vegetation within individual patches is constantly in flux: patches continue to move through their life-cycle before being disturbed and starting afresh.

Beyond its conceptual appeal, this idea of a dynamic equilibrium allows us to close the demographic feedback loop and thereby create a self-regulating system. The equilibrium seed rain for multi-species communities is approached demographically, incorporating the combined effects of the model's physiological rules, species traits, competitive interactions and the prevailing disturbance regime on the size-distributions of plants within a metapopulation of patches. Unlike some vegetation models, there is no need to set the density of seeds or seedlings, these arise as outputs from the model. Characteristics of the vegetation such as total leaf area, biomass, productivity and allocation like arise as emergent properties (Fig. \ref{fig:patch}). Similarly, we can observe emergent patterns for size-distribution, growth and mortality  (Fig. \ref{fig:emergent}).

# Invasion fitness

With the extension to metapopulation, we are modelling demography across the entire life cycle and are thus in a position to estimate the fitness of different types. Invasion fitness quantifies the ability of a rare individual with particular traits to establish in a community of established residents at their equilibrium densities. Invasion fitness is ideally calculated as the long-term per capita growth rate of the new type; however, in structured metapopulations, the most convenient indicator of per-capita growth rate is given by the logarithm of the basic reproduction ratio [@Gyllenberg-2001; @Metz-2001]. The basic reproduction ratio $R$ is simply the total seed output of the new type, averaged across the metapopulation. The new type can invade when $R > 1$.

## Use cases and examples

With fitness defined, it becomes possible to model the adaptation and community assembly[@Dieckmann-2007; @Geritz-1998]. The reproductive success of individuals in the size- and patch structured metapopulation is both frequency- and density-dependent, meaning the shape of the fitness landscape depends on the traits and densities of species in the current resident community. In such circumstances, evolution tends to favour different trait mixtures to models optimising some feature of the community, such as total biomass or carbon production, or even seed production in the absence of competition [@Falster-2003; @Dieckmann-2007].

Frequency-dependence is a necessary but not sufficient condition for the stable coexistence of different types [@Dieckmann-1997]. The underlying model physiological and demographic model must also include real opportunities for niche differentiation. Figure \ref{fig:landscape} shows a fitness landscape for LMA.... assembly.

Identifying the conditions promoting trait diversity is perhaps one the most important use-cases for TREE. It is now well established that coexisting plant species differ in a range of physiological traits, yet the conditions allowing for these different types to coexist in face of competition for a common set of resources remain largely unknown.

# Closing comments


Compare to IPM approach

- mathematics similar, difference is source of variability


Lists of unexplored research questions

- adaptation to climate change
- tradeoffs promoting diversity
- competition for other resources
- questions about complementarity

Structured metapopulations

- Although these assumptions make the system a somewhat simplified version of real vegetation, it still represents a substantial advance over the completely unstructured populations used in most vegetation models.



# Acknowledgements

DS Falster was supported by an ARC discovery grant (DP110102086). RG FitzJohn was supported by the Science and Industry Endowment Fund (RP04-174).

# Supplementary material {#sec:supp_mat}

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
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/plant.pdf}
\caption{\textbf{Growth trajectories.} Sensitivity of height growth rate to trait variation across size.
\label{fig:trajectories}}
\end{figure}

\newpage

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/patch.pdf}
\caption{\textbf{Patterns of leaf area accumulation within a patch, showing contribution of different species. Overlay single line showing average for metapopulation.}
\label{fig:patch}}
\end{figure}

\newpage

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/empty.pdf}
\caption{\textbf{Emergent size-distributions across metapopulation}
\label{fig:emergent}}
\end{figure}

\newpage

\begin{figure}[h!]
\centering
\includegraphics[width=15cm,height=15cm,keepaspectratio]{output/fitness.pdf}
\caption{\textbf{Example fitness landscape for LMA, showing potential for coexistence of multiple types}
\label{fig:landscape}}
\end{figure}


\newpage


# Supplementary figures

\renewcommand{\thefigure}{S\arabic{figure}}
\renewcommand{\thetable}{S\arabic{table}}

\setcounter{figure}{0}
\setcounter{table}{0}


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

# References
