{smcl}
{* *! version 1.1 24sep2014 Philip M Jones pjones8@uwo.ca}{...}
{cmd:help csti}
{hline}

{title:Title}

{p 4 11 2}
{bf:csti} {hline 2} Wrapper for -csi- command in order to use total numbers rather than individual cell counts{p_end}

{title:Syntax}

{p 8 17 2}
{cmd:csti} #n1/#N1 #n2/#N2  [, {it:csi_options}]

{it:where,}
{phang2}n1 = number of events in the 'exposed' (intervention) group{p_end}
{phang2}N1 = total number of subjects in the 'exposed' (intervention) group{p_end}
{phang2}n2 = number of events in the 'unexposed' (control) group{p_end}
{phang2}N2 = total number of subjects in the 'unexposed' (control) group{p_end}

{phang2}Note the slash ("/") is mandatory and the command will fail if it is not entered.{p_end}

{pstd}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:csi_options}
{synopt:{opt or}}report odds ratio{p_end}
{synopt:{opt w:oolf}}use Woolf approximation to calculate SE and CI of the odds ratio{p_end}
{synopt:{opt tb}}calculate test-based confidence intervals{p_end}
{synopt:{opt e:xact}}calculate Fisher's exact p{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is level(95){p_end}

{pstd}

{title:Description}

{pstd}{opt csti} Ñ In many journals, including medical journals, binary outcomes (such as mortality) are typically displayed in a Table as the number of events over the number of patients or subjects in the group, i.e. "n/N".
If one wants to compute a risk ratio and chi-squared (or Fisher's exact test) P value, Stata's {dialog csi:csi} command can be used.
 
{pstd}However, to use {opt csi}, it is first necessary to calculate, within each group, the difference between the total number of subjects and the number of events.
This is because {opt csi} expects the data to be entered as individual cell counts rather than "events" and "total subjects".{p_end}

{pstd}While this is not particularly difficult, it is prone to simple math errors, and requires more effort than simply entering the number of events and the denominator within each group.
This is especially true when performing this task for multiple outcomes.{p_end}

{pstd}Also, the {opt csi} command requires you to enter the cell counts in a slightly awkward way, as it expects the events for both groups to be entered first, followed by the non-event counts.
When going through a journal article, for instance to verify RRs and P values, it seems more natural to enter both counts for one group first, followed by the counts for the other group.

{pstd}For example, if 23/130 patients died in an intervention group while 13/127 patients died in a control group, Stata's {opt csi} syntax would be:{p_end}
{phang2}{cmd:. csi 23 13 107 114}{p_end}

{pstd}{opt csti} allows you to enter data more naturally. The same outcomes as above, when using {opt csti}, are entered like this:{p_end}
{phang2}{cmd:. csti 23/130 13/127}{p_end}


{title:Details}

Because this is a wrapper command for {opt csi}, all {it:csi_options} are passed along and will work normally.


{title:Options and Saved results}

The {opt csi} command's options are described in {help csi:csi's help file}. All "r" returned values are retained from the {opt csi} command.


{title:Examples}

{phang}1. A two-group randomized trial showed that 109/2012 patients developed kidney failure with Treatment A while 57/2015 patients developed kidney failure with Treatment B.{p_end}

{phang2}{cmd:. csti 109/2012 57/2015}{p_end}

{phang}2. The same numbers as Example #1, but now you want the P value to be from Fisher's exact test (instead of from the chi-squared test), and you also want to see the odds ratio as well as the risk ratio:{p_end}

{phang2}{cmd:. csti 109/2012 57/2015, exact or}{p_end}

{phang}3. If you were using Stata's {opt csi} command, you would have entered the following command to obtain exactly the same results as Example #2:{p_end}

{phang2}{cmd:. csi 109 57 1903 1958, exact or}{p_end}


{title:Author Information:}

{phang}Philip M Jones, MD, MSc (Clinical Trials), FRCPC{p_end}
{phang}Department of Anesthesiology & Perioperative Medicine{p_end}
{phang}Department of Epidemiology & Biostatistics{p_end}
{phang}Faculty of Medicine & Dentistry, University of Western Ontario{p_end}
{phang}London, Ontario, Canada{p_end}
{phang}pjones8@uwo.ca{p_end}

{title:Change Log:}

{phang}{bf:17sep2014} - Version 1.0{p_end}
{phang2}Initial version published.{p_end}

{phang}{bf:01oct2014} - Version 1.1{p_end}
{phang2}Changed syntax based on very helpful feedback from Sergiy Radyakin.
Added some (minor) error detection.{p_end}

{title:Also see}

{psee}
Manual:  {manlink ST epitab}

{psee}
{space 2}Help:  {help csi:csi}
{p_end}
