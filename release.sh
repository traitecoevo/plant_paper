#!/bin/sh
set -e
remake all
rm -rf plant_paper
mkdir plant_paper
cp -rp vignettes figures ms.pdf plant_paper
zip -r plant_paper.zip plant_paper
rm -rf plant_paper
