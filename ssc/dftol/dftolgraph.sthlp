{smcl}
{* *! version 1.1.1 20jan2013}{...}
{vieweralsosee "dftol" "help dftol"}{...}
{vieweralsosee "dftolss" "help dftolss"}{...}
{viewerjumpto "Syntax" "dftolgraph##syntax"}{...}
{viewerjumpto "Description" "dftolgraph##description"}{...}
{viewerjumpto "Options" "dftolgraph##options"}{...}
{viewerjumpto "Examples" "dftolgraph##examples"}{...}
{viewerjumpto "Author" "dftolgraph##author"}{...}
{viewerjumpto "References" "dftolgraph##references"}{...}

{title:Title}

{p2colset 5 19 23 2}{...}
{p2col:{hi:dftolgraph} {hline 2}}Graphs for distribution-free tolerance intervals{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd:dftolgraph} {cmd:,} [{opt c:onf(#)} {opth r(numlist)}]

{synoptset 12 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt c:onf(#)}}set confidence level of the tolerance interval; default is {cmd:conf(95)}{p_end}
{synopt:{opt r(numlist)}}set the number of blocks removed; default is {cmd:r(1 2 3 4 5 7 10 15 20 30 50 100 200 400)}{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:dftolgrah} produces graphs showing the relationship between sample size (from 10 up to 1000), number of blocks removed (<= 500), confidence
 level and percentage of the population contained in distribution-free tolerance intervals. The graphs displayed are similar in spirit to those
 shown in Murphy (1948) or Hahn and Meeker (1991). See also {help dftol} and {help dftolss}.{p_end}

{marker options}{...}
{title:Options}

{phang}
{opt conf(#)} specifies the confidence level of the tolerance interval as a percentage. The default is {cmd:conf(95)}, meaning a 95% confidence level.

{phang}
{opt r(numlist)} specifies the number of blocks removed. The default is {cmd:r(1 2 3 4 5 7 10 15 20 30 50 100 200 400)}. The maximal
 length of the {it:numlist} is 14 and the maximum allowable value of any component is 500.

{marker examples}{...}
{title:Examples} 

{cmd: . dftolgraph}
{cmd: . dftolgraph, c(90) r(5(20)85)}

{marker author}{...}
{title:Author}

{pstd}Ignacio López de Ullibarri{p_end}
{pstd}Department of Mathematics{p_end}
{pstd}University of A Coruña, Spain{p_end}
{pstd}E-mail: {browse "mailto:ilu@udc.es":ilu@udc.es}{p_end}

{marker references}{...}
{title:References}

{phang}
Hahn G and Meeker WQ (1991), {it:Statistical Intervals}, New York: Wiley & Sons

{phang}
Murphy RB (1948), Non-parametric tolerance limits, {it:Annals of Mathematical Statistics}, 19: 581-589
