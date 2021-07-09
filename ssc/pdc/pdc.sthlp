{smcl}
{* *! version 1.2.0 15apr2019}{...}

{title:Title}

{p2colset 5 12 21 2}{...}
{p2col:{hi:pdc} {hline 2}} Proportion of Days Covered (of a medication) {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}


{p 8 17 2}
{cmd:pdc} {it: fill_date}  {it: days_supply}  {ifin}
{cmd:,} [ {opt id(str)} {opt dr:ug(str)} {opt sta:rt(str)} {opt end(str)} {opt len:gth(#)} {opt cred:it} ]


{pstd}
In the syntax, {it:fill_date} is the date when the prescription was filled and {it:days_supply} is the number of days that the medication was intended to last.

{synoptset 19 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt id(string)}}specifies the patient identifier if the data contain multiple patients{p_end}
{synopt :{opt dr:ug(string)}}specifies the drug variable if the data contain multiple medications{p_end}
{synopt:{opt sta:rt(string)}}specifies a study start-date and must be specified in the DDmonCCYY format, such as start(01jan2013); default is to use the first fill_date in the data {p_end}
{synopt:{opt end(string)}}specifies a study end-date, such as end(31dec2018); default is to use the date corresponding to the last ({it:fill_date} + {it:days_supply}) - 1 {p_end}
{synopt:{opt len:gth(#)}}specifies a study {it:duration} as an alternative to specifying {cmd:end()}. Either {cmd:length()} or {cmd:end()} can be specified, but not both {p_end}
{synopt:{opt cred:it}}specifies that overlapping refill periods should be spaced out, thereby giving "credit" to the patient for the overlapping supply of medication {p_end}
{synoptline}

{p 4 6 2}
{p2colreset}{...}				
	
{title:Description}

{pstd}
The Proportion of days covered (PDC) is a widely-used measure of {it:adherence} (also referred to as {it:compliance}) to a medication regimen (as an alternative to the medication 
Possession Ratio (MPR) which can be implemented using {search mpr:mpr}). PDC utilizes administrative pharmacy claims data to assess how frequently patients refill their prescriptions, 
and assumes that patients who refill their prescriptions regularly also consume the medications as prescribed. 
The general formula for PDC is:{p_end}


	days of supply on hand in the study period
	-------------------------------------------
	   number of days in the study period


{pstd}
In this equation, the numerator indicates the actual count of days in which the patient has medication available (each day is categorized as either 1 or 0, representing 
having or not having medication available on that day). Many investigators prefer the PDC over MPR 
because it does not double count overlapping refills (which is due to refilling the prescription prior to running out of the drug on hand). 
Consequently, the PDC equation can never exceed 1.0, whereas the MPR may exceed 1.0 if the numerator (e.g. total pill count) is greater than the number of days
in the study period.{p_end}

{pstd}
{cmd:pdc} computes the proportion of days covered under a large number of scenarios. The PDC can be computed for a single patient or multiple patients, 
with prescriptions filled for one medication or multiple medications. Moreover, {cmd:PDC} provides the user with tremendous flexibility in specifying the study period.
The two most common methods for setting the study period are; (1) a {it:fixed} study period, which keeps the denominator constant at a fixed time
interval (e.g. by specifying {cmd: start()} and {cmd: end()}, or by specifying {cmd: start()} and {cmd: length()}) and (2), a {it:variable} study period, 
which allows the number of days in the denominator to vary, depending on how the user specifies either the {cmd: start()} or {cmd: end()} of the study period. 
For example, specifying {cmd: start()} but not {cmd: end()} will result in the total days of supply in the last refill to be counted in the PDC (while the first
fill may be truncated for the days of supply spanning earlier than the study start date). Conversely, specifying {cmd: end()} but not {cmd: start()} 
will result in the total amount of supply in the first prescription to be counted in the PDC (while the last refill may be truncated if the days supply of refill 
spans beyond the observation end date).    



{title:Options}

{p 4 8 2}
{cmd:id(}{it:string}{cmd:)} the patient identifier if the data contain multiple patients. When {cmd:id()} is not specified, {cmd:PDC} assumes that there is
a single patient in the data.

{p 4 8 2}
{cmd:drug(}{it:string}{cmd:)} the variable specifying the drug if the data contain multiple medications per patient. When {cmd:drug()} is not specified, {cmd:PDC} assumes that there is
only one medication per patient in the data.

{p 4 8 2}
{cmd:start(}{it:string}{cmd:)} represents the desired start date of a study period, aand must be specified in the DDmonCCYY format (e.g. 01feb2018). When {cmd: start()}
is not specified, {cmd:pdc} uses the first {it:fill_date}.

{p 4 8 2}
{cmd:end(}{it:string}{cmd:)} represents the desired end date of a study period, and must be specified in the DDmonCCYY format (e.g. 31dec2018). When {cmd: end()}
is not specified, {cmd:pdc} uses the date corresponding to the last ({it:fill_date} + {it:days_supply}) - 1. 

{p 4 8 2}
{cmd:length(}{it:#}{cmd:)} specifies a study duration as an alternative to specifying {cmd:end()}. Either {cmd:length()} or {cmd:end()} can be specified, but not both.

{p 4 8 2}
{cmd:credit} specifies that overlapping refill periods should be spaced out by moving the next {it:fill_date} forward to coincide with day after the previous refill is exhausted. This
essentially gives the patient "credit" for having more supply of medication on hand. 		

{title:Examples}

{pstd}
There are four possible scenarios in which {cmd:pdc} can be implemented: 1) a
single patient on a single medication, 2) a single patient on multiple medications, 
3) multiple patients on a single medication, and 4) multiple patients on multiple medications.  The
examples below are described accordingly:


{pstd}
{opt 1) A single patient on a single medication:}{p_end}

{pmore} setup {p_end}
{pmore2}{bf:{stata "use medadheredata.dta, clear":. use medadheredata.dta, clear}}{p_end}
{pmore2}{bf:{stata "keep if id==1 & drug==1": . keep if id==1 & drug==1}} {p_end}

{pmore}
If the data are for a single patient and single medication, we do not specify either {cmd: id()} or {cmd: drug()}. 
Here we specify the start and end dates of the study period to span all days in 2013.{p_end}

{phang3}{bf:{stata "pdc fill_date days_supply,  start(01jan2013) end(31dec2013)": . pdc fill_date days_supply,  start(01jan2013) end(31dec2013)}}{p_end}


{pstd}
{opt 2) A single patient on multiple medications:}{p_end}

{pmore} setup {p_end}
{pmore2}{bf:{stata "use medadheredata.dta, clear":. use medadheredata.dta, clear}}{p_end}
{pmore2}{bf:{stata "keep if id==1": . keep if id==1}} {p_end}

{pmore}
If the data are for a single patient on multiple medications, we do specify {cmd: drug()} but not {cmd: id()}. 
Here we specify the start date and length of the study period to span 365 days in 2013 (as an alternative to specifying {cmd: end()}).{p_end}

{phang3}{bf:{stata "pdc fill_date days_supply, drug(drug) start(01jan2013) length(365)": . pdc fill_date days_supply, drug(drug) start(01jan2013) length(365)}}{p_end}


{pstd}
{opt 3) Multiple patients on a single drug:}{p_end}

{pmore} setup {p_end}
{pmore2}{bf:{stata "use medadheredata.dta, clear":. use medadheredata.dta, clear}}{p_end}
{pmore2}{bf:{stata "keep if drug==1": . keep if drug==1}} {p_end}

{pmore}
If the data are for multiple patients and a single medication, we specify {cmd: id()} but not {cmd: drug()}. 
Here we do not specify the start date, which means that {cmd:pdc} will use the earliest {it:filldate} as the start date. We set the end date of the study period
at 30June2013 (allowing each patient to have a different observation duration).{p_end}

{phang3}{bf:{stata "pdc fill_date days_supply, id(id) end(30jun2013)": . pdc fill_date days_supply, id(id) end(30jun2013)}}{p_end}


{pstd}
{opt 4) Multiple patients on multiple medications:}{p_end}

{pmore} setup {p_end}
{pmore2}{bf:{stata "use medadheredata.dta, clear":. use medadheredata.dta, clear}}{p_end}

{pmore}
If the data are for multiple patients and multiple medications, we specify both {cmd: id()} and {cmd: drug()}. 
Here we do not specify either the start date or the end date, but specify the study period as being 180 days. Additionally, we specify {cmd: credit}
to move overlapping refill periods forward.{p_end}

{phang3}{bf:{stata "pdc fill_date days_supply, id(id) drug(drug) length(180) credit": . pdc fill_date days_supply, id(id) drug(drug) length(180) credit}}{p_end}

{pmore}
If there is a sufficient sample size, we could also look at confidence intervals.{p_end}

{phang3}{bf:{stata "mean pdc, over(drug)":. mean pdc, over(drug)}}{p_end}

{pmore} or alternatively {p_end}

{phang3}{bf:{stata "ratio supply study_days, over(drug)":. ratio supply study_days, over(drug)}}{p_end}

{pmore}
Some investigators prefer to dichotomize the adherence rate at a cut-point at 0.80, in 
which patients above the cut-point are considered adherent and those below the cut-point are considered non-adherent. 
Here we generate a binary variable and then tabulate by drug.{p_end}

{phang3}{bf:{stata "generate pdc80 = cond(pdc >= .80,1,0)":. generate pdc80 = cond(pdc >= .80,1,0)}}{p_end}
{phang3}{bf:{stata "tabulate pdc80 drug, column":. tabulate pdc80 drug, column}}{p_end}



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



{marker citation}{title:Citation of {cmd:pdc}}

{p 4 8 2}{cmd:pdc} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2018). PDC: Stata module for computing the Proportion of Days Covered of a medication.
{browse "http://econpapers.repec.org/software/bocbocode/s458551.htm":http://econpapers.repec.org/software/bocbocode/s458551.htm} {p_end}


{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}


{title:Also see}

{p 4 8 2} Online: {helpb mpr} (if installed){p_end}

