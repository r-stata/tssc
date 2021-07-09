{smcl}
{* *! version 1.1.4 24may2013}{...}
{viewerjumpto "Syntax" "landemets##syntax"}{...}
{viewerjumpto "Description" "landemets##description"}{...}
{viewerjumpto "Remarks" "landemets##remarks"}{...}
{viewerjumpto "Options" "landemets##options"}{...}
{viewerjumpto "Examples" "landemets##examples"}{...}
{viewerjumpto "Saved results" "landemets##savedresults"}{...}
{viewerjumpto "Author" "landemets##author"}{...}
{viewerjumpto "References" "landemets##references"}{...}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col:{hi:landemets} {hline 2}}Boundaries for group sequential clinical trials using alpha spending functions{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd:landemets} {cmd:,} [{help options}]

{synoptset 15 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt t(numlist)}}set monitoring times; default is {cmd:t(1)}{p_end}
{synopt:{opt a:lpha(numlist)}}set type I error probability(ies); default is {cmd:alpha(.05)}{p_end}
{synopt:{opt m:ethod(method)}}set the alpha spending function(s); default is {cmd:method(obf)}{p_end}
{synopt:{opt r:ho(numlist)}}set the parameter of alpha spending functions in the power family{p_end}
{synopt:{opt o:nesided}}control if one-sided boundaries are to be computed{p_end}
{synopt:{opt b:eta}}set total type II error probability(ies){p_end}
{synopt:{opt th:eta}}set standardized treatment difference (drift){p_end}
{synopt:{opt p:lot}}display a graph with the boundaries{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:landemets} computes boundaries for group sequential clinical trials using the method of Lan and DeMets (1983).{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:landemets} requires that the Stata module -moremata- (Jann, 2005) be installed.{p_end}

{marker examples}{...}
{title:Examples} 

{pstd}
Compute boundaries with the default options:{p_end}
{pmore}
{cmd:. landemets}{p_end}

{pstd}
Ten equally spaced monitoring times between 0.1 and 1:{p_end}
{pmore}
{cmd:. landemets, t(0.1(0.1)1)}{p_end}

{pstd}
The same, but plotting the boundaries:{p_end}
{pmore}
{cmd:. landemets, t(0.1(0.1)1) plot}{p_end}

{pstd}
Type I error probability set to 0.01, with a different choice of four, not equally spaced times:{p_end}
{pmore}
{cmd:. landemets, t(0.2 0.3 0.5 1) alpha(0.01)}{p_end}

{pstd}
The same, but using a Pocock type alpha spending function:{p_end}
{pmore}
{cmd:. landemets, t(0.2 0.3 0.5 1) alpha(0.01) method(poc)}{p_end}

{pstd}
One-sided boundaries using an alpha spending function in the power family, with parameter set to 1.5:{p_end}
{pmore}
{cmd:. landemets, t(0.2(0.2)1) method(pow) rho(1.5) onesided}{p_end}

{pstd}
Two-sided asymmetric boundaries; the total type I error probability, 0.05, is divided in 0.04 and 0.01 for the lower and 
 upper boundaries, respectively; an O'Brien-Fleming type alpha spending function is used for both boundaries:{p_end}
{pmore}
{cmd:. landemets, t(0.2(0.2)1) alpha(0.04, 0.01) method(obf obf)}{p_end}

{pstd}
Two-sided asymmetric boundaries; the total type I error probability, 0.05, is equally divided between the lower and upper 
 boundaries, but different alpha spending functions are used for each boundary (lower: power family, with rho = 2, upper:
 O'Brien-Fleming type):{p_end}
{pmore}
{cmd:. landemets, t(0.2(0.2)1) alpha(0.025, 0.025) method(pow obf) rho(2)}{p_end}

{pstd}
Besides the boundaries for a total type I error probability equal to 0.05 (using default options), computation of the
 standardized treatment differences (drifts) for total type II error probabilities equal to 0.1 and 0.2, respectively:{p_end}
{pmore}
{cmd:. landemets, beta(0.1 0.2)}{p_end}

{pstd}
Besides the boundaries for a total type I error probability equal to 0.05 (using default options), computation of the
 total type II error probabilities for standardized treatment differences (drifts) equal to 1, 1.5 and 2, respectively:{p_end}
{pmore}
{cmd:. landemets, theta(1 1.5 2)}{p_end}

{marker options}{...}
{title:Options}

{phang}
{opt t(numlist)} specifies the times at which analyses are to be performed. They must be contained in (0,1], and the maximum
 value should be 1. The default is {cmd:t(1)}, meaning no interim analyses.

{phang}
{opt alpha(numlist)} specifies the type I error probability. The {it:numlist} may be of length one or two. If it has only one
 value, two-sided (symmetric) or one-sided stopping boundaries for a type I error probability equal to that value are computed 
 (whether two-sided or one-sided boundaries are computed is controlled by the {opt onesided} option; see below). If the length 
 of {it:numlist} is two, its components give the type I error probability for, respectively, the lower and upper boundaries. Thus,
 if the two alpha values or the alpha spending function used for each boundary are different (see the {opt method} option below), 
 asymmetric two-sided boundaries are obtained. The default is {cmd:alpha(0.05)}.

{phang}
{opt method(method)} specifies the alpha spending function(s) to be used. The accepted arguments are:{p_end}
{phang2}
a) one of {cmd:obf} (O'Brien-Fleming type), {cmd:poc} (Pocock type), or {cmd:pow} (power family). This is the way to specify the 
 alpha spending function for symmetric two-sided or one-sided boundaries. When the method is thus specified, the argument of the
 {opt alpha} option must be of length one.{p_end}
{phang2}
b) any two (possibly repeated) values in a) separated by one or more spaces. This is the way to specify the alpha spending functions
 used for each boundary (the first word for the lower boundary, the second word for the upper one) for asymmetric boundaries. When 
 the method is thus specified, the argument of the {opt alpha} option must be of length two.{p_end}
{pmore}
The default is {cmd: method(obf)}. For details on the types of alpha spending functions see, e.g., Cook and DeMets, 2008.

{phang}
{opt rho(numlist)} specifies the parameter(s) of the power family alpha spending function(s). The {it:numlist} may be of length one
 or two, depending on how many alpha spending functions of this type are specified by the {opt method} option.
 
{phang}
{opt onesided} specifies if one-sided, instead of two-sided boundaries, are to be computed.

{phang}
{opt beta(numlist)} specifies the total type II error probability(ies). For the computed boundaries and for each value of the {it:numlist}, 
 the corresponding value of theta, i.e. the standardized treatment difference or drift, is computed. It is an error to try to use the
 options beta and theta at the same time.

{phang}
{opt theta(numlist)} specifies the standardized treatment difference(s) or drift(s). For the computed boundaries and for each value of
 the {it:numlist}, the corresponding value of beta, i.e. the total type II error probability, is computed. It is an error to try to use the
 options beta and theta at the same time.

{phang}
{opt plot} specifies if a plot of stopping boundaries vs. monitoring times is to be displayed.
   
{marker savedresults}{...}
{title:Saved results}

{cmd:landemets} saves the following in {cmd:r()}:

Scalars

{p2colset 5 22 26 2}{...}
{p2col:{cmd:r(alpha)}}overall probability of type I error (omitted when asymmetric boundaries are computed){p_end}
{p2col:{cmd:r(alpha_lower)}}overall probability of type I error for the lower boundary (omitted when symmetric or one-sided
 boundaries are computed){p_end}
{p2col:{cmd:r(alpha_upper)}}overall probability of type I error for the upper boundary(omitted when symmetric or one-sided 
 boundaries are computed){p_end}
{p2col:{cmd:r(K)}}number of interim analyses{p_end}
{p2colreset}{...}
  
Macros 

{p2colset 5 22 26 2}{...}
{p2col:{cmd:r(bound_type)}}type of boundaries computed: two-sided (asymmetric or not) or one-sided{p_end}
{p2col:{cmd:r(method)}}alpha spending function used (omitted when asymmetric boundaries are computed){p_end}
{p2col:{cmd:r(method_lower)}}alpha spending function used for the lower boundary (omitted when symmetric or one-sided 
 boundaries are computed){p_end}
{p2col:{cmd:r(method_upper)}}alpha spending function used for the upper boundary (omitted when symmetric or one-sided
 boundaries are computed){p_end}
{p2colreset}{...}

Matrices

{p2colset 5 22 26 2}{...}
{p2col:{cmd:r(bound_alpha)}}a matrix with the following named columns:{p_end}
{p2col:}{it:  time}, monitoring times{p_end}
{p2col:}{it:  lower}, lower boundaries (omitted if one-sided boundaries are computed){p_end}
{p2col:}{it:  upper}, upper boundaries{p_end}
{p2col:}{it:  cumalpha}, cumulative alpha values{p_end}
{p2col:}{it:  diffalpha}, first difference of the cumulative alpha values{p_end}
{p2col:{cmd:r(beta_theta)}}a matrix (omitted when theta and beta options are not used) with the following named columns:{p_end}
{p2col:}{it:  beta}, total type II error probabilities{p_end}
{p2col:}{it:  theta}, standardized treatment differences (drifts){p_end}
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
Cook TD and DeMets DL (2008), {it:Introduction to Statistical Methods for Clinical Trials}, Boca Raton: Chapman & Hall/CRC

{phang}
Jann B (2005), {it:moremata: Stata module (Mata) to provide various functions}, available from 
 {browse "http://ideas.repec.org/c/boc/bocode/s455001.html"}

{phang}
Lan K and DeMets DL (1983), Discrete sequential boundaries for clinical trials, {it:Biometrika}, 70: 659-663
