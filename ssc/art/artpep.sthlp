{smcl}
{* 23dec2014}{...}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:artpep} {hline 2}}ART (Survival Outcomes) - Projection of Events and Power{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmdab:artpep}
[{cmd:using} {it:filename}[{cmd:.dta}]]
[
{cmd:,}
{it:options}
]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt date:start(ddmmmyyyy)}}Calendar date of trial opening{p_end}
{synopt :{opt ed:f0(slist0)}}Survival function in group {p_end}
{synopt :{opt epe:riods(#)}}Number of future periods
    over which projection of power and number of events is to be calculated{p_end}
{synopt :{opt ept:s(numlist)}}Numbers of additional patients to be recruited in each period{p_end}
{synopt :{opt pts(numlist)}}Numbers of patients recruited in each period since the start of the trial{p_end}
{synopt :{opt replace}}Allows {it:filename} to be replaced if it exists{p_end}
{synopt :{opt sta:rtperiod(#)}}Period to start reporting projections of events and power{p_end}
{synopt :{opt stop:recruit(#)}}Number of periods after which recruitment is to cease{p_end}
{synopt :{it:artsurv_options}}Options appropriate to {helpb artsurv}{p_end}
{synoptline}
{* synopt :{opt n(#)} Number of patients recruited by the end of the current period {p_end}}

{title:Description}

{pstd}
{cmd:artpep} estimates the number of events and power achieved in real
time as patients are recruited to a clinical trial with a time-to-event
outcome. It allows projection of events and power into the future,
allowing "what if?" sensitivity analyses to be evaluated. For example,
the effect on power of future patterns of patient accrual and survival
might be studied. Quantities calculated by {cmd:artpep} may optionally
be stored in a new Stata file called {it:filename} to facilitate further
analysis, plotting, etc.

{pstd}
Note that {cmd:artpep} is available either as a command-line program
(described here) or via a dialog, invoked by typing {cmd:db artpep}.
A separate help file ({helpb artpepdlg}) is available for the dialog.
Running the dialog will also generate the equivalent command line for
{cmd:artpep}.

{pstd}
See {it:Remarks} for details of {cmd:using} {it:filename}. 


{title:Options}

{phang}
{opt datestart(ddmmmyyyy)} signifies the date of opening of the trial (i.e.
when recruitment started). The date of the end of each period is used
to label the output, and is stored in {it:filename} if {cmd:using} is
specified. Example: {cmd:datestart(14oct2009)}.

{phang}
{cmd:edf0(}{it:slist0}{cmd:)} is not optional and gives the survival
	function in the control group (group 1). 
	This need not be one of the survival distributions to be compared
	in the trial, unless hratio = 1 for at least one of the groups. The format of
	{it:slist0} is {it:#1}[{it:#2 ...#r}{cmd:,}{it:#1 #2 ...#r}]. 
	Thus, {cmd:edf0(}p_1 p_2 ... p_r{cmd:,}t_1 t_2 ... t_r{cmd:)} gives the 
	value p_i for the survival function for the event time at the 
	end of time period t_i, i=1,...,r. Instantaneous event rates (i.e. hazards)
	are assumed constant within time periods, that is,
	the distribution of time-to-event is assumed to be piecewise exponential.
	Note that when used in a given calculation up to period T, t_r may validly be
	less than, equal to or greater than T. If t_r <= T, the rules described in the
	{cmd:edf0()} option of {help artsurv} are applied to compute the survival
	function at all periods <=T. If t_r > T, the same calculation is used but
	estimated survival probabilities for periods > T are not used
	in the calculation at T, although they may of course be used in calculations
	(e.g. projections of sample size and events) for periods later than T.

{pin}
	Be aware that use of the {cmd:median()} and {cmd:fp()}
	options of {cmd:artsurv} may modify the effects 
	and interpretation of {cmd:edf0()}.
	
{phang}
{cmd:eperiods(}{it:#}{cmd:)} specifies the number of 'extra' (future) periods
    over which projection of power and number of events is to be calculated.
    Default {it:#} is 1.

{phang}
{cmd:epts(}{it:numlist}{cmd:)} specifies in {it:numlist} the 
	numbers of 'extra' (additional) patients to be recruited in each period following
	the recruitment phase defined by the {cmd:pts()} option. For example,
	{cmd:pts(23 12 25) epts(30 30)} would specify 3 initial periods of
	recruitment followed by 2 further periods. A projection of events and power
	is required over the 2 further periods. The initial recruitment
	is of 23 patients in period 1, 12 in period 2 and 25 in period 3; 
	in each of periods 4 and 5, we expect to recruit an additional 30 patients.
	If the number of items in (or implied by expanding) {it:numlist} is less
	than that specifed by {cmd:pts()}, the final value in {it:numlist}
	is replicated as necessary to all subsequent periods. If {cmd:epts()}
	is not given, the default is that the mean of the numbers of patients
	specified in {cmd:pts()} is used for all projections.

{phang}
{cmd:pts(}{it:numlist}{cmd:)} is not optional. {it:numlist} specifies the 
	numbers of patients recruited in each period since the start of the trial,
	i.e. since randomisation. See {help artsurv} for the definition of a 'period'.
	The number of items in {it:numlist} defines the number of periods of recruitment so far.
	For example, {cmd:pts(23 12 25)} specifies 3 initial periods of
	recruitment, with recruitment of 23 patients in period 1, 12 in period 2,
	and 25 in period 3. The 'current' period would be period 3 and would be
	surrounded by parallel lines in the output.

{phang}
{cmd:replace} allows {it:filename} to be replaced if it exists.

{phang}
{cmd:startperiod(}{it:#}{cmd:)} specifies {it:#} as the period to start 
    reporting the projections of events and power. To report from the
    beginning of the trial, specify {cmd:startperiod(1)}. Note that
    {cmd:startperiod()} does not affect the period at which the
    calculations are started, only how the results are reported.
    The default {it:#} is the last period defined by {cmd:pts()}.
			
{phang}
{cmd:stoprecruit(}{it:#}{cmd:)} specifies the number of periods after which recruitment is
	to cease. {it:#} must be no smaller than the number of periods of
	recruitment implied by {cmd:pts()}. Default {it:#} = 0,
	meaning continue recruiting indefinitely (no follow-up phase).

{phang}
{it:artsurv_options} are any of the options of {cmd:artsurv} except {cmd:recrt()},
	{cmd:nperiod()}, {cmd:power()}, {cmd:n()}.


{title:Remarks}

{pstd}
The {cmd:using} {it:filename}[{cmd:.dta] construct saves items to 
{it:filename}{cmd:.dta}, as in the following example:

. artpep using myres, pts(15 14 15 16 19 40 44 63 65 56 65 59 78 67) epts(65)
  eperiods(7) startperiod(1) stoprecruit(15) datestart(24apr2001) alpha(.05)
  aratios(1 1) hratio(1, .75) ngroups(2) ni(0) onesided(0) trend(0) tunit(3)
  edf0(0.49 0.26 0.19 0.085 0.057, 4(4)20) median(0) method(l)

Date      |  quarter |    #pats    #C-events   #events   Power
----------+----------+-----------------------------------------
23jul2001 |      1   |      15         1           2    0.03521
22oct2001 |      2   |      29         3           5    0.04761
21jan2002 |      3   |      44         5           9    0.06248
23apr2002 |      4   |      60         9          16    0.08023
23jul2002 |      5   |      79        13          23    0.10128
22oct2002 |      6   |     119        19          34    0.12981
22jan2003 |      7   |     163        28          49    0.16942
23apr2003 |      8   |     226        39          70    0.22272
23jul2003 |      9   |     291        54          97    0.29037
23oct2003 |     10   |     347        70         128    0.36653
22jan2004 |     11   |     412        89         162    0.44703
22apr2004 |     12   |     471       110         200    0.52800
23jul2004 |     13   |     549       133         242    0.60767
----------+----------+-----------------------------------------
22oct2004 |     14   |     616       157         288    0.68285
----------+----------+-----------------------------------------
21jan2005 |     15   |     681       183         336    0.74893
23apr2005 |     16   |     681       206         381    0.79989
23jul2005 |     17   |     681       226         418    0.83529
22oct2005 |     18   |     681       241         449    0.86056
21jan2006 |     19   |     681       254         475    0.87914
23apr2006 |     20   |     681       265         497    0.89332
23jul2006 |     21   |     681       275         517    0.90446

file myres.dta saved

. use myres, replace

. describe

Contains data from myres.dta
  obs:            21                          
 vars:             6                          19 Sep 2012 09:31
 size:           504                          
---------------------------------------------------------------------------
              storage  display     value
variable name   type   format      label      variable label
---------------------------------------------------------------------------
date            float  %td                    date of end of period
period          float  %9.0g                  quarter period
patients        float  %9.0g                  Cumulative patients
Events          float  %9.0g                  Cumulative control-arm events
events          float  %9.0g                  Cumulative total events
power           float  %9.0g                  Power
---------------------------------------------------------------------------

. list

     +------------------------------------------------------------+
     |      date   period   patients   Events   events      power |
     |------------------------------------------------------------|
  1. | 23jul2001        1         15        1        2   .0352053 |
  2. | 22oct2001        2         29        3        5   .0476124 |
  3. | 21jan2002        3         44        5        9   .0624845 |
  4. | 23apr2002        4         60        9       16   .0802253 |
  5. | 23jul2002        5         79       13       23   .1012759 |
     |------------------------------------------------------------|
  6. | 22oct2002        6        119       19       34    .129815 |
  7. | 22jan2003        7        163       28       49   .1694168 |
  8. | 23apr2003        8        226       39       70   .2227229 |
  9. | 23jul2003        9        291       54       97   .2903701 |
 10. | 23oct2003       10        347       70      128   .3665293 |
     |------------------------------------------------------------|
 11. | 22jan2004       11        412       89      162   .4470252 |
 12. | 22apr2004       12        471      110      200   .5280019 |
 13. | 23jul2004       13        549      133      242   .6076685 |
 14. | 22oct2004       14        616      157      288   .6828461 |
 15. | 21jan2005       15        681      183      336   .7489257 |
     |------------------------------------------------------------|
 16. | 23apr2005       16        681      206      381   .7998888 |
 17. | 23jul2005       17        681      226      418   .8352927 |
 18. | 22oct2005       18        681      241      449   .8605611 |
 19. | 21jan2006       19        681      254      475   .8791357 |
 20. | 23apr2006       20        681      265      497   .8933169 |
     |------------------------------------------------------------|
 21. | 23jul2006       21        681      275      517   .9044613 |
     +------------------------------------------------------------+




{title:Examples of artpep command lines}

{phang}{cmd:. artpep, pts(25 30 40) edf0(0.5, 2) hr(1, 0.7)}

{phang}{cmd:. artpep, pts(25 30 40) datestart(15jan2008) epts(50) eperiods(3) edf0(0.5, 2) hr(1, 0.7)}

{phang}{cmd:. artpep, pts(5 7 12 18 25 30 40) eperiods(8) stoprecruit(12) edf0(0.5, 2) hr(1, 0.7)}

{phang}{cmd:. artpep using myres, pts(5 7 12 18 25 30 40) datestart(01nov1995) epts(45) eperiods(8) startperiod(3) stoprecruit(12) edf0(0.9 0.7 0.1, 1 2 9) hr(1, 0.7) replace}

{phang}{cmd:. use myres, replace}

{phang}{cmd:. line patients events date, sort}


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
Royston, P., and F. M.-S. Barthel. 2010. Projection of power and events in
clinical trials with a time-to-event outcome. {it:Stata Journal} 10: 386-394.


{title:Also see}

{psee}
Online:  help for {help artpepdlg}, {help artsurv}
