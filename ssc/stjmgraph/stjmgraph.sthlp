{smcl}
{* *! version 1.0.4 21apr2015}{...}
{hline}
{cmd:help stjmgraph} {right:also see: {helpb stjm}, {helpb stjm postestimation}}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:stjmgraph} {hline 2}}Joint longitudinal and survival graph{p_end}
{p2colreset}{...}

{title:Syntax}

{phang2}
{cmd: stjmgraph} {it:long_depvar} {ifin} [{cmd:,} {it:options}]


{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt p:anel(varname)}}panel identification variable{p_end}
{synopt:{opt indcensg:raphopts(string)}}options to pass to each individual line plot for censored observations{p_end}
{synopt:{opt indeventg:raphopts(string)}}options to pass to each individual line plot for observations with the event{p_end}
{synopt:{opt censg:raphopts(string)}}options to pass to the overall twoway plot for censored observations{p_end}
{synopt:{opt eventg:raphopts(string)}}options to pass to the twoway plot for observations with the event{p_end}
{synopt:{opt combine:opts(string)}}options to pass to the final graph combine{p_end}
{synopt:{opt draw}}displays all graphs used to create the final combined graph{p_end}
{synopt:{opt low:ess}}overlay a lowess smoother{p_end}
{synopt:{opt adjust}}adjust the timescale by scaling to event/censoring time{p_end}
{synopt:{opt no:data}}suppresses displaying individual trajectories for every patient{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:stjmgraph} creates a longitudinal trajectory plot, whereby the timescale can be adjusted by taking away each patient's 
event/censoring time. This form of graph can be useful to display joint longitudinal and survival data, giving an indication 
of any association between the two processes. A separate plot is created for patients who were censored and for patients who 
experienced the event of interest. They are then combined using {cmd:graph combine}.{p_end}

{pstd}
The dataset must be {cmd:stset} correctly into enter and exit times, using the enter option; see {manhelp stset ST}. 
{cmd:stjmgraph} uses {cmd:_t0} to denote measurement times. For example, below we have 3 patients with 2, 5 and 3 measurements 
each, respectively.{p_end}

		{hline 33}
		id    _t0    _t   _d    long_resp
		{hline 33}
		 1    0     0.2    0         0.93
		 1    0.2   0.7    0         1.32
		 2    0     0.5    0         1.15
		 2    0.5   1.2    0         1.67
		 2    1.2   1.6    0         1.92
		 2    1.6   1.9    0         2.65
		 2    1.9   2.6    1         3.15
		 3    0     2      0         0.25
		 3    2     2.3    0         0.21
		 3    2.3   2.4    1         0.31
		{hline 33}

{pstd}See {help stjm} for more details.{p_end}
		
		
{title:Options}

{phang}
{opt panel(varname)} defines the panel identification variable.

{phang}
{opt indcensgraphopts(string)} pass options to each individual line graph of censored observations. See {help twoway_options}.

{phang}
{opt indeventgraphopts(string)} pass options to each individual line graph of observations who experienced the event of interest. See {help twoway_options}.

{phang}
{opt censgraphopts(string)} pass options to the twoway graph of censored observations. See {help twoway_options}.

{phang}
{opt eventgraphopts(string)} pass options to the twoway graph of observations who experienced the event of interest. See {help twoway_options}.

{phang}
{opt combineopts(string)} pass options to the final graph combine. See {help graph combine}.

{phang}
{opt draw} displays the intermediate twoway plots used to create the final graph.

{phang}
{opt lowess} overlays a lowess smoother to aid interpretation.

{phang}
{opt adjust} scales the timescale (x-axis) by taking away each patient's censoring/event time from their measurement times. This is useful to see differences in trajectories 
prior to an event.

{phang}
{opt nodata} suppresses the display of individual trajectories for each patient.


{title:Example}

{pstd}Load primary biliary cirrhosis dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/s/stjm_pbc_example_data":. use http://fmwww.bc.edu/repec/bocode/s/stjm_pbc_example_data}{p_end}

{pstd}stset the data:{p_end}
{phang}{stata "stset stop, enter(start) f(event=1) id(id)":. stset stop, enter(start) f(event=1) id(id)}{p_end}

{pstd}Create joint plot:{p_end}
{phang}{stata "stjmgraph logb, panel(id) lowess adjust":. stjmgraph logb, panel(id) lowess adjust}{p_end}


{title:Author}

{pstd}Michael J. Crowther{p_end}
{pstd}University of Leicester{p_end}
{pstd}UK{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}.{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:References}

{phang}
Crowther MJ, Abrams KR and Lambert PC (2012). {browse "http://repec.org/usug2011/UK11_crowther.pdf":Joint modelling of longitudinal and survival data}. (Submitted).{p_end}


{title:Also see}

{psee}
Online: {helpb stjm}, {helpb stjm postestimation}
{p_end}
