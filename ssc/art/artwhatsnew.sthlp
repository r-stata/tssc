{smcl}
{* 17apr2018}{...}

{title:Title}

{phang}
{hi:ART - Assessment of Resources for Trials}


{title:Description}

{pstd}
This file summarizes changes made to ART since its general release on 01nov2004.
Please refer to individual ART dialogs and help files for further information.
Most recent changes are listed first.


{hline 8} {hi:update 17apr2018} {hline}

{phang}
1.	One-sided option for non-inferiority designs corrected.
The previous version double-adjusted alpha.


{hline 8} {hi:update 23dec2014} {hline}

{phang}
1.	Sample size and power for non-inferiority designs corrected.

{phang}
2.	Point mass at time 0 for distribution functions enabled.

{phang}
3.	Index parameter for the Harrington-Fleming test enabled.
The test method no longer gives an error message with this option.

{phang}
4.	Expected proportions lost to follow-up and crossing over are now
stored in {cmd:r()} functions.

{phang}
5.  Update of all ART help files, and all are now *.sthlp files.


{hline 8} {hi:update 19oct2009} {hline}

{phang}
1.  The number of events in each group is displayed with the {cmd:detail} option.

{phang}
2.  {cmd:artpep} has been updated to display the number of control arm events and
the calendar date of the end of each period.


{hline 8} {hi:update 20aug2009} {hline}

{phang}
1.  The call to artmenu has been updated to work with Stata 11.


{hline 8} {hi:update 24oct2006} {hline}

{phang}
1.  {it:numlist} abbreviated entry of lists of periods now supported,
e.g. {hi:1 2 3 4 5 6} may be entered as {hi:1(1)6}. See {help numlist}.

{phang}
2.  {help artpep} dialog added (see {help artpepdlg}).

{hline 8} {hi:update 06jul2005} {hline}

{phang}
1.  Correction to the actions of the main dialog when specifying hazard ratios after cross-over

{phang}
2.  Improvements to some of the help files. In particular you may wish to
consult {help artmenu} for a discussion on how to calculate sample size for
trials in which several experimental arms are compared with a control arm.


{hline 8} {hi:update 13jan2005} {hline}

{phang}
1.  New "Save using filename" option in the ART survival dialog, to
    correspond to the equivalent facility in artsurv.ado

{phang}
2.  Syntax for {cmd:trend} option in artsurv has changed.

{phang}
3.  Minor changes to the help files.


{hline 8} {hi:update 13dec2004} {hline}

{phang}
1.  Version 1.0.3 of {help artsurv} released - includes ability to save
    probabilities and hazard ratios to a new file. Bug fix on output
    of accrual weights, which could look wrong (although they were
    correct internally).
    {cmd:nohead} option to suppress header on output.

{phang}
2.  Minor wording changes to panel 1 of the ART survival dialog.

{phang}
3.  Various improvements to the help files.

{phang}
4.  Addition of earlier version of this file (artwhatsnew.hlp).


{hline 8} {hi:update 12nov2004} {hline}

{phang}
1.  Version 1.0.2 of {help artsurv} released - allows more periods in defining the
    survival curve than are indicated by nperiod().

{phang}
2.  Version 1.0.0 of {help artpep} released - projections of power and events,
    data saved to new file


{title:Authors}

{pstd}Abdel Babiker, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:a.babiker@ucl.ac.uk":Ab Babiker}

{pstd}Friederike Maria-Sophie Barthel, formerly MRC Clinical Trials Unit{break}
{browse "mailto:sophie@fm-sbarthel.de":Sophie Barthel}

{pstd}Babak Choodari-Oskooei, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:b.choodari-oskooei@ucl.ac.uk":Babak Oskooei}

{pstd}Patrick Royston, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:j.royston@ucl.ac.uk":Patrick Royston}
