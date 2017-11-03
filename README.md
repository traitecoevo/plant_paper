# Paper about the plant package

This repository contains code needed to reproduce the article:

Falster DS, FitzJohn RG, Brännström Å, Dieckmann U, Westoby M (2016) **plant: A package for modelling forest trait ecology & evolution**. *Methods in Ecology and Evolution* 7: 136-146. (doi: [10.1111/2041-210X.12525](http://doi.org/10.1111/2041-210X.12525)

# Instructions

Recreating all the figures from the paper will take around 2 hrs. 

## Install relevant software

All analyses were done in `R`. You need to [download this repository](https://github.com/traitecoevo/plant_paper/archive/master.zip), and then open an R session with working directory set to the root of the project.

To compile the paper, including figures and supplementary material we use the [remake](https://github.com/richfitz/remake) package for R. You can install remake using the `devtools` package (run `install.packages("devtools")` to install devtools if needed):

```r
devtools::install_github("richfitz/storr", dependencies=TRUE)
devtools::install_github("richfitz/remake", dependencies=TRUE)
```

We use the non-CRAN packages [plant](https://github.com/traitecoevo/plant) and [sowsear](https://github.com/richfitz/sowsear).  These can be installed by remake:

```r
remake::install_missing_packages()
```

Compilation requires also [pandoc](https://pandoc.org/installing.html), or the `rmarkdown` renderer will fail with a cryptic error (version 0.5.1 at least). Finally, compiling the paper requires a reasonably complete LaTeX installation (e.g. [MacTeX](https://tug.org/mactex/) for OSX or [MikTex](http://miktex.org/) for windows). The LaTeX compilation will depend on a few packages from CTAN, make sure to allow automatic package installation by your LaTeX distribution

## Re run analyses

To compile everything, run

```r
remake::make()
```

Compiling just the figures and manuscript can be done with:

```r
remake::make("ms.pdf")
```

and should only take 20 minutes or so.

