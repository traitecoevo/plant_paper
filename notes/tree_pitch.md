% Modelling trait-, size- and patch-structured population dynamics and fitness in vegetation with the TREE package
% Daniel Falster^1,\*^, Rich FitzJohn^1^, Mark Westoby^1^

^1^ *Biological sciences, Macquarie University NSW 2109 Australia*

^\*^ To whom correspondence should be addressed; E-mail: daniel.falster@mq.edu.au

## Abstract

Population dynamics in forest communities are strongly size-structured: larger
plants shade smaller plants while also expending proportionately more energy
on building and maintaining woody stems. Although the importance of size-
structure for demography is widely recognised, many mechanistic models either
omit it entirely, or include only coarse approximations. In this paper we
outline an extensible framework and package (called TREE, for TRait Ecology
and Evolution) for modelling plant demography, driven by a mechanistic model
of plant function, across the entire life cycle. At its core, TREE is an
individual-based model, wherein plants are modelled as a system of coupled
differential equations. Individuals from multiple species can be grown in
isolation, in patches of competing plants, or in  metapopulations under a
prevailing disturbance regime. The dynamics within patches of competing plants
are resolved using either 1) a stochastic simulator, or 2) a deterministic
approximation of their density. The latter is achieved via a novel extension
of the Escalator Boxcar Train technique. The combined effects of trait-, size-
and patch-structured dynamics can then be integrated into a population level
estimate of reproductive fitness. The core of TREE is programmed in C++ with
wrappers allowing both interactive and scripted use from R. Moreover, we allow
for alternative physiologies and hyper-parametrisation on the basis of plant
functional traits. A detailed test suite is provided to ensure accuracy. We
discuss how the methods outlined can be used to address fundamental questions
on how functional traits influence the growth of individual plants, whole patches
and assembly of ecological communities.
