{smcl}
{* *! version 1.1.1 20jan2013}{...}
{viewerjumpto "Syntax" "dftol##syntax"}{...}
{viewerjumpto "Description" "dftol##description"}{...}
{viewerjumpto "Remarks" "dftol##remarks"}{...}
{viewerjumpto "Options" "dftol##options"}{...}
{viewerjumpto "Examples" "dftol##examples"}{...}
{viewerjumpto "Saved results" "dftol##savedresults"}{...}
{viewerjumpto "Author" "dftol##author"}{...}
{viewerjumpto "References" "dftol##references"}{...}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col:{hi:dftol} {hline 2}}Distribution-free tolerance intervals{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd:dftol} {help varname} {ifin} {cmd:,} [{opt c:onf(#)} {opt b:eta(#)} {opt r:lower} {opt d:etail}]

{synoptset 12 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt c:onf(#)}}set confidence level of the tolerance interval; default is {cmd:conf(95)}{p_end}
{synopt:{opt b:eta(#)}}set percentage of the population covered by the tolerance interval; default is {cmd:beta(95)}{p_end}
{synopt:{opt r:lower}}control how an odd number of blocks is removed{p_end}
{synopt:{opt d:etail}}display additional information{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:dftol} computes distribution-free tolerance intervals for {it:varname} following the method proposed by Murphy (1948).{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:dftol} requires that the Stata module -moremata- (Jann, 2005) be installed.{p_end}

{marker options}{...}
{title:Options}

{phang}
{opt conf(#)} specifies the confidence level of the tolerance interval as a percentage. The default is {cmd:conf(95)}, meaning a 95% confidence level.

{phang}
{opt beta(#)} specifies the percentage of the sampled population to be contained in the tolerance interval. The default is {cmd:beta(95)}, meaning a percentage equal to 95%.

{phang}
{opt rlower} specifies the way the blocks are removed from the left and right ends of the ordered sample, when an odd number of blocks is to be
 removed. Denoting by {it:r} the number of blocks, if {it:r} is an odd number and this option is used, then ({it:r}-1)/2 and ({it:r}+1)/2 blocks
 are removed from the left and right ends, respectively. If {it:r} is an even number this option has no effect and exactly the same number of blocks
 are removed from each end (see Hahn and Meeker, 1991). To better understand the name chosen for the option, note that when only one block is removed
 ({it:r}=1) the result is a lower bound (i.e., a tolerance interval whose right limit is infinity) if the option is used, and an upper bound (i.e., a
 tolerance interval whose left limit is minus infinity) if the option is not used.

{phang}
{opt detail} displays auxiliary information. The following items are printed: a) Index(es) of the observation(s) defining the  interval, b) number of blocks
 removed and c) actual confidence level. Note that even is this option is not used, the information is always saved and may be recovered from the saved results
 (see below and also {manhelp return P}).
 
{marker examples}{...}
{title:Examples} 

{cmd: . sysuse auto}
{cmd: . dftol price}
{cmd: . dftol price, c(99) b(99)}
{cmd: . dftol price, b(90)}
{cmd: . dftol price, b(90) nulower}
{cmd: . dftol price, detail}

{marker savedresults}{...}
{title:Saved results}

{cmd:dftol} saves the following in {cmd:r()}:

Scalars

{p2colset 5 20 24 2}{...}
{p2col:{cmd:r(lower)}}lower limit of the tolerance interval (omitted if exactly one block is removed without {cmd:rlower}){p_end}
{p2col:{cmd:r(indexlower)}}index of the observation of the ordered sample giving the lower limit of the tolerance interval
 (omitted if exactly one block is removed without {cmd:rlower}){p_end}
{p2col:{cmd:r(upper)}}upper limit of the tolerance interval (omitted if exactly one block is removed with {cmd:rlower}){p_end}
{p2col:{cmd:r(indexupper)}}index of the observation of the ordered sample giving the upper limit of the tolerance interval
 (omitted if exactly one block is removed with {cmd:rlower}){p_end}
{p2col:{cmd:r(removed)}}number of blocks removed{p_end}
{p2col:{cmd:r(actualconf)}}actual confidence level of the tolerance interval{p_end}
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
Hahn G and Meeker WQ (1991), {it:Statistical Intervals}, New York: Wiley & Sons

{phang}
Jann B (2005), {it:moremata: Stata module (Mata) to provide various functions}, available from {browse "http://ideas.repec.org/c/boc/bocode/s455001.html"}

{phang}
Murphy RB (1948), Non-parametric tolerance limits, {it:Annals of Mathematical Statistics}, 19: 581-589
