# plant

To compile the paper, including figures and supplementary information (vignettes) we use [remake](https://github.com/traitecoevo/remake).  The easiest way to install is via [drat](https://github.com/eddelbuettel/drat):

```r
drat:::add("traitecoevo")
install.packages("remake")
```

(install drat itself with `install.packages("drat")`)

Compilation requires pandoc, or the `rmarkdown` renderer will fail with a cryptic error (version 0.5.1 at least), and a reasonably complete LaTeX installation (e.g. MacTeX).

We use the non-CRAN packages [plant](https://github.com/traitecoevo/plant), [callr](https://github.com/traitecoevo/callr) and [sowsear](https://github.com/richfitz/sowsear).  These can be installed by remake:

```r
remake::install_missing_packages()
```

To compile everything, run

```r
remake::make()
```

Compilation, including vignettes, takes about 1.5 hours on a 2012 iMac.  Compiling just the figures and manuscript can be done with:

```r
remake::make("ms.pdf")
```

and should only take 20 minutes or so.
