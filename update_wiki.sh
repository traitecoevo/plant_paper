#!/bin/sh
remake vignettes_md

if [ -d wiki/ ]; then
    git -C wiki pull
else
    git clone https://github.com/traitecoevo/plant_paper.wiki.git wiki
fi

cp vignettes/*.md vignettes/*.pdf wiki
cp -r vignettes/figure wiki
git -C wiki add .
SHA=$(git rev-parse --short HEAD)
git -C wiki commit -m "Updated wiki to ${SHA}"
git -C wiki push
