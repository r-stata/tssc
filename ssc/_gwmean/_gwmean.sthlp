{smcl}
{* *! version 1.0 30 Mar 2021}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "c:\ado\personal\_\_gwmean##syntax"}{...}
{viewerjumpto "Description" "c:\ado\personal\_\_gwmean##description"}{...}
{viewerjumpto "Options" "c:\ado\personal\_\_gwmean##options"}{...}
{viewerjumpto "Remarks" "c:\ado\personal\_\_gwmean##remarks"}{...}
{viewerjumpto "Examples" "c:\ado\personal\_\_gwmean##examples"}{...}
{title:Title}
{phang}

{bf:[D] egen } {hline 2} User written {bf: egen } function {bf: wmean()}, mnemonic for {bf: weighted mean}: 
calculates (optionally) byable, (optionally) weighted, Arithmetic, Geometric or Harmonic mean. 
Requires Stata 11. Written by Gueorgui I. Kolev in March 2021. 

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
egen
newvarname
= wmean(expression)
[{help if}]
[{help in}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt by(varlist)}}  
The user can optionally specify by(varlist), and the function will calculate the weighted mean for each of the groups defined by(varlist). If by(varlist) is not specified, the function calculates the overall weighted mean. 
{p_end}

{synopt:{opt w:eights(varname)}}  
The user can optionally specify weights(varname), where this option can be abbreviated down to {bf:w(varname)}. If the option is specified, the function calculates the weighted mean. 
If the option is not specified, the function calculates the unweighted mean, which is equivalent to a weighted mean where all the weights are equal to 1. 
{p_end}

{synopt:{opt a:rithmetic}}  
Requires the calculation of the Arithmetic mean and is the {bf: default}. The option can be abbreviated down to {bf:a}, or omitted altogether. 
If none of the options arithmetic, geometric and harmonic is specified, the function calculates arithmetic mean, the {bf: default}. 
The formula is Arithmetic Mean = Sum(Wi*Xi)/Sum(Wi), where Wi are the weights, Xi is the expression being averaged (can be a variable or {bf:can be a general expression} as well). 
The formula is applied for each group defined by(varlist) if the latter is specified.
{p_end}

{synopt:{opt g:eometric}}  
Requires the calculation of the Geometric mean, and the option can be abbreviated down to {bf:g}.  The formula is Geometric Mean = exp{Sum[Wi*log(Xi)]/Sum(Wi)}. 
The Geometric mean is defined only for all positive Xi. If some of the Xi are negative or 0, the function will calculate Geometric mean on the basis of the positive Xi only. 
{p_end}

{synopt:{opt h:armonic}} 
Requires the calculation of the Harmonic mean, and the option can be abbreviated down to {bf:h}.  The formula is Harmonic Mean = 1/[Sum(Wi/Xi)/Sum(Wi)]. The Harmonic mean is defined only for all positive Xi. 
If some of the Xi are negative or 0, the function will calculate Harmonic mean on the basis of the positive Xi only.
{p_end}

{synopt:{opt l:abel}} 
The option can be abbreviated down to {bf:l}, and if specified will result in the new generated variable being labelled, e.g., "Arithmetic Mean of Xi".
 {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description} 

Optionally byable, optionally weighted, Arithmetic, Geometric, or Harmonic mean. 
{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt by(varlist)}    {p_end}
{phang}
{opt w:eights(varname)}    {p_end}
{phang}
{opt a:rithmetic}    {p_end}
{phang}
{opt g:eometric}    {p_end}
{phang}
{opt h:armonic}    {p_end}
{phang}
{opt l:abel}    {p_end}


{marker examples}{...}
{title:Examples}


sysuse auto, clear

keep foreign price weight

* Introduce some missing, and negative values

sort foreign

replace price = . in 1/4

replace weight = . in 4/7

replace price = -price in -3/l

egen arimean = wmean(price), by(foreign) weights(weight) label // the default is Arithmetic mean, 
//Weights can be abbreviated to w. Option Label can be abbreviated to l, and labels the new generated variable. 

egen geomean = wmean(price), by(foreign) w(weight) geometric 
							// Geometric mean option can be abbreviated to g. 

egen harmean = wmean(price), by(foreign) w(weight) harmonic label // Harmonic mean option can be 
							// abbreviated to h. 

* The native Stata's -ameans- calculates on this data the same Arithmetic, 
* Geometric, and Harmonic means as our -egen, wmean- function above. 

by foreign: ameans price [aw=weight]

tabstat arimean geomean harmean, by(foreign) stat(mean count) notot 

* And an example where the argument of the function is a general expression, and with If and In.

egen arimeanexpre = wmean(log(price)*price) if weight>3000 in 10/l, by(foreign) weights(weight) label



{pstd}


{title:Author}

Gueorgui I. Kolev

Version 1: 5 March 2021.
{p}



