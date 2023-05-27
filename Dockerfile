FROM texlive/texlive:latest

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl git git-annex xz-utils zsh python3 python3-pip \
  python3-venv gosu software-properties-common curl
RUN apt-add-repository multiverse && apt-get update

# ---------
# MS CORE FONTS
# ---------
# from http://askubuntu.com/a/25614
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
RUN apt-get install -y --no-install-recommends fontconfig ttf-mscorefonts-installer
ADD localfonts.conf /etc/fonts/local.conf
RUN fc-cache -f -v

# Install pandoc
WORKDIR /build

# Pandoc and pandoc crossref

RUN curl -LJOf https://github.com/jgm/pandoc/releases/download/2.18/pandoc-2.18-1-amd64.deb \
  && apt-get install -y ./pandoc-2.18-1-amd64.deb \
  && apt-get autopurge pandoc-data

RUN curl -LJOf https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.13.0/pandoc-crossref-Linux.tar.xz \
  && tar -xf pandoc-crossref-Linux.tar.xz \
  && mv pandoc-crossref /usr/local/bin/ \
  && chmod a+x /usr/local/bin/pandoc-crossref \
  && mkdir -p /usr/local/man/man1 \
  && mv pandoc-crossref.1  /usr/local/man/man1

RUN python3 -m venv /python-env
ENV PATH="/python-env/bin:$PATH"
RUN pip3 install "poetry>=1.3.0"

WORKDIR /paper-components

COPY poetry.lock pyproject.toml ./
COPY modules/ ./modules

RUN poetry install --no-dev --no-root

COPY . /paper-components

RUN poetry install

# Install the paper executable
RUN make install

ENTRYPOINT [ "/paper-components/bin/docker-entrypoint.sh", "paper" ]