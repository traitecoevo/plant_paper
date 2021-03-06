#!/bin/sh
set -e
remake all

## What do we need?
##   - ms.pdf
##   - vignettes/code.pdf
##   - vignettes/demography.pdf
##   - vignettes/physiology.pdf

rm -rf release supporting_material plant_paper
mkdir release
cp ms.pdf release

mkdir supporting_material
cp vignettes/*.pdf supporting_material
zip -r release/supporting_material.zip supporting_material
rm -rf supporting_material

## All artefacts:
mkdir plant_paper
cp -r figures vignettes ms.pdf plant_paper
zip -r release/plant_paper.zip plant_paper
rm -rf plant_paper
