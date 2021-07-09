{smcl}
{* *!0.3.0  Brent Mcsharry brent@focused-light.net 11dec2015/26oct2017}{...}
{cmd:help tabcusum}
{hline}

{title:O-E + tabular CUSUM charts}

{p2colset 5 18 20 2}{...}
{p2col :{hi:tabcusum} {hline 2}}command to graph O-E (VLAD) type CUSUM vertically aligned with tabular (SPRT) CUSUM{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmdab:tabcusum}
{outcome sequence}
{ifin}
, {opt p:redicted(varname)}
[{it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}
{synopt:{opt or: (#)}} the odds ratio for the alternative hypothesis. Default is 2{p_end}
{synopt:{opt t:hreshold (#)}} decision threshold (h). Default 2.9 {p_end}
{synopt:{opt head:start (#)}} point for CUSUM to reset to as a proportion of upper threshold. Default 0 {p_end}
{synopt:{opt xlabel: (rule_or_values)}} major ticks plus labels. see {help axis_label_options}{p_end}
{synopt:{opt title: (tinfo)}} overall title. see {help title_options }{p_end}
{synopt:{opt note: (tinfo)}} note about graph. see {help title_options }{p_end}
{synopt:{opt sub:title (tinfo)}} subtitle. see {help title_options }{p_end}
{synopt:{opt xt:itle (axis_title)}} title for x axis. see {help axis_title_options}{p_end}
{synopt:{opt xax:is (# [# ...])}} the x axis on which the plot is to appear. see {help axis_choice_options}{p_end}
{synopt:{opt lim:its (numlist)}} upper and lower confidence bound(s) to display on O-E (0,100){p_end}
{synopt:{opt notrunc:limits}} show all confidence bounds{p_end}
{synopt:{opt sha:dearea (#)}} value of {sequencevar} above which the graph will be shaded grey{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:tabcusum} Plots the observed minus expected (O-E or variable life adjusted display [VLAD]) type CUSUM, vertically aligned with tabular (sequential probability ratio) CUSUM over sequential observations. 
Exceeding the decision threshold on the tabular CUSUM places a corresponding marker on the O-E CUSUM.
{p_end}

{pstd}
{cmd:outcome} The actual outcome being benchmarked. Must only contain the values missing(.), 0 or 1.
{p_end}
{pstd}
{cmd:sequence} A variable denoting in what order each subject has entered the analysis. 
{p_end}
{pstd}
{cmdab:p:redicted} The predicted value for the outcome under investigation.
{p_end}

{title:Options}

{dlgtab:Main}

{phang}
{opt t:hreshold}
The decision threshold (often denoted h). Default is 2.9. It is recommended the value be chosen after approximating the desired average run lengths. 
See section {bf:Also see} (bottom of this help file) for articles discussing setting appropriate run lengths, 
and links to a program to calculate simulated average run lengths for a given threshold.
{p_end}

{phang}
{opt lim:its} upper and lower confidence bound(s) to display on O-E Cusum chart. value(s) must be greater than 0 and less than 100. 
If not specified, no confidence intervals are displayed. Obviously the usual caveats apply when applying frequentist confidence intervals to continuously analysed real time data.
{p_end}

{phang}
{opt notrunc:limits} show all confidence bounds. without specifying this option, confidence boundaries denoted in the {opt limits} option will only be displayed for the range relevant to the min & max of the O-E graph.
{p_end}

{phang}
{opt head:start} point for CUSUM to reset to as a proportion of upper threshold.
Must be a value between 0 and 1.
Default 0. 
This is for creating fast initial response (FIR) CUSUM graphs. 
{p_end}

{phang}
{opt xlabel: }
Custom labels can be added. Tabcusum will generate a linear sequence from 1 to _N (number of variables) so that the deflection (gradient and step) for a given outcome is constant regardless of variable intervals between cases.
Therefore for the custom labels to work, first generate a sequencevar {stata gen seq = _n}. Another program written by the same author {stata findit mydatelabels} may be of use.
{p_end}

{phang}
{opt xax:is }
Will apply multiple axes to the O-E (top) graph.
{p_end}

{phang}
{opt sha:dearea}
The value of {sequencevar} above which the graph will be shaded grey. 
This can be used to indicate more contemporaneous data may not be complete or not fully validated.
{p_end}

{title:Authors}

{p 4 4 2}Brent McSharry, Starship Children's Hospital, Auckland New Zealand {break}
brentm@adhb.govt.nz
{p_end}

{title:Examples}
{hline}
{pstd}Setup{p_end}
{phang2}. {stata clear}{p_end}
{phang2}. {stata webuse cancer}{p_end}
{phang2}. {stata gen int study_entry_sequence=_n}{p_end}
{phang2} assuming we would expect each subject to have a 50% probability of failure/death {p_end}
{phang2}. {stata gen float p = 0.5}{p_end}

{pstd}Plot{p_end}
{phang2}. {stata tabcusum died study_entry_sequence, pred(p) threshold(2.2) headstart(0.5)}{p_end}
{phang2} with confidence bounds {p_end}
{phang2}. {stata tabcusum died study_entry_sequence, pred(p) threshold(2.2) headstart(0.5) limit(95 99)}{p_end}
{phang2} showing entire range of upper and lower confidence bounds {p_end}
{phang2}. {stata tabcusum died study_entry_sequence, pred(p) threshold(2.2) headstart(0.5) limit(95 99) notrunc}{p_end}

{pstd}Working with dates - involves installing {cmd:mydatelabels}{p_end}
{phang2}. {stata gen study_entry_date = td(#1jan2010#) in 1}{p_end}
{phang2}. {stata replace study_entry_date = study_entry_date[_n-1] + (runiform()*20) in 2/l}{p_end}
{phang2} divide the year into quarters, and label the first case in each quarter {p_end}
{phang2}. {stata mydatelabels study_entry_sequence =ceil(month( study_entry_date )/3),local(mymac) start format(%tdMon_'YY)}{p_end}
{phang2}. {stata tabcusum died study_entry_sequence, pred(p) threshold(2.2) headstart(0.5) limit(95 99) xlabel(`mymac', axis(2)) xaxis(1 2)}{p_end}

{hline}
{title:Also see}
{psee} Stata: {stata findit rasprt} plots a Risk adjusted sequential probability ratio test chart +/- Risk Adjusted Cumulative Sum chart (CUSUM){p_end}
{psee} Article: {it:Liver Transplantation} 2010; Volume 16, Number 10: pp. 1119–28 
{browse "http://onlinelibrary.wiley.com/doi/10.1002/lt.22131/full":Review of methods for measuring and comparing center performance after organ transplantation}
{p_end}
{psee} Article: {it:Transplantation} 2009; Volume 88, Number 8: pp. 970-5
{browse "http://www.ncbi.nlm.nih.gov/pubmed/19855240":The UK scheme for mandatory continuous monitoring of early transplant outcome in all kidney transplant centers}{p_end}
{psee} Program: {browse "https://github.com/mcshaz/CusumARL/releases":CusumARL} is a free, open source (MIT license) console application for calculating average run lengths for a given decision threshold. 
ARL0 is the expected number of observations taken from an in-control process until the control chart falsely signals. 
ARL1 is the expected number of observations taken from an out-of-control process until the control chart correctly signals. 
CusumARL is written by the author of RASPRT in C++ rather than Stata for reasons of performance over millions of Monte Carlo iterations. 
Binaries have not been compiled for Mac or Linux - feel free to contact the author if you would like these binaries, or more features.
{p_end}

{hline}
{title:Change log}

{phang}
{opt 0.3.0}{p_end}
{phang}confidence boudaries added to O-E cusum{p_end}
{phang}
{opt 0.2.0}{p_end}
{phang}Graph commences at 0 rather than first cumulative observation. {p_end}
{phang}Graph line stops after exceeding threshold (instead of circle). {p_end}
{phang}headstart, note and title options introduced.{p_end}
