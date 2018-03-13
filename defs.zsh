function prepare-crossref {
  # Prepares Pandoc markdown for crossref filter by opportunistically
  # wrapping references in escaped brackets to mimic citation style
  # so that [@fig:stuff] prints as [Figure 1].
  # Also escapes pipes for subfigures with non-printing characters,
  # enabling the @fig:stuff|b signature.
  inmatch="\S+"
  sed -r "s/\[((@(fig|eq|sec|tbl):$inmatch;? ?)*)\]/\\\[\1\\\]/g" \
  | sed -r "s/(@(fig|tbl):$inmatch)\|/\1‌/g"
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

function text-pipeline-html {
   prepare-crossref \
   | pandoc \
      --from markdown \
      --to html \
      --section-divs \
      --number-sections \
      --csl='paper-components/agu.csl' \
      --bibliography=text/references.bib \
      --filter pandoc-comments \
      --filter pandoc-crossref \
      --filter pandoc-citeproc
}

function run-latex {
  echo "Running LaTeX"
  latexmk -f -xelatex -output-directory=$2 $1
}
