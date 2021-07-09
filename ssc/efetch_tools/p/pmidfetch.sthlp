{smcl}
{* *! 1.0  30Jan2012}{...}
{vieweralsosee "[P] viewsource" "mansection P viewsource"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] genefetch" "help genefetch"}{...}
{vieweralsosee "[R] pmidfetch" "help snpfetch"}{...}
{viewerjumpto "Syntax" "pmidfetch##syntax"}{...}
{viewerjumpto "Description" "pmidfetch##description"}{...}
{viewerjumpto "Usage" "pmidfetch##usage"}{...}
{cmd:help pmidfetch}{right: (version 1.0) }
Daniel Elwood Cook {Danielecook@gmail.com} {right: www.Elwoodcook.com}
{hline}

{pstd}
{bf:pmidfetch}{hline 2} {bf: Retreive publication information from Pubmed for a set of PMIDs (Pubmed Identifier). The following information is retrieved:}

{col 10}Title
{col 10}Volume
{col 10}Issue
{col 10}Page
{col 10}Date
{col 10}Affiliation
{col 10}Abstract (upto 244 characters)
{col 10}Authors (upto 244 characters)
{col 10}Mesh Terms (upto 244 characters)

{marker syntax}{...}
{title:Syntax}

{phang}
{cmd:pmidfetch} 
pmid_list
{it:, bundle(integer)}

{marker description}{...}
{title:Description}

{pstd}
{cmd:pmidfetch} uses the efetch utilities provided by the NCBI (National Center for Biotechnology Information) to retrieve information for a given list of PMIDs (Pubmed Identifiers). 

{pstd}
	You should use {cmd:pmidfetch} for data management/retrieval purposes primarily. It creates several variables with set names and fills them with data. It will {bf:overwrite} pre-existing data in these variables (example: Gene_ID, Chr_ID, Alleles).

{pstd}
	Ideally, you'll use this plugin to annotate a dataset you have by running it on only the set of snps from the set and merging or by taking care with the names of the variables in your set.
	
{pstd}
	One thing you might try: {cmd:pmidfetch} downloads the MeSH terms (MeSH = Medical Subject Headings) and authors for a given publication. 
	
{pstd}
	You can use the {cmd:{help strmatch}} function to identify authors or to classify publications by subject.

{pstd}
	{cmd:pmidfetch} can handle duplicates.

{marker usage}{...}
{title:Usage}

{pstd}
	Follow the command with the name of a variable specifying a list of SNPs. Your list can be numeric, ignoring the rs prefix, or a string with or without the rs prefix. {cmd: pmidfetch} will work with both and download a large amount of data for each set.

{pstd}
	The option {bf: bundle} can be used to adjust how many records Stata will attempt to download at once.{cmd: pmidfetch} works by downloading a set of records for your list of snps, parsing each set out, add the data to your dataset, and move onto the next set. This was necessary due to string length limitations within Stata.
{pstd}

