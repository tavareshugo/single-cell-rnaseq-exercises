#!/bin/bash
#SBATCH -A HELARIUTTA-SL2-CPU
#SBATCH -D /home/hm533/rds/rds-bioinfo-training-Wvut5whigiI/single-cell-rnaseq-exercises/prepare_data/celegans
#SBATCH -o logs/00-fastqdump_%a.log
#SBATCH -p icelake
#SBATCH -c 2
#SBATCH -t 01:00:00
#SBATCH -a 2-37

eval "$(conda shell.bash hook)"
source $CONDA_PREFIX/etc/profile.d/mamba.sh
mamba activate sra

# fetch current SRA id
sra=$(cat celegans_sra_accessions.csv | head -n $SLURM_ARRAY_TASK_ID | tail -n 1 | cut -d ',' -f 1)

# prefetch
prefetch --max-size 100G ${sra}

# validate
vdb-validate ${sra}

# convert
fasterq-dump --split-files --include-technical --outdir reads/ ${sra}

# gzip
cd reads/
for i in $(ls ${sra}*.fastq)
do
  gzip ${i}
done