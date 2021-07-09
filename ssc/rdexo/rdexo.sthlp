{smcl}
{* *! version 1.0.0  05-26-2019}{...}
{viewerjumpto "Data" "rdexo##data"}{...}
{viewerjumpto "Syntax" "rdexo##syntax"}{...}
{viewerjumpto "Examples" "rdexo##examples"}{...}

{title:Title}

{p 4 8}{cmd:rdexo} {hline 2} produces relevant estimates for testing the external validity of LATE to other compliance groups at the threshold according to 
Bertanha and Imbens (2019).{p_end}


{marker data}{...}
{title:Data}

{p 4 8}You need to have a dataset with one outcome variable (Y), one forcing variable (X), and one binary variable describing the actual treatment status (W). You have the option of using pre-treatment covariates (V1, ..., Vq).{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdexo } {it:varlist(numeric)} {ifin} 
{cmd:,} 
[CUToff(numlist)]
[COVariate(varlist)]
[Hwidth(numlist>=0)]
[Bootstrap(numlist>0)]
{p_end}

{p 4 8} where the capital letters indicate how you can abbreviate option names.{p_end}

{p 8 12}{cmd:varlist}: (required) enter the list of variables you want to regress in this order: outcome variable (Y), forcing variable (X), and binary treatment status variable (W). {p_end}

{p 8 12}{cmd:[if]} or {cmd:[in]}: (optional) like in any other STATA command, to restrict the sample you want to obtain your estimates from. {p_end}

{p 8 12}{cmd:cutoff(numlist)} or {cmd:cut(numlist)}: (optional) the threshold that determines the assignment of treatment.
 {cmd:rdexo} assumes that the participants are eligible for the treatment if the forcing variable is above the threshold 
 (default threshold is zero).{p_end}

{p 8 12}{cmd:covariate(varlist)} or {cmd:cov(varlist)}: (optional) pre-treatment characteristics. If {cmd:covariate} is provided and data is fuzzy, {cmd:rdexo} will produce additional estimates adjusted for covariates. {p_end}

{p 8 12}{cmd:hwidth(numlist>=0)} or {cmd:h(numlist>=0)}: (optional) bandwidth for estimating conditional mean jumps.
 If you decide to use this option, make sure to specify {cmd:hwidth} or {cmd:h} as six numbers, regardless of other options:{p_end}
 
{p 12 16}{cmd:h[1]} is used to estimate E[Y|X=c+]-E[Y|X=c-].{p_end}
{p 12 16}{cmd:h[2]} is used to estimate E[W|X=c+]-E[W|X=c-]. In case the data is sharp, this jump won't be estimated. 
					Set {cmd:h[2]}=0 in this case.{p_end}
{p 12 16}{cmd:h[3]} is used to estimate E[Y|X=c+,W=0]-E[Y|X=c-,W=0]. In case the data is sharp on the right, this jump won't be estimated. 
					Set {cmd:h[3]}=0 in this case.{p_end}
{p 12 16}{cmd:h[4]} is used to estimate E[Y|X=c+,W=1]-E[Y|X=c-,W=1]. In case the data is sharp on the left, this jump won't be estimated. 
					Set {cmd:h[4]}=0 in this case.{p_end}
{p 12 16}{cmd:h[5]} is used to estimate E[Y|X=c+,W=0,V]-E[Y|X=c-,W=0,V], where V denotes a vector of covariates.
					In case no covariates are provided 
					or the data is sharp on the right, this jump won't be estimated.
					Set {cmd:h[5]}=0 in this case.{p_end}
{p 12 16}{cmd:h[6]} is used to estimate E[Y|X=c+,W=1,V]-E[Y|X=c-,W=1,V], where V denotes a vector of covariates.
					In case no covariates are provided 
					or the data is sharp on the left, this jump won't be estimated. 
					Set {cmd:h[6]}=0 in this case.{p_end}

{p 12 16} If you do not use the {cmd:hwidth} option, then the bandwidths {cmd:h[1]}, ..., {cmd:h[4]} are selected by the 
Imbens and Kalyanaram (2012) (IK) method with edge kernel and local linear regression.
This requires the file "ikbw.ado".
In case covariates are used, {cmd:h[5]}={cmd:h[3]} and {cmd:h[6]}={cmd:h[4]}.{p_end}


{p 8 12}{cmd:bootstrap(numlist>0)} or {cmd:b(numlist>0)}: (optional) the number of bootstrap samples for variance estimation (default number is 1000). {p_end}


{marker examples}{...}
{title:Examples}

    
{p 4 8}Test external validity{p_end}
{p 8 8}{cmd:. rdexo Y X W}{p_end}

{p 4 8}Test external validity with one pre-treatment covariate V{p_end}
{p 8 8}{cmd:. rdexo Y X W, cov(V)}{p_end}

{p 4 8}Test external validity using specific cutoff, bandwidths, number of bootstrap samples, and no covariates{p_end}
{p 8 8}{cmd:. rdexo Y X W, cut(1.3) h(27 39 28 37 0 0) b(1000)}{p_end}

{title:Reference}

{p 4 8}Bertanha, M., and Imbens, G. (2019),
External Validity in Fuzzy Regression Discontinuity Designs.
{it:Journal of Business & Economic Statistics} (forthcoming)


{title:Contributor to this Code:} Wei Qian, University of Notre Dame.




