function aggregate-text {
  echo ""
  for fn in $@; do
    cat $fn
    echo "\n\n"
  done
}

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
 | sed "s/º/°/g" \
 | pandoc \
    --from markdown \
    --to latex \
    --natbib \
    --metadata=draft:true \
    --filter pandoc-comments \
    --filter pandoc-crossref
}

function mark-inline-figures {
  sed -r 's/<!--\[\[\[(.+)\]\]\]-->/\\inlinefigure\{\1\}/g'
}

function text-pipeline-agu {
 mark-inline-figures \
 | text-pipeline \
 | sed "s/{µm}/{\\\micro\\\meter}/g" \
 | sed "s/[º°]/\\\textdegree{}/g" \
 | sed "s/‌//g" \
}


function text-pipeline-html {
   prepare-crossref \
   | pandoc \
      --from markdown+pipe_tables \
      --to html \
      --section-divs \
      --number-sections \
      --csl='paper-components/agu.csl' \
      --bibliography=text/references.bib \
      --filter pandoc-comments \
      --filter pandoc-crossref \
      --filter pandoc-citeproc \
      $@
}

function text-pipeline-docx {
   prepare-crossref \
   | pandoc \
      --from markdown \
      --to docx \
      --number-sections \
      --csl='paper-components/agu.csl' \
      --bibliography=text/references.bib \
      --filter pandoc-comments \
      --filter pandoc-crossref \
      --filter pandoc-citeproc \
      $@
}

function scale-images {
  # Usage: scale-images [input file] [output file] [screen*|ebook|printer|prepress]
  # gs -sDEVICE=pdfwrite -dMaxSubsetPct=100 \
  #    -dPDFSETTINGS=/prepress -dAutoFilterColorImages=false \
  #    -dColorImageFilter=/FlateEncode -sOutputFile=$2 \
  #    -dNOPAUSE -dBATCH $1
 gs -sDEVICE=pdfwrite \
   -dNOPAUSE -dQUIET -dBATCH -dPDFSETTINGS=/${3:-"screen"} \
   -dCompatibilityLevel=1.4 -sOutputFile="$2" "$1" 
}

function run-latex {
  echo "Running LaTeX"
  latexmk -f -interaction=nonstopmode -xelatex \
    --jobname=${2:t:r} -output-directory="${2:h}" $1
}
