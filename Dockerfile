FROM condaforge/miniforge3:latest
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    mamba install snakemake=8 natsort python>=3.11
WORKDIR /usr/local/src/acanthophis
COPY . .
RUN pip install -e .
