#!/bin/bash

#BSUB -J Short_Read__BWA           # job name
#BSUB -o Short_Read_BWA_RNA_Seq.%J.out     # Name of the job output file
#BSUB -e Short_Read_BWA_RNA_Seq.%J.error   # Name of the job error file   
#BSUB -R "rusage[mem=16GB]" #spefies the amount of memory requested
#BSUB -M 16GB #kill job if over this much memory
#BSUB -W 24:00 
# if you want to receive e-mail notifications on a non-default address
#BSUB -u hadjipas@pennmedicine.upenn.edu
### -- send notification at start --
#BSUB -B
### -- send notification at completion --
#BSUB -N

set -euo pipefail

#Savana Hadjipanteli
#Febuary 2, 2025
#Objective: Align previous short read CHM13 data (specifically PRO-Seq for this protocol) to CHM13 genome using bwa mem alignment

#RUN: bsub -n 24 < BWA_align.sh #assume this will run in less than one day so no need to put it in epistasis_long and change min run time, currently ahve the memory set for 16GB, which may be overkill but is what I used for alignmnt with pacbio

#Feb 11, 2025
#Attempting to run this on RNA-seq data --> will eventually need to run with a splice aware aligner, but given some of the reads we got are unspliced, I think attempting this is worthwhile...
#changing the current directory to RNA seq folder, so converted all reference file paths to absolute paths
#I also moved this entire folder to a project folder that's just my name, I'm going to convert things over here with time, so be vigilant about path names

#input variables
#path to reference fasta
ref="/project/logsdon_shared/projects/CenRNA/ONT-Seq/ref/T2T-CHM13v2.fasta"
#path to reference bwa index file
index="/project/logsdon_shared/projects/Savana/Short-Read/CHM13_PRO-Seq/CHM13_index/T2T-CHM13v2"
#list input files (separated by spaces)
#here these are the two replicates of PRO-seq data, starting with one first...still need to upload the other
files='SRR15054301_1.fastq SRR15054301_2.fastq SRR15054302_1.fastq SRR15054302_2.fastq'
out="CHM13_RNA-Seq_bwa_aln.bam"

###########CREATED CONDA ENVIRONMENT FOR BWA

#conda create -n bwa
#conda install bioconda::bwa
#conda install bioconda::samtools

#bwa is version 0.7.18, samtools is 1.21
#####################
cd /project/logsdon_shared/projects/Savana/Short-Read/CHM13_RNA-Seq

#activate conda environment
source activate bwa

#First: index CHM13 for bwa --> ran interactively: bsub -I -q epistasis_interactive

#bwa index -p T2T-CHM13v2 -a bwtsw "$ref"


##Second: align, allowing for many multi-mappers -c sets reads with greater than 1 million maps to be thrown out, default is like 10000?

#glennis' example alignment included: bwa mem -t 24 -k 50 -c 1000000 options, I removed -k and allowed their default option (19) because 50 felt kind of long? (this is for seed sequence when searching) --> changed it to 35
#For RNA seq data changed k back to 50 (from 35)... since reads are longer (150)
bwa mem -t 24 -k 50 -c 1000000 "$index" $files | samtools view -bS -F 4 | samtools sort -m 8G -T tmp1 -o "$out"
samtools view -bS -q 1 "$out" > "${out%.*}_q1.bam"
echo "Alignment of $files completed with $(samtools view -c $out) reads"
#-F 2308 excludes alignments thate are unmapped, not primary alignments, or not secondary alingnments
#we need to add a filter for alignments with mapQ greater than 1 use -q 1...I feel like we should keep secondary alignments and just exclude unmapped so we'll use flag -F4
#do alignments for both replicates at once

#index output bam
samtools index "${out%.*}_q1.bam"
echo "Index of aligned bam created"

conda deactivate

source activate bed
#generate bedgraph
bedtools genomecov -ibam "${out%.*}_q1.bam" -bga > "${out%.*}_q1_bedgraph.bed"
#no split bc the alignments weren't splice aware
echo "Bedgraph generated..."

conda deactivate




