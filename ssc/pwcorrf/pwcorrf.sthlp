{smcl}
{* *! version 1.0.0  11july2016}{...}
{findalias asfradohelp}{...}
{title:pwcorrf}

{phang}
{bf:pwcorrf} {hline 2} Faster version of pwcorr, with builtin reshape option


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: pwcorrf}
{varlist}
[{cmd:,} {it:reshape full showt}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt reshape}}calculates correlations of a single variable across panel groups {p_end}
{synopt:{opt full}}forces full display of the correlation matrix{p_end}
{synopt:{opt showt}}displays the number of joint observations per pair{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:pwcorrf} calculates the pairwise correlations across {varlist}. It returns the same results as {cmd:pwcorr}. Specifying the reshape option allows you to calculate correlations of a single variable across panel units.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt reshape} reshapes your data wide, such that the correlation calculated is across panel groups, rather than across variables. Your data will be unaffected.

{phang}
{opt full} forces the program to show the full correlation matrix after execution. The default is to show the first 6x6 matrix of correlations.

{phang}
{opt showt} forces the program to show the matrix of the number of joint observations per pair. This matrix can always be assessed by calling r(T).
{marker remarks}{...}
{title:Remarks}

{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed information on the original command, see {helpb pwcorr}. {cmd:pwcorrf} is (usually) faster, but can only calculate the Pearson correlation.

{pstd}
The interpretation of the correlations calculated using reshape depends on the sort of data used. E.g. if your panel units are countries, they are spatial correlations.

{pstd}
Any mistakes are my own.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. pwcorrf mpg weight}{p_end}

{phang}{cmd:. pwcorrf mpg weight, full}{p_end}

{phang}{cmd:. xtset county quarter}{p_end}
{phang}{cmd:. pwcorrf gdp, reshape}{p_end}


{marker results}{...}
{title:Stored results}


{pstd}
{cmd:pwcorrf} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(C)}}correlation matrix{p_end}
{synopt:{cmd:r(T)}}number of joint observations per pair{p_end}
{p2colreset}{...}


{title:Author}
Jesse Wursten
Faculty of Economics and Business
KU Leuven
{browse "mailto:jesse.wursten@kuleuven.be":jesse.wursten@kuleuven.be} 
