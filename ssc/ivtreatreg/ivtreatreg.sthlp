{smcl}
{* 30aug2011}{...}
{cmd:help ivtreatreg}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:ivtreatreg} {hline 1}}Estimation of binary treatment models with idiosyncratic average effect{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:ivtreatreg}
{it: outcome} 
{it: treatment}
[{it: varlist}]
{ifin}
{weight}{cmd:,}
{cmd:model}{cmd:(}{it:{help ivtreatreg##modeltype:modeltype}}{cmd:)}
[{cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)}
{cmd:iv}{cmd:(}{it:varlist_iv}{cmd:)}
{cmd:conf}{cmd:(}{it:number}{cmd:)}
{cmd:graphic}
{cmd:vce(robust)}
{cmd:const(noconstant)}
{cmd:head(noheader)}]


{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.



{title:Description}

{pstd} {cmd:ivtreatreg} estimates four different (binary) treatment models {it:with} and {it:without}
idiosyncratic (or heterogeneous) average effect.
Depending on the model specified, {cmd:ivtreatreg} provides consistent estimation of average treatment 
effects under the hypothesis of "selection-on-unobservables" (i.e., treatment endogeneity)
by suitably using Instrumental-Variables (IV) and a generalized Heckman Selection-Model. 
Conditional on a pre-specified subset of exogenous variables - thought of as those driving
the heterogeneous response to treatment - {cmd:ivtreatreg} 
calculates for each specific model the Average Treatment Effect (ATE), the Average Treatment Effect on Treated (ATET) and 
the Average Treatment Effect on Non-Treated (ATENT), as well as the estimates
of these parameters conditional on the observable factors x (i.e., ATE(x), ATET(x) and ATENT(x)).

     
{title:Options}
    
{phang} {cmd:model}{cmd:(}{it:{help ivtreatreg##modeltype:modeltype}}{cmd:)} specifies the treatment model
to be estimated, where {it:modeltype} must be one of the following five
models: "direct-2sls", "probit-2sls", "probit-ols", "heckit".
it is always required to specify one model.   

{phang} {cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)} specifies the variables over 
which to calculate the idyosincratic Average Treatment Effect ATE(x), ATET(x) and ATENT(x),
where x={it:varlist_h}. It is optional for all models. When this option is not specified, the command
estimates the specified model without heterogeneous average effect. Observe that
{it:varlist_h} should be the same set or a subset of the variables specified in {it:varlist}.

{phang} {cmd:iv}{cmd:(}{it:varlist_iv}{cmd:)} specifies the variable(s) to be used as instruments.
This option is strictly required only for "direct-2sls", "probit-2sls" and "probit-ols", 
while it is optional for "heckit". 

{phang} {cmd:graphic} allows for a graphical representation of the density distributions of 
ATE(x), ATET(x) and ATENT(x). It is optional for all models and gives an outcome 
only if variables into {cmd:hetero()} are specified.

{phang} {cmd:vce(robust)} allows for robust regression standard errors. It is optional for all models.

{phang} {cmd:beta} reports standardized beta coefficients. It is optional for all models.

{phang} {cmd:const(noconstant)} suppresses regression constant term. It is optional for all models. 

{phang} {cmd:conf}{cmd:(}{it:number}{cmd:)} sets the confidence level equal to the specified {it:number}. 
The default is {it:number}=95. 


{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:Model}
{p2coldent : {opt direct-2sls}}IV regression estimated by direct two-stage least squares{p_end}
{p2coldent : {opt probit-2sls}}IV regression estimated by Probit and two-stage least squares{p_end}
{p2coldent : {opt probit-ols}}IV two-step regression estimated by Probit and ordinary least squares{p_end}
{p2coldent : {opt heckit}}Heckman two-step selection model{p_end}
{synoptline}


{pstd}
{cmd:ivtreatreg} creates a number of variables:

{pmore}
{inp:_ws_}{it:varname_h} are the additional regressors used in model's regression when {cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)}
is specified. They are created in all models.

{pmore}
{inp:_z_}{it:varname_h} are the instrumental-variables used in model's regression when {cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)}
and {cmd:iv}{cmd:(}{it:varlist_iv}{cmd:)} are specified. They are created only in IV models.

{pmore}
{inp:ATE(x)} is an estimate of the idiosyncratic Average Treatment Effect.

{pmore}
{inp:ATET(x)} is an estimate of the idiosyncratic Average Treatment Effect on treated.

{pmore}
{inp:ATENT(x)} is an estimate of the idiosyncratic Average Treatment Effect on Non-Treated.

{pmore}
{inp:G_fv} is the predicted probability from the Probit regression, conditional on the observable used.

{pmore}
{inp:_wL0, wL1} are the Heckman correction-terms.



{pstd}
As an e-class command {cmd:ivtreatreg} returns a series of objects. The most relevant are the following scalars:

{pmore}
{inp:e(N_tot)} is the total number of (used) observations.

{pmore}
{inp:e(N_treated)} is the number of (used) treated units.

{pmore}
{inp:e(N_untreated)} is the number of (used) untreated units.

{pmore}
{inp:e(ate)} is the value of the Average Treatment Effect.

{pmore}
{inp:e(atet)} is the value of the Average Treatment Effect on Treated.

{pmore}
{inp:e(atent)} is the value of the Average Treatment Effect on Non-treated.



{title:Remarks} 

{pstd} The treatment has to be a 0/1 binary variable (1 = treated, 0 = untreated).

{pstd} The standard errors for ATET and ATENT may be obtained via bootstrapping.

{pstd} When option {cmd:hetero} is not specified, ATE(x), ATET(x) and ATENT(x) are one singleton
number equal to ATE=ATET=ATENT.

{pstd} Since when {cmd:hetero} is not specified in model "heckit" {cmd:ivtreatreg} uses
the in-built command {cmd:treatreg}, the following has to be taken into account:
(i)  option {cmd:beta} and option {cmd:head(noheader)} are not allowed;
(ii) Option {cmd:vce} takes this sintax: {cmd:vce}{cmd:(}{it:vcetype}{cmd:)},
     where {it:vcetype} may be "conventional", "bootstrap", or "jackknife".
	 
{pstd} Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.


{title:Examples}

{pstd} {cmd:*** EXAMPLES WITHOUT IDIOSYNCRATIC AVERAGE EFFECT ***}

   {inp:. #delimit ;}
   {inp:. ivtreatreg children educ7 tv ,}
   {inp:. model(direct-2sls) iv(frsthalf) head(noheader) const(noconstant) vce(robust) beta }
   {inp:. ;}
   
   {inp:. #delimit ;}
   {inp:. ivtreatreg children educ7 tv ,}
   {inp:. model(probit-2sls) iv(frsthalf) head(noheader) const(noconstant) vce(robust) beta }
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. ivtreatreg children educ7 tv ,}
   {inp:. model(probit-ols) head(noheader) const(noconstant) vce(robust) beta }
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. ivtreatreg children educ7 tv ,}
   {inp:. model(heckit) iv(frsthalf) head(noheader) const(noconstant) conf(80) vce(vce(conventional))}
   {inp:. ;}
   

{pstd} {cmd:*** EXAMPLES WITH IDIOSYNCRATIC AVERAGE EFFECT ***}

   {inp:. #delimit ;}
   {inp:. ivtreatreg children educ7 tv ,} 
   {inp:. model(direct-2sls) hetero(yearfm agefm) iv(frsthalf) graphic} 
   {inp:. head(noheader) const(noconstant) conf(90) beta vce(robust)}
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. ivtreatreg children educ7 tv ,} 
   {inp:. model(probit-2sls) hetero(yearfm agefm) iv(frsthalf) graphic} 
   {inp:. head(noheader) const(noconstant) conf(90) beta vce(robust)}
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. ivtreatreg children educ7 tv ,} 
   {inp:. model(probit-ols) hetero(yearfm agefm) graphic} 
   {inp:. head(noheader) const(noconstant) conf(90) beta vce(robust)}
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. ivtreatreg children educ7 tv ,} 
   {inp:. hetero(yearfm agefm) iv(frsthalf) model(heckit) graphic} 
   {inp:. head(noheader) const(noconstant) conf(90) beta vce(robust)}
   {inp:. * Test for checking the existence of the selection bias:}
   {inp:. test _b[_wL1]=_b[_wL0]=0}
   {inp:. ;}


{pstd} {cmd:*** EXAMPLE ON HOW TO BOOTSTRAP STD. ERR. FOR "ATET" AND "ATENT" ***}

   {inp:. #delimit ;}
   {inp:. bootstrap atet=r(atet) atent=r(atent), rep(10):}
   {inp:. ivtreatreg children educ7 tv , hetero(yearfm agefm) iv(frsthalf) model(heckit)}
   {inp:. head(noheader) const(noconstant) conf(90) beta vce(robust)}
   {inp:. ;}

   
{title:Reference}

{phang}
Cameron, A. C., and P. K. Trivedi. 2005. {it:Microeconometrics: Methods and Applications}. 
Chapter 25. Cambridge University Press, New York.
{p_end}

{phang}
Cerulli, G. 2012. Ivtreatreg: a new STATA routine for estimating binary treatment models with heterogeneous 
response to treatment under observable and unobservable selection, 
{it:Working Paper Cnr-Ceris}, N° 03/2012.
{p_end}

{phang}
Wooldridge, J. M. 2002. {it: Econometric Analysis of Cross Section and Panel Data}. 
Chapter 18. The MIT Press, Cambridge.
{p_end}

{phang}
Wooldridge, J. M. 2010. {it: Econometric Analysis of Cross Section and Panel Data, 2nd Edition}.
Chapter 21. The MIT Press, Cambridge.
{p_end}


{title:Acknowledgment}

{pstd} 
I wish to thank all the participants to the "8th Italian Stata Users Group" meeting held in Venice (Italy) 
on November 17–18, 2011. A special thank to David Drukker for the useful discussions had with him in Venice
and to the PhD students of the Doctoral School of Economics of the University of Rome 
"La Sapienza" who pushed me to write this routine in Stata 11.
{p_end}


{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}Ceris-CNR{p_end}
{phang}Institute for Economic Research on Firms and Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:g.cerulli@ceris.cnr.it":g.cerulli@ceris.cnr.it}{p_end}



{title:Also see}

{psee}
Online:  {helpb teffects}, {helpb etregress}, {helpb etpoisson}, {helpb ivregress}, {helpb pscore}, {helpb psmatch2}, {helpb nnmatch}
{p_end}
