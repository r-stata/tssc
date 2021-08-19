{smcl}
{* *! version 1.0.0 12aug2014}{...}
{cmd:help ipdfc}
{hline}


{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:ipdfc} {hline 2}}Reconstruct individual participant data (IPD) from a published Kaplan-Meier curve{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd:ipdfc,} {it:required_options} [ {it:optional_options} ]


{synoptset 26}{...}
{synopthdr :required_options}
{synoptline}
{synopt :{opt surv(varname)}}survival percentages extracted from y-coordinates
of a Kaplan-Meier curve{p_end}
{synopt :{opt ts:tart(varname)}}times from randomization extracted from the
x-coordinates of a Kaplan-Meier curve {p_end}
{synopt :{opt tr:isk(varname)}}time intervals specified in the risk table {p_end}
{synopt :{opt nr:isk(varname)}}number of patients at risk at each value of {opt trisk()} {p_end}
{synopt :{opt gen:erate(varname1 varname2)}}generates the time
to event and event indicator from the input information{p_end}
{synopt :{cmdab:sav:ing(}{it:filename}[{opt , replace}]{cmd:)}}saves the reconstructed survival data {p_end}

{synopthdr :optional_options}
{synoptline}
{synopt :{opt prob:ability}}states that values in {opt surv(varname)} are
probabilities. Default is percentages {p_end}
{synopt :{opt fail:ure}}states that values in {opt surv(varname)} are
failure percentages or failure probabilities. Default is survival {p_end}
{synopt :{opt iso:tonic}}use isotonic regression to correct monotonicity violators {p_end}
{synopt :{opt tot:events(#)}}total number of events in the sample {p_end}
{synoptline}


{title:Description}

{pstd}
{cmd:ipdfc} reconstructs patient-level survival (time-to-event) data from a
Kaplan-Meier curve. For example, Kaplan-Meier estimates may have been obtained by
digitizing a published graphical image. The risk table, that is the numbers of
patients at risk at particular time points, if available, may be used to
improve the accuracy of the reconstructed data. If the risk table is not available, the total 
number of participants in the sample at time origin should be specified (see description 
below for {opt trisk} and {opt nrisk}).  The total number of events, if known, 
may also be used to improve the reconstruction.

{pstd}
{cmd:ipdfc} makes use of the x- and y-coordinates of the Kaplan-Meier curve. 
In a randomized trial, the x-coordinates are times since randomization. The
y-coordinates are the percentages or probabilities of survival or 
failure.

{pstd}
Through the {opt generate()} option, {cmd:ipdfc} creates two new variables:
individual-level time to an event or censoring, and a censoring indicator
(1 = event, 0 = censored) for each patient contributing to the
Kaplan-Meier curve.

{pstd}
It should be noted that {cmd:ipdfc} does not handle more than one sample at once. 
When dealing with a trial having more than one arm, the syntax converts data extracted 
from one curve at a time to time-to-event data for the respective arm. This should be 
done for all arms one by one.


{title:Options}

{phang}
{opt surv(varname)} specifies the data extracted from the ordinate (y-axis) of
a published Kaplan-Meier curve. It can be survival probabilities, survival percentages, 
failure probabilities or failure percentages. By default, {it: varname} is assumed
to contain survival percentages. See also options {opt probability} and {opt failure}.

{phang}
{opt tstart(varname)} specifies the time since randomization as extracted from the abscissa (x-axis) 
of a published Kaplan-Meier curve. The time could be in any units (e.g. days, months, years) 
as specified in the publication.

{phang}
{opt trisk(varname)} specifies the times corresponding to the numbers of
patients at risk in {opt nrisk()}. If the risk table is available, the values in 
{opt trisk} are strictly increasing and the values in {opt nrisk} are strictly non-increasing.
Set {it:varname} = 0 if only the total number of patients in the sample is known. 
See also {opt nrisk()}. 

{phang}
{opt nrisk(varname)} supplies the number of patients at risk for each time in
{opt trisk()}. Both {opt nrisk()} and {opt trisk()} may often be found
in a 'risk table' displayed beneath published Kaplan-Meier curves. If no
risk table is available, specify {opt nrisk()} as the number of patients in
the sample and {opt trisk()} as 0. In any case, {opt nrisk} should be specified 
only once for each value of {opt trisk}. 

{phang}
{opt generate(varname1 varname2)} generates the time-to-event outputs extracted from the
input information. {it: varname1 varname2} specify two new variables, the time to an event and 
{it: varname2} an event indicator(1 = event, 0 = censored).For example,
{cmd:generate(time event)} would create {cmd:time} as the time to event
and {cmd:event} as the event indicator.

{phang}
{cmd:saving(}{it:filename}[{cmd:, replace}]{cmd:)} saves the reconstructed
survival data to file {it:filename}.dta. {opt replace} allows the file to be
replaced if it already exists.

{phang}
{opt probability} signifies that {it: varname} in {it: surv(varname)} contains probabilities
rather than the default percentages.

{phang}
{opt failure} signifies that {it: varname} in {it: surv(varname)} contains failure information
rather than the default survival information.

{phang}
{opt isotonic} invokes use of isotonic regression to adjust values which violate
the time-related monotonicity in {opt surv(varname)}. By default, an alternative,
simpler method is used to correct the values of violators, by
replacing the value of a violator by the value of its adjacent violator.

{phang}
{opt totevents(#)} is the total number of events and is used to adjust the
number of observations censored in the final interval of the risk table.


{title:Examples}

{pstd}
{bf:Example 1: Head and neck cancer trial}

{pstd}
This example is from a two-arm randomised controlled trial comparing
radiotherapy plus cetuximab with radiotherapy for squamous-cell carcinoma
of the head and neck (Bonner {it: et al.}, 2006). The example was used
by Guyot {it: et al.}(2012) to demonstrate the reconstruction of
individual-level time-to-event data. Survival {bf: percentages} were extracted
across 60 months of follow up. The following code shows how to use {cmd:ipdfc}
to convert the extracted survival percentages to time-to-event data.

{pstd}
Read data extracted from the Kaplan-Meier curve for the control arm:

{phang}{cmd:. import delimited using "Head_and_neck_arm0.txt", clear}{p_end}

{pstd}
Reconstruct time-to-event data for the control arm and store the reconstructed data in temp0.dta:

{phang}{cmd:. ipdfc, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) isotonic generate(t_ipd event_ipd) saving(temp0)}{p_end}

{pstd}
Read data extracted from the Kaplan-Meier curve for the treatment arm:

{phang}{cmd:. import delimited using "Head_and_neck_arm1.txt", clear}{p_end}

{pstd}
Reconstruct time-to-event data for the treatment arm and store the reconstructed data in temp1.dta:

{phang}{cmd:. ipdfc, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) isotonic generate(t_ipd event_ipd) saving(temp1)}{p_end}

{pstd}
Now amalgamate the data from both arms:

{phang}{cmd:. use temp0, clear}{p_end}
{phang}{cmd:. gen byte arm = 0}{p_end}
{phang}{cmd:. append using temp1}{p_end}
{phang}{cmd:. replace arm = 1 if missing(arm)}{p_end}
{phang}{cmd:. label define ARM 0 "Radiotherapy" 1 "Radiotherapy plus Cetuximab" }{p_end}
{phang}{cmd:. label values arm ARM}{p_end}
{phang}{cmd:. stset t_ipd, failure(event_ipd)}{p_end}

{pstd}
Run the Cox proportional hazards model on the reconstructed data:

{phang}{cmd:. stcox arm}{p_end}

{pstd}
Using the reconstructed data, obtain the Kaplan-Meier curves:

{phang}{cmd:. sts graph, by(arm) title("") xlabel(0(10)70) ylabel(0(0.2)1) /// }{p_end}
{phang}{cmd:  xtitle("Months") l2title("Locoregional Control") legend(off) /// }{p_end}
{phang}{cmd:  text(0.52 53 "Radiotherapy plus Cetuximab")  text(0.20 60 "Radiotherapy") /// }{p_end}
{phang}{cmd:  risktable(0(10)50, order(2 "Radiotherapy" 1 "Radiotherapy plus" bottom(msize(5)))) /// }{p_end}
{phang}{cmd:  text(-0.38 -9 "Cetuximab") }

{pstd}
Now suppose that the risk table is not available but the total number of participants 
in each arm is known. The following code shows how to use {opt ipdfc} to convert the extracted data
to time-to-event data.

{pstd}
Read in extracted data assuming the risk table is not available but
the total number of participant for the control arm is known.

{phang}{cmd: import delimited using "Head_and_neck_arm0_no_risk_table.txt", clear}{p_end}

{pstd}
Check that the total number of participant in the radiotherapy group is specified for the time origin.

{phang}{cmd: list trisk nrisk if trisk == 0}{p_end}

{pstd}
Reconstruct time-to-event data for the radiotherapy group assuming the risk
table is not available, and restore the reconstructed data in temp0.dta. Use {cmd: saving(temp0, replace)} instead of 
{cmd: saving(temp0)} if temp0.dta has been defined before. 

{phang}{cmd: ipdfc, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) isotonic generate(t_ipd event_ipd) saving(temp0)}{p_end}

{pstd}
The following code read in the extracted data for the treatment arm, check that the 
total number of participants is specified for the time origin, reconstruct time-to-event data and
restore the time-to-event data in temp1.dta. 

{phang}{cmd: import delimited using "Head_and_neck_arm1_no_risk_table.txt", clear}{p_end}
{phang}{cmd: list trisk nrisk if trisk == 0}{p_end}
{phang}{cmd: ipdfc, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) isotonic generate(t_ipd event_ipd) saving(temp1)}{p_end}

{pstd}
The code to amalgamate the data from both arms is the same as described above.

{bf:Example 2: ICON7 trial}

{pstd}
This example is from ICON7, a two-arm randomized controlled trial of
bevacizumab in advanced ovarian cancer (Perren {it: et al.} 2011). Survival
{bf: probabilities} instead of percentages were extracted across 30 months
of follow up. The following code shows how to use {cmd:ipdfc} to convert the
extracted survival probabilities to time-to-event data.

{phang}{cmd:. local tot0 464}{p_end}
{phang}{cmd:. local tot1 470}{p_end}
{phang}{cmd:. import delimited using "ICON7_data_arm0.txt", clear}{p_end}
{phang}{cmd:. ipdfc, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) probability iso totevents(`tot0') ///}{p_end}
{phang}{cmd:       generate(t_ipd event_ipd) saving(temp0)}{p_end}
{phang}{cmd:. import delimited using "ICON7_data_arm1.txt", clear}{p_end}
{phang}{cmd:. ipdfc, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) probability iso totevents(`tot1') ///}{p_end}
{phang}{cmd:       generate(t_ipd event_ipd) saving(temp1)}{p_end}

{pstd}
The following code amalgamates the data from both arms and then conducts survival analysis.

{phang}{cmd:. use temp0, clear}{p_end}
{phang}{cmd:. generate byte arm = 0}{p_end}
{phang}{cmd:. append using temp1}{p_end}
{phang}{cmd:. replace arm = 1 if missing(arm)}{p_end}
{phang}{cmd:. stset t_ipd, failure(event_ipd)}{p_end}
{phang}{cmd:. stcox arm}{p_end}
{phang}{cmd:. sts graph, by(arm) xlabel(0(3)30) ylabel(0(0.2)1)  /// }{p_end}
{phang}{cmd:  risktable(0(6)30, order(1 "Bevacizumab" 2 "Standard chemo-" )) legend(off) /// }{p_end}
{phang}{cmd:  xtitle("Months since Randomization") l2title("Alive without progression")  ///}{p_end}
{phang}{cmd:  plot1opts(lpattern(solid) lcolor(gs12)) plot2opts(lpattern(solid) lcolor(black)) ///}{p_end}
{phang}{cmd:  text(-0.38 -3.2 "therapy") text(0.75 14 "Bevacizumab", place(e))  text(0.5 10 "Standard chemotherapy")}

{bf:Example 3: EUROPA trial}

{pstd}
This example is from a two-arm randomized placebo-controlled trial in
evaluating the efficacy of perindopril in reduction of cardiovascular events
among patients with stable coronary artery disease (Fox {it: et al.} 2003).
{bf: Failure} percentages instead of survival percentages were extracted from
the published Kaplan-Meier curves across 5 years of follow-up. The following
shows how to convert the extracted failure percentages to time-to-event data
for each arm of the trial.

{phang}{cmd:. import delimited using "europa_data_arm0.txt", clear}{p_end}
{phang}{cmd:. ipdfc, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) failure iso ///}{p_end}
{phang}{cmd:  generate(t_ipd event_ipd) saving(temp0)}{p_end}
{phang}{cmd:. import delimited using "europa_data_arm1.txt", clear}{p_end}
{phang}{cmd:. ipdfc, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) failure iso ///}{p_end}
{phang}{cmd:  generate(t_ipd event_ipd) saving(temp1)}{p_end}

{pstd}
The following code amalgamates the data from both arms and conducts survival
analysis:

{phang}{cmd:. use temp0, clear}{p_end}
{phang}{cmd:. generate byte arm = 0}{p_end}
{phang}{cmd:. append using temp1}{p_end}
{phang}{cmd:. replace arm = 1 if missing(arm)}{p_end}
{phang}{cmd:. stset t_ipd, failure(event_ipd)}{p_end}
{phang}{cmd:. stcox arm}{p_end}
{phang}{cmd:. sts graph, by(arm) failure title("") ylabel(0(0.04)0.14) ///}{p_end}
{phang}{cmd:  risktable(0(1)5, order(1 "Placebo" 2 "Perindopril"))   ///}{p_end}
{phang}{cmd:  xtitle("Time(years)") ytitle("Probability of composite events") ///}{p_end} 
{phang}{cmd:  text(0.07 4.5 "Perindopril") text(0.125 4.6 "Placebo") legend(off)}{p_end}

   
{title:Authors}

{pstd}
Yinghui Wei, Plymouth University, Plymouth.{break}
yinghui.wei@plymouth.ac.uk

{pstd}
Patrick Royston, MRC Clinical Trials Unit at UCL, London.{break}
j.royston@ucl.ac.uk


{title:References}

{phang}
J.A. Bonner,P.M. Harari, J. Giralt, N. Azarnia, D.M. Shin, R.B. Cohen,
C.U. Jones, R. Sur, D. Raben, J. Jassem, R. Ove, M.S. Kies, J. Baselga,
H. Youssoufian, N. Amella, E.K. Rowinsky and K.K. Ang (2006) Radiotherapy
plus cetuximab for squamous-cell carcinoma of the head and neck.
{it:New England Journal of Medicine}, {bf: 354}: 567-578.

{phang}
K.M. Fox, EURopean trial On reduction of cardiac events with Perindopril
in stable coronary Artery diseases investigators (2003) Efficacy of perindopril
in reduction of cardiovascular events among patients with stable coronary
artery disease: randomised, double-blind, placebo-controlled, multicentre
trial. {it:Lancet}, {bf:362}: 782-788.

{phang}
P. Guyot, A.E. Ades, M. Ouvwens and N.J. Welton (2012) Enhanced secondary
analysis of survival data: reconstructing the data from published Kaplan-Meier
survival curves. {it: BMC Medical Research Methodology}, {bf:12}: 9.

{phang}
T.J. Perren, A.M. Swart, J. Pfisterer, J.A. Ledermann, E. Pujade-Lauraine,
G. Kristensen, M.S. Carey, P. Beale, A. Cervantes, C. Kurzeder, A. du Bois,
J.Sehouli, R. Kimig, A. Stahle, F. Collinson, S. Essapen, C. Gourley,
A. Lortholary, F. Selle,  M.R. Mirza, A. Leminen, M. Plante, D. Stark,
W. Qian, M.K.B. Parmar and A.M. Oza (2011) A phase 3 trial of bevacizumab in
ovarian cancer. {it:New England Journal of Medicine}, {bf:365}: 2484—2496.


{title:Also see}

{psee}
Online:  help for {help sts graph}
{p_end}
