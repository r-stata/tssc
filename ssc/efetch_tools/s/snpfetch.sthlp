{smcl}
{* *! 1.2  15Feb2012}{...}
{vieweralsosee "[R] genefetch" "help genefetch"}{...}
{vieweralsosee "[R] pmidfetch" "help pmidfetch"}{...}
{viewerjumpto "Syntax" "snpfetch##syntax"}{...}
{viewerjumpto "Description" "snpfetch##description"}{...}
{viewerjumpto "Usage" "snpfetch##usage"}{...}
{cmd:help snpfetch}{right: (version 1.2) }
Daniel Elwood Cook {Danielecook@gmail.com} {right: www.Elwoodcook.com}
{hline}

{pstd}
{bf:snpfetch}{hline 2} {bf: Retreive information from dbSNP for a set of SNP id's. The following information is retrieved:}

{col 10}Gene Name
{col 10}Gene ID
{col 10}Chromosome
{col 10}Base Pair Position
{col 10}Alleles
{col 10}Heterozygosity
{col 10}Locus type
{col 10}Orientation of Strand
{col 10}Species
{col 10}Validated SNP
{col 10}Minimum Probability
{col 10}Maximum Probability

{marker syntax}{...}
{title:Syntax}

{phang}
{cmd:snpfetch} 
rs_list
{it:, bundle(integer)}
{it:assembly(string)}

{marker description}{...}
{title:Description}

{pstd}
{cmd:snpfetch} uses the efetch utilities provided by the NCBI (National Center for Biotechnology Information) to retrieve information for a given list of SNPs (Single Nucleotide Polymorphims). 

{pstd}
	You should use {cmd:snpfetch} for data management/retrieval purposes primarily. It creates several variables with set names and fills them with data. It will {bf:overwrite} pre-existing data in these variables.

{pstd}
	(example: Gene_ID, Chr_ID, Alleles).

{pstd}
	Ideally, you'll use this plugin to annotate a dataset you have by running it on only the set of snps from the set and merging or by taking care with the names of the variables in your set.

{pstd}
	{cmd:snpfetch} can handle duplicates.



{marker usage}{...}
{title:Usage}

{pstd}
	Follow the command with the name of a variable specifying a list of SNPs. Your list can be numeric, ignoring the rs prefix, or a string with or without the rs prefix. 

{pstd}	
	{cmd: snpfetch} will work with both and download a large amount of data for each set.

{pstd}
	The option {bf: bundle} can be used to adjust how many records Stata will attempt to download at once. {cmd: snpfetch} works by downloading a set of records for your list of snps, parsing each set out, add the data to your dataset, and move onto the next set. This was necessary due to string length limitations within Stata.

{pstd}
	The option {bf: assembly} can be used to specify different reference assemblies to retrieve data from. If not specified, the assembly is set to "GRCh37.p5" (This is the latest human reference assemblies). 
	
{pstd}
	{bf: Important!} If you are retrieving data for organisms other than humans, you must specify the name of the assembly.

{pstd}
	For more information on assemblies, see: 
	
{pstd}
	GRCh37.p5 - http://www.ncbi.nlm.nih.gov/projects/genome/assembly/grc/human/
	
{pstd}HuRef - http://huref.jcvi.org/

