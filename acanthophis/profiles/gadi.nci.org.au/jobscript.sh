#!/bin/bash -l
# properties = {properties}

export TMPDIR=$PBS_JOBFS

set -ueo pipefail
{exec_job}
