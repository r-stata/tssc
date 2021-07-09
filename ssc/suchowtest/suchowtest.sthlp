{smcl}
{cmd:help suchowtest}
{hline}



{title:Title}

{pstd}
{hi:suchowtest} performs successive Chow tests on cross-section and time series data



{title:Syntax}

{phang2}
{cmd:suchowtest}
	{depvar} [{indepvars}]
	{ifin} {weight}
	[{cmd:,} {it:options}]


{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt: {opth thresv(varname)}}indicates the threshold variable{p_end}
{synopt: {opt stub(string)}}designates a string name from which new variable names will be created{p_end}
{synopt :{opt fpctile(#)}}specifies the lower bound percentile of the threshold variable{p_end}
{synopt :{opt lpctile(#)}}specifies the upper bound percentile of the threshold variable{p_end}
{synopt :{opt step(#)}}indicates the step by which we want to move the sample's break point{p_end}
{synopt: {opt sig(#)}}designates the significance level we want to set for the p-value of the Chow test{p_end}

{syntab:Reporting}
{synopt: {opt nographs}}suppress the display of graphs after the estimations are performed{p_end}
{synopt: {opt saving(string)}}allows to save the graphs that the command displays.{p_end}


{syntab:Additional Options}
{synopt :{it:{help regress:regress_options}}}In addition to the options listed above, all options of the {cmd:regress} command can be used{p_end}
{synoptline}
{phang}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.
{p_end}
{p 4 6 2}
{cmd:by} is not allowed with {hi:suchowtest}; see {manhelp by D} for more details on {cmd:by}.{p_end}
{p 4 6 2}
{it:indepvars} and the {opth thresv(varname)} option may contain factor variables; see {help fvvarlist}. {p_end}
{p 4 6 2}
{it:depvar}, {it:indepvars} and the {opth thresv(varname)} option may contain time-series operators; see {help tsvarlist}.{p_end}



{title:Description}

{pstd}
{hi:suchowtest} performs successive Chow tests on cross-section and time series data. Habitually,
when we are doing the Chow test, we split the sample of study in two subsamples using an
exogenous break point. Unlike the previous method, the command {hi:suchowtest}
finds the break point endogenously. We do not have to supply a break point.
If there is a threshold, the command finds it by using the information given
by the data. If there is no break point the command will inform us too. This
method of finding thresholds appears to be more reasonable in cases where the
researcher does not know a priori the breaking point. The theory behind the
command {hi:suchowtest} is provided by Berthelemy and Varoudakis (1996).



{title:Options}

{dlgtab:Model}

{phang}
{opth thresv(varname)} indicates the threshold variable. To form this option,
you put inside the brackets the variable name representing the threshold variable.
You must specify this option in order to get a result. Hence this option is not optional.

{phang}
{opt stub(string)} designates a string name from which new variable names will be
created. To form this option, you put inside the brackets a string name (without the double quotes). Then new
variable names will be created from this string. You must specify this option in
order to get a result. Hence this option is not optional.

{phang}
{opt fpctile(#)} specifies the lower bound percentile of the threshold variable that
must be included in the search for a break point. The default value of this option is 10.
Hence the search for the break point starts at the 10th percentile of the threshold variable.

{phang}
{opt lpctile(#)} specifies the upper bound percentile of the threshold variable that
must be included in the search for a break point. The default value of this option is 90.
Hence the search for the break point starts at the 10th percentile and goes up to the 90th
percentile of the threshold variable.

{phang}
{opt step(#)} indicates the step by which we want to move the sample's break point.
The default value of this option is 1. This means that the sample's break point is
moved forward by one observation every time.

{phang}
{opt sig(#)} designates the significance level we want to set for the p-value of the Chow
test. The default value of this option is 0.10. This means that we want the p-value of the
Chow test to be significant at most at the 10% level.

{dlgtab:Reporting}

{phang}
{opt nographs} suppress the display of graphs after the estimations are performed. This
option is used when we do not want to display the graphs after the estimations are done.

{phang}
{opt saving(string)} In this option, you specify the complete file path where you want to save the
graphs produced by the command. You must enclose de path in double quotes. If you do not
specify this option, the graphs will be displayed, if you do not choose the {opt nographs}
option, but they will not be saved.

{dlgtab:Additional Options}

{phang}
{it:{help regress:regress_options}}:
{opt noc:onstant},
{opt h:ascons},
{opt tsscons},
{opth vce(vcetype)},
{opt l:evel(#)},
{opt b:eta},
{opth ef:orm(strings:string)}, etc.
See {manhelp regress R}.
All options of the {cmd:regress} command can be used.

{phang2}
You can use all the options of the command {cmd:regress}. To use them, enter them in the
same manner that you would do with the {cmd:regress} command.



{title:Saved results}

{pstd}
{cmd:suchowtest} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(maxchowfh)}}Chow Test (F-Test){p_end}
{synopt:{cmd:r(maxpvchowtest)}}P-Value of the Chow Test{p_end}
{synopt:{cmd:r(maxbreakpt)}}Value of the break point parameter{p_end}
{synopt:{cmd:r(maxobsvalue)}}Observation number corresponding to the break point{p_end}
{synopt:{cmd:r(qlstat)}}Maximum of the QL Statistic{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(chowfh)}}Variable containing all the Chow F-Statistics{p_end}
{synopt:{cmd:r(chowstatpv)}}Variable containing all the P-Values of the Chow Test{p_end}
{synopt:{cmd:r(breakptpar)}}Variable containing all the Break Point Parameters{p_end}
{synopt:{cmd:r(qlvariable)}}Variable containing all the QL Statistics{p_end}



{title:Examples}

{p 4 8 2} Before beginning the estimations, we use the {hi:set more off} instruction to tell
{hi:Stata} not to pause when displaying the results. {p_end}

{p 4 8 2}{stata "set more off"}{p_end}

{p 4 8 2} We load the data we are going to use and describe them. The description shows that
we have cross section data which represent the average of the variables  from 1975 to 2004. {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/s/suchowtestcross.dta, clear"}{p_end}

{p 4 8 2}{stata "describe"}{p_end}

{p 4 8 2} We estimate a standard conditional convergence growth regression in which the real GDP
per capita growth rate is regressed on initial real GDP per capita, stock market capitalization
(financial development) and human capital. We use financial development as threshold variable
with the option {opt thresv()}. We also specify the option {opt stub()} in which we put the
string "sct" without the double quotes. Note that these two options are required. {p_end}

{p 4 8 2}{stata "suchowtest croisspibt lninitgdppc lnstmktcap lnyr_sch_sec, thresv(lnstmktcap) stub(sct)"}{p_end}

{p 4 8 2} The estimation firstly gives some statistics concerning the threshold. The first
statistic is the observation number at which the break point occurs.  The second is the
maximum of the QL statistic. The third is the Chow test and its p-value and the last one
is the value of the threshold variable at the break point. Secondly, the estimation provides
the OLS regression below the break point parameter. Thirdly, the estimation gives the OLS
regression above the break point parameter. The estimation also offers three graphs. 
The first titled "QL STATISTIC" draws the QL statistic against the break point parameter. 
The green vertical line represents the observation at which the break point occurs.
The second titled "P-VALUES OF THE CHOW TEST" graphs the p-values of the Chow test against
the break point parameter. The green horizontal line is the significance level of the
p-value of the Chow test. The third titled "PV. CHOW TEST AND QL STAT." is the combination
of the two previous graphs. The left y-axis graphs the p-values of the Chow test while
the right y-axis provides the QL statistic.  {p_end}

{p 4 8 2} The estimation also generates variables containing the previously provided
statistics. These variables contain: The break point parameter, the QL statistic, the
p-values of the Chow test and the Chow F-statistic. To see these variables, we type: {p_end}

{p 4 8 2}{stata "describe sct_*"}{p_end}

{p 4 8 2} We illustrate the use of options {opt fpctile(#)} and {opt lpctile(#)}. By default
the search for the break point starts at the 10th percentile and goes up to the 90th percentile
of the threshold variable. Now we extend the search range of the threshold. We start from the
5th percentile and goes up to the 95th percentile. {p_end}

{p 4 8 2}{stata "suchowtest croisspibt lninitgdppc lnstmktcap lnyr_sch_sec lngconsgdp lnopenwb, thresv(lnstmktcap) stub(sct) fpctile(5) lpctile(95)"}{p_end}

{p 4 8 2} We show the use of the option {opt sig()}. We enter the value 0.01 as the significance level of the p-value of the Chow test. {p_end}

{p 4 8 2}{stata "suchowtest croisspibt lninitgdppc lnstmktcap lnyr_sch_sec lngconsgdp lnopenwb, thresv(lnstmktcap) stub(sct) sig(0.01)"}{p_end}

{p 4 8 2} The command {hi:suchowtest} indicates that there is no break point at this significance level. It suggests us to increase the significance
level to augment the chance of obtaining a threshold. Hence we increase the significance level to 0.05.  {p_end}

{p 4 8 2}{stata "suchowtest croisspibt lninitgdppc lnstmktcap lnyr_sch_sec lngconsgdp lnopenwb, thresv(lnstmktcap) stub(sct) sig(0.05)"}{p_end}

{p 4 8 2} If we do not want to display the graphs, we type: {p_end}

{p 4 8 2}{stata "suchowtest croisspibt lninitgdppc lnstmktcap lnyr_sch_sec lngconsgdp, thresv(lnstmktcap) stub(sct) nographs"}{p_end}

{p 4 8 2} In addition to the options cited above, all options of the {cmd:regress} command can be used. For instance we show here how
to compute robust standard errors with the option {opt vce(robust)}.{p_end}

{p 4 8 2}{stata "suchowtest croisspibt lninitgdppc lnstmktcap lnyr_sch_sec lngconsgdp vtotopen, thresv(lnstmktcap) stub(sct) vce(robust)"}{p_end}

{p 4 8 2} In the following, we demonstrate how to use the {opt saving(string)} option. Assume that you have Windows as your Operating System and you
want to save the graphs produced by the command {hi:suchowtest} in a folder named "mystatagraphs" located in the "C:\" drive. So the full path name
is "C:\mystatagraphs". Note that, you must physically create this folder, otherwise the next instructions will not work at all. Also if you have an
Operating System other than Windows, you must supply the correct file path according to your Platform. To save the graphs in the "mystatagraphs" folder, just type
(without forgetting the double quotes): {p_end}

{p 4 8 2}{stata `"suchowtest croisspibt lninitgdppc lnstmktcap lnyr_sch_sec, thresv(lnstmktcap) stub(sct) saving("C:\mystatagraphs") "'}{p_end}

{p 4 8 2} If you open the folder "mystatagraphs", you will find that it contains three graphs. If you want to save another set of graphs in the
same folder, just change the name that you put in the {opt stub()} option. For instance, change it to "robt" and you will have three more graphs
in the folder "mystatagraphs" by executing the following line. {p_end}

{p 4 8 2}{stata `"suchowtest croisspibt lninitgdppc lnstmktcap lnyr_sch_sec lngconsgdp vtotopen, thresv(lnstmktcap) stub(robt) vce(robust) saving("C:\mystatagraphs") "'}{p_end}

{p 4 8 2} Now let's illustrate how to use the command {hi:suchowtest} with time series data. We load the data, describe and {it:tsset} them.
We observe that we have time series data for France from 1960 to 2013. {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/s/suchowtesttime.dta, clear"}{p_end}

{p 4 8 2}{stata "describe"}{p_end}

{p 4 8 2}{stata "tsset year"}{p_end}

{p 4 8 2} Next, we estimate an investment equation in which the first difference of log investment is regressed on the first differences of log
real GDP, real interest rate and inflation. The regression also takes into account a time trend. As usual, the options {opt thresv()} and
{opt stub()} are included. Here we employ the first difference of the log of real GDP as the threshold variable. {p_end}

{p 4 8 2}{stata "suchowtest d.linvest d.lrgdp d.rirs d.inflati trend, thresv(d.lrgdp) stub(invsb)"}{p_end}



{title:References}

{pstd}
Berthelemy, J. C. and A. Varoudakis: 1996, "Economic Growth, Convergence Clubs, and the Role
of Financial Development", {it:Oxford Economic Papers} 48(2), 300-328.
{p_end}



{title:Author}

{p 4}Diallo Ibrahima Amadou, {browse "mailto:zavren@gmail.com":zavren@gmail.com} {p_end}



{title:Also see}

{psee}
Online: help for {bf:{help regress}}, {bf:{help chowreg}} (if installed)
{p_end}

