FROM texlive/texlive:latest

# Install pandoc
RUN apt-get update && apt-get install -y pandoc pandoc-crossref git git-annex

COPY . /paper-components

WORKDIR /paper-components

RUN pip3 install "poetry>=1.3.0"

RUN poetry config virtualenvs.create false

RUN python3 -m venv .venv

# Activate the virtual environment
ENV PATH="/paper-components/.venv/bin:$PATH"

# Install the paper executable
RUN make install

WORKDIR /paper

ENTRYPOINT [ "paper" ]