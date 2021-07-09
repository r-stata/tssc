{smcl}
{* *! 1.2  15Feb2012}{...}
{vieweralsosee "[R] genefetch" "help snpfetch"}{...}
{vieweralsosee "[R] pmidfetch" "help pmidfetch"}{...}
{viewerjumpto "Syntax" "genefetch##syntax"}{...}
{viewerjumpto "Description" "genefetch##description"}{...}
{viewerjumpto "Usage" "genefetch##usage"}{...}
{cmd:help genefetch}{right: (version 1.2) }
Daniel Elwood Cook {Danielecook@gmail.com} {right: www.Elwoodcook.com}
{hline}

{pstd}
{bf:genefetch} {hline 2} {bf: Retreive information from Pub Med for a set of Entrez Gene id's or Gene Names. The following information is retrieved:}

{col 10}Gene Name
{col 10}Gene ID
{col 10}Full Name
{col 10}Species
{col 10}Location
{col 10}From (start bp)
{col 10}To (end bp)
{col 10}Chromosome

{marker syntax}{...}
{title:Syntax}

{phang}
{cmd:genefetch} 
Gene_Names_OR_IDs
{it:, bundle(integer)}
{it:organism(string)}

{marker description}{...}
{title:Description}

{pstd}
{cmd:genefetch} uses the efetch utilities provided by the NCBI (National Center for Biotechnology Information) to retrieve information for a given list of Gene ID's or Gene Names (Single Nucleotide Polymorphims). 

{pstd}
	You should use {cmd:genefetch} for data management/retrieval purposes primarily. It creates several variables with set names and fills them with data. It will {bf:overwrite} pre-existing data in these variables (example: Gene_ID, Chr_ID).

{pstd}
	Ideally, you'll use this plugin to annotate a dataset you have by running it on only the set of snps from the set and merging or by taking care with the names of the variables in your set.

{pstd}
	{cmd:genefetch} can handle duplicates.

{marker usage}{...}
{title:Usage}

{bf: Method 1: Providing Gene Names}

{pstd}
	There are two ways to use {cmd: genefetch}. One is to provide a list of gene names. If you do this, {cmd: genefetch} will retrieve gene id's by performing searches on Pubmed's gene database and retrieving the top result.

{pstd}
	{bf:(!Important!)} This method has the potential to retrieve incorrect information. However, as long as you use the HGNC approved symbol for your gene, {cmd: genefetch} should always retrieve the correct record.

{pstd}
	{bf:(!Important!)} If you do provide a list of Gene Names and are working with a species other than homo sapiens, you {bf: must} use the {bf:organism} option, specifying the taxonomic name (e.g. Mus musculus, Rattus norvegicus, Nomascus leucogenys). If you do not specify an organism, it is set to {it:homo sapien}.

{pstd}
	I would recommend using a variable named {bf: gene} containing a list of Gene names when using this method. This variable will remain intact when Gene information is retrieved and you can compare the {cmd:Gene} and {cmd:Gene_Name} variables to ensure that the correct record has been retrieved.

{bf: Method 2: Providing a list of Gene IDs}

{pstd}
	The second way to use {cmd:genefetch} is to provide it with a list of Entrez Gene ID's. This method will always pull in the correct Gene information provided the id exists.

{pstd}
	Follow the command with the name of a variable specifying a list of SNPs. Your list can be numeric, ignoring the rs prefix, or a string with or without the rs prefix. {cmd: genefetch} will work with both and download a large amount of data for each set.

{pstd}
	The option {bf: bundle} can be used to adjust how many records Stata will attempt to download at once. {cmd: genefetch} works by downloading a set of records for your list of snps, parsing each set out, add the data to your dataset, and move onto the next set. This was necessary due to string length limitations within Stata.

