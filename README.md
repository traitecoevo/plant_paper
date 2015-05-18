# tree

Compilation requires pandoc, or the `rmarkdown` renderer will fail with a cryptic error (version 0.5.1 at least), and a reasonably complete LaTeX installation (e.g. MacTeX).

```r
remake::install_missing_packages()
remake::make()
```
