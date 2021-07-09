{smcl}
{* *! 1.0  07Feb2012}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "pmidfetch##syntax"}{...}
{viewerjumpto "Description" "pmidfetch##description"}{...}
{viewerjumpto "Usage" "pmidfetch##usage"}{...}
{cmd:help dataplink}{right: (version 1.0) }
Daniel Elwood Cook {Danielecook@gmail.com} {right: www.Elwoodcook.com}
{hline}

{pstd}
{bf:dataplink} {hline 2} {bf: Import .ped and .map files from recoded, tab delimited, plink files into Stata}

{marker syntax}{...}
{title:Syntax}

{phang}
{cmd:dataplink} 
using {it: filename (Do not include .PED or .MAP)}

{marker description}{...}
{title:Description}

{p 5 5 10}
{cmd:dataplink} is a simple program for importing recoded data from plink. Dataplink imports genotypic from {bf:.ped} files and also imports variable names (snp names) from {bf:.map} files.

{p 5 5 10}
Data from plink must be exported using the following commands:

{col 10}--recode / --recode12
{col 10}--tab

{p 5 5 10} Once your data is exported from plink, you should have two files of the same name but with different extensions: {bf:.ped} and {bf:.map}.
The {bf:.ped} file contains genotype data while the {bf:.map} file contains the names of the SNPs.

{p 5 5 10}{bf:! Important:} When you specify the {it:filename} do not use extensions (i.e. do not add {bf:.ped} or {bf:.map}). Dataplink will look for
a .map and .ped file of the same name

{marker usage}{...}
{title:Usage}

{p 5 5 10}{bf:Example Input}
		
{p 10 5 10}dataplink using "C:/my/dir/chrom1segment"

{p 5 5 10}{bf:! Important:} Notice that the file extension {bf:.map} and {bf:.ped} are not included!

{p 5 5 10}{bf:! Important LIMIT:} Stata can import a maximum of 32,767 variables in SE and MP flavors and 2,047 in IC. This means you can only import ~32,000 SNPs and ~2,000 depending on your version.



