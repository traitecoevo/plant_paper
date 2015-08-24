#!/bin/sh
set -e
remake all
rm -rf release supporting_material plant_paper
mkdir release
cp ms.pdf release

mkdir supporting_material
(cd vignettes; pandoc combined.html -o ../supporting_material/combined.pdf --template template.tex --toc)


for file in $(find vignettes -name '*.html' | sed -e 's|.*/||'); do
    echo "Converting ${file}"
    (cd vignettes; pandoc "$file" -o ../supporting_material/"${file%.html}.pdf" --template template.tex)
done
cp vignettes/*.pdf supporting_material
zip -r release/supporting_material.zip supporting_material
rm -rf supporting_material

## All artefacts:
mkdir plant_paper
cp -r figures vignettes ms.pdf plant_paper
zip -r release/plant_paper.zip plant_paper
rm -rf plant_paper
