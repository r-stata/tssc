{smcl}
{* 01sep2014}{...}
{cmd:help ntreatreg}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:ntreatreg} {hline 1}}Stata module for estimation of treatment effects in the presence of neighbourhood interactions{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:ntreatreg}
{it: outcome} 
{it: treatment}
[{it:varlist}]
{ifin}
{weight}{cmd:,}
[{cmd:spill}{cmd:(}{it:matrix}{cmd:)}
{cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)}
{cmd:conf}{cmd:(}{it:number}{cmd:)}
{cmd:graphic}
{cmd:vce(robust)}
{cmd:const(noconstant)}
{cmd:head(noheader)}]


{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.



{title:Description}

{pstd} {cmd:ntreatreg} estimates Average Treatment Effects (ATEs) under 
Conditional Mean Independence (CMI) when neighbourhood interactions may be present. It incorporates 
such externalities within the traditional Rubin’s potential outcome model.
As such, it provides an attempt to relax the Stable Unit Treatment 
Value Assumption (SUTVA) generally used in observational studies.

     
{title:Options}
    
{phang} {cmd:spill}{cmd:(}{it:matrix}{cmd:)} specifies the adjacent (weighted) matrix used to define presence and strength of units’ relationship. It could be a distance matrix, with distance loosely defined either as vector or spatial.    

{phang} {cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)} specifies the variables over 
which to calculate the idyosincratic Average Treatment Effect ATE(x), ATET(x) and ATENT(x),
where x={it:varlist_h}. It is optional. When this option is not specified, the command
estimates the specified model without heterogeneous average effect. Observe that
{it:varlist_h} should be the same set or a subset of the variables specified in {it:varlist}.

{phang} {cmd:graphic} allows for a graphical representation of the density distributions of 
ATE(x), ATET(x) and ATENT(x). It is optional for all models and gives an outcome 
only if variables into {cmd:hetero()} are specified.

{phang} {cmd:vce(robust)} allows for robust regression standard errors. It is optional for all models.

{phang} {cmd:beta} reports standardized beta coefficients. It is optional for all models.

{phang} {cmd:const(noconstant)} suppresses regression constant term. It is optional for all models. 

{phang} {cmd:conf}{cmd:(}{it:number}{cmd:)} sets the confidence level equal to the specified {it:number}. The default is {it:number}=95. 


{pstd}
{cmd:ntreatreg} creates a number of variables:

{pmore}
{inp:_ws_}{it:varname_h} are the additional regressors used in model's regression when {cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)}
is specified.

{pmore}
{inp:_z_}{it:varname_h} are the spillover additional regressors.

{pmore}
{inp:_v_}{it:varname_h} are the first spillover component of {inp:_z_}{it:varname_h}.

{pmore}
{inp:_ws_v_}{it:varname_h} are the second spillover component of {inp:_z_}{it:varname_h}. 

{pmore}
{inp:ATE(x)} is an estimate of the idiosyncratic Average Treatment Effect.

{pmore}
{inp:ATET(x)} is an estimate of the idiosyncratic Average Treatment Effect on treated.

{pmore}
{inp:ATENT(x)} is an estimate of the idiosyncratic Average Treatment Effect on Non-Treated.


{pstd}
{cmd:ntreatreg} returns the following scalars:

{pmore}
{inp:e(N_tot)} is the total number of (used) observations.

{pmore}
{inp:e(N_treat)} is the number of (used) treated units.

{pmore}
{inp:e(N_untreat)} is the number of (used) untreated units.

{pmore}
{inp:e(ate)} is the value of the Average Treatment Effect.

{pmore}
{inp:e(atet)} is the value of the Average Treatment Effect on Treated.

{pmore}
{inp:e(atent)} is the value of the Average Treatment Effect on Non-treated.


{title:Remarks} 

{pstd} The treatment has to be a 0/1 binary variable (1 = treated, 0 = untreated).

{pstd} When the matrix of interactions is provided into the option {cmd:spill()}, 
please be careful that it has been sorted in a proper way so to have, 
both by row and by column, first the treated units and then the untreated units. 
See the tutorial in the references.   

{pstd} When option {cmd:hetero()} is not specified, ATE(x), ATET(x) and ATENT(x) are one singleton
number equal to ATE=ATET=ATENT.

{pstd} Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.


{title:Example}

{pstd} . ntreatreg y w x1 x2 , hetero(x1 x2) spill(omega) graphic



{title:References}

{phang}
Cerulli, G. 2014. Identification and Estimation
of Treatment Effects in the Presence
of Neighbourhood Interactions, 
{it:Working Paper Cnr-Ceris}, N° 04/2014.
{p_end}

{phang}
Wooldridge, J. M. 2010. {it: Econometric Analysis of Cross Section and Panel Data, 2nd Edition}.
Chapter 21. The MIT Press, Cambridge.
{p_end}


{title:Acknowledgments}

{pstd} 
An early version of this routine was presented at CEMMAP (Centre for Microdata Methods and Practice), University
College London, on March 27th 2013. The author wishes to thank all the participants to the seminar and in particular
Richard Blundell, Andrew Chesher, Charles Manski, Adam Rosen and Barbara Sianesi for the useful discussion. A more developed
version was presented at the Department of Economics, Boston College, on November 12th 2013.
The author wishes to thank all the participants to the seminar and in particular Kit Baum, Andrew Beauchamp,
Rossella Calvi, Federico Mantovanelli, Scott Fulford and Mathis Wagner for their participation and suggestions.
{p_end}


{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}CNR-IRCrES (www.ircres.cnr.it){p_end}
{phang}Research Institute on Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Also see}

{psee}
Online:  {helpb treatreg}, {helpb ivregress}, {helpb pscore}, {helpb psmatch2}, {helpb nnmatch}, {helpb ivtreatreg}, {helpb treatrew}
{p_end}
