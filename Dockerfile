FROM texlive/texlive:latest

# Install pandoc
WORKDIR /build


RUN apt-get update \
  && apt-get install -y curl git git-annex xz-utils zsh python3 python3-pip python3-venv gosu

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

# Set a default git user
RUN git config --global user.email "anonymous@paper" \
  && git config --global user.name "Anonymous"

ENTRYPOINT [ "/paper-components/bin/docker-entrypoint.sh", "paper" ]