#!/usr/bin/env bash
# properties = {properties}
# This script gets executed on a compute node on the cluster

source /broad/software/scripts/useuse
use {{ cookiecutter.cluster_name }}
use {{ cookiecutter.dotkits }} 

source activate {{ cookiecutter.conda_env }}

echo -e "JOB ID\t$JOB_ID"
echo "=============================="

{exec_job}
EXIT_STATUS=$?

# Report resource consumption because it's not reported by default
echo "------------------------------"
qstat -j $JOB_ID | grep '^usage'

# if the job succeeds, snakemake 
# touches jobfinished, thus if it exists cat succeeds. if cat fails, the error
# code indicates job failure
# an error code of 100 is needed since UGER only prevents execution of
# dependent jobs if the preceding
# job exits with error code 100

cat $1 &>/dev/null
if [[ $? -eq 0 ]]; then
    exit 0
else
    if [[ "{workflow.immediate_submit}" -eq "True" ]]; then
        exit 100
    else
        exit $EXIT_STATUS
    fi
fi

