function prepare-crossref {
  # Prepares Pandoc markdown for crossref filter by opportunistically
  # wrapping references in escaped brackets to mimic citation style
  # so that [@fig:stuff] prints as [Figure 1].
  # Also escapes pipes for subfigures with non-printing characters,
  # enabling the @fig:stuff|b signature.
  sed -r "s/\[((@(fig|eq|sec|tbl):\w+;? ?)*)\]/\\\[\1\\\]/g" \
  | sed "s/\(@fig:\(\w\+\)\)|/\1‌/g"
}

function text-pipeline {
 prepare-crossref \
 | wrap-si-units \
 | pandoc \
    --from markdown \
    --to latex \
    --natbib \
    --metadata=draft:true \
    --filter pandoc-comments \
    --filter pandoc-crossref
}

function run-latex {
  latexmk -f -xelatex -quiet -output-directory=$2 $1
}
