{smcl}
{* 23dec2014}{...}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:artpepdlg} {hline 2}}ART (Survival Outcomes) - Projection of Events and Power dialog{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:artpep} projects the power and number of events for new patients
to be recruited to a clinical trial with a time-to-event outcome.
Quantities calculated by {cmd:artpep} may optionally be stored in a new Stata file
called {it:filename} to facilitate further analysis, plotting, etc. The number of
events in the control arm is output under the heading {cmd:#C-events}, and
the total number of events (all groups) under {cmd:#events}.

{pstd}
{hi:IMPORTANT}: the {it:ART/Survival outcomes} dialog must be run before this dialog,
to set up the basic parameters of the trial design. This may be done via the
{it:ART Settings} button, or from the ART menu. Compulsory entries are
(from Panel 1) {cmd:Number of groups}, {cmd:Alpha (2-sided)},
{cmd:Baseline survival or failure probabilities}
and corresponding {cmd:At end of period(s)}, or alternatively 
{cmd:Median survival time}; (from Panel 2) {cmd:Hazard ratios}. Enter these values
and any other options you require, and run the {it:ART/Survival outcomes} dialog.
Ignore its output.
{cmd:Number of periods} from Panel 1 and patient recruitment information from Panel 3
will be ignored since they are provided by the {it:Artpep} dialog.
The entries from the {it:ART/Survival outcomes} dialog
are stored in a global macro called {hi:$S_ARTPEP} (see {it:Remarks}).

{pstd}
The only compulsory entry for the {it:Artpep} dialog is
{cmd:Patients recruited in each period so far}. Defaults are provided
for other entries.

{pstd}
See {it:Remarks} for details of what appears in the Stata Review window
as a result of running the {it:Artpep} dialog.


{title:Options}

{phang}
{it:view dialog artsurv} opens a dialog where the user may set any of the
options of {cmd:artsurv} except {cmd:recrt()}, {cmd:nperiod()}, {cmd:power()},
{cmd:n()}.

{phang}
{cmd:Patients recruited in each period so far} (pts) is not optional.
{it:numlist} specifies the numbers of patients recruited in each period since
the start of the trial, i.e. since randomisation. See {help artsurv} for the
definition of a 'period'. The number of items in {it:numlist} defines the
number of periods of recruitment so far. For example,
{cmd:pts(23 12 25) epts(30 30)} specifies 3 initial periods of
recruitment, with recruitment of 23 patients in period 1, 12 in period 2,
and 25 in period 3. The current period would be period 3 and would be
surrounded by parallel lines in the output.

{phang}
{cmd:Additional patients to be recruited} (epts) specifies in {it:numlist} the 
numbers of additional patients to be recruited in each period following
the recruitment phase defined by the {cmd:pts()} option. For example,
{cmd:pts(23 12 25) epts(30 30)} would specify 3 initial periods of
recruitment followed by 2 further periods. A projection of events and power
is required over the 2 further periods. The initial recruitment
is of 23 patients in period 1, 12 in period 2 and 25 in period 3; 
in each of periods 4 and 5, we expect to recruit an additional 30 patients.
If the number of items in (or implied by expanding) {cmd:numlist} is less
than that specifed by {cmd:pts()}, the final value in {it:numlist}
is replicated as necessary to all subsequent periods. If {cmd:epts()}
is not given, the default is that the mean of the numbers of patients
specified in {cmd:pts()} is used for all projections.

{phang}
{cmd:Number of periods over which to project} (eperiods) specifies the
number of periods over which projection of power and number of events
is to be calculated. Default {it:#}: 1.

{phang}
{cmd:Period in which recruitment to cease} (stoprecruit) specifies the
number of periods after which recruitment is to cease. {it:#} must be
no smaller than the number of periods of recruitment implied by
{cmd:pts()}. Default {it:#} = 0, meaning continue recruiting indefinitely
(no follow-up phase).
	
{phang}
{cmd:No. of pts. recruited at end of current period} (n) specifies that
the number of patients recruited by the end of the current period is {it:#}.
Use of this option converts the recruitment figures given in {cmd:pts()}
to weights, rather than absolute numbers of patients (the default). This
option is useful if you have an analysis of all patients with follow-up
at the current time, and you wish to check that the number of events
observed on this subset of all recruited patients agrees roughly with
what is expected from the assumptions underlying the design.
	
{phang}
{cmd:Period to start reporting projections} (startperiod) specifies the
period from which to start projections of power and events.

{phang}
{cmd:Start date of trial (ddmmmyyyy)} is the calendar day of the beginning
of recruitment. {cmd:artpep} reports the date of the end of each design
period. Because on average a year contains about 365.25 days not 365, 
when the time unit is 1 year, the exact day reported may vary by one
day (e.g. usually 14oct2009, might occasionally be 15oct2009). The
reported dates are of course only a rough indication. Example of
date format: 14oct2009.


{title:Remarks}

{pstd}
Note that when Stata executes {cmd:artsurv}, it places the options
for {cmd:artsurv}, which are used by {cmd:artpep}, in a global macro called
$S_ARTPEP. The string $S_ARTPEP is echoed to the command line and appears in the Review
window after {cmd:artpep} has been executed. Also, the string $S_ARTPEP is expanded
and the full {cmd:artpep} command also appears in the Review window. This allows
you easily to edit the {cmd:artsurv} options that are supplied to
{cmd:artpep}.


{title:Examples}

{phang}{cmd:. artpep, pts(25 30 40) edf0(0.5, 2) hr(1, 0.7)}

{phang}{cmd:. artpep, pts(25 30 40) epts(50) eperiods(3) edf0(0.5, 2) hr(1, 0.7)}

{phang}{cmd:. artpep, pts(5 7 12 18 25 30 40) eperiods(8) stoprecruit(12) edf0(0.5, 2) hr(1, 0.7)}

{phang}{cmd:. artpep using myres, pts(5 7 12 18 25 30 40) epts(45) eperiods(8) startperiod(3) stoprecruit(12) edf0(0.9 0.7 0.1, 1 2 9) hr(1, 0.7) replace}

{phang}{cmd:. use myres, replace}

{phang}{cmd:. line patients events period, sort}


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
Online:  help for {help artsurv}, {help artpep}.
