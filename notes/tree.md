# TREE: A package for modelling plant TRait Ecology and Evolution

Participants: Daniel Falster, Rich FitzJohn, Mark Westoby

Arising from SIEF_BDKD Issue number: [#23](https://github.com/dfalster/SIEF_BDKD/issues/23)

Github repo: [github.com/traitecoevo/tree_paper](https://github.com/traitecoevo/tree_paper)

Aim is to contribute to special Issue of BES journals aligned with their
symposium [Demography Beyond The Population](http://www.britishecologicalsociety.org/events/current_future_meetings/demography-beyond-the-population-bes-annual-symposium/)

	Demographic methods and population modelling have long provided powerful
	approaches for ecologists. Recent advances have expanded the scope of
	questions that can be addressed with these tools, helping to integrate
	population-level processes more broadly into ecological research. This
	symposium aims to highlight the emerging role of demographic tools as
	bridges across ecological, spatial, and temporal scales. Specific topics
	include evolutionary demography, communities and coexistence, species
	ranges, conservation, environmental drivers of population dynamics, and
	methodological advances."

- see pitch [here](tree_pitch.md)

## Abstract
*(Fundamental task(s) which the software accomplishes, examples of biological insights from the use of the software, details of availability, including where to download the most recent source code, the license, any operating system dependencies, and support mailing lists. Max 300m words)*

We present an open-source and extensible software platform for modelling the ecological and evolutionary dynamics of vegetation on the basis of traits. While most plants have the same basic physiological function, large differences exist among species in the amount of energy invested in different tissues (leaves, stems, roots) and the quality with which these tissues are constructed[@westoby_plant_2002;@niklas_evolution_2000]. The TREE model provides a platform for understanding  i) how physiological "traits" scale up to influence the growth and structure of individual plants, patches of competing plants, and entire vegetation, ii) which trait axes enable multiple species to coexist, and iii) what trait mixtures will be favoured under a given set of environmental conditions. At its core, TREE is an individual-based model, consisting of a large number of plants modelled as a system of coupled ODEs and/or linked via a PDE. The size-asymmetric nature of competitive shading induces strong non-linear feedbacks. To solve this system we provide a novel extension of the Escalator Boxcar Train technique, a method for solving PDEs via integrating along their characteristics. Evolutionary outcomes are estimated on the basis of fitness, which is calculated across the metapopulation on the basis of reproductive output. The core of TREE is programmed in C++ (for speed), but with wrappers allowing both interactive and scripted use from the R platform. Moreover, the software allows for alternative physiological models and hyper parametrisation. Finally, a detailed testing suite is provided to ensure accuracy. All code is open-source and hosted on github.

## Introduction

 *(A description of the problem addressed by the software and of its novelty and
exceptional nature in addressing that problem.)*

Problem is that only one dominant vegetation model includes size structure, even
though competition for light widely acknowledged as most fundamental of processes.
Methods for studying size-structured metapopulations poorly developed, relying mostly
on simulation.
Means that unable to answer many questions, particular about traits, where need to
evaluate affect across entire life cycle, and taking into account effects on growth,
fecundity and mortality.

What does tree model do

- Individual plants growing
	- estimate plant growth rates in relation to size, light env, traits
- Plants competing in a patch (stochastic, deterministic)
	-  multi-species self-thinning, successional transitions
- Trait, Size and Patch structured vegetation
	- emergent behaviours: vegetation (e.g. Falster et al 2011), demography
- Fitness in metapopulation
	- community assembly, evolution, adaptation
- Evolution, community assembly, e.g. successional diversity

Series of nested uses

- has multiple possible spin-offs, we highlight some ways of extended
- Each step down is just one way of extending thing above

## Design and Implementation
*(Details of the algorithms used by the software, how those algorithms have been instantiated, including dependencies. Details of the supplied test data and how to install and run the software should be detailed in the supplementary material.)*

- new method for solving PDEs
	+ estimate density using modified version of EBT, integration along characteristics.
	+ not sure if better than original EBT but simpler
	+ at present don't have cohort mean implemented, but could easily enough [RF ~
	2 days] --> would
	need this is wanted to make any claims about one method being better
- stochastic and deterministic versions [RF < 1 wek]
- multiple models physiological models possible
- hyper-parametrisation with respect to traits
- Extensive testing [Possible couple days of clean-up]
- Possible to drive core from C++ (with minimal modification), and thereby interfacing other languages

## Scope

Major new piece of software (lines), designed with..... 1300 R code, 7000 cpp

See De Roos book [for example](http://simsrad.net.ocs.mq.edu.au/login?url=http://site.ebrary.com/lib/mqau/docDetail.action?docID=10640067)

## Results

*(Examples of biological problems solved using the software, including results obtained with the deposited test data and associated parameters.)*

Examples illustrating uses

### Demographics

Example from growth trajectories

### Scaling from trait to patch and vegetation

Successional dynamics

Emergent mortality, growth, size distributions


### Community assembly

- Fundamental versus realised niche
- Niche differentiation and evolved neutrality
- Evolutionary responses to environmental change

### Differences to EBT

- density via point estimates rather than averages across cohorts
- In original EBT, total number of individuals constrained through formation of a
cohort,, but only via first-order approximation. Here estimates of n is exact,
but could be error in total number of individuals.
- adaptive spacing of cohorts


## Fitness

See De Roos 1997, equation 24 - possible to estimate population growth rate.

## Feedbacks

De Roos PSPM tool allows for three different types of feedback in environment variable
(see page 51 of manual)

1. PERCAPITARATE: is one that follows dynamics described by an ordinary differential
equation (ODE) and in addition can potentially be 0 in equilibrium, e.g depletion of resource.
$dE/dt = G(E, n) E$
2. GENERALODE: is one that follows dynamics described by an ordinary differential
equation (ODE), but Ei = 0 is not a potential equilibrium value for this environment variable.
$dE/dt = G(E, n)$
3. POPULATIONINTEGRAL: The last type of environment variable are variables that represent
measures (weighted integrals) of the population distribution itself, i.e. represents a direct
density-dependent effect of the population on the life history of the individuals.
$E=\int f(x,E) n (x) dx$

## Compare behaviour of stochastic finite-population size and approximation of dynamics with partial differential equations

Expected that two should converge for large populations (i.e. many and large patches).

As starting point, compare growth dynamics within a patch with fixed seed rain varying across

- patch size
- seed rain density

Then consider implications for metapopulation. Perhaps also how our estimate of R0 performs.

## Availability and Future Directions
*(Where the software has been deposited. Any future work planned to be carried out by the authors, how others might extend the software.)*

Lists of unexplored research questions

- questions about complementarity

List of possible extensions

- other resources
- physiology

Parametrisation

## Supplementary Information

Full model description generated as pdf from software
