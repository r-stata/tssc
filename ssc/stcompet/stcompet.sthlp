{smcl}
{* 06nov2012}{...}
{hline}
help for {hi:stcompet}
{hline}

{title:Generate Cumulative Incidence in presence of Competing Events}

{p 4 13}{cmd:stcompet} {it:newvarname} {cmd:=} {c -(} {cmd:ci} | {cmd:se} | {cmd:hi} | {cmd:lo} {c )-}
[[{it:newvarname} {cmd:=} {it:...}] [{it:...}] ] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] {cmd:,}
{cmd:compet1(}{it:numlist}{cmd:)} [{cmd:compet2(}{it:numlist}{cmd:)} {cmd:compet3(}{it:numlist}{cmd:)}
{cmd:compet4(}{it:numlist}{cmd:)} {cmd:compet5(}{it:numlist}{cmd:)} {cmd:compet6(}{it:numlist}{cmd:)}
{cmd:by(}{it:varname}{cmd:)} {cmdab:allign:ol} {cmdab:l:evel}{cmd:(}{it:#}{cmd:)} ]



{p 4 4 2}
{cmd:stcompet} is for use with survival-time data; see help {help st}. You must 
have {cmd:stset} your data before using this command; see help {help stset}.{p_end}
{p 4 4 2}
In previous {cmd:stset} you must specify {cmdab:f:ailure(}{it:varname}{cmd:==}{it:numlist}
{cmd:)} where {it:numlist} refers to the event of interest.


Examples:

{p 4 4}Generate variables containing Cumulative Incidence and Standard Error{p_end}
{p 12 20}{inp:. stset survtime, f(event==1)}{p_end}
{p 12 20}{inp:. stcompet CumInc = ci SError = se, compet1(2) compet2(4)}{p_end}

{p 4 4}Generate variables containing Cumulative Incidence Confidence Bounds{p_end}
{p 12 20}{inp:. stcompet High = hi Low = lo, compet1(2) compet2(4)}{p_end}

{p 4 4}Note that each created variable contains the function for all competing events : i.e. the
event of interest specified in stset statement and the events in compet# options. So if you want graph functions relating to each event
you need to type:{p_end} 
{p 12 20}{inp:. gen CumInc1 = CumInc if event==1}{p_end}
{p 12 20}{inp:. gen CumInc2 = CumInc if event==2}


{title:Description}

{p 4 4 2}
In survival or cohort studies the failure of an individual may be one of several distinct 
failure types. In such a situation we observe an event of interest and one or more competing
events whose occurrence precludes or alters the probability of occurence of the first one.
{cmd:stcompet} creates variables containing Cumulative Incidence, a function that in this case
appropriately estimates the probability of occurrence of each endpoint, corresponding Standard
Error and Confidence Bounds.{p_end}
{p 4 4 2}The values in {it:numlist} of the previous {cmd:stset} are assumed as occurrence of event of interest.
In {cmd:compet#()} options you can specify {it:numlist} relating to the occurrence of up to six 
competing events.{p_end}



{title:Functions}

{p 4 8 2}
{cmd:ci} produces the cumulative incidence function.

{p 4 8 2}
{cmd:se} produces the standard error of the cumulative incidence.

{p 4 8 2}
{cmd:hi} produces the higher bound of the confidence interval based on 
ln[-ln(Cumulative Incidence)].

{p 4 8 2}
{cmd:lo} produces the lower bound of the confidence interval based on 
ln[-ln(Cumulative Incidence)].


{title:Options}

{p 4 8 2}
{cmd:compet1(}{it:numlist}{cmd:)} is not an option because at least one event must
compete with the event of interest. A failure of a competing event occurs whenever 
{it:failvar} specified in the previous {cmd:stset } takes on any of the values of this 
{it:numlist}. Note that the function required will be estimated relating to this
competing event and to the event of interest as well.

{p 4 8 2}
{cmd:compet2(}{it:numlist}{cmd:)}{it:...}{cmd:compet6(}{it:numlist}{cmd:)} 
are optional. Each {it:numlist} refers to a failure for other competing events.

{p 4 8 2}
{cmd:by(}{it:varname}{cmd:)} produces separate functions by making
separate calculations for each group identified by equal values of the
{cmd:by()} variable taking on integer or string values.

{p 4 8 2}
{cmd:allignol} specifies that confidence bounds are computed
by applying log-log transformation to 1-cumulative incidence as suggested by Lin (1997) and Allignol et al.(2010).
Confidence bounds are then equal to those obtained via the {it:etm} package in R. 

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} specifies the confidence level, in percent,
for the pointwise confidence interval around the cumulative incidence functions; 
see help {help level}.



{title:Remarks}

{p 4 4 2}
Cumulative Incidence is estimated by summing up to {it:t} {space 2} S{it:(t-1)} * h'{it:(t)},
{space 2} where S{it:(t-1)} is the KME of the overall survival function and h'{it:(t)} is 
the cause-specific hazard at the time {space 1}{it:t}.

{p 4 4 2}
Standard errors are computed according to the formula in Marubini & Valsecchi
(1995) p. 341. They derive the estimator using delta method.{p_end}

{p 4 4 2}
{cmd:stcompet} may by used also with left-truncated survival data.


{title:Also see}

{p 4 13}
On-line:  {manhelp stset ST}, {manhelp sts_gen ST: sts gen}, {manhelp stcrreg ST}


{title:References}

{p 0 4 2} 1 - Marubini E., Valsecchi M.G. Analysing Survival Data from Clinical Trials and 
Observational Studies. Wiley: Chichester, 1995.

{p 0 4 2} 2 - Choudhury J.B. Non-parametric confidence interval estimation for competing risks 
analysis: application to contraceptive data. Statistics in Medicine 2002; 21: 1129-1144.

{p 0 4 2} 3 - Gooley T.A., Leisenring W., Crowley J., and Storer B.E. Estimation of failure probabilities
in the presence of competing risks: new representations of old estimators. Statistics in 
Medicine 1999; 18: 695-706.

{p 0 4 2} 4 - Lin D.Y. Non-parametric inference for cumulative incidence functions in competing risks studies. 
Statistics in Medicine 1997; 16: 901-910.

{p 0 4 2} 5 - Allignol A., Schumacher M., and Beyersmann, J. A note on variance estimation of the Aalen-Johansen 
estimator of the cumulative incidence function in competing risks, with a view toward left-truncated data. 
Biometrical Journal 2010; 52(1): 126-137.


{title:Authors}

        Enzo Coviello, Local Health Unit BT, Italy
        enzo.coviello@tin.it
        
        May Boggess
