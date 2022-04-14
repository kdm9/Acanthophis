acanthophis-init --yes
# download kraken DB
mkdir data/dbs/kraken/viral
pushd  data/dbs/kraken/viral
wget https://genome-idx.s3.amazonaws.com/kraken/k2_viral_20201202.tar.gz
tar xvf k2_viral_20201202.tar.gz
popd
snakemake --snakefile Snakefile.generate-rawdata -j 4 --use-conda --conda-frontend mamba
