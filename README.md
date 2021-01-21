# General formatting scripts
#### Author: Richard J. Bankoff, Ph.D.
## Introduction
This repostiory contains a number of (mostly perl) scripts for formatting various kinds of bioinformatic data.

## NextoNuc_2.pl
A script to convert a list of Nexus formatted genomic data files into .Nuc formatted data files 
for running Phylogenetic Analysis by Maximum Likelihood (PAML) analyses. This script assumes one of the sequences
in each file is named the same, and that that sequence will be used as a reference in further analyses.

### Syntax 
~~~~~~~~~~~~~~~~~~~~~
perl NexttoNuc_2.pl [name of text file containing newline-delimited list of Nexus formatted files]
~~~~~~~~~~~~~~~~~~~~~

.Nuc outputs will be in the working directory with the stem name of the Nexus formatted file of origin concatenated
to a ".nuc" suffix.

### IMPORTANT NOTE
On line 97, there is a hard-coded name of a taxon ("Emulti") which the script will search for in 
order to bring to the top of the reconstituted .Nuc files. This variable should be changed to reflect the name of 
your reference sequence.
