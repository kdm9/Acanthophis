#!/bin/bash
#PBS -q normal
#PBS -l ncpus=2
#PBS -l walltime=48:00:00
#PBS -l mem=50G
#PBS -l storage=scratch/xe2+gdata/xe2
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -P xe2

set -ueo pipefail
logdir=data/log/cluster/
mkdir -p $logdir
export TMPDIR=${PBS_JOBFS:-$TMPDIR}
TARGET=${TARGET:-all}
SNAKEFILE=${SNAKEFILE:-Snakefile}

QSUB="qsub -q {cluster.queue} -l ncpus={threads} -l jobfs={cluster.jobfs}"
QSUB="$QSUB -l walltime={cluster.time} -l mem={cluster.mem} -N {cluster.name} -l storage=scratch/{cluster.project}+gdata/{cluster.project}"
QSUB="$QSUB -l wd -j oe -o $logdir -P {cluster.project}"

if [ "${RMTEMP:-yes}" == yes ]
then
	temp=''
else
	temp='--notemp'
fi

snakemake \
    --use-conda \
    --conda-frontend mamba \
    --conda-create-envs-only \
    --snakefile "$SNAKEFILE"                                       \

snakemake                                                          \
    -j 1000                                                        \
    --use-conda                                                    \
    --cluster-config gadi/cluster.yaml                           \
    --local-cores ${PBS_NCPUS:-1}                                  \
    --js gadi/jobscript.sh                                       \
    --nolock                                                       \
    --rerun-incomplete                                             \
    --keep-going                                                   \
    $temp                                                          \
    --snakefile "$SNAKEFILE"                                       \
    --cluster "$QSUB"                                              \
    "$TARGET"                                                      \
    |& tee data/log/submitter_${PBS_JOBID:-headnode}_snakemake.log \

