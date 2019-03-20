function aggregate-text {
  paper cat $@
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

function implicit-introduction {
   sed -r 's/^\\section\{(Introduction)\}/\\invisiblesection\{\1\}/g'
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

pc=$PAPER_DIR/paper-components

function text-pipeline-docx {
   prepare-crossref \
   | pandoc \
      --from markdown \
      --to docx+styles \
      --reference-doc="$pc/templates/reference.docx" \
      --bibliography="$PAPER_DIR/text/references.bib" \
      --csl="$pc/agu.csl" \
      --filter "$pc/bin/figure-ref-filter" \
      --filter pandoc-comments \
      --filter pandoc-crossref \
      --filter pandoc-citeproc \
      $@
}

function scale-images {
  # Usage: scale-images [input file] [output file] [screen*|ebook|printer|prepress]
  # Makes sure to embed all fonts so we don't get weird character subsetting effects
  /usr/local/bin/gs -sDEVICE=pdfwrite \
   -dNOPAUSE -dQUIET -dBATCH -dPDFSETTINGS=/${3:-"screen"} \
   -dSAFER \
   -dCompressFonts=true \
   -dSubsetFonts=true \
   -dEmbedAllFonts=true \
   -dRENDERTTNOTDEF=true \
    -dColorImageDownsampleType=/Bicubic -dColorImageResolution=150 \
    -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=150 \
    -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=150 \
   -dCompatibilityLevel=1.4 -sOutputFile="$2" "$1"
 }

function run-latex-draft {
  xelatex -interaction=nonstopmode -no-pdf \
    --jobname=${2:t:r} -output-directory="${2:h}" $1
}

function run-latex {
  latexmk -f -bibtex -interaction=nonstopmode -xelatex \
    --jobname=${2:t:r} -output-directory="${2:h}" $1
}

#function run-latex {
  #xelatex -interaction=nonstopmode \
    #--jobname=${2:t:r} -output-directory="${2:h}" $1
#}
