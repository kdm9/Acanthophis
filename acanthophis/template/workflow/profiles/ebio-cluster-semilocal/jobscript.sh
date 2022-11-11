#!/bin/bash -l
# properties = {properties}
test -f ~/.bash_env && source ~/.bash_env
set -ueo pipefail
{exec_job}
