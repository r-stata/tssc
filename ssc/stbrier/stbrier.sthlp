{smcl}
{* *! version 1.0.2  05August2017}{...}
{cmd:help stbrier}
{hline}

{title:Title}

{p2colset 5 17 21 2}{...}
{p2col :{hi:stbrier} {hline 2}}Brier score for censored time-to-event (survival) data {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
		{cmd:stbrier} {it:{help varlist:varlist}} {ifin} 
		{cmd:,}
		{cmdab:bt:ime(}{it:#}{cmd:)}
		[ {cmdab:d:istribution(}{it:string}{cmd:)} 
		{cmdab:comp:ete(}{it:crvar}[{cmd:==}{it:{help numlist}}]{cmd:)} 
		{cmdab:i:pcw(}{it:{help varlist:varlist}}{cmd:)} 
		{cmdab:g:en(}{it:string}{cmd:)}
		{it:model_options}
		]


{p 4 4 2}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{cmdab:bt:ime}{cmd:(#}{cmd:)}}specify the timepoint at which the Brier score should be computed; {cmd:required} {p_end}
{synopt:{cmdab:d:istribution}{cmd:(string}{cmd:)}}specify the survival distribution for an streg model; see {helpb streg} for available distributions {p_end}
{synopt:{cmdab:comp:ete(}{it:crvar}[{cmd:==}{it:{help numlist}}]{cmd:)}}specify competing-risks event(s) for a competing-risk model; see {helpb stcrreg}{p_end}
{synopt:{cmdab:i:pcw(}{it:{help varlist}}{cmd:)}}specify covariates for estimating the inverse probability of censoring weights (IPCW){p_end}
{synopt:{cmdab:g:en}{cmd:(string}{cmd:)}}generate a variable containing the observation-level {cmd:stbrier} scores {p_end}
{synopt :{it: model_options}}specify all available options for {helpb streg} when the {cmd:model} option is chosen; 
all available options for {helpb stcrreg} when the {cmd:compete} option is chosen; otherwise all available options for {helpb stcox}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stbrier}; see {manhelp stset ST}.{p_end}
{p 4 6 2}
{it:varlist} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s may be specified using 
{cmd:stset}; see {manhelp stset ST}. Weights are not supported with 
{cmd:efron} and {cmd:exactp}.{p_end}

		
{p 4 6 2}

{title:Description}

{pstd} {opt stbrier} computes the Brier score for risk prediction
models in survival analysis based on right censored data by weighting
individuals by their inverse probability of being uncensored [Graf et
al. 1999; Gerds & Schumacher 2006; Binder et al. 2009] (see {helpb brier}
for non-censored data). In settings without competing risks
{opt stbrier} can compute the Brier score of a parametric
({cmd:streg}) or semi-parametric Cox regression model ({cmd:stcox}),
and in the presence of competing risks, the Brier score of a Fine-Gray
regression model ({cmd:stcrreg}). To serve as a benchmark (null model),
{opt stbrier} can be computed without covariates [Gerds et
al. 2008]. Additionally, the user can use a simple wrapper program to
compute the integrated Brier score [Graf et al.1999] across all values
of {cmd:btime} (see the example below).

{pstd} The Brier score is a quadratic scoring rule defined as the
average of the squared differences between actual binary outcomes Y at
the prediction horizon {cmd:btime} and probabilities {it:p}. For
each individual the squared difference is calculated as (Y -
{it:p})^2, where {it:p} is the predicted risk of the event until
{cmd:btime} based on the baseline covariates of this individual and Y
is 1 if the event occured before {cmd:btime} for this individual, and
0 otherwise. The Brier score can range from 0 to 1, the lower the
better. A useful model should have a value lower than 0.25, because
this can be achieved by a non-informative model which predicts a 50%
risk of the event for all subjects, i.e. (Y - 0.50)^2.  When the
population average outcome risk at the prediction horizon {cmd:btime}
is lower or higher than 50%, then the Brier score of the benchmark
null model (without covariates) will be lower than 0.25 and a good
regression model which uses the covariates should outperform the null
model.
		
{title:Options}

{phang} {opt btime(#)} specifies the timepoint (prediction horizon) at
which the Brier score should be computed. Any {cmd:btime} value within
the range of the follow-up times can be specified. An error is
produced if {opt btime} is either not specified, or if the specified {cmd:btime} falls 
beyond the range of the data.

{phang}
{opt distribution(string)} specifies the survival distribution for an streg model; 
see {helpb streg} for available distributions. {helpb stcox} is implemented when 
{cmd:distribution()} and {cmd:compete()} are not specified.

{phang}
{cmd:compete(}{it:crvar}[{cmd:==}{it:{help numlist}}{cmd:])} specifies the events 
that are associated with failure due to competing risks (see {helpb stcrreg}).

{pmore}
If {opt compete(crvar)} is specified, {it:crvar} is interpreted as an 
indicator variable; any nonzero, nonmissing values are interpreted as 
representing competing events.

{pmore}
If {opt compete(crvar==numlist)} is specified, records with {it:crvar} taking
on any of the values in {it:numlist} are assumed to be competing
events.

{pmore} The syntax for {cmd:compete()} is the same as that for
{cmd:stset}'s {cmd:failure()} option.  Use {cmd:stset, failure()} to
specify the event of interest, that is, the event you wish to predict.
Use {cmd:stcrreg, compete()} to specify the event or events that
compete with the failure event of interest. 

{phang} {cmd:ipcw(}{it:{help varlist}}{cmd:)} specifies the covariates
to include in estimating the inverse probability of censoring weight
model.

{phang} 
{opt gen} generates a variable containing the observation-level {cmd:stbrier} scores. 

{phang}
{cmd: {it:model_options}} specifies all available options for {helpb streg} when the 
{cmd:model} option is chosen; {helpb stcrreg} when the {cmd:compete} option is chosen; 
otherwise all available options for {helpb stcox}.


{title:Examples with semi-parametric Cox regression}

{pstd}Setup{p_end}
{phang2}{cmd:. use GBSG2.dta, clear}{p_end}

{pstd}Declare data to be survival-time data{p_end}
{phang2}{cmd:. stset time, fail(cens)}{p_end}

{pstd}Estimate the stbrier score with no covariates (and {cmd:efron} option for ties) at time 1990, to serve as a benchmark for other models (this
is not equal, but asymptotically equivalent, to the Kaplan-Meier estimator){p_end}
{phang2}{cmd:. stbrier , bt(1990) efron}{p_end}

{pstd}Estimate the stbrier score at the median survival time, specifying the {cmd:efron} option for ties, and generate a variable for
individual-level stbrier scores{p_end}
{phang2}{cmd:. stsum}{p_end}
{phang2}{cmd:. stbrier i.horth ib2.menostat i.tgrade age tsize pnodes, efron ipcw(i.horth ib2.menostat i.tgrade age tsize pnodes) gen(brier) bt(1807)}{p_end}

{pstd}Estimate the stbrier score with strata{p_end}
{phang2}{cmd:. stbrier ib2.menostat i.tgrade age tsize pnodes, bt(1990) strata(horth) efron ipcw(ib2.menostat i.tgrade age tsize pnodes)}{p_end}


{title:Example with parametric survival regression}

{pstd} Estimate the stbrier score at time 2000 using an exponential distribution for the event time and no covariates in either the risk model or IPCW model{p_end}
{phang2}{cmd:. stbrier , d(expon) btime(2000)}{p_end}

{pstd}Estimate the stbrier score using survival regression with an exponential distribution, specifiying certain covariates in the IPCW model, and
generating a variable for individual-level stbrier scores{p_end}
{phang2}{cmd:. stbrier i.horth ib2.menostat i.tgrade age tsize pnodes, d(expon) ipcw(i.tgrade age tsize) gen(brier) btime(2000)}{p_end}

{pstd}Estimate the stbrier score using a Weibull regression model, and generating a variable for individual-level stbrier
scores{p_end}
{phang2}{cmd:. stbrier i.horth ib2.menostat i.tgrade age tsize pnodes, d(weib) btime(2000) ipcw(i.tgrade age tsize) gen(brier)}{p_end}


{title:Example with competing-risk regression}

{pstd}Setup{p_end}
{phang2}{cmd:. use melanoma.dta, clear}{p_end}

{pstd}Declare data to be time-to-event data where the event of interest is status==1 {p_end}
{phang2}{cmd:. stset time, fail(status==1)}{p_end}

{pstd} Estimate the stbrier score at time 1000 using Fine-Gray regression, where the competing risk is status==2 without covariates in
the risk prediction model. We use covariates for the inverse probability of censoring weights{p_end}
{phang2}{cmd:. stbrier , comp(status==2) btime(1000) ipcw(age i.sex logthick i.ulcer) gen(brier)}{p_end}

{pstd}Same as above but now with covariates{p_end}
{phang2}{cmd:. stbrier age i.sex logthick i.ulcer, comp(status==2) btime(1000) ipcw(age i.sex logthick i.ulcer) gen(brier)}{p_end}


{title:Computing the integrated Brier score}

{pstd}Setup{p_end}
        {cmd:. use GBSG2.dta, clear}

{pstd}Declare data to be survival-time data{p_end}
        {cmd:. stset time, fail(cens)}

{pstd}Run loop over all time values in the data and generate a line graph{p_end}
        {cmd:levelsof _t, local(times)}
            {cmd:foreach i of local times {c -(}}
                 {cmd:stbrier i.horth ib2.menostat i.tgrade age tsize pnodes, efron ipcw(i.horth ib2.menostat i.tgrade age tsize pnodes) btime(`i') gen(br`i') }
            {cmd:{c )-}}
        {cmd:collapse (mean) br*}
        {cmd:gen id = _n}
        {cmd:reshape long br , i(id) j(_t)}
        {cmd:line br _t if _t <2100}


{title:Saved results}

{p 4 8 2}
By default, {cmd:stbrier} returns the following results, which can be displayed by typing {cmd: return list} after 
{cmd:stbrier} is finished (see {help return}).  

{synoptset 10 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(brier)}} mean Brier score{p_end}

{synoptset 10 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(table)}} estimates from mean table{p_end}



{title:References}

{p 4 8 2}
Binder H, Allignol A, Schumacher M, Beyersmann J. Boosting for high-dimensional time-to-event data with competing risks. 
{it:Bioinformatics} 2009;25(7):890{c -}896.

{p 4 8 2}
Gerds TA, Cai T, Schumacher M. The performance of risk prediction models. 
{it:Biom J} 2008;50:457{c -}479.

{p 4 8 2}
Gerds TA, Scheike TH, Blanche P, Ozenne B. riskRegression: Risk Regression Models and Prediction Scores 
for Survival Analysis with Competing Risks. {it:R} package version 1.3.7. (2017). {browse "https://CRAN.R-project.org/package=riskRegression"}

{p 4 8 2}
Gerds TA, Schumacher M. Consistent estimation of the expected Brier score in general survival models 
with right-censored event times. 
{it:Biom J} 2006;48:1029{c -}1040.

{p 4 8 2}
Graf E, Schmoor C, Sauerbrei W, Schumacher M. Assessment and comparison of prognostic classification 
schemes for survival data. 
{it:Stat in Med} 1999;18:2529{c -}2545.

{p 4 8 2}
Schumacher M, Graf E, Gerds T. How to assess prognostic models for survival data: a case study in oncology. 
{it:Methods Inf Med} 2003;42:564{c -}571.

{p 4 8 2}
Steyerberg EW, Vickers AJ, Cook NR, Gerds T, Gonen M, Obuchowski N, Pencina MJ, Kattan MW. 
Assessing the performance of prediction models: a framework for some traditional and novel measures. 
{it:Epidemiology} 2010;21:128{c -}138.



{marker citation}{title:Citation of {cmd:stbrier}}

{p 4 8 2}{cmd:stbrier} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A, Gerds TA, Huber C. (2017). STBRIER: Stata module for estimating the Brier score for survival (censored) data. {browse "https://ideas.repec.org/c/boc/bocode/s458368.html"} {p_end}


{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}
{browse "http://www.lindenconsulting.org"}{p_end}

{p 4 4 2}
Thomas A Gerds {break}
Professor, University of Copenhagen{break}
tag@biostat.ku.dk{break}

{p 4 4 2}
Chuck Huber{break}
Senior Statistician, StataCorp, LLC{break}
chuber@stata.com{break}


        
{title:Acknowledgments} 

{p 4 4 2}
We wish to thank Isabel Canette, Yulia Marchenko, and Nick J Cox for their support while developing {cmd:stbrier}.{p_end}


{title:Also see}

{p 4 8 2}Online: {helpb stcox}, {helpb stcox postestimation}, {helpb streg}, {helpb streg postestimation}, 
{helpb stcrreg}, {helpb stcrreg postestimation}, {helpb sts list}, {helpb stsum}, {helpb brier} {p_end}
