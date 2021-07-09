{smcl}
{* *! version 1.1.1 20jan2013}{...}
{vieweralsosee "dftol" "help dftol"}{...}
{viewerjumpto "Syntax" "dftolss##syntax"}{...}
{viewerjumpto "Description" "dftolss##description"}{...}
{viewerjumpto "Remarks" "dftolss##remarks"}{...}
{viewerjumpto "Options" "dftolss##options"}{...}
{viewerjumpto "Examples" "dftolss##examples"}{...}
{viewerjumpto "Saved results" "dftolss##savedresults"}{...}
{viewerjumpto "Author" "dftolss##author"}{...}
{viewerjumpto "References" "dftolss##references"}{...}

{title:Title}

{p2colset 6 17 21 2}{...}
{p2col:{hi:dftolss} {hline 2}}Sample size calculation for distribution-free tolerance intervals{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd:dftolss} {cmd:,} [{opt c:onf(#)} {opt b:eta(#)} {opt r(#)}]

{synoptset 12 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt c:onf(#)}}set confidence level of the tolerance interval; default is {cmd:conf(95)}{p_end}
{synopt:{opt b:eta(#)}}set percentage of the population covered by the tolerance interval; default is {cmd:beta(95)}{p_end}
{synopt:{opt r(#)}}set the number of blocks removed; default is {cmd:r(2)}{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:dftolss} computes the smallest sample size for the tolerance intervals obtained removing {cmd:r(#)} blocks to contain, at confidence level {cmd:conf(#)%},
 at least a percentage {cmd:beta(#)%} of the sampled population. See also {help dftol}.{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:dftolss} requires that the Stata module -moremata- (Jann, 2005) be installed.{p_end}

{marker options}{...}
{title:Options}

{phang}
{opt conf(#)} specifies the confidence level of the tolerance interval as a percentage. The default is {cmd:conf(95)}, meaning a 95% confidence level.

{phang}
{opt beta(#)} specifies the percentage of the sampled population to be contained in the tolerance interval. The default is {cmd:beta(95)}, meaning a percentage equal to 95%.

{phang}
{opt r(#)} specifies the number of blocks removed. The default is {cmd:r(2)}, which, according to the definition of block (see Murphy, 1948) means that
 the endpoints of the tolerance interval would be the smallest and largest observations of the sample. Note that for {cmd:r(1)}, i.e. when only one
 block is removed, the interval reduces to a one-sided lower (alternatively, upper) tolerance bound.

{marker examples}{...}
{title:Examples} 

{cmd: . dftolss}
{cmd: . dftolss, c(90) b(90)}
{cmd: . dftolss, c(99) b(99) r(4)}

{marker savedresults}{...}
{title:Saved results}

{cmd:dftolss} saves the following in {cmd:r()}:

Scalars

{p2colset 5 20 22 2}{...}
{p2col:{cmd:r(n)}}sample size){p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{pstd}Ignacio López de Ullibarri{p_end}
{pstd}Department of Mathematics{p_end}
{pstd}University of A Coruña, Spain{p_end}
{pstd}E-mail: {browse "mailto:ilu@udc.es":ilu@udc.es}{p_end}

{marker references}{...}
{title:References}

{phang}
Jann B (2005), {it:moremata: Stata module (Mata) to provide various functions}, available from {browse "http://ideas.repec.org/c/boc/bocode/s455001.html"}

{phang}
Murphy RB (1948), Non-parametric tolerance limits, {it:Annals of Mathematical Statistics}, 19: 581-589
