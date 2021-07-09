{smcl}
{* *! version 1.0.1  }{...}
{cmd:help hamiltonfilter}
{hline}

{title:Title}

{pstd}
    {hi: Calculates the Hamilton Filter for a Single Time Series or for a Panel Dataset}



{title:Syntax}

{phang2}
{cmd:hamiltonfilter}
{help varname:{it:varname}}
{ifin}
{cmd:,} {it:options}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt stub:(string)}}designates a string name from which new variable names will be created {p_end}
{synopt:{opt freq:uency(string)}}specifies the units of the time variable: monthly, quarterly or yearly {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {opt tsset}  or {opt xtset} your data before using {opt hamiltonfilter};
see {manhelp tsset TS} and {manhelp xtset XT}.{p_end}
{p 4 6 2}
The {hi:hamiltonfilter} command works for both Time series and Panel data. {p_end}
{p 4 6 2}
{help varname:{it:varname}} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
{cmd:by} is not allowed with {hi:hamiltonfilter}; see {manhelp by D} for more details on {cmd:by}.{p_end}



{title:Description}

{pstd}
{cmd:hamiltonfilter} calculates the Hamilton filter for a single time series or for a panel 
dataset. The command uses the Hamilton filter to separate a time series into trend and 
cyclical components. The Hamilton filter is utilized as an alternative to the Hodrick-Prescott 
high-pass filter. The theory behind the command {cmd:hamiltonfilter} is provided by 
Hamilton (2017). The paper also gives the criticisms of the Hodrick-Prescott filter 
and explains why the Hamilton filter is a superior alternative.



{title:Options}

{phang}
{opt stub(string)} designates a string name from which new variable names will be 
created. To form this option, you put inside the brackets a string name (without the 
double quotes). Then new variable names will be created from this string. You must 
specify this option in order to get a result. Hence this option is required.

{phang}
{opt freq:uency(string)} specifies the units of the time variable. To form this 
option, you put inside the brackets one of the following string names (without the 
double quotes): monthly, quarterly or yearly. If your data have a {it:monthly} 
frequency, you indicate the {opt freq:uency(string)} option as 
{opt freq:uency(monthly)}, if you have {it:quarterly} data, you specify 
{opt freq:uency(quarterly)} and  if you have {it:yearly} data, you define 
{opt freq:uency(yearly)}. You must indicate this option in order to get a 
result. Hence this option is required.



{title:Stored results}

{pstd}
{cmd:hamiltonfilter} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(cyclevar)}}variable containing estimates of the cyclical component{p_end}
{synopt:{cmd:r(trendvar)}}variable containing estimates of the trend component{p_end}
{synopt:{cmd:r(varlist)}}original time-series variable{p_end}
{synopt:{cmd:r(frequency)}}units of the time variable{p_end}
{p2colreset}{...}



{title:Examples}

{p 4 8 2} Before beginning the estimations, we use the {hi:set more off} instruction to tell
{hi:Stata} not to pause when displaying the output. {p_end}

{p 4 8 2}{stata "set more off"}{p_end}

{p 4 8 2} We illustrate the use of the command {cmd:hamiltonfilter} with the dataset {hi:hamiltonfilterdmonthly.dta}.
This dataset contains monthly data for the {it:USA} from 1999m1 to 2017m9. {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/h/hamiltonfilterdmonthly.dta, clear"}{p_end}

{p 4 8 2} Next we describe the dataset to see the definition of each variable. We see that we have monthly 
seasonally adjusted data on Real Personal Consumption Expenditures (RPCE) for the {it:USA}. {p_end}

{p 4 8 2}{stata "describe"}{p_end}

{p 4 8 2} Now let us compute the Hamilton filter. We begin by indicating the name of the command {cmd:hamiltonfilter}, followed 
by the variable for which we want to calculate the Hamilton filter. This variable is named 
{hi:lgrpcecm} in this dataset. Then we specify the option {opt stub()} in which we put the 
string {hi:"hamfmo"} without the double quotes. This option is required. We finish by indicating 
the option {opt frequency()} in which we put the string {hi:"monthly"} without the double quotes. This 
option is also required. {p_end}

{p 4 8 2}{stata "hamiltonfilter lgrpcecm, stub(hamfmo) frequency(monthly)"}{p_end}

{p 4 8 2} To see the variables that the command has created, we type: {p_end}

{p 4 8 2}{stata "describe"}{p_end}

{p 4 8 2} We notice that two more variables have been generated in our dataset: {hi:hamfmo_trend} 
and {hi:hamfmo_cycle} which respectively correspond to the {hi:trend} and {hi:cycle} 
of {hi:lgrpcecm}. By default, these variables are respectively labeled 
as {it:"lgrpcecm Trend from the Hamilton Filter, Monthly"} 
and {it:"lgrpcecm Cycle from the Hamilton Filter, Monthly"}. {p_end}

{p 4 8 2} Next we summarize our variables of interest to see their descriptive statistics. {p_end}

{p 4 8 2}{stata "summarize lgrpcecm hamfmo_trend hamfmo_cycle"}{p_end}

{p 4 8 2} Now we plot the {hi:lgrpcecm} variable with its Hamilton filtered trend {hi:hamfmo_trend} by 
using the command {bf:{manhelp tsline TS}}. In this last command, we utilize the following 
options: we put the legend at 6 o'clock, the legend in one column, specify the lines to be thick 
and give a name to our graph. See the command {bf:{manhelp tsline TS}} for more details. {p_end}

{p 4 8 2}{stata "tsline lgrpcecm hamfmo_trend,  legend(pos(6)) legend(col(1)) lwidth(thick thick) name(trendmo, replace)"}{p_end}

{p 4 8 2} In this graph the variable {hi:lgrpcecm} is in blue and the variable {hi:hamfmo_trend} is in red as indicated 
by the legend. There are some missing values at the beginning of the trend variable. These values were created in the 
computation process of the Hamilton filter. If we have data with a long temporal depth, this is generally not a big problem. {p_end}

{p 4 8 2} Let us now plot the cyclical component named {hi:hamfmo_cycle} of the variable {hi:lgrpcecm}. {p_end}

{p 4 8 2}{stata "tsline hamfmo_cycle, lwidth(thick) name(cyclemo, replace)"}{p_end}

{p 4 8 2} If we want to close all the previously created graphs, we type: {p_end}

{p 4 8 2}{stata "graph close _all"}{p_end}

{p 4 8 2} Now we illustrate how to use of the command {cmd:hamiltonfilter} with quarterly data. We open the dataset {hi:hamiltonfilterdquarterly.dta}.
This dataset contains quarterly data for the {it:USA} from 1947q1 to 2017q3. {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/h/hamiltonfilterdquarterly.dta, clear"}{p_end}

{p 4 8 2} We describe the dataset to see the definition of each variable. We see that we have quarterly 
seasonally adjusted data on the Real Gross Domestic Product (GDP) of the {it:USA}. {p_end}

{p 4 8 2}{stata "describe"}{p_end}

{p 4 8 2} We compute the Hamilton filter for this dataset. {p_end}

{p 4 8 2}{stata "hamiltonfilter lgrgdpusaq, stub(hamfqt) frequency(quarterly)"}{p_end}

{p 4 8 2} We plot the {hi:lgrgdpusaq} variable with its Hamilton filtered trend {hi:hamfqt_trend}. {p_end}

{p 4 8 2}{stata "tsline lgrgdpusaq hamfqt_trend,  legend(pos(6)) legend(col(1)) lwidth(thick thick) name(trendqt, replace)"}{p_end}

{p 4 8 2} We see that the trend fits very well the variable. {p_end}

{p 4 8 2} Next we plot the cyclical component. {p_end}

{p 4 8 2}{stata "tsline hamfqt_cycle, lwidth(thick) name(cycleqt, replace)"}{p_end}

{p 4 8 2} Let us now compare the Hamilton filter with the Hodrick-Prescott filter. First, we calculate the 
Hodrick-Prescott filter for our variable of interest named {hi:lgrgdpusaq}. We compute both its cyclical 
and trend components. We use the {hi:Official} {hi:Stata} command {helpb tsfilter hp:tsfilter hp} to achieve this.  {p_end}

{p 4 8 2}{stata "tsfilter hp lgrgdpusaq_hp_cylce = lgrgdpusaq, trend(lgrgdpusaq_hp_trend)"}{p_end}

{p 4 8 2} Second, we plot the trend components of the Hamilton filter and the Hodrick-Prescott filter respectively. {p_end}

{p 4 8 2}{stata "tsline hamfqt_trend lgrgdpusaq_hp_trend,  legend(pos(6)) legend(col(1)) lwidth(thick thick) name(trendcomparqt, replace)"}{p_end}

{p 4 8 2} Third, we plot the cyclical components of the Hamilton filter and the Hodrick-Prescott filter respectively. {p_end}

{p 4 8 2}{stata "tsline hamfqt_cycle lgrgdpusaq_hp_cylce,  legend(pos(6)) legend(col(1)) lwidth(thick thick) name(cylcecomparqt, replace)"}{p_end}

{p 4 8 2} Fourth, we close all the previously created graphs. {p_end}

{p 4 8 2}{stata "graph close _all"}{p_end}

{p 4 8 2} Now we demonstrate how to use of the command {cmd:hamiltonfilter} with yearly data. We open the dataset {hi:hamiltonfilterdyearly.dta}.
This dataset contains yearly data for the {it:USA} from 1947 to 2016. {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/h/hamiltonfilterdyearly.dta, clear"}{p_end}

{p 4 8 2} We describe the dataset to see the definition of each variable. We see that we have yearly 
data on the Real Gross Domestic Product (GDP) of the {it:USA}. {p_end}

{p 4 8 2}{stata "describe"}{p_end}

{p 4 8 2} We compute the Hamilton filter for this dataset. {p_end}

{p 4 8 2}{stata "hamiltonfilter lgrgdpusay, stub(hamfyr) frequency(yearly)"}{p_end}

{p 4 8 2} We plot the {hi:lgrgdpusay} variable with its Hamilton filtered trend {hi:hamfyr_trend}. {p_end}

{p 4 8 2}{stata "tsline lgrgdpusay hamfyr_trend,  legend(pos(6)) legend(col(1)) lwidth(thick thick) name(trendyr, replace)"}{p_end}

{p 4 8 2} We plot the cyclical component. {p_end}

{p 4 8 2}{stata "tsline hamfyr_cycle, lwidth(thick) name(cycleyr, replace)"}{p_end}

{p 4 8 2} Let us elucidate how to use the Hamilton filter with time-series operators; see {help tsvarlist} for more 
details. We compute the Hamilton filter for a {hi:2-period lead} of our variable of interest named {hi:lgrgdpusay}. {p_end}

{p 4 8 2}{stata "hamiltonfilter F2.lgrgdpusay, stub(hamfyrtso) frequency(yearly)"}{p_end}

{p 4 8 2} We plot the {hi:F2.lgrgdpusay} variable with its Hamilton filtered trend {hi:hamfyrtso_trend}. {p_end}

{p 4 8 2}{stata "tsline F2.lgrgdpusay hamfyrtso_trend,  legend(pos(6)) legend(col(1)) lwidth(thick thick) name(trendyrtso, replace)"}{p_end}

{p 4 8 2} We plot the cyclical component. {p_end}

{p 4 8 2}{stata "tsline hamfyrtso_cycle, lwidth(thick) name(cycleyrtso, replace)"}{p_end}

{p 4 8 2} If we want to close all the previously created graphs, we type: {p_end}

{p 4 8 2}{stata "graph close _all"}{p_end}

{p 4 8 2} Now we exhibit how to utilize the command {cmd:hamiltonfilter} with yearly panel data. We open the dataset {hi:hamiltonfilterdgseven.dta}.
This dataset contains yearly panel data for the {it:G7} countries from 1950 to 2014. {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/h/hamiltonfilterdgseven.dta, clear"}{p_end}

{p 4 8 2} We describe the dataset to see the definition of each variable. We see that we have yearly panel 
data on the Real Gross Domestic Product (GDP) of the {it:G7} countries. {p_end}

{p 4 8 2}{stata "describe"}{p_end}

{p 4 8 2} We compute the Hamilton filter for this dataset. {p_end}

{p 4 8 2}{stata "hamiltonfilter lgrgdpolev, stub(hamfyrpan) frequency(yearly)"}{p_end}

{p 4 8 2} We plot the {hi:lgrgdpolev} variable with its Hamilton filtered trend {hi:hamfyrpan_trend} by 
using the command {bf:{manhelp tsline TS}}. In addition to our usual options for this last command, we 
augment the following options: we specify that we want the graphs by country and indicate the major 
ticks plus labels for the x and y axes. We can enlarge the figure window to see the graphs very well. {p_end}

{p 4 8 2}{stata "tsline lgrgdpolev hamfyrpan_trend,  legend(pos(6)) legend(col(1)) lwidth(thick thick) name(trendyrpan, replace) by(country) ylabel(25(3)31) xlabel(1950(20)2014)"}{p_end}

{p 4 8 2} We plot the cyclical component. {p_end}

{p 4 8 2}{stata "tsline hamfyrpan_cycle, lwidth(thick) name(cycleyrpan, replace) by(country) xlabel(1950(20)2014)"}{p_end}

{p 4 8 2} Let us explain how to use the Hamilton filter with the {help if} qualifier; see {helpb if} for more 
details. We compute the Hamilton filter for the {it:G7} countries after the {it:"first oil shock"} of our variable of interest named {hi:lgrgdpolev}. {p_end}

{p 4 8 2}{stata "hamiltonfilter lgrgdpolev if year > 1973, stub(hamfyrpanos) frequency(yearly)"}{p_end}

{p 4 8 2} We plot the {hi:lgrgdpolev} variable with its Hamilton filtered trend {hi:hamfyrpanos_trend} for the same period. {p_end}

{p 4 8 2}{stata "tsline lgrgdpolev hamfyrpanos_trend if year > 1973,  legend(pos(6)) legend(col(1)) lwidth(thick thick) name(trendyrpanos, replace) by(country) ylabel(25(3)31) xlabel(1973(10)2014)"}{p_end}

{p 4 8 2} We plot the cyclical component for the same period. {p_end}

{p 4 8 2}{stata "tsline hamfyrpanos_cycle if year > 1973, lwidth(thick) name(cycleyrpanos, replace) by(country) xlabel(1973(10)2014)"}{p_end}

{p 4 8 2} If we want to close all the previously created graphs, we type: {p_end}

{p 4 8 2}{stata "graph close _all"}{p_end}

{p 4 8 2} The {cmd:hamiltonfilter} command works when there are missing values for an entire country in a panel data of countries. As 
an illustration, suppose that the data for {it:Japan} are missing. Thus, we type: {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/h/hamiltonfilterdgseven.dta, clear"}{p_end}

{p 4 8 2}{stata `"replace lgrgdpolev = . if country == "Japan""'}{p_end}

{p 4 8 2} We compute the Hamilton filter for this new dataset. {p_end}

{p 4 8 2}{stata "hamiltonfilter lgrgdpolev, stub(hamfyrpmiss) frequency(yearly)"}{p_end}

{p 4 8 2} We plot the {hi:lgrgdpolev} variable with its Hamilton filtered trend {hi:hamfyrpmiss_trend}. We notice 
that the graphic for {it:Japan} is empty. This, because the Hamilton Filter was not computed for {it:Japan}. {p_end}

{p 4 8 2}{stata "tsline lgrgdpolev hamfyrpmiss_trend, legend(pos(6)) legend(col(1)) lwidth(thick thick) name(trendyrpmiss, replace) by(country) ylabel(25(3)31) xlabel(1950(20)2014)"}{p_end}

{p 4 8 2} We plot the cyclical component. We notice that the graphic for {it:Japan} is empty. This, because the Hamilton Filter 
was not computed for {it:Japan}. {p_end}

{p 4 8 2}{stata "tsline hamfyrpmiss_cycle, lwidth(thick) name(cycleyrpmiss, replace) by(country) xlabel(1950(20)2014)"}{p_end}

{p 4 8 2} If we want to close all the previously created graphs, we type: {p_end}

{p 4 8 2}{stata "graph close _all"}{p_end}

{p 4 8 2} The {cmd:hamiltonfilter} command also works when the panel data are {manhelp tsset TS} or {manhelp xtset XT}, but one 
or more entries of the panel identifier are dropped. As an illustration, assume that the data for the first country, in 
the alphabetical order, of the {it:G7} countries {it:(Canada)} are dropped. Hence, we type: {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/h/hamiltonfilterdgseven.dta, clear"}{p_end}

{p 4 8 2}{stata "drop if id == 1"}{p_end}

{p 4 8 2} We compute the Hamilton filter for this new dataset. {p_end}

{p 4 8 2}{stata "hamiltonfilter lgrgdpolev, stub(hamfyrpdro) frequency(yearly)"}{p_end}

{p 4 8 2} We plot the {hi:lgrgdpolev} variable with its Hamilton filtered trend {hi:hamfyrpdro_trend}. We notice that the 
graphic for {it:Canada} is missing. This, because the computation of the Hamilton Filter was not performed for {it:Canada}. {p_end}

{p 4 8 2}{stata "tsline lgrgdpolev hamfyrpdro_trend,  legend(pos(6)) legend(col(1)) lwidth(thick thick) name(trendyrpdro, replace) by(country) ylabel(25(3)31) xlabel(1950(20)2014)"}{p_end}

{p 4 8 2} We plot the cyclical component. We notice that the graphic for {it:Canada} is missing. This, because the 
computation of the Hamilton Filter was not performed for {it:Canada}. {p_end}

{p 4 8 2}{stata "tsline hamfyrpdro_cycle, lwidth(thick) name(cycleyrpdro, replace) by(country) xlabel(1950(20)2014)"}{p_end}

{p 4 8 2} If we want to close all the previously created graphs, we type: {p_end}

{p 4 8 2}{stata "graph close _all"}{p_end}



{title:References}

{pstd}
{hi:Hamilton, James D.: 2017,} "Why You Should Never Use the Hodrick-Prescott Filter", {it:Department of Economics, UC San Diego,} {hi:Working Paper}.
{p_end}

{pstd}
{hi:Hamilton, James D.: 2018}, "Why You Should Never Use the Hodrick-Prescott Filter", {it:The Review of Economics and Statistics} {hi:100}(5), 831-843.
{p_end}

 

{title:Author}

{p 4}Diallo Ibrahima Amadou {p_end}
{p 4}CERDI, University of Clermont Auvergne {p_end}
{p 4}26 Avenue Leon Blum  {p_end}
{p 4}63000 Clermont-Ferrand   {p_end}
{p 4}France {p_end}
{p 4}{hi:E-Mail}: {browse "mailto:zavren@gmail.com":zavren@gmail.com} {p_end}



{title:Also see}

{psee}
Online:  help for  {bf:{manhelp tsfilter TS}}, {helpb tsfilter hp:tsfilter hp}, {bf:{manhelp tsline TS}} 
{p_end}


