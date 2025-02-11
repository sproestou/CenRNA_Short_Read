# Re-Mapping of Previous Short Read Srequencing Data for CHM13 - RNA-Seq and PRO-Seq

## PRO-Seq - nascent RNA transcription

### Previous Methods and Analysis:
- CHM13 PRO-seq (Precision Run-On sequencing) Bowtie2 alignments to CHM13v2.0 (minus chrY) and unique genome-wide 21mer filtering (stranded)
- PRO-seq detects nascent transcription (including from non-coding) from RNA polymerases with nucleotide resolution at genome-scale.
- The PRO-seq experiment was done on CHM13 cells (in duplicate, A and B) and sequenced from the 3' end for 75bp single-ended reads. Reads were adapter trimmed, quality filtered (-q 20), and length filtered (-m 20) with Cutadapt (v2.7). Trimmed reads were then reverse complemented since they were sequenced in the 3'-->5' direction. D. melanogaster spike-ins were removed with Bowtie2 (v2.3.5.1) and samtools view -f 4 (v1.9). Reads were then mapped with either Bowtie2 (v2.3.5.1) default or -k 100 (allowing up to 100 multi-mappers). Unique genome-wide 21mers were generated through Meryl (https://github.com/marbl/meryl). The reads mapped with -k 100 were filtered with these unique genome-wide 21mers through one of two methods:
	1) Locus-specific unique genome-wide 21mer filtering (overlapSelect -overlapBases=21; UCSC tools (GenomeBrowser/20180626)) 
	2) Read- and locus-specific unique genome-wide 21mer filtering (https://github.com/arangrhie/T2T-Polish/tree/master/marker_assisted, overlapSelect -overlapBases=21) 

Data: BioProject Number PRJNA559484 NCBI accession number is SRR15035502

- Data is apparently available via NCBI SRA toolkit, which I tried to configure on my local computer, but that did not work so I attempted to download the raw fastq files here locally...I'm hoping they are adapter tirmmed?

Replicate 1: s3://sra-pub-src-15/SRR15035502/CHM13-5B_proseq.fastq.gz.1

### New Analysis
- Will run with BWA mem with centromere argument allowing for approx. 1 million multi-maps and filter for MAPQ > 1...
	- Note there is no need for splice aware alignment here because the transcripts should be nascent/unprocessed


## RNA-Seq

Previous Methods and Analysis:
- CHM13 RNA-seq Bowtie2 alignments to CHM13v2.0 (minus chrY) and unique genome-wide 21mer filtering (unstranded)
- Poly-A+ RNA-seq was performed on CHM13 in duplicate (A and B) and sequenced with 150-bp paired-ended reads. Reads were adapter trimmed, quality filtered (-q 20), and length filtered (-m 100) with Cutadapt (v2.7). Reads were then mapped with either Bowtie2 (v2.3.5.1) default or -k 100 (allowing up to 100 multi-mappers) and then filtered with samtools view F1548. Unique genome-wide 21mers were generated through Meryl (https://github.com/marbl/meryl). The reads mapped with -k 100 were filtered with these unique genome-wide 21mers through one of two methods:
	1) Locus-specific unique genome-wide 21mer filtering (overlapSelect -overlapBases=21; UCSC tools (GenomeBrowser/20180626))
    	2) Read- and locus-specific unique genome-wide 21mer filtering ( https://github.com/arangrhie/T2T-Polish/tree/master/marker_assisted overlapSelect -overlapBases=21)
- Contains 2 Replicates

Data: NCBI BioProject PRJNA559484

Replicate 1: 
- s3://sra-pub-src-18/SRR15054302/CHM13_1_S182_L002_R1_001.fastq.gz.1
- s3://sra-pub-src-18/SRR15054302/CHM13_1_S182_L002_R2_001.fastq.gz.1

	- Post fasterq-dump output:
		spots read      : 90,930,105
		reads read      : 181,860,210
		reads written   : 181,860,210
	- outupt files are both 33G which is kinda weird and that's the same as before...
Replicate 2: 
- s3://sra-pub-src-17/SRR15054301/CHM13_2_S183_L002_R1_001.fastq.gz.1
- s3://sra-pub-src-17/SRR15054301/CHM13_2_S183_L002_R2_001.fastq.gz.1

### New Analysis
- Attempt BWA MEM alignment as done above
- Additionally attempt using a splice aware aligner, perhaps STAR (kallisto is not good for repeat elements I don't think...?)
- Have both allow for many multi maps and filter for MAPQ > 1

1) Try alignment with BWA MEM (no splicing, allow for 1 million multi maps) --> directly fitler out unmapped (flag 4) --> see what it keeps --> then filter for mapq >1 and look at depth in centromeric regions
2) try alignment with star aligner (allows for splicing)