{smcl}
{* *! version 1.0.0 20dec2018}{...}

{title:Title}

{p2colset 5 12 21 2}{...}
{p2col:{hi:mpr} {hline 2}} Medication Possession Ratio  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}


{p 8 17 2}
{cmd:mpr} {it: fill_date}  {it: days_supply}  {ifin}
{cmd:,} [ {opt id(str)} {opt dr:ug(str)} {opt sta:rt(str)} {opt end(str)} {opt len:gth(#)} ]


{pstd}
In the syntax, {it:fill_date} is the date when the prescription was filled and {it:days_supply} is the number of days that the medication was intended to last.

{synoptset 19 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt id(string)}}specifies the panel identifier if the data contain multiple patients{p_end}
{synopt :{opt dr:ug(string)}}specifies the drug variable if the data contain multiple medications{p_end}
{synopt:{opt sta:rt(string)}}specifies a study start-date in the DDmonCCYY format (e.g. 01feb2018); default is to use the first fill_date in the data {p_end}
{synopt:{opt end(string)}}specifies a study end-date in the DDmonCCYY format (e.g. 31dec2018); default is to use the date corresponding to the last ({it:fill_date} + {it:days_supply}) - 1 {p_end}
{synopt:{opt len:gth(#)}}specifies a study {it:duration} as an alternative to specifying {cmd:end()}. Either {cmd:length()} or {cmd:end()} can be specified, but not both{p_end}
{synoptline}

{p 4 6 2}
{p2colreset}{...}				
	
{title:Description}

{pstd}
The Medication Possession Ratio (MPR) is a widely-used measure of {it:adherence} (also referred to as {it:compliance}) to a medication regimen. 
It utilizes administrative pharmacy claims data to assess how frequently patients refill their prescriptions, 
and assumes that patients who refill their prescriptions regularly also consume the medications as prescribed. 
The general formula for MPR is:{p_end}


	sum of supply (doses) in the observation period
	-----------------------------------------------
	   number of days in the observation period


{pstd}
In this equation, the numerator indicates the sum of the doses (e.g. total pill count) filled in the observation period. A ratio of 1.0 indicates perfect 
adherence, whereas a ratio of 0 indicates complete non-adherence. The primary criticism of MPR as a measure of adherence is that the resulting ratio may be 
greater than 1.0 if the amount of drug on hand is greater than the number of days in the observation period (due to refilling the prescription prior to exhausting
the quantity of the medication on hand). Some investigators deal with this issue by truncating the MPR value to 1.0. {cmd:mpr} retains the true ratio (which may be greater 
than 1.0) and allows the user to determine whether to truncate or not. {p_end}

{pstd}
{cmd:mpr} computes the medication possession ratio under a large number of scenarios. The MPR can be computed for a single patient or multiple patients, 
with prescriptions filled for one medication or multiple medications. Moreover, {cmd:mpr} provides the user with tremendous flexibility in specifying the observation period.
The two most common methods for setting the observation period are; (1) a {it:fixed} observation period, which keeps the denominator constant at a fixed time
interval (e.g. by specifying {cmd: start()} and {cmd: end()}, or by specifying {cmd: start()} and {cmd: length()}) and (2), a {it:variable} observation period, 
which allows the number of days in the denominator to vary, depending on how the user specifies either the {cmd: start()} or {cmd: end()} of the observation period. 
For example, specifying {cmd: start()} but not {cmd: end()} will result in the total days of supply in the last refill to be counted in the MPR (while the first
fill may be truncated for the days of supply spanning earlier than the observation start date). Conversely, specifying {cmd: end()} but not {cmd: start()} 
will result in the total amount of supply in the first prescription to be counted in the MPR (while the last refill may be truncated if the days supply of refill 
spans beyond the observation end date).    



{title:Options}

{p 4 8 2}
{cmd:id(}{it:string}{cmd:)} the panel identifier if the data contain multiple patients. When {cmd:id()} is not specified, {cmd:mpr} assumes that there is
a single patient in the data.

{p 4 8 2}
{cmd:drug(}{it:string}{cmd:)} the variable specifying the drug if the data contain multiple medications per patient. When {cmd:drug()} is not specified, {cmd:mpr} assumes that there is
only one medication per patient in the data.

{p 4 8 2}
{cmd:start(}{it:string}{cmd:)} represents the desired start date of an observation (study) period, and must be specified in the DDmonCCYY format (e.g. 01feb2018). When {cmd: start()}
is not specified, {cmd:mpr} uses the first {it:fill_date}.

{p 4 8 2}
{cmd:end(}{it:string}{cmd:)} represents the desired end date of an observation (study) period, and must be specified in the DDmonCCYY format (e.g. 31dec2018). When {cmd: end()}
is not specified, {cmd:mpr} uses the date corresponding to the last ({it:fill_date} + {it:days_supply}) - 1. 

{p 4 8 2}
{cmd:length(}{it:#}{cmd:)} specifies a study duration as an alternative to specifying {cmd:end()}. Either {cmd:length()} or {cmd:end()} can be specified, but not both.
		

{title:Examples}

{pstd}
There are four possible scenarios in which {cmd:mpr} can be implemented: 1) a
single patient with a single medication, 2) a single patient on multiple medications, 
3) multiple patients on a single medication, and 4) multiple patients on multiple medications.  The
examples below are described accordingly:


{pstd}
{opt 1) A single patient on a single medication:}{p_end}

{pmore} setup {p_end}
{pmore2}{bf:{stata "use medadheredata.dta, clear":. use medadheredata.dta, clear}}{p_end}
{pmore2}{bf:{stata "keep if id==1 & drug==1": . keep if id==1 & drug==1}} {p_end}

{pmore}
If the data are for a single patient and single medication, we do not specify either {cmd: id()} or {cmd: drug()}. 
Here we specify the start and end dates of the observation period to span all days in 2013.{p_end}

{phang3}{bf:{stata "mpr fill_date days_supply,  start(01jan2013) end(31dec2013)": . mpr fill_date days_supply,  start(01jan2013) end(31dec2013)}}{p_end}


{pstd}
{opt 2) A single patient on multiple medications:}{p_end}

{pmore} setup {p_end}
{pmore2}{bf:{stata "use medadheredata.dta, clear":. use medadheredata.dta, clear}}{p_end}
{pmore2}{bf:{stata "keep if id==1": . keep if id==1}} {p_end}

{pmore}
If the data are for a single patient on multiple medications, we do specify {cmd: drug()} but not {cmd: id()}. 
Here we specify the start date and length of the observation period to span 365 days in 2013 (as an alternative to specifying {cmd: end()}).{p_end}

{phang3}{bf:{stata "mpr fill_date days_supply, drug(drug) start(01jan2013) length(365)": . mpr fill_date days_supply, drug(drug) start(01jan2013) length(365)}}{p_end}


{pstd}
{opt 3) Multiple patients on a single medication:}{p_end}

{pmore} setup {p_end}
{pmore2}{bf:{stata "use medadheredata.dta, clear":. use medadheredata.dta, clear}}{p_end}
{pmore2}{bf:{stata "keep if drug==1": . keep if drug==1}} {p_end}

{pmore}
If the data are for multiple patients and a single medication, we specify {cmd: id()} but not {cmd: drug()}. 
Here we do not specify the start date, which means that {cmd:mpr} will use the earliest {it:filldate} as the start date. We set the end date of the observation period
at 30June2013 (allowing each patient to have a different observation duration).{p_end}

{phang3}{bf:{stata "mpr fill_date days_supply, id(id) end(30jun2013)": . mpr fill_date days_supply, id(id) end(30jun2013)}}{p_end}


{pstd}
{opt 4) Multiple patients on multiple medications:}{p_end}

{pmore} setup {p_end}
{pmore2}{bf:{stata "use medadheredata.dta, clear":. use medadheredata.dta, clear}}{p_end}

{pmore}
If the data are for multiple patients on multiple medications, we specify both {cmd: id()} and {cmd: drug()}. 
Here we do not specify either the start date or the end date, but specify the observation period as being 180 days.{p_end}

{phang3}{bf:{stata "mpr fill_date days_supply, id(id) drug(drug) length(180)": . mpr fill_date days_supply, id(id) drug(drug) length(180)}}{p_end}

{pmore}
If there is a sufficient sample size, we could also look at confidence intervals.{p_end}

{phang3}{bf:{stata "mean mpr, over(drug)":. mean mpr, over(drug)}}{p_end}

{pmore} or alternatively {p_end}

{phang3}{bf:{stata "ratio supply study_days, over(drug)":. ratio supply study_days, over(drug)}}{p_end}

{pmore}
Some investigators prefer to dichotomize the adherence rate at a cut-point at 0.80, in 
which patients above the cut-point are considered adherent and those below the cut-point are considered non-adherent. 
Here we generate a binary variable and then tabulate by drug.{p_end}

{phang3}{bf:{stata "generate mpr80 = cond(mpr >= .80,1,0)":. generate mpr80 = cond(mpr >= .80,1,0)}}{p_end}
{phang3}{bf:{stata "tabulate mpr80 drug, column":. tabulate mpr80 drug, column}}{p_end}



{title:References}

{p 4 8 2}
Andrade, S. E., Kahler, K. H., Frech, F., and Chan, K. A. (2006). Methods for evaluation of medication adherence and persistence using automated databases. 
{it:Pharmacoepidemiology and drug safety} 15: 565-574. {p_end}

{p 4 8 2}
Cramer, J. A., Roy, A., Burrell, A., Fairchild, C. J., Fuldeore, M. J., Ollendorf, D. A., & Wong, P. K. (2008). 
Medication compliance and persistence: terminology and definitions. {it:Value in Health} 11: 44-47. {p_end}

{p 4 8 2}
Farmer, K. C. (1999). Methods for measuring and monitoring medication regimen adherence in clinical trials and clinical practice. 
{it:Clinical Therapeutics} 21: 1074-1090. {p_end}

{p 4 8 2}
Hess, L. M., Raebel, M. A., Conner, D. A. and Malone, D. C. (2006). Measurement of adherence in pharmacy administrative databases: a proposal 
for standard definitions and preferred measures. {it:Annals of Pharmacotherapy} 40: 1280-1288. {p_end}

{p 4 8 2}
Peterson, A. M., Nau, D. P., Cramer, J. A., Benner, J., Gwadry-Sridhar, F. and Nichol, M. (2007). 
A checklist for medication compliance and persistence studies using retrospective databases. {it:Value in Health} 10: 3-12. {p_end}

{p 4 8 2}
Steiner, J. F., Koepsell, T. D., Fihn, S. D., & Inui, T. S. (1988). A general method of compliance assessment 
using centralized pharmacy records: description and validation. {it:Medical care} 26: 814-823. {p_end}



{marker citation}{title:Citation of {cmd:mpr}}

{p 4 8 2}{cmd:mpr} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2018). MPR: Stata module for computing the Medication Possession Ratio. 
{browse "http://ideas.repec.org/c/boc/bocode/s458547.html":http://ideas.repec.org/c/boc/bocode/s458547.html} {p_end}



{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}


{title:Also see}

{p 4 8 2} Online: {helpb pdc} (if installed){p_end}

