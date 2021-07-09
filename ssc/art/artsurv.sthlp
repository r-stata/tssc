{smcl}
{* 22dec2014}{...}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:artsurv} {hline 2}}ART (Survival Outcomes) - Sample Size and Power{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmdab:artsurv}
[{cmd:using} {it:filename}[{cmd:.dta}]]
[{cmd:,}
{it:options}
]

    
{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt al:pha(#)}}significance level for testing treatment effect(s){p_end}
{synopt :{opt ar:atios(aratio_list)}}allocation ratio(s){p_end}
{synopt :{opt cr:over(#[#...#])}}treatment cross-over(s){p_end}
{synopt :{opt de:tail}}report more detailed results{p_end}
{synopt :{opt di:stant(#)}}calculations under distant alternative hypothesis{p_end}
{synopt :{opt do:ses(dose_list)}}doses for linear trend test{p_end}
{synopt :{opt ed:f0(slist0)}}baseline survival function{p_end}
{synopt :{opt fp(#)}}suppress banner heading{p_end}
{synopt :{opt hr:atio(hrlist)}}hazard ratios{p_end}
{synopt :{opt ind:ex(#)}}index for Harrington-Fleming weights{p_end}
{synopt :{opt ld:f(llist [, llist ...])}}distribution function of time to loss-to-follow-up{p_end}
{synopt :{opt lg(#[#...#])}}specifies groups subject to loss to follow-up{p_end}
{synopt :{opt med:ian(#)}}median survival time in group 1{p_end}
{synopt :{opt me:thod(methodname)}}type of logrank test used{p_end}
{synopt :{opt n(#)}}total sample size{p_end}
{synopt :{opt ng:roups(#)}}number of treatment groups in trial{p_end}
{synopt :{opt ni(#)}}non-inferiority trial{p_end}
{synopt :{opt np:eriod(#)}}number of time-periods{p_end}
{synopt :{opt o:nesided(#)}}use one-sided significance level{p_end}
{synopt :{opt po:wer(#)}}power of trial{p_end}
{synopt :{opt pw:ehr(hrlist)}}hazard ratio function post withdrawal from allocated treatment{p_end}
{synopt :{opt re:crt(rlist)}}duration and rate of recruitment{p_end}
{synopt :{opt replace}}allows {it:filename} to be replaced if it exists{p_end}
{synopt :{opt tr:end(#)}}specifies a linear trend test{p_end}
{synopt :{opt tu:nit(#)}}time units{p_end}
{synopt :{opt wd:f(wlist [, wlist ...])}}distribution function of time to withdrawal from allocated treatment{p_end}
{synopt :{opt lg(#[#...#])}}specifies groups subject to withdrawal from allocated treatment{p_end}
{synoptline}


{title:Description}

{pstd}
{cmd:artsurv} calculates sample size and power for comparative studies with
time-to-event outcomes at the end of follow-up.
The survival probabilities and hazard ratios calculated by {cmd:artsurv} for
each time-period in the trial may optionally be stored in a new Stata file
called {it:filename} for plotting, etc; see {cmd:Remarks} for further details.
{cmd:artsurv} has the following flexible features:
{p_end}

{p 8 15 2}1. Any number of groups between 2 and 6.

{p 8 15 2}2. Global or linear trend tests with arbitrary dose levels.

{p 8 15 2}3. Logrank test - unweighted or weighted (Tarone-Ware or Harrington-Fleming with
   any index).
   
{p 8 15 2}4. Time-dependent rates of event, loss to follow-up and withdrawal from 
   allocated treatment (treatment change).
   
{p 8 15 2}5. Staggered entry


{title:Options}

{phang}
{opt alpha(#)} specifies the significance level. By default two-sided
significance levels are assumed. The default {it:#} is 0.05.

{phang}
{opt aratios(aratio_list)} specifies the allocation ratio(s).
Suppose {it:aratio_list} has r items, {it:#}1,...,{it:#}r. The allocation
ratio for group k is {it:#}k, k = 1,...,r. If r is less than {opt ngroups()}
then the allocation ratio for group r+1, r+2, ... is taken as {it:#}r.
If {opt aratios()} is not specified, the default allocation ratios are all
1, i.e. equal group sizes are assumed.

{phang}
{cmd:crover(}{it:#}[{it:#...#}]{cmd:)} (only applies when {cmd:wg()} is specified) 
	is the target group number when crossing over. {cmd:crover(}{it:#1 #2...#r}{cmd:)}
	means that the kth group withdrawing from allocated treatment (specified by 
	{cmd:wg()}) crosses over to receive the allocated treatment of group #k, 
	k=1,...r. The default is that when individuals in group 1 change treatment, 
	they receive the treatment assigned to those in group 2. Individuals in group 
	k (k > 1) cross over to receive the treatment assigned to group 1.

{phang}
{cmd:detail(}{it:#}{cmd:)} with {it:#} = 1 requests more detailed output,
	including hazard ratios per group and period, expected proportion of failure,
    	withdrawal from allocated treatment and loss to follow-up by the end of
    	the study. Default{it:#} is 0, meaning shorter output.

{phang}
{cmd:distant(}{it:#}{cmd:)} specifies calculations for the logrank test under
	distant or local alternative hypotheses. Default {it:#} is 0, meaning
	local alternatives. Distnat alternatives are specified by {cmd:distant(1)}.

{phang}
{opt doses(dose_list)} specifies doses for a dose-response (linear trend)
test. {cmd:doses(}{it:#}1 {it:#}2...{it:#}r{cmd:)} assigns doses for groups 1,...,r. 
If r is less than {opt ngroups()}, the dose is assumed equal to {it:#}r
for groups r+1, r+2, ... . The default is {cmd:dose(1 2 ... }{opt ngroups())},
which applies only when {cmd:trend(1)} is specified and {opt dose()}
is not specified.

{phang}
{opt edf0(slist0)} is required and gives the baseline survival function. 
This need not be one of the distributions to be compared unless
the hazard ratio is set to 1 (see {opt hratio()})
for one of the groups (usually group 1) at all periods.
The format is {cmd:edf0(}{it:slist0}{cmd:)}, where 
string {it:slist0} is {it:#}1[{it:#}2 ...{it:#}r{cmd:,}{it:#}1 {it:#}2 ...{it:#}r]. 
Thus, {cmd:edf0(}{it:p1 p2 ...pr}{cmd:,}{it:t1 t2 ...tr}{cmd:)} gives the 
value pi for the survival function for the event time at the 
	end of time period ti, i=1,...,r. Note that the times {it:t1 t2 ...tr},
	which are integer period numbers, may be entered as a {it:numlist}
	(see {help numlist}). For example, times 1 2 3 4 5 6 may be
	validly abbreviated to 1(1)6.

{pin}
	Instantaneous event rates are assumed 
	constant within time periods (time-to-event is piecewise exponential). 
	If r < {cmd:nperiod()}, the instantaneous event rates in periods r+1,...,{cmd:nperiod()} 
	are taken to be the same as in period r. If only one value of {cmd:edf0} 
	is specified, this is taken to be the value at the end of the study and 
	the instantaneous event rate is constant thoughout follow-up. Thus if the 
	number of periods {cmd:nperiod()} {it:= 6} then {cmd:edf0(}{it:0.5}{cmd:)} is
    equivalent to {cmd:edf0(}{it:0.5}{cmd:,}{it:6}{cmd:)} and gives 50% survival 
   	at the end of period {cmd:nperiod()} and an exponential distribution 
   	for the baseline failure time. {cmd:edf0(}{it:0.8 0.6}{cmd:,}{it:1 5}{cmd:)} 
   	gives expected survival probability {it:0.8} at the end of the 
   	first period and {it:0.6} at the end of the fifth period. The instantaneous 
   	event rate during the first period is {it:-log(0.8)=0.223}. The instantaneous 
   	event rate during periods 2,3,4 and 5 is {it:-log((0.6)/(0.8))/4 = 0.072} 
   	which is also the default rate during period 6. This gives survival
   	probability of {it:0.45} at the end of period 6. See also the {cmd:fp()}
   	option to specify failure probabilities instead of survival probabilities.
   	There is no default; either {cmd:edf0()} or {cmd:median()} must be given.

{phang}
{cmd:fp(}{it:#}{cmd:)} specifies whether survival probabilities or 
	cumulative failure probabilities
	have been supplied in {cmd:edf0()}. The default # is 0, meaning
	survival probabilities. {cmd:fp(1)} specifies failure probabilities.

{phang}
{cmd:nohead} suppresses the banner heading on the output. Lessens irritation
	when running several sample size calculations successively.

{phang}
{cmd:hratio(}{it:hrlist}{cmd:)} is required adn specifies the event hazard-ratio 
	functions. The format is {cmd:hratio(}{it:hrlist}{cmd:)}, where the string 
	{it:hrlist} is {it:#1_1}[{it:#1_2 ...#1_r1}]{cmd:,}{it:#2_1}[{it:#2_2 ...#2_r2}]{cmd:,}{it:...}{cmd:,}{it:#k_1}[{it:#k_2 ...#k_rk}].
    	The event hazard ratio of group i (relative to the baseline distribution specified in
    	{cmd:edf0()}) is #i_j during period j, j=1,...ri; i=1,...k, If ri < {cmd:nperiod()} then
    	the hazard ratio function during periods ri+1,...{cmd:nperiod()} is assumed to be
    	#i_ri. If k < {cmd:ngroups()}, the hazard ratio functions for groups k+1,...,
    	{cmd:ngroups} are assumed equal to the geometric mean of the hazard ratio
    	functions for groups 1,...k.

{phang}
{cmd:index(}{it:#}{cmd:)} is the index I for Harrington-Fleming weights. Default # is 1.

{phang}
{cmd:ldf(}{it:llist}[{cmd:;}{it:llist}{cmd:;}{it:... llist}]{cmd:)} is required when {cmd:lg()}, 
	groups with loss to follow-up, is specified. {cmd:ldf()} specifies the distribution 
	function of time to loss-to-follow-up. The format is
	{cmd:ldf(}{it:llist}[{cmd:;}{it:llist}{cmd:;}{it:... llist}]{cmd:)}, 
	where each {it:llist} specifies a cumulative distribution function for time to loss to
    	follow-up, one for each group specified by {cmd:lg()} and in the same order.
    	Each {it:llist} has the same form as a distribution function
    	as {it:slist0} in {cmd:edf0()}, but {it:llist} is to be interpreted as a cumulative
    	distribution, not a survival distribution. For example, if {cmd:nperiod()} = 6, then
    	{cmd:lg(}{it:1 3}{cmd:)} {cmd:ldf(}{it:0.2}{cmd:;}{it:.05 0.15}{cmd:,}{it:2 5}{cmd:)} 
    	specifies that:{p_end}

{p 12 15 2}(i)   Groups 1 and 3 are subject to loss to follow-up.

{p 12 17 2}(ii)  The cumulative probability of loss to follow-up is .2 by the end
         of the last period in group1, .05 at the end of the period 2 and
         .15 at the end of period 5 in group 3.
         
{p 12 18 2}(iii) Individuals in the other groups are not subject to loss to
         follow-up.

{phang}
{cmd:lg(}{it:#}[{it:#...#}]{cmd:)} specifies the groups subject to loss to follow-up. 
	{cmd:ldf()} must then be specified giving the cumulative distribution functions 
	of time to loss to follow-up in the same order.

{phang}
{cmd:median(}{it:#}{cmd:)} specifies {it:#} to be the median survival in group 1.
	Use of this option over-rides the {cmd:edf0()} option. There is no default value.

{phang}
{cmd:method(}{it:methodname}{cmd:)} - {it:methodname} is
	{cmd:l} or {cmd:t} or {cmd:h} or {cmd:b} or {cmd:u}, where

{p 12 16 2}{cmd:l} = unweighted logrank (default test),

{p 12 16 2}{cmd:t} = Tarone-Ware test (logrank with weights proportional to the square 
	    root of the total number at risk at event times,
	    
{p 12 16 2}{cmd:h} = Harrington-Fleming (logrank with weights proportional to S**I,
            where S is the estimated pooled survival function at event times
            and I is the index for Harrington-Fleming weights (see option
            {cmdab:ind:ex()}),
            
{p 12 16 2}{cmd:b} = Binomial test conditional on the proportion of failures at the end
	    of the study, using Peto's approximation to the log odds ratio,
	    
{p 12 16 2}{cmd:u} = unconditional binomial test.

{phang}
{cmd:n(}{it:#}{cmd:)} specifies that total sample size is calculated if {cmd:n} = 0. 
	Otherwise power is calculated given total sample size = {cmd:n}. The default # is 0.

{phang}
{cmd:ngroups(}{it:#}{cmd:)} specifies the number of comparative groups. The default # is 2.

{phang}
{cmd:ni(}{it:#}{cmd:)} specifies whether the trial is of a superiority or a
	non-inferiority design. The default # is 0, meaning a superiority design.
	{cmd:ni(1)} specifies a non-inferiority design.

{phang}
{cmd:nperiod(}{it:#}{cmd:)} is the number of time periods within which all instantaneous
    	rates are constant. The default # is 1.

{phang}    
{cmd:onesided(}{it:#}{cmd:)} - {it:#} = 1 specifies that {cmd:alpha()}
	relates to a one-sided significance test. The default {it:#} is 0,
	meaning a two-sided test.

{phang}
{cmd:power(}{it:#}{cmd:)} specifies the study power. The default # is 0.8 if {cmd:n()} = 0.

{phang}
{cmd:pwehr(}{it:hrlist}{cmd:)} specifies the hazard ratio function post withdrawal 
	from allocated treatment. The format is {cmd:pwehr(}{it:hrlist}{cmd:)}, where 
	hrlist gives the hazard ratio functions (relative to the baseline event time 
	distribution) after treatment change for the groups specified by {cmd:wg} and 
	in the same order. The format and interpretation of hrlist is the same as that 
	of {cmd:hratio()} except that the hazard ratio functions for the remaining groups, 
	subject to treatment change (given in {cmd:wg}) but not assigned to a hazard ratio
    	function by {cmd:pwehr()}, is taken to be the same as the last hazard ratio
    	function specified by {cmd:pwehr()}. When both {cmd:pwehr()} and {cmd:crover()} are
    	specified, {cmd:crover()} is ignored.

{phang}
{cmd:recrt(}{it:rlist}{cmd:)} specifies the duration and rate of recruitment.
	Its format is {cmd:recrt(}[{it:duration [recrpr0]}]{cmd:,}[{it:w1 w2...wk}]{cmd:,}[{it:s1 s2...sk}]{cmd:)}, 
    	where {p_end}

{p 12 23 2}{it:duration} = the number of periods for the completion of recruitment.
	The default {it:duration} is the number of periods specified by {cmd:nperiod(}{it:#}{cmd:)}.
                   
{p 12 22 2}{it:recrpr0} = the proportion recruited (instantaneously) at the start
	of the study. The default is {it:recrpr0} = 0.
                  
{p 12 20 2}{it:w1...wk} are the relative proportions recruited in periods 1 to k.
	The default specifies equal proportions.
                
{p 12 20 2}{it:s1...sk} specify the shape of recruitment time distribution within
	periods. si = 0 for uniform entry during period i, and
	si = L>0 for negative exponential with rate L. The default
	is uniform entry time within each period.
 
{p 8 8 2}
	If  {cmd:recrt()} is not specified, recruitment is assumed completed at the begining 
	of the study, i.e. duration of recruitment = 0; this is equivalent to specifying
	{cmd:recrt(0, 0, 0)}.
 
{phang}               
{cmd:trend(}{it:#}{cmd:)} specifies a linear trend test. With the default
       ({it:#} = 0), the trend assumed is linear on the dose levels 1, 2, 3 ....
       With {it:#} = 1, doses are specified by using the {cmd:doses()} option.

{phang}
{cmd:replace} allows {it:filename} to be replaced if it exists.

{phang}
{cmd:tunit(}{it:#}{cmd:)} specifies the time-units of the periods. This option has
	no effect whatsoever on the computation of the power and sample size. It
	is used to label the output and serves as an aide-memoire. The value of {it:#}
	must be between 1 and 7, with 1 = years, 2 = 6 months, 3 = quarters, 4 = months,
	5 = weeks, 6 = days, 7 = unspecified. Default {it:#} is 1 (years).

{phang}
{cmd:wdf(}{it:wlist}[{cmd:;}{it:wlist}{cmd:;}{it:... wlist}]{cmd:)} is required when 
	{cmd:wg()}, groups with treatment change (withdrawal from allocated treatment), 
	is specified. {cmd:wdf()} specifies the distribution function of time to withdrawal. 
	The format is the same as that of {cmd:ldf()}.

{phang}
{cmd:wg(}{it:#}[{it:#...#}]{cmd:)} specifies the groups subject to withdrawal from allocated 
	treatment. {cmd:wdf()} must then be specified giving the cumulative distribution 
	functions of time to withdrawal from allocated treatment in the same order as in
    	{cmd:wg()}.


{title:Remarks}

{phang}
The file optionally saved by {cmd:artsurv} contains variables called {cmd:period}, and
{cmd:surv1}, ... {cmd:hr1}, ..., with one variable for each group. For example, {cmd:surv1}
contains the survival probabilities at the end of each period in group 1. The file
includes values of 1 for the survival probabilities and missing for the hazard ratios
at "period 0" i.e. the beginning of the trial, to facilitate plotting. The file
contains enough information to allow you to transpose it into "long" format from the
default "wide" format (see {help reshape} for more on these data formats). Using
the dataset and typing
{cmd:reshape long} will convert the data to the alternate format, and typing
{cmd:reshape wide} will convert it back again.


{title:Examples}

{phang}{cmd:. artsurv, method(l) edf0(0.5) hr(1,0.75) np(3) recrt(0 0, 1, 0 ) distant(0) detail(0) onesided(0) ni(0) tunit(1)}{break}
           (compares two exponential distributions using the logrank test)

{phang}{cmd:. artsurv, method(l) edf0(0.5) hr(1,0.75,0.5) np(3) ng(3) recrt(2 0,1,0) distant(0) detail(0) onesided(0) ni(0) tunit(1)}

{phang}{cmd:. artsurv, method(l) edf0(0.9 0.7 0.5, 1(1)3) hr(1,0.75,0.5) np(3) ng(3) recrt(2 0,1,0) trend(1) distant(0) detail(0) onesided(0) ni(0) tunit(1)}

{phang}{cmd:. artsurv, method(l) edf0(0.8 0.5, 1 3) hr(1,0.6 0.6 0.75) np(3) recrt(2 0,1,0) distant(0) detail(0) onesided(0) ni(0) tunit(1)}{break}
           (treatment effect changes over time)

{phang}{cmd:. artsurv using myres, method(l) edf0(0.8 0.5, 1 3) hr(1,0.6 0.6 0.75) np(3) recrt(2 0,1,0) distant(0) detail(0) onesided(0) ni(0) tunit(1)}{break}
           (saves survival probabilities and hazard ratios in 3 periods to myres.dta)

{phang}{cmd:. artsurv, method(l) edf0(0.5) hr(1,0.75) np(3) lg(1 2) ldf(.1;.1) recrt(2 0,1,0) distant(0) detail(0) onesided(0) ni(0) tunit(1)}{break}
           (10% lost to follow-up by end of study)

{phang}{cmd:. artsurv, method(l) edf0(0.5) hr(1,0.75) np(3) lg(1 2) ldf(.1;.1) wg(1 2) wdf(.3;.1) recrt(2 0,1,0) distant(0) detail(0) onesided(0) ni(0) tunit(1)}{break}
           (30% of group 1 and 10% of group 2 crossover by end of study)


{title:Authors}

{pstd}Abdel Babiker, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:a.babiker@ucl.ac.uk":Ab Babiker}

{pstd}Friederike Maria-Sophie Barthel, formerly MRC Clinical Trials Unit{break}
{browse "mailto:sophie@fm-sbarthel.de":Sophie Barthel}

{pstd}Babak Choodari-Oskooei, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:b.choodari-oskooei@ucl.ac.uk":Babak Oskooei}

{pstd}Patrick Royston, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:j.royston@ucl.ac.uk":Patrick Royston}


{title:Reference}

{phang}
Barthel, F.  M.-S., Babiker, A., Royston, P., and M. K. B. Parmar. 2006.
Evaluation of sample size and power for multi-arm survival trials
allowing for non-uniform accrual, non-proportional hazards, loss to
follow-up and cross-over. {it:Statistics in Medicine} 25: 2521-2542.


{title:Also see}

    Manual:  {hi:[R] sampsi},  {hi:[R] stpower}

{psee}
Online:  help for {help artmenu}, {help artbin}, {help artpep}, {help artsurvdlg}, {help artbindlg}
