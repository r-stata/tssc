{smcl}
{* *! version 1.0  9 Apr 2021}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "c:\ado\personal\s\suregr##syntax"}{...}
{viewerjumpto "Description" "c:\ado\personal\s\suregr##description"}{...}
{viewerjumpto "Options" "c:\ado\personal\s\suregr##options"}{...}
{viewerjumpto "Remarks" "c:\ado\personal\s\suregr##remarks"}{...}
{viewerjumpto "Examples" "c:\ado\personal\s\suregr##examples"}{...}
{title:Title}
{phang}

{bf: suregr } {hline 2} User written {bf: post estimation } command {bf: suregr}, mnemonic for {bf: suregr[obust]}: 
Calculates robust, or cluster-robust variance post {bf:[R] sureg } Seemingly Unrelated Regressions estimation.   
Requires Stata 11. Written by Gueorgui I. Kolev in March 2021. 

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab: suregr}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt cluster(clustvar)}} 
The command {bf: suregr} can only be called after a Seemingly Unrelated Regressions model has been fit through {bf: sureg}, that is, {bf: suregr} is a post estimation command. 
By default {bf: suregr} produces robust variance and robust standard errors of the parameter estimates. 
If the user wishes the variance and standard errors to be cluster-robust, the user specifies this through the option {bf: cluster(clustvar)} with the variable defining the clusters ({bf:clustvar}) in parentheses.  {p_end}
{synopt:{opt minus(#)}}  
Controls the degrees of freedom adjustment factor in the robust, or cluster-robust variance calculation. 
Default value is {bf: minus(0)}, which is equivalent to no degrees of freedom adjustment. 
This option is inherited from {bf: [P] _robust} and detailed instructions of how to apply the degrees of freedom adjustment through the option {bf: minus(#)} are given in the manual entry for {bf: [P] _robust}. {p_end}
{synopt:{opt noh:eader}}  
This option suppresses the header of the {bf:[R] sureg } regression table. The default is to display the header of the regression table. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

Stata's {bf:[R] sureg } estimates Arnold Zellner's Seemingly Unrelated Regressions model. 
However {bf:[R] sureg} cannot estimate robust or cluster-robust variance matrix and standard errors for the parameter estimates. 
Gueorgui I. Kolev (2021) "Robust and/or cluster-robust variance estimation in Seemingly Unrelated Regressions, and in Multivariate Regressions" shows
 the relevant formulae for robust and cluster-robust variance and standard errors, 
 and these formulae are automatically implemented by the post estimation  command {bf: suregr}. 
 {bf: Important:} all that {bf: suregr} does is replace the estimated non-robust variance with robust or cluster-robust variance. Therefore
1) everything that can be done with {bf: sureg} remains the same, e.g., one can apply linear constraints in the {bf: sureg} stage of the estimation.
2) Similarly {bf: suregr} returns the robust or cluster-robust variance in the proper format, so that further post estimation commands 
after {bf: suregr} proceed as usual, e.g., {bf:[R] test}, {bf:[R] lincom}, {bf:[R] nlcom}, etc., proceed after {bf: suregr} as usual, and work as usual.    
{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt cluster(varname)}    {p_end}
{phang}
{opt minus(#)}    {p_end}
{phang}
{opt noh:eader}    {p_end}


{marker examples}{...}
{title:Examples}

sysuse auto, clear

* Typical use of -suregr-, we firstly fit -sureg- quietly, and then we follow up with -suregr- 
* to get the robust variance.
* If we do not specify the minus option, the default is minus(0) meaning no degrees of freedom adjustment.
* Of course if we want to see the non-robust standard errors as well we can also run -sureg- noisily.  

quietly sureg (price headroom) (mpg weight length)

suregr

* Typical use for getting the cluster-robust variance follows. We use the minus(1) degrees of freedom adjustment, 
* because this is the common adjustment cluster-robust variance estimators in native Stata commands use.
* We also use the option noheader to omit the header from our regression table. 

quietly sureg (price headroom) (mpg weight length)

suregr, cluster(rep) minus(1) noheader


* Post estimation after -suregr- works as usual.
* -suregr- has substituted the (cluster-)robust variance, and the post estimation commands like -test-
* -lincom- and -nlcom- use  the (cluster-)robust variance in the calculations they are carrying out:

quietly sureg (price headroom) (mpg weight length)

suregr, cluster(rep) minus(1) noheader

test [price]headroom = [mpg]weight

nlcom [price]headroom/[mpg]weight

* Imposing linear constraints works as usual too

constraint define 1 [price]headroom = [mpg]weight

quietly sureg (price headroom) (mpg weight length), constraint(1)

suregr,  noheader
{pstd}


{title:References}

Kolev, Gueorgui I. (2021). Robust and/or cluster-robust variance estimation in Seemingly Unrelated Regressions, and in Multivariate Regressions. 
(under review at the {it: Stata Journal}, available upon request from the author). 
{p}

{title:Author}

Gueorgui I. Kolev
joro.kolev@gmail.com 
version 1:  08 Oct 2020
{p}



