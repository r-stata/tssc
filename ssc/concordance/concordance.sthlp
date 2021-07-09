{smcl}
{* *! version 0.1.0  07may2018}{...}
{vieweralsosee "[D] merge" "help merge"}{...}
{viewerjumpto "Syntax" "concordance##syntax"}{...}
{viewerjumpto "Description" "concordance##description"}{...}
{viewerjumpto "Examples" "concordance##examples"}{...}
{title:Title}

{phang}
{bf:concordance} {hline 2} harmonize classification codes


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{opt conc:ordance} {varlist} 


{marker description}{...}
{title:Description}

{pstd}
{cmd:concordance} provides an algorithm for concording industrial classification codes consistently over time.{p_end}
{pstd}
It is similar to Pierce and Schott (2012), {p_end}
{pstd}
but implemented as a Stata command that internally calls Java programs relying {p_end}
{pstd}on a graph algorithm developed by Sedgewick and Wayne(2011).{p_end}
{pstd}{p_end}

{pstd}
{cmd:concordance} requires exactly three variables: oldcode, newcode and year (of replacement).{p_end}
{pstd}Those variables provide all existing replacements between old and new codes together with the year of the replacement. {p_end}
{pstd}Format of oldcode/newcode can be numeric or string, but must be convertable to a positive{p_end}
{pstd}number that contains up to 18 digits (no blanks or special characters).{p_end}
{pstd}Dateformat of year: can be yyyy, yyyymm or yyyymmdd{p_end}

{pstd}
{cmd:concordance} groups together all old and new codes that are related through different replacements over time, assigns them a common group code{p_end}
{pstd}
and generates an output file with four variables:{p_end}
{pstd}
productcode: contains all single old and new codes{p_end}
{pstd}
groupcode: respective common group codes {p_end}
{pstd}
year: the year when this productcode first appears in the concordance file{p_end}
{pstd}
endyear: 0 if productcode is still active, or  
			date if productcode has been replaced{p_end}

{pstd}
Data on product-level with changing codes over time{p_end}
{pstd}can now be merged with the resulting output file to allocate a{p_end}
{pstd}common groupcode to all concatenated product codes. See {bf:{help merge:[D] merge}}.


{marker remarks}{...}
{title:Remarks}

{pstd}
concordance.jar and concordance.ado must be installed in the user’s ado/plus directory.{p_end}
{pstd}concordance.jar is released under the {browse "http://www.gnu.org/copyleft/gpl.html": GNU General Public License, version 3}{p_end}
{pstd}and available for download: {browse "https://github.com/belln1/Concordance"}.{p_end}
{pstd}Use dataset testSet.csv to test concordance.ado.{p_end}


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. insheet oldcode newcode year using "testSet.csv", clear delimiter(;)}{p_end}

{pstd}Perform harmonization{p_end}
{phang2}{cmd:. concordance oldcode newcode year}{p_end}

    {hline}

	
{marker citation}{...}
{title:Citation of concordance}

{pstd}
{cmd:concordance} is a user-written command provided to the research community.{p_end}
{pstd}Please cite the following paper if you refer to the command:{p_end}
{pstd}Bellert, N., Fauceglia, D. 2019.{p_end}
{pstd}A practical routine to harmonize product classifications over time (Working Paper){p_end}
	
	
{marker authors}{...}
{title:Authors}

{pstd}
Bellert, N., Fauceglia, D.{p_end}
{pstd}


{marker references}{...}
{title:References}

{pstd}
Pierce, J. R. and Schott, P. K, 2012. Concording US Harmonized System Codes
over Time.{p_end}
{pstd}Journal of Official Statistics 2012, 28(1): 53–68.{p_end}

{pstd}
Sedgewick, R. and Wayne, K. 2011. {it:Algorithms.} Massachusetts: Pearson Education.{p_end}





