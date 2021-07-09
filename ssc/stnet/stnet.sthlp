{smcl}
{* *! version 0.0.4 **Jun2020}{...}
{cmd:help stnet} 
{right:also see:  {help strs} {help stpp}}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:stnet} {hline 2}}Estimating net survival{p_end}
{p2colreset}{...}

{title:Syntax}

{p 4 10 4}
{cmd:stnet}
{cmd:using} {it:filename} 
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmdab:iw:eight}{it:=varname}]
, 	
{cmdab:m:ergeby}{cmd:(}{it:varlist}{cmd:)}
{cmdab:diag:date}{cmd:(}{it:varname}{cmd:)}
{cmdab:birth:date}{cmd:(}{it:varname}{cmd:)}
[{cmdab:br:eaks}{cmd:(}{it:range}{cmd:)} 
{cmd:unique}
{cmd:by}{cmd:(}{it:varlist}{cmd:)}
{cmd:attage}{cmd:(}{it:newvar}{cmd:)}
{cmd:attyear}{cmd:(}{it:newvar}{cmd:)}
{cmd:survprob}{cmd:(}{it:varname}{cmd:)}
{cmd:maxage}{cmd:(}{it:int 99}{cmd:)}
{cmdab:ed:erer2}
{cmdab:stand:strata}{cmd:(}{it:varname}{cmd:)}
{cmd:brenner}
{cmdab:indwe:ight}{cmd:(}{it:varname}{cmd:)}
{cmdab:li:st}{cmd:(}{it:varlist}{cmd:)}
{cmd:at(}{it:#}|{it:{help numlist}}{cmd:)}
{cmd:listyearly}
{cmdab:f:ormat:(%}{it:fmt}{cmd:)}
{cmdab:notab:les}
{cmdab:l:evel}{cmd:(}{it:int}{cmd:)}
{cmd:saving(}{it:filename}[{cmd:,replace}]{cmd:)} 
{cmdab:savst:and(}{it:filename}[{cmd:,replace}]{cmd:)} 


{p}{cmd:stnet} is for use with survival-time data; see help {help st}. 
You must stset your data with time since entry in years as the timescale before using {cmd:stnet}; see help {help stset}.{p_end}

{p}{cmdab:iw:eight}s are allowed; see help {help weights} and see example using weights below. Weights must be specified as 
[{cmd:iweight}{it:=varname}]{p_end}.


{title:Description}

{p}{cmd:stnet} estimates net survival as proposed by Pohar Perme, Stare and Estève (Biometrics 2011) by using a life tables approach.
The command displays the results in life tables stratified by the variables specified in the {cmd:by} option. 
Optionally relative survival using the Ederer II method can be calculated. 
This command may be used also for period or hybrid analysis and to compute adjusted (weighted) estimates.{p_end}

{p}{cmd:using} {it:filename} specifies a file containing general population survival 
probabilities (conditional probabilities of surviving one year), typically stratified by age, sex, and calendar year.
Age must be specified in one year increments (typically from 0 to 99) and calendar year in one year intervals. 
The file must be sorted by the variables specified in {cmd:mergeby()}. Default names for variables in this 
file are {it:prob} for the survival probabilities (see the {cmd:survprob()} option), {it:_age} for age 
(see the {cmd:attage()} option), and {it:_year} for calendar year (see the {cmd:attyear()} option). 
The maximum age is specified using the {cmd:maxage()} option (default is 99).{p_end}



{title:Options}

{p 0 4}{cmdab:m:ergeby}{cmd:(}{it:varlist}{cmd:)} specifies the variables which uniquely determine the records 
in the file of general population survival probabilities. This file must also be sorted by these variables.

{p 0 4}{cmdab:diag:date}{cmd:(}{it:varname}{cmd:)} specifies the variable containing the date of diagnosis. 

{p 0 4}{cmdab:birth:date}{cmd:(}{it:varname}{cmd:)} specifies the variable containing the date of birth.

{p 0 4}{cmdab:br:eaks}{cmd:(}{it:range}{cmd:)} specifies the cutpoints for the lifetable intervals as 
{it:range} in the {help forvalues} command. The units must be years, e.g., use {cmd:breaks}{cmd:(}{it:0(0.08333333)5}{cmd:)} 
for monthly intervals up to 5 years.

{p 0 4}{cmd:unique} specifies that cutpoints for the lifetable intervals must correspond to each observed survival time.

{p 0 4}{cmdab:by}{cmd:(}{it:varlist}{cmd:)} specifies the life table stratification variables. One life table is
estimated for each combination of these variables.

{p 0 4}{cmd:attage}{cmd:(}{it:newvar}{cmd:)} specifies the variable containing attained age (i.e., age at the time of
follow-up). This variable cannot exist in the patient data file (it is created from the difference between date of diagnosis and 
date of birth plus follow-up time) but must exist in the using file. Default is {it:_age}.

{p 0 4}{cmd:attyear}{cmd:(}{it:newvar}{cmd:)} specifies the variable containing attained calendar 
year (i.e. calendar year at the time of follow-up). This variable cannot exist in the patient 
data file (it is created form the date of diagnosis plus follow-up time) but must 
exist in the using file. Default is {it:_year}.

{p 0 4}{cmdab:surv:prob}{cmd:(}{it:varname}{cmd:)} specifies the variable in the using file that contains 
the g.eneral population survival probabilities. Default is {it:prob}.

{p 0 4}{cmdab:maxage}{cmd:(}{it:int 99}{cmd:)} specifies the maximum age for which general  
population survival probabilities are provided in the using file. Probabilities for 
individuals older than this value are assumed to be the same as for the maximum age.

{p 0 4}{cmdab:ed:erer2} specifies that Ederer II relative survival estimates be calculated. Note that {cmd:stnet} 
calculates the observed survival by transforming the interval specific cumulative hazard (Dickman). Therefore the results
are not exactly equal to those obtained by using {cmd:ltable}. 

{p 0 4}{cmdab:li:st}{cmd:(}{it:varlist}{cmd:)} specifies the variables to be listed in the life tables. The variables
start and end are included by default, but if only one of these is specified in the list option then the other is suppressed.

{p 0 4} {cmd:at(}{it:#}|{it:{help numlist}}{cmd:)} reports estimated net survival at specified times.

{p 0 4}{cmd:listyearly} display the net survival estimates at the end of each year of the time of the follow-up.

{p 0 4}{cmdab:stand:strata}{cmd:(}{it:varname}{cmd:)} specifies a variable defining strata across which
to average the cumulative survival estimate. Weights must be given by [{cmd:iweight}{it:=varname}].

{p 0 4}{cmd:brenner} specifies that the age adjustment be performed using the approach proposed by Brenner et al (2004). 
This option requires that [iweight] and standstrata() are also specified.

{p 0 4}{cmdab:indwe:ight}{cmd:(}{it:varname}{cmd:)} specifies a variable where individual weights are defined.
This option allows the user to pass any kind of weights.
When weights are supplied this way, {cmdab:stand:strata}{cmd:(}{it:varname}{cmd:)} and {cmd:brenner} cannot be used.

{p 0 4}{cmdab:f:ormat:(%}{it:fmt}{cmd:)} specifies the {help format} for variables containing 
survival estimates. Default is %6.4f.

{p 0 4}{cmdab:notab:les} suppresses display of the life tables.

{p 0 4}{cmdab:l:evel}{cmd:(}{it:int}{cmd:)} sets the confidence level; default is based on 
the value of the global macro S_level which, by default, takes the value 95.

{p 0 4}{cmd:saving(}{cmd:(}{it:filename}[{it:replace}{cmd:)}] saves in {it: filename} a data sets containing one 
observation for each life table interval. 

{p 0 4}{cmdab:savst:and(}{it:filename}[{it:,replace}]{cmd:)} saves in {it: filename} standardised estimates. 



{title:Example: Net survival (Pohar Perme and coll.) by sex using 1 month as length of interval in the life table}

{p 4 8 2}{cmd:. stnet using lifetab, br(0(.083333333)10) mergeby(_year sex _age) diagdate(dx) birthdate(bdate) by(sex)}



{title:Example: Net survival (Pohar Perme and coll.) by sex where cutpoints of interval in the life table correspond to each observed survival time}

{p 4 8 2}{cmd:. stnet using lifetab, unique mergeby(_year sex _age) diagdate(dx) birthdate(bdate) by(sex) at(1(1)10)}

When using {cmd:unique}, results shown may be very long. Therefore, we also specifies {cmd:at(}{it:{help numlist}}{cmd:)} to show results only at specified {cmd:(}{it:{help numlist}}{cmd:)}

Note that, when {cmd:unique} is specified, the time-scale is still split into a number of intervals and our life table approach is applied for the estimation of net survival.
This is a different implementation to {cmd:stpp} and {cmd:stns}. In our experience results of both approaches are very close.  



{title:Example: Ederer II estimates by sex}

{p 4 8 2}{cmd:. stnet using lifetab, br(0(0.083333333)10) mergeby(_year sex _age) diagdate(dx) birthdate(bdate) by(sex) ederer2}



{title:Example: Estimation using a period approach}

{p} The approach is to first {help stset} the data with calendar time as the timescale.
For example, we might be interested in the time at risk between 1 January 2005 and 31 December 2007. 

{p 4 8 2}{cmd:. stset datafu, fail(status==1 2) origin(dx) enter(time mdy(1,1,2005)) exit(time mdy(12,31,2007)) scale(365.241)} 

We then can use {cmd:stnet} in the usual manner to get net survival and Ederer II estimates

{p 4 8 2}{cmd:. stnet using lifetab, br(0(0.083333334)10) mergeby(_year sex _age) diagdate(dx) birthdate(bdate) by(sex) ederer2}



{title:Example: Age-standardised estimates of net survival}

{p}To age-standardise using traditional direct standardisation we could specify the following command

{p 0}{cmd:. stnet using lifetab [iw=standwei], br(0(.083333334)10) mergeby(_year sex _age) diagdate(dx) birthdate(bdate) by(sex)  standstrata(agegroup)}
 
{p}{cmd:stnet} first constructs life tables for each level of sex and agegroup then calculates age-standardised estimates 
for each sex by weighting the age-specific estimates using the weights specified in the variable {it:standwei}.
The strata across which to average are defined using the {cmdab:standstrata(}{it:varname}{cmd:)} option; a variable 
containing the weights (which must be less than 1) must exist in the data set and be specified using the {cmdab:iweight=} option.

{p}Standard errors are estimated using the approach described by Corazziari et al (2004).



{title:Example: Age-adjusted estimates of net survival according to Brenner and Hakulinen approach}

{p}When data are sparse the traditional age-standardisation can fail to produce age-adjusted net survival estimates.
Rather than weighting based on the age distribution at the start, Brenner and Hakulinen (2004) propose using weights that change throughout follow-up time. 
This approach allows to produce comparable net survival estimates even when data are sparse by assigning individual weights to each patient 
and constructing a weighted life table. 

{p 0}{cmd:. stnet using lifetab [iw=standwei], br(0(.083333334)10) mergeby(_year sex _age) diagdate(dx) birthdate(bdate) by(sex)  standstrata(agegroup) brenner}{p_end}
 
{p}We can assign other user-defined individual weights by specifying {cmd: indweight(varname)}. For example, we can reproduce the above age-adjusted 
net survival estimates by the following commands{p_end} 
{p 0}{cmd:. local total = _N}{p_end}
{p 0}{cmd:. bysort agegroup: gen a_age = _N/`total'}{p_end}
{p 0}{cmd:. gen wt = (standwei/a_age)}{p_end}
{p 0}{cmd:. stnet using lifetab , br(0(.083333334)10) mergeby(_year sex _age) diagdate(dx) birthdate(bdate) by(sex) indweight(wt)}{p_end}

{p 0}When {cmd: indweight(varname)} are specified {cmd: standstrata(agegroup)} and {cmd: [iw=standwei]} no longer need.{p_end}



{title:Example: Saving estimates}

{p}Saving estimates is needed to graph net survival estimates

{p 0}{cmd:. stnet using lifetab, br(0(.083333334)10) mergeby(_year sex _age) diagdate(dx) birthdate(bdate) by(sex) saving(colonnetsurv,replace)}



{title:Remarks}

{p} Net survival is the function of interest for cancer registries because it is the survival that we can measure
if cancer is the only cause of death. Therefore it is suitable to compare cancer survival among different populations and
to analyze survival trends. Pohar Perme and coll. shown that the correlation between cancer survival and other causes survival
must be taken into account to properly estimate the net survival. They propose a method based on the inverse probability weights.
For each individual weights are given by the inverse of its expected survival probability computed from the survival probabilities 
of the general population supplied in the {cmd:using} file. 
Danieli and coll. proven that the method proposed by Pohar Perme and coll. actually estimates the net survival.{p_end}

{p} In {cmd:stnet} we apply a life table approach for the estimation of the net survival. First we compute for each interval the cumulative
weighted excess hazard given by {p_end}
{center: Hw = {it:k} x (dw - d_hatw) / pyw}.

{p} where {it:k} is the length of the interval, dw is the weighted number of deaths, d_hatw is the weighted 
number of the expected deaths and pyw are the weighted person-years at risk. Then we transform it in the interval specific net survival 
by {p_end}
{center:NS = exp(-Hw)} 

{p}Finally the cumulative net survival is obtained by the product of the interval specific estimates.{p_end} 

{p}Since this approach assumes that hazard and weights are constant within the interval, {cmd:stnet} is
sensitive to the choice of interval length. In our checks by specifying one month as interval length the NS computed by 
{cmd:stnet} is usually very close to the results obtained by using the {it:rs.surv} function, available within the {it:relsurv} package
on R software, that calculates NS at each time deaths and censorings happen in the data set. Longer intervals usually 
cause {cmd:stnet} underestimates NS computed by {it:rs.surv}.{p_end}



{title:Authors}

{p}Enzo Coviello ({browse "mailto:enzocovi@gmail.com":enzocovi@gmail.com}), Paul Dickman, Karri Seppa, and Arun Pokhrel.{p_end}


{title: Aknowledgments}

{p} I wish to thank Mark Rutherford for making available the code for the simulations of relative survival data and other tests of the command.
Also thanks to Mark Rutherford and Paul Lambert for drawing attention to the usefulness of Brenner age-standardisation.{p_end}



{title:References}

{p} Pohar Perme M, Stare J, Estève J 
{browse "http://www.ncbi.nlm.nih.gov/pubmed/21689081":On estimation in relative survival},
{it:Biometrics} 2012 Mar;68(1):113-20.{p_end}

{p} Danieli C, Remontet L, Bossard N, Roche L, Belot A. 
{browse "http://www.ncbi.nlm.nih.gov/pubmed/22281942":Estimating net survival: the importance of allowing for informative censoring}
{it:Statistics in Medicine} 2012 Apr 13;31(8):775-86{p_end}

{p} Dickman P.
{browse "http://www.pauldickman.com/rsmodel/stata_colon/standard_errors.pdf":Standard errors of observed and relative survival in strs}.{p_end}

{p} Corazziari I, Quinn M, Capocaccia R.
{browse "http://www.ncbi.nlm.nih.gov/pubmed/15454257":Standard cancer patient population for age standardising survival ratios},
{it:European Journal of Cancer} 2004;40:2307-16.{p_end}

{p} Brenner H., Arndt V., Gefeller O., Hakulinen T.  
{browse "https://www.ncbi.nlm.nih.gov/pubmed/15454258":An alternative approach to age adjustment of cancer survival rates},
{it:European Journal of Cancer 2004;40:2317-2322.{p_end}

{p} Sasieni P, Brentnall A.R.
{browse "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5507182/":On Standardized Relative Survival},
{it:Biometrics} 2017;73:473-482.{p_end}


{p 0 19}On-line:  help for {help stset}, {help strs}, {help ltable}

