{smcl}
{* 23Jul2009}{...}
{cmd: help clump}
{hline}

{title:Title}

{hi: Genetic association for chromosome data using a permutation test}

{title:Syntax}

{p 8 17 2}
{cmdab:clump}
[{varlist}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt lrchi2}} specifies whether to use the likelihood ratio test.{p_end}
{synopt:{opt noi:se}} specifies .{p_end}
{synopt:{opt maxiter}} specifies the maximum number of iterations.{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
Note: the first variable is the case/control variable that has to be
binary. The next pair of variables are the pairs of alleles at the marker
in question. A line of data represents one subject.

{title:Description}

{pstd} This program assesses the significance of the departure of observed values in a 
contingency table from the expected values conditional on the marginal totals. The present 
implementation works on {hi:2 x N} tables and was designed for use in genetic case-control association 
studies, but the program should be useful for any {hi: 2 x N} contingency table, especially where 
{hi: N} is 
large and the table is sparse. The significance is assessed using a Monte Carlo approach, 
by performing repeated simulations to generate tables having the same marginal totals 
as the one under consideration, and counting the number of times that a chi-squared value 
associated with the real table is achieved by the randomly simulated data. This means that 
the significance levels assigned should be unbiased (with accuracy dependent on the number 
of simulations performed) and that no special account needs to be taken of continuity corrections 
or small expected values. 

{pstd}The method is described in full in:  Sham PC & Curtis D. 1995. Monte Carlo tests for 
associations between disease and alleles at highly polymorphic loci. {it: Ann Hum Genet.} 
{bf:59}: 97-105. 

{title:Options}
{dlgtab:Main}

{phang}
{opt lrchi2} specifies use of the likelihood ratio test on the 2 by 2 table.
If a table contains a 0 cell the test statistic is missing.

{phang}
{opt noi:se} displays chi-squared tables on original data

{phang}
{opt maxiter(#)} max iterations for the permutation test 

{title:Examples}

{pstd}
{inp:. clump cc a1628 b1628, noi maxiter(200) lrchi2}

{title:Author}
{pstd}
Adrian Mander, MRC Biostatistics Unit, Cambridge, UK.{p_end}
{pstd}
Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}

{title:Also see}

{pstd}
Related commands

{pstd}
HELP FILES {space 13}SSC installation links{space 4}Description

{pstd}
{help gipf} (if installed){space 5}({stata ssc install gipf}){space 8}Graphical representation of a log-linear model {p_end}
{pstd}
{help hapipf} (if installed){space 3}({stata ssc install hapipf}){space 6}Haplotype frequency estimation using log-linear models {p_end}
