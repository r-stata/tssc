{smcl}
{* *! version 0.1 beta  17 Dec 2012}{...}
{cmd:help vcf}{right: (version 1.0) }
By Daniel E. Cook {Danielecook@gmail.com} {right: www.Danielecook.com}
{hline}
{title:vcf}

{p 5 12 20}{cmd:vcf} {hline 2} Used to import VCF (Variant Caller Format) Files into Stata and format genotype data.{p_end}

{p 5 5 20}This program does 2 challenging things:{p_end}

{p 5 5 20}(1) Splits the INFO column (delimited by ;) into seperate columns. It also pulls out variable descriptions and assigns them as variable labels.{p_end}

{p 5 5 20}(2) Recodes genotypic data, showing the genotypes of each individual.{p_end}

{p 5 5 20} {cmd:Important!} This is a new release, as such it is still undergoing development. Please report any issues/errors/comments/suggests (email above).

{p2colreset}{...}

{title:Syntax}

{p 5 16 2 200}
{cmd:vcf using "path/to/file.vcf"}

{title:Limits}

{p 5 5 20}(1) While it is possible to read in very large files - this program cannot handle enormous VCF Files. I have successfully loaded in files that are a few gigabytes.

{p 5 5 20}(2) If your VCF Files has more than 9 alternative alleles, this program will incorrectly assign alleles beyond the 9th alternative allele.

{it: Initial Release} - 12/17/12


