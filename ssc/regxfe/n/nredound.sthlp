{smcl}
{* *! version 1.0  Aug2014}{...}
{cmd:help nredound}{right: ({browse "http://www.stata-journal.com/article.html?article=st0409":SJ15-3: st0409})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{cmd:nredound} {hline 2}}Estimate the number of redundant parameters within the specified list of fixed effects{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:nredound} {varlist} {ifin} 


{marker description}{...}
{title:Description}

{pstd}
{cmd:nredound} uses an algorithm based on the one described in Abowd, Creecy, and
Kramarz (2002) to calculate the number of redundant parameters within the
specified list of categorical variables in {varlist}.


{title:Remarks}

{pstd}
The program uses the commands {helpb a2group}, {helpb tuples}, and 
{helpb distinct}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. webuse nlswork}{p_end} 
{phang}{cmd:. nredound ind_code occ_code idcode year}{p_end}

{phang}{cmd:. nredound ind_code occ_code idcode year if age>15}{p_end}


{title:Stored results}

{pstd}
{cmd:nredound} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(M)}}the number of redundant parameters{p_end}


{title:Reference}

{phang}
Abowd, J. M., R. H. Creecy, and F. Kramarz. 2002. Computing person and
firm effects using linked longitudinal employer-employee data.
Technical Paper No. TP-2002-06, Center for Economic Studies, U.S. Census
Bureau. {browse "http://www2.census.gov/ces/tp/tp-2002-06.pdf"}.


{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{marker also_see}{...}
{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=st0409":st0409}{p_end}
