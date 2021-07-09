{smcl}
{* *! version 1.0.0 21oct2019}{...}
{p2colset 1 9 16 2}{...}
{p2col:{bf:tstf} {hline 2}}Intervention time-series models{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:tstf}
{depvar}
{ifin}
[{cmd:,} {it:options} ]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt arima(#p,#d,#q)}}specify ARIMA({it:p,d,q}) model for dependent variable{p_end}
{synopt:{opt sarima(#P,#D,#Q,#s)}}specify period-{it:#s} multiplicative seasonal ARIMA term{p_end}
{synopt:{opt int:date(time_value)}}specify the intervention date in the units of time variable{p_end}
{synopt:{opt pulse}}specify the pulse transfer function{p_end}
{synopt:{opt decay}}specify the decay transfer function{p_end}
{synopt:{opt step}}specify the step transfer function{p_end}
{synopt:{opt smooth}}specify the smooth transfer function{p_end}

{syntab:Path}
{synopt :{opt pathr(R_pathname)}}specifies a path name for invoking the R command{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt tab:ulate}}tabulate effect of the intervention{p_end}
{synopt:{opt grd:ta}}graph observed, predicted, and counterfactual data{p_end}
{synopt:{opt gre:ffect}}graph the intervention effect{p_end}
{synopt:{opt ef:orm}}exponentiate the results presented in tabular and graphical forms{p_end}
{synopt:{it:twoway_options}}specify the options to pass to the graph{p_end}
 
{synoptline}
{p2colreset}{...}
{p 4 6 2}
Data must be {opt tsset} before using {opt tstf}; see {manhelp tsset TS}.
{p_end}

{marker description}{...}
{title:Description}

{pstd}
{opt tstf} fits intervention time-series models. The command {cmd:tstf} is a wrapper for the 
{browse "https://www.rdocumentation.org/packages/TSA/versions/1.2/topics/arimax":arimax} package in 
{browse "http://cran.r-project.org/":R}. Therefore {browse "http://cran.r-project.org/":R} needs to be installed.

{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}{opt int:date(time_value)} specify the intervention date (an integer number) in the units of time variable. 
It is a required option to create the transfer function. 

{phang}{opt pulse} specify the pulse transfer function. 
The effect of the intervention is given by _b[omega] at the intervention time point.

{phang}{opt step} specify the step transfer function.
The effect of the intervention is given by _b[omega] at any time time point following the intervention.

{phang}{opt decay} specify the decay transfer function.
The effect of the intervention is given by _b[omega]*_b[delta]^k evaluated at k units of time after intervention.

{phang}{opt smooth} specify the smooth transfer function. 
The effect of the intervention is given by _b[omega]*(1-(_b[delta])^(k+1))/(1-_b[delta]) evaluated at k units of time after intervention.

{phang}
{opt arima(#p,#d,#q)} is 
shorthand notation for specifying models with ARMA disturbances.  The 
dependent variable is differenced 
{it:#d} times, 1 through {it:#p} lags of autocorrelations
and 1 through {it:#q} lags of moving averages are included in the model.
The default is (0,0,0). 

{phang}
{opt sarima(#P,#D,#Q,#s)} is a shorthand notation for specifying
   the multiplicative seasonal components of models with ARMA disturbances.
   The dependent variable is lag-{it:#s}
   seasonally differenced {it:#D} times, and 1 through {it:#P} seasonal lags
   of autoregressive terms and 1 through {it:#Q} seasonal lags of
   moving-average terms are included in the model.
   The default is (0,0,0,0). 
   
{dlgtab:Path}

{phang}
{opt pathr(R_pathname)} specifies the path name for invoking the R command.
The default path for a Mac is set to "/usr/local/bin/R". 
The R_pathname can also be set by defining a {help macro:global macro} {hi:Rterm_path}
(See {help rsource:rsource}, {hi:{help rsource##rsource_technote:Technical note}}). 
The R code is available after running {cmd:tstf} command by typing {hi: viewsource tstf_to_r.R}

{dlgtab:Reporting}

{phang}
{opt level(#)}; see
{bf:{help estimation options##level():[R] estimation options}}.

{marker examples}{...}
{title:Examples}

    {hline}

* Read time-series data on the "Effect of tobacco control policies on the Swedish Smoking Quitline" {it:BMJ Open}

	{stata "use http://www.stats4life.se/data/quitline, clear"}
	{stata "tsset time, monthly"}
  
* Evaluation of the effect of the EU Directive on May 2016

* Interrupted time-series analysis using a Poisson regression model {it:({stata `"do "`c(sysdir_plus)'/t/SNTQ_poisson.do"':click to run})}  

* Intervention time-series model

	{stata `"tstf lograte if inrange(time, 625, 691), smooth int(676) arima(1,1,1) sarima(1,0,0,12) tabulate grdata eform ytitle("Calling rates per 100,000 smokers") xlabel(625(6)691, angle(45)) xmtick(625(1)691) name(figure2a, replace)"'}
	{stata `"tstf lograte if inrange(time, 625, 691), smooth int(676) arima(1,1,1) sarima(1,0,0,12) greffect eform ytitle("Rate Ratio") xlabel(625(6)691, angle(45)) xmtick(625(1)691) name(figure2b, replace)"'}

* Evaluation of the effect of a campaign on passive smoking on Jan 2001

	{stata `"tstf lograte if inrange(time, 468, 511), smooth int(492) arima(2,1,0) sarima(0,0,0,12) tabulate grdata eform ytitle("Calling rates per 100,000 smokers") xlabel(468(6)511, angle(45)) xmtick(468(1)511) name(figure3a, replace)"'}
	{stata `"tstf lograte if inrange(time, 468, 511), smooth int(492) arima(2,1,0) sarima(0,0,0,12) greffect eform ytitle("Rate Ratio")  xlabel(468(6)511, angle(45)) xmtick(468(1)511) name(figure3b, replace) "'} 

* Evaluation of the effect of larger text warnings on Sept 2002

	{stata `"tstf lograte if inrange(time, 492, 544), smooth int(512) arima(2,1,0) sarima(1,0,0,12) tabulate grdata eform ytitle("Calling rates per 100,000 smokers") xlabel(492(6)544, angle(45)) xmtick(492(1)544) name(figure4a, replace) "'}
	{stata `"tstf lograte if inrange(time, 492, 544), smooth int(512) arima(2,1,0) sarima(1,0,0,12) greffect eform ytitle("Rate Ratio") xlabel(492(6)544, angle(45)) xmtick(492(1)544) name(figure4b, replace) "'}

* Evaluation of the effect of smoking free restaurants on Jan 2005 

	{stata `"tstf lograte if inrange(time, 512, 587), smooth int(545) arima(1,0,0) sarima(0,1,1,12) tabulate grdata eform ytitle("Calling  rates per 100,000 smokers") xlabel(512(6)587, angle(45)) xmtick(512(1)587)  name(figure5a, replace) "'}
	{stata `"tstf lograte if inrange(time, 512, 587), smooth int(545) arima(1,0,0) sarima(0,1,1,12) greffect eform ytitle("Rate Ratio")  xlabel(512(6)587, angle(45)) xmtick(512(1)587)  name(figure5b, replace) "'}

* Evaluation of the effect of a Tax increase on Jan 2012 

	{stata "drop if time == 624"} 
	{stata `"tstf lograte if inrange(time, 588, 659), smooth int(624) arima(0,1,1) sarima(1,0,0,12) tabulate grdata eform ytitle("Calling rates per 100,000 smokers") xlabel(588(6)659, angle(45)) xmtick(588(1)659)  name(figure6a, replace)"'}
	{stata `"tstf lograte if inrange(time, 588, 659), smooth int(624) arima(0,1,1) sarima(1,0,0,12) greffect eform ytitle("Rate Ratio") xlabel(588(6)659, angle(45)) xmtick(588(1)659)  name(figure6b, replace) "'}
	
{marker references}{...}
{title:References}

{phang}
Zhou X, Crippa A, Danielsson AK, Galanti R, Orsini N (2019). Effect of tobacco control policies on the Swedish Smoking Quitline using intervention time series analysis. {it:BMJ Open}.

{phang}
Box GEP, Tiao GC (1975). Effect of tobacco control policies on the Swedish Smoking Quitline using intervention time series analysis. {it:Journal of the American Statistical Association},
70(349), 70–79.
 
{title:Authors}

    Nicola Orsini & Xing-Wu Zhou
    Biostatistics Team
    Department of Public Health Sciences, Karolinska Institutet
    Stockholm, Sweden
