# Paper components

This repository of "paper components" is a set of loosely-coupled tools that
are used in a `pandoc markdown` -> `LaTeX` paper production pipeline. Over
time, they have evolved into a set of interlocking, extensible scripts that can
be used to quickly and efficiently produce nice-looking manuscripts and
journal-formatted papers. The modular structure allows the software to evolve over time.

The scripts were once mostly invoked within individual projects, but
most of the code-level differences have been resolved in favor of a single
application with hooks for different functionality. The current
tool is based around the `paper` command-line application, which wraps
a range of individual commands for extracting references, versioning text,
and creating preprints, journal-formatted papers (only AGU currently supported),
and review responses.

## Rationale

LaTeX code can involve a lot of boilerplate, and the production process is confusing.
[`pandoc`](https://pandoc.org) fixes a lot of the worst issues (e.g. switching
between `natbib` and `biblatex` citation backends), but figures, rich paper templates,
and such are still difficult. This tool abstracts out as many of the pain points as
possible to leave each paper's core build files as content-focused as feasible.

## In use

This tools was used to build all of my papers beginning during my PhD.
Preprints for [my structural study of northeast Syrtis Major, Mars](https://eartharxiv.org/fzhk7/)
and the associated paper on [orientation statistics methods](https://eartharxiv.org/4enzu/)
were both produced using the standard template here; they are good references for the
styling capabilities of the pipeline.
[My PhD thesis](https://thesis.library.caltech.edu/10953/) and
preprint files from each chapter were also created using this tool.

## Basic usage

The paper directory is expected to contain a `paper-defs.zsh` file that sets key environment variables.
Within this directory, a `text` directory contains the contents of the paper itself. Much like the `git`
command, actions run within a paper directory will act on that project as a whole. An example
project structure is below:

```
.
├── collected-figures
│   ├── regional-orientations.pdf
│   ├── structure-model.pdf
│   └── ...figures...
├── paper-defs.zsh
└── text
    ├── abstract.md
    ├── chapters
    │   ├── 01-introduction.md
    │   ├── 02-geologic-context.md
    │   ├── ...main text...
    │   ├── ...of paper ...
    ├── figure-captions.md
    ├── includes.yaml
    ├── key-points.md
    ├── revision-1
    │   ├── cover-letter.md
    │   └── review-responses.md
    ├── revision-2
    │   ├── cover-letter.md
    │   └── review-responses.md
    ├── title-block-agu.tex
    └── title-block.tex
```

The `paper-defs.zsh` file has the following basic structure

```
name="Syrtis-Major"
author="Daven Quinn"

FIGURE_SEARCH_DIRECTORIES=( \
  $PROJECT_REPOSITORY/graphics/output-annotated \
  $PROJECT_REPOSITORY/graphics \
  ./text \
  ./figures)

BIBTEX_LIBRARY="/Users/Daven/Resources/Papers/library.bib
```

Some software, such as XeLaTeX, Latexmk, and pandoc, are required dependencies

## Other components

This repository wraps the [`figurator` module](https://github.com/davenquinn/figurator),
which allows templating of figures in TeX papers. Other related modules I have
used in paper production are a command-line wrapper for the [Word "compare documents" tool](https://github.com/davenquinn/compare-documents)
(Mac only) and the [`pdf-printer`](https://github.com/davenquinn/pdf-printer) module for
composing figures using Javascript.


