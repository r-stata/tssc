{smcl}
{* *! version 1.0  13feb2016}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:vratio} {hline 2} Variation ratio and proportion of maximum heterogeneity (measures of dispersion) for categorical variables.


{marker syntax}{...}
{title:Syntax} 

{p 8 17 2}
{cmdab:vratio}
{varlist}

{marker description}{...}
{title:Description} 

{pstd}
{cmd:vratio} calculates dispersion for categorical variables at the nominal/ordinal level of measurement.
Quantities calculated include the variation ratio (VR), maximum variation ratio (VRmax), and proportion of maximum heterogeneity (VR/VRmax).
VR is the proportion of observations not in the modal category.   
VRmax is the maximum heterogeneity or, in other words, the maximum value VR could take if all categories had the same number of observations.
VR/VRmax is the proportion of maximum possible heterogeneity.  
Higher VR and VR/VRmax values indicate greater dispersion. 
k is also reported, which is simply the number of categories for categorical variables.  
Please note that k itself (but not VR, VRmax, and VR/VRmax) might be useful in some applications with interval/ratio variables as it would indicate the number of unique scores in a distribution.     

{marker formulas}{...}
{title:Formulas}

     VR = 1-(Fm/n) 
     VRmax = 1-((n/k)/n) 
	 
     Fm-frequency of modal category; n-number of observations; k-number of categories

{marker examples}{...}
{title:Examples}

     {cmd:preserve}
     {cmd:sysuse auto, clear}
     {cmd:tab1 rep78 foreign}
     {cmd:vratio rep78 foreign} 
     {cmd:return list} 
     {cmd:restore}

{marker storedresults}{...}
{title:Stored Results}

   Matrices
     {cmd:r(vr)}	variation ratio
     {cmd:r(vrmax)}	maximum variation ratio 
     {cmd:r(pmh)}	proportion of maximum heterogeneity
     {cmd:r(k)}		number of categories

{marker requiedado}{...}
{title:Required Ado File}

{pstd}
The vratio command uses the {cmd: mmodes} command created by: Adrian Mander, MRC Human Nutrition Research, Cambridge, UK.

{marker citation}{...}
{title:Citation}

{pstd}
Ward, J.T. (2016). vratio: Stata module to calculate variation ratio and proportion of maximum heterogeneity for categorical variables. 

{marker author}{...}
{title:Author}

{pstd}
Jeffrey T. Ward, Ph.D., Temple University, Department of Criminal Justice (professorward@temple.edu).



