FROM condaforge/mambaforge:latest

WORKDIR /usr/local/src/acanthophis
COPY . .
RUN conda config --add channels bioconda &&  mamba install --yes --all snakemake && pip install -e .
