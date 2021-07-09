{smcl}
{* *! version 1.0.3  09jun2015}{...}
{cmd:help spreg postestimation} {right:also see:  {helpb spreg}  }
{hline}


{title:Title}

{p 4 16 2}
{cmd:spreg postestimation} {hline 2} Postestimation tools for spreg{p_end}


{title:Description}

{pstd}
The following postestimation commands are available after {cmd:spreg}:

{synoptset 17 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_estatic
INCLUDE help post_estatsum
INCLUDE help post_estatvce
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{synopt :{helpb spreg postestimation##predict:predict}}predicted values{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:statistic}]

{synoptset 28 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :Main}
{synopt :{opt rf:orm}}reduced-form predicted values; the default{p_end}
{synopt :{opt li:mited}}predictions based on a limited information set{p_end}
{synopt :{opt full}}predictions based on a full information set{p_end}
{synopt :{opt na:ive}}predictions based on the observed values of {bf:y}{p_end}
{synopt :{opt xb}}linear prediction{p_end}
{synopt :{opt rft:ransform(real matrix T)}}user-provided ({bf:I}-{it:lambda}*{bf:W})^(-1){p_end}
{synoptline}
{p2colreset}{...}


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt rform} predicted values calculated from the reduced-form equation,
{bf:y} = ({bf:I}-{it:lambda}*{bf:W})^(-1)*{bf:X}*{bf:b}.

{phang}
{opt limited} predicted values based on the limited information set.
This option is available only for a model with homoskedastically-distributed errors.

{phang}
{opt full} predicted values based on the full information set.
This option is available only for a model with homoskedastically-distributed errors.

{phang}
{opt naive} predicted values based on the observed values of {bf:y},
{it:lambda}*{bf:W}*{bf:y} + {bf:X}*{bf:b}.

{phang}
{opt xb} calculates the linear prediction {bf:X}*{bf:b}.

{phang}
See {it:{help spreg_postestimation##remarks:Remarks}} below for a detailed
explanation of the {bf:predict} options.

{phang}
{opt rftransform()} tells {cmd:predict} to use the user-specified inverse of
({bf:I}-{it:lambda}*{bf:W}).  The matrix {it:T} should reside in Mata memory.
This option is available only with the reduced-form predictor.


{marker remarks}{...}
{title:Remarks}

{pstd}
The methods implemented in {cmd:predict} after {cmd:spreg} are 
documented in Drukker, Prucha, and Raciborski (2011) which can be 
downloaded from 
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spreg_2011.pdf"}.


{pstd}
Recall the spatial-autoregressive spatial-error (SARAR) model

{p 8 6 2}
{bf:y} = {it:lambda}*{bf:W}*{bf:y} + {bf:X}*{bf:b} + {bf:u}

{p 8 6 2}
{bf:u} = {it:rho}*{bf:M}*{bf:u} + {bf:e}

{pstd}
This model specifies a system of {it:n} simultaneous equations for the dependent
variable {bf:y}.

{pstd}
The predictor based on the reduced-form equation is obtained by solving the
model for the endogenous variable {bf:y} which gives 
({bf:I}-{it:lambda}*{bf:W})^(-1)*{bf:X}*{bf:b} for the SAR and SARAR models
and {bf:X}*{bf:b} for the SARE model.

{pstd}
The limited information set predictor is described in Kalejian and Prucha (2007).
Let

	{bf:U} = ({bf:I}-{it:rho}*{bf:M})^(-1) * ({bf:I}-{it:rho}*{bf:M}')^(-1)
	
	{bf:Y} = ({bf:I}-{it:lambda}*{bf:W})^(-1) * {bf:U} * ({bf:I}-{it:lambda}*{bf:W}')^(-1)
	
	E({it:w_i}*{bf:y}) = {it:w_i} * ({bf:I}-{it:lambda}*{bf:W})^(-1) * {bf:X}*{bf:b}
	
	var({it:w_i}*{bf:y}) = {it:sigma}^2 * {it:w_i}*{bf:Y}*{it:w_i}'
	
	cov({it:u_i},{it:w_i}*{bf:y}) = {it:sigma}^2 * {it:u_i}*({bf:I}-{it:lambda}*{bf:W}')^(-1)*{it:w_i}'

{pstd}
where {it:w_i} and {it:u_i} denote the {it:i}th row of {bf:W} and {bf:U}, respectively.
The limited information set predictor for observation {it:i} is given by

	                       cov({it:u_i},{it:w_i}*{bf:y})
	{it:lambda}*{it:w_i}*{bf:y} + {it:x_i}*{bf:b} + -------------- * [{it:w_i}*{bf:y} - E({it:w_i}*{bf:y})]
	                         var({it:w_i}*{bf:y})

{pstd}
where {it:x_i} denotes the {it:i}th row of {bf:X}.  Because the formula involves
the {it:sigma}^2 term, this predictor is available only for a model
with homoskedastically-distributed errors.

{pstd}
The reduced-form predictor is based on the information set {{bf:X},{bf:W}}.
The limited information set predictor includes additionally the linear
combination {bf:W}*{bf:y}, thus it is more efficient than the reduced-form
predictor.  Both predictors are unbiased predictors conditional on their
information set.

{pstd}
The full information set predictor is described in Kalejian and Prucha (2007).
It is based on the largest information set and is an efficient minimum mean
square error predictor.
Let {bf:S_i} denote an {{it:n}-1} x {it:n} selector matrix which is identical
to an {it:n} x {it:n} identity matrix {bf:I} except that the {it:i}th row of
{bf:I} is deleted.  Let {bf:y_i} be the available {it:n}-1 observations on
the dependent variable.

{pstd}
Define
	
	E({bf:y_i}) = {bf:S_i} * ({bf:I}-{it:lambda}*{bf:W})^(-1) * {bf:X}*{bf:b}
	
	VC({bf:y_i}) = {it:sigma}^2 * {bf:S_i}*{bf:Y}*{bf:S_i}'
	
	cov({it:u_i},{bf:y_i}) = {it:sigma}^2 * {it:u_i}*({bf:I}-{it:lambda}*{bf:W}')^(-1)*{bf:S_i}'

{pstd}
The full information set predictor for observation {it:i} is given by

	{it:lambda}*{it:w_i}*{bf:y} + {it:x_i}*{bf:b} + cov({it:u_i},{bf:y_i}) * (VC({bf:y_i}))^(-1) * [{bf:y_i} - E({bf:y_i})]

{pstd}
Because the formula involves
the {it:sigma}^2 term, this predictor is available only for a model
with homoskedastically-distributed errors.

{pstd}
The naive predictor is obtained by treating the values of {bf:y} on the
right-hand side as given, which results in the formula 
{it:lambda}*{bf:W}*{bf:y} + {bf:X}*{bf:b} for the SAR and SARAR models, and 
{bf:X}*{bf:b} for the SARE model.  Note that this predictor is a special case
of the limited information set predictor with cov({it:u_i},{it:w_i}*{bf:y}) = 0,
but this this is true only when {it:lambda} = {it:rho} = 0.

{pstd}
The naive predictor ignores the feedback that the neighboring observations
may have on the value of {bf:y} in a given observation.  The reduced-form and
limited information set predictors factor this feedback into the computations
through the ({bf:I}-{it:lambda}*{bf:W})^(-1)*{bf:X}*{bf:b} term.  If you are
interested in how a change to a covariate in an observation affects the entire
system, you should use the reduced-form or the limited information set predictor.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use pollute}{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}
{phang2}{cmd:. spreg ml pollution factories area, id(id) dlmat(cobj) elmat(cobj)}{p_end}

{pstd}Obtain predicted values based on the reduced-form equation{p_end}
{phang2}{cmd:. predict y0}{p_end}

{pstd}Increase {cmd:factories} in observation 50 by 1 and obtain a new set of
predicted values{p_end}
{phang2}{cmd:. replace factories = factories+1 in 50}{p_end}
{phang2}{cmd:. predict y1}{p_end}

{pstd}Compare the two sets of predicted values{p_end}
{phang2}{cmd:. gen deltay = abs(y1-y0)}{p_end}
{phang2}{cmd:. count if deltay!=0}{p_end}

{pstd}Note that a change in one observation resulted in a total of 25 changes.{p_end}


{title:References}

{phang}
Drukker, D. M., I. R. Prucha, and R. Raciborski. 2011. 
Maximum-likelihood and generalized spatial two-stage least-squares estimators
for a spatial-autoregressive model with spatial-autoregressive disturbances.
Working paper, University of Maryland, Department of Economics,
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spreg_2011.pdf"}.


{phang}Kelejian H. H., and I. R. Prucha. 2007.
The relative efficiencies of various predictors in spatial econometric models
containing spatial lags. {it:Regional Science and Urban Economics} 37, 363-374.


{title:Also see}

{psee}
Online:  {helpb spreg}, {helpb spivreg} (if installed){p_end}

