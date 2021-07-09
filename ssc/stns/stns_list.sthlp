{smcl}
{* *! version 1.4.4 15may2014}{...}
{viewerdialog "stns list" "dialog stns_list"}{...}
{vieweralsosee "[ST] stns list" "mansection ST stnslist"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[ST] stns" "help stns"}{...}
{vieweralsosee "[ST] stns graph" "help stns_graph"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[ST] stset" "help stset"}{...}
{viewerjumpto "Syntax" "stns_list##syntax"}{...}
{viewerjumpto "Description" "stns_list##description"}{...}
{viewerjumpto "Options" "stns_list##options"}{...}
{viewerjumpto "Examples" "stns_list##examples"}{...}
{title:Title}

{p2colset 5 23 25 2}{...}
{p2col :{help stns list:stns list} {hline 2}}List the net survival or cumulative hazard function{p_end}
{p2colreset}{...}

{pstd}
{opt using}, {opt age()}, {opt period()}, and {opt rate()} are required to estimate the
 net survival function, net failure function, and net cumulative hazard function. When 
 the rate table is stratified, {opt strata()} is required to match the stratification 
 variables in the dataset and the rate table.
{p_end}

{pstd}
You must {cmd:stset} your data before using {cmd:stns}; see
{manhelp stset ST}.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 21 2}{cmd:stns} {opt l:ist} {cmd:using {it:lifetable}} {ifin} [{cmd:,} {it:options}]

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main (Estimation options)}

{synopt :{opt age:(varname=name)}}varname specifies the age variable in the dataset; name that in the ratetable{p_end}
{synopt :{opt period:(varname=name)}}varname specifies the survival time variable in the dataset; name that in the ratetable{p_end}
{synopt :{opt rate:(name)}}name specifies the rate variable in the ratetable{p_end}
{synopt :{opth st:rata(varlist)}}stratifies on different groups of {it:varlist}{p_end}

{synopt :{opt ty:pe(type)}}specifies type of estimates: Kaplan-Meier-type (the default) or Fleming-Harrington-type{p_end}
{synopt :{cmdab:begin:time(}{cmdab:ori:gin} | {cmdab:ent:er}{cmd:)}}specifies the beginning time for the computation of the expected survival used as weights{p_end}
{synopt :{opth by(varlist)}}estimates separate functions for each group formed by {it:varlist}{p_end}
{synopt :{opt end:_followup(#)}}indicates the date of the end of the follow up (in days since 01jan1960){p_end}

{syntab:Options}
{synopt :{opt sur:vival}}reports net survival function; the default{p_end}
{synopt :{opt f:ailure}}reports net failure function{p_end}
{synopt :{opt cumh:az}}reports netcumulative hazard function{p_end}

{synopt :{cmd:at(}{it:#}|{it:{help numlist}}[{cmd:, }{opt scale:factor(#)}{cmd: }{opt unit(unit)}{cmd: }{opt round(#)}{cmd: }{opt meth:od(method)}])}{p_end}
{p 35 35 2}reports estimated net survival/ net cumulative hazard function at specified times; default is to report at all unique time values{p_end}
{synopt :{opt nosh:ow}}does not show st setting information{p_end}
{synopt :{opt nodet:ail}}does not show the results{p_end}
{synopt :{opt city:pe(citype)}}specifies type of confidence interval: plain (the default), log or loglog{p_end}
{synopt :{opt l:evel(#)}}sets confidence level; default is {cmd:level(95)}{p_end}
{synopt :{cmdab:sav:ing:(}{it:{help filename}}[{cmd:,} {cmd:replace}]{cmd:)}}saves results to {it:filename}; use {opt replace} to overwrite existing {it:filename}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stns list}; see {manhelp stset ST}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:stns list} lists the estimated net survival (failure) and related functions, such as the 
cumulative hazard function. See {help stns:stns} for an introduction to this command.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt age}, {opt period}, {opt rate}, and {opt strata} are required to estimate
the net survival/failure function or net cumulative hazard stratified on 
variables in {it:varlist}.

{phang}
{opt type(type)} specifies the type of estimates: {ul:ka}plan-{ul:me}ier (the default) 
or {ul:fl}eming-{ul:ha}rrigton-{ul:ne}lson-{ul:aa}len.

{phang}
{cmdab:begin:time(}{cmdab:ori:gin} | {cmdab:ent:er}{cmd:)} specifies the beginning time for the computation of the expected 
survival used as weights. This option is useless when subjects enter the study when they become at risk ({it:i.e.} when the option {cmd:enter()} is not used in {cmd:stset}). 

{phang2}
{cmdab:ori:gin} (the default) indicates that the expected survival starts when a subject becomes at risk (option {cmd:origin()} of {cmd:stset}; 

{phang2}
{cmdab:ent:er}indicates that the expected survival starts when a subject first enters study (option {cmd:enter()} of {cmd:stset}; 

When 

{phang}
{opth by(varlist)} estimates a separate function for each by-group. By-groups
are identified by equal values of the variables in {it:varlist}. 

{phang}
{opt end_followup(#)} specifies the date of the end of the follow up. The default is 
the time exit of stset command.


{dlgtab:Options}

{phang}
{opt survival}, {opt failure}, and {opt cumhaz} specify the function to
report.

{phang2}
{opt survival} specifies that the net survival function be listed. This 
option is the default if a function is not specified.

{phang2}
{opt failure} specifies that the net failure function 1 - S(t+0) be
listed.

{phang2}
{opt cumhaz} specifies that the estimate of the net cumulative
hazard function be listed.

{phang}
{cmd:at(}{it:#}|{it:{help numlist}}[{cmd:, }{opt scale:factor(#)}{cmd: }
{opt unit(unit)}{cmd: }{opt round(#)}{cmd: }{opt meth:od(method)])} specifies 
the time values at which the estimated net survival (failure) or net cumulative 
hazard function is to be listed. The default is to list the function at all 
the unique time values in the data, or if functions are being compared, at about 
10 times chosen over the observed interval. In any case, you can control the 
points chosen.

{pmore}
{opt scalefactor(#)} indicates the step between times which are shown.{p_end}

{pmore}
{opt unit(unit)} specifies the unit of time variable and prints it on the 
results. Default is void.{p_end}

{pmore}
{opt round(#)} specifies the decimal of the rounding. For example, if # equals 
to 10 time will be rounded to the nearest tenth. By default it takes 1, i.e. the 
rounding is made for the unity.{p_end}

{pmore}
{opt method(step|lin)} indicates how the survival and the cumulative hazard functions 
are interpolated: {bf:step} for left-continuous step function and {bf:lin} 
for linear interpolation. {bf:step} is the default.{p_end}

{pmore}
{opt method( {cmd:step:} {c |} {cmd:lin:} step|lin)} indicates how the survival and the cumulative hazard functions 
are interpolated: {bf:step} for left-continuous step function and {bf:lin} 
for linear interpolation. {bf:step} is the default.{p_end}

{phang3}
{cmd:at(5 10 20 30 50 90)} would display the function at the designated
times.

{phang3}
{cmd:at(10 20 to 100)} would display the function at times 10, 20, 30, 40, ...,
100.

{phang3}
{cmd:at(5 10 to 100 200)} would display the function at times 5, 10, 15,..., 100, 
 and 200.

{phang3}
{cmd:at(10(5)30)}{cmd: } would display the function at the times 10, 15, 20, 25,
 and 30.

{phang3}
{cmd:at(20)} would display the function at (roughly similarly to {cmd: sts}; see 
{manhelp sts ST}) 20 equally spaced times over the interval observed in the data. 
We say roughly because Stata may choose to increase or decrease your number slightly 
if that would result in rounder values of the chosen times.

{phang3}
{cmd:at(15, round(100))} would display the function at 15 equally spaced times, 
which are around rounded to the nearest hundredth.

{phang3}
{cmd:at(1(1)5,}{cmd: }{opt scalefactor}{cmd:(365.25) }{opt method(step)} would 
display the function at times 1*365.25, 2*365.25, ..., 5*365.25. If a specified time 
does not correspond to an observation time, it would display the function at the 
previous observation time.

{phang}
{opt noshow} prevents {cmd:stns list} from showing the key st variables. This 
option is seldom used because most people type {cmd:stset , show} or
{cmd:stset, noshow} to set whether they want to see these variables mentioned
at the top of the output of every st command; see {manhelp stset ST}.

{phang}
{opt nodetail} prevents {cmd:stns list} from showing the results.

{phang}
{opt citype(citype)} specifies the type of confidence interval: plain,
log or log-log. The default is plain.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for the
Pohar-Perme pointwise confidence interval of the net survival (failure) or for the
pointwise confidence interval of the net cumulative hazard function;
see {manhelp level R}.

{phang}
{cmd:saving(}{it:{help filename}}[{cmd:,} {cmd:replace}]{cmd:)} saves the
results in a Stata data file ({opt .dta} file).

{pmore}
{cmd:replace} specifies that {it:filename} be overwritten if it exists. 


 
{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use rdata}{p_end}
{phang2}{cmd:. stset survtime, failure(cens==1) id(id)}

{pstd}Suppress showing st settings{p_end}
{phang2}{cmd:. stset, noshow}

{pstd}Compute and list the net survival function{p_end}
{phang2}{cmd:. stns list using myslopop, age(agediag=age) period(datediag=year) rate(rate) strata(sex)}

{pstd}Compute and list the net survival function for the two categories of {cmd:sex}{p_end}
{phang2}{cmd:. stns list using myslopop, age(agediag=age) period(datediag=year) rate(rate) strata(sex) by(sex)}{p_end}
{phang2}{cmd:. stns list, by(sex)}{p_end}

{pstd}Compute and list the net survival function for each time before 3000{p_end}
{phang2}{cmd:. stns list using myslopop, age(agediag=age) period(datediag=year) rate(rate) strata(sex) by(sex) end_followup(3000)}{p_end}

{pstd}Same as above, but list at the specified times{p_end}
{phang2}{cmd:. stns list using myslopop, age(agediag=age) period(datediag=year) rate(rate) strata(sex) by(sex) at(0 250 to 3000)}{p_end}

{pstd}Now list the net cumulative hazard functions at the specified times for the two
categories of {cmd:sex}{p_end}
{phang2}{cmd:. stns list, cumhaz at(0 250 to 3000) by(sex)}{p_end}
