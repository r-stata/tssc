{smcl}
{* *! version 1.0  9 May 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install tabstat2excel" "ssc install tabstat2excel"}{...}
{vieweralsosee "Help tabstat2excel (if installed)" "help tabstat2excel"}{...}
{viewerjumpto "Syntax" "tabstat2excel##syntax"}{...}
{viewerjumpto "Description" "tabstat2excel##description"}{...}
{viewerjumpto "Options" "tabstat2excel##options"}{...}
{viewerjumpto "Remarks" "tabstat2excel##remarks"}{...}
{viewerjumpto "Examples" "tabstat2excel##examples"}{...}
{title:Title}
{phang}
{bf:tabstat2excel} {hline 2} Export summary statistics generated from a tabstat command to an Excel spreadsheet

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:tabstat2excel}
{varlist}
{ifin}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt filename(string)}}
specify file name without the .xlsx extension
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:tabstat2excel} exports summary statistics (n, mean, median, min, and max) for a numeric variable or several numeric variables with variable labels to an Excel file. 


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}Export summary statistics of {cmd:price} and {cmd:weight} to an Excel file named 'summary'{p_end}
{phang2}{cmd:. tabstat2excel price weight, filename(summary)}{p_end}

{pstd}Export summary statistics of {cmd:price} and {cmd:weight} for domestic cars{p_end}
{phang2}{cmd:. tabstat2excel price weight if foreign == 0, filename(summary)}{p_end}


{title:Authors}
{pstd} 	Sara Ansari			<saraansari1007@gmail.com>	{p_end}
{pstd}	Kabira Namit			<knamit@worldbank.org> 		{p_end}
{pstd}	Jonathan Seiden			<jseiden@savechildren.org>	
{p_end}

