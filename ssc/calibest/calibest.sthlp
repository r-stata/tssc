{smcl}
{* *! version 1.3  7Feb2011}{...}
{cmd:help calibest}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi: calibest} {hline 2}}Estimates proportions and means after survey data have been calibrated to population totals{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:calibest} {it:varlist} ,
{cmdab:mar:ginals}({it:varlist}) {cmdab:sel:wt}({it:varname}) {cmdab:calib:wt}({it:varname}) {cmd:psu}({it:psu}) {cmdab:meth:od}({it:method}) [{it:options}] 


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{pstd}{it:Required}{p_end}
{synopt :{cmdab:sel:wt(}{it:varname}{cmd:)}}is the selection weight{p_end}
{synopt :{cmdab:calib:wt(}{it:varname}{cmd:)}}is the calibration weight{p_end}
{synopt :{cmdab:mar:ginals(}{it:varlist}{cmd:)}}are the variables that were used in the calibration{p_end}
{synopt :{cmd:psu(}{it:psu}{cmd:)}}is the primary sampling unit (or _n if simple random sampling was used){p_end}
{synopt :{cmdab:meth:od(}{it:method}{cmd:)}}specifies the estimation method{p_end}

{pstd}{it:Options}{p_end}
{synopt :{cmdab:des:ign(}{it:design}{cmd:)}}specifies the design options used in the sampling design{p_end}
{synoptline}


{title:Description}

{pstd} {opt calibest} estimates means or proportions of survey data after selection weights have been calibrated to population totals using,
for example, one of methods 1 or 2 of Deville and S{c a:}rndal (1992). It can be regarded as a generalisation of Stata's post-stratification estimation commands.

{pstd} The selection weight, {it:selwt}, the calibrated weight, {it:calibwt}, the variables used in the 
calibration, {it:marginals}, the primary sampling unit, {it:psu}, and the method to be used (means or proportions) must all be specified. Sampling design options can also be specified.

{pstd} The output includes estimates, asymptotic standard errors and 95% confidence intervals. The asymptotic standard errors and
confidence intervals are calculated using methods based on S{c a:}rndal, Swensson, and Wretman (1992) and are valid if the sample size is large.
They are asymptotically valid regardless of which calibration method is used.

{title:Options}

{phang}
{cmdab:meth:od(}{it:method}{cmd:)} specifies the estimation method.  Options are {it:mean} or {it:prop}. 

{phang}
{cmdab:des:ign(}{it:design}{cmd:)} specifies the design options used in the sampling design.
Standard Stata syntax to define strata, secondary sampling units or finite population corrections can be included.



{title:Also see}

{pstd} The program {cmd:calibrate} can calculate the calibration weights to be used in the estimation. See also {cmd:svyset}, which can be used when calibrating to a single
categorical variable.



{title:Example 1}

{pstd} Demonstrate on the {cmd:multistage} dataset.  

{phang2}{cmd:. use http://www.stata-press.com/data/r9/multistage}{p_end}

{pstd} The population consists of 8,000,000 high school seniors. If we were estimating the mean weight of high school seniors and
the distribution of sex and race using selection weight only, we would use the design options given in the Stata manual.

{phang2}{cmd:. svyset county [pweight=sampwgt], strata(state) fpc(ncounties) || school, fpc(nschools)} {p_end}
{phang2}{cmd:. svy: mean weight} {p_end}
{phang2}{cmd:. svy: prop sex race} {p_end}

{pstd} To estimate the same quantities using the calibration weights we need information about population totals. Suppose it is known that
the population is 50% male and 50% female, and contains 7,000,000 white seniors. First create calibration weights. 
Start by converting the categorical variables {cmd:sex} and {cmd:race} into binary indicator variables.

{phang2}{cmd:. tab sex, gen(isex)}{p_end}
{phang2}{cmd:. tab race, gen(irace)}{p_end}

{pstd} Make a row matrix of popultaion totals (male, female, white).

{phang2}{cmd:. matrix M=[4000000, 4000000, 7000000]}{p_end}

{pstd} Now calibrate (creating a calibration weight wt1). We use linear calibration.

{phang2}{cmd:. calibrate  , marginals(isex1 isex2 irace1) poptot(M) entrywt(sampwgt) exitwt(wt1)}{p_end}

{pstd} Estimation using {cmd:calibest}:

{phang2}{cmd:. calibest weight, method(mean) selwt(sampwgt) calibwt(wt1) marginals(isex1 isex2 irace1) psu(county) design(strata(state) fpc(ncounties) || school, fpc(nschools))}{p_end}
{phang2}{cmd:. calibest sex race, method(prop) selwt(sampwgt) calibwt(wt1) marginals(isex1 isex2 irace1) psu(county) design(strata(state) fpc(ncounties) || school, fpc(nschools))}{p_end}

{title:Example 2 (Post-stratification)}

{pstd} The special case where we are post-stratifying (calibrating to a single categorical variable) can be dealt with using the post-stratification option of {cmd:svyset},
but {cmd:calibest} should give the same result. To illustrate, we post-stratify to sex (4,000,000 male and 4,000,000 female).

{phang2}{cmd:. gen sextot=4000000} {p_end}
{phang2}{cmd:. svyset county [pweight=sampwgt], strata(state) fpc(ncounties) || school, fpc(nschools) poststrata(sex) postweight(sextot)} {p_end}
{phang2}{cmd:. svy: mean weight} {p_end}
{phang2}{cmd:. svy: prop sex race} {p_end}


{pstd} The same results can be obtained using {cmd:calibest}.

{phang2}{cmd:. matrix M=[4000000, 4000000]}{p_end}
{phang2}{cmd:. calibrate  , marginals(isex1 isex2) poptot(M) entrywt(sampwgt) exitwt(wt2)}{p_end}
{phang2}{cmd:. calibest weight, method(mean) selwt(sampwgt) calibwt(wt2) marginals(isex1 isex2) psu(county) design(strata(state) fpc(ncounties) || school, fpc(nschools))}{p_end}
{phang2}{cmd:. calibest sex race, method(prop) selwt(sampwgt) calibwt(wt2) marginals(isex1 isex2) psu(county) design(strata(state) fpc(ncounties) || school, fpc(nschools))}{p_end}


{title:Saved results}

{pstd}
{cmd:calibest} with {cmd:method=}{it:mean} saves the following matrices in {cmd:r()}. ({cmd:method=}{it:prop} does not save anything):

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(meff)}}column matrix of mis-specification effect (one row for each dependent variable){p_end}
{synopt:{cmd:r(rmat)}}results matirx with one row for each dependent variable and four columns: (estimate, SE, lower and upper 95% confidence limits){p_end}


{title:References}

{phang}
Deville, J.-C., and C.-E. S{c a:}rndal.  1992.  Calibration estimators in
survey sampling.  {it:Journal of the American Statistical Association} 87:
376-382.

{phang}
S{c a:}rndal, C.-E., and S. Lundstr{c o:}m.  2005.  {it:Estimation in Surveys with Nonresponse}.
New York, Wiley.

{phang}
S{c a:}rndal, C.-E., B. Swensson, and J. H. Wretman 1992. {it:Model Assisted Survey Sampling}.
New York: Springer-Verlag.


{title:Author}

{pstd}John D'Souza{p_end}
{pstd}National Centre for Social Research{p_end}
{pstd}London, England, UK{p_end}
{pstd}John.D'Souza@natcen.ac.uk{p_end}


