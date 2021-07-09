{smcl}
{right:version:  2.0}
{cmd:help ascol} {right:Dec 28, 2017}
{hline}
{viewerjumpto "frequency_opt" "ascol##freq"}{...}
{viewerjumpto "returns" "ascol##returns"}{...}
{viewerjumpto "prices" "ascol##prices"}{...}
{viewerjumpto "tsset" "ascol##tsset"}{...}
{viewerjumpto "keep" "ascol##keep"}{...}
{viewerjumpto "generate" "ascol##gen"}{...}
{viewerjumpto "Examples" "ascol##examples"}{...}
{vieweralsosee "other programs" "ascol##also"}{...}


{title:Title}

{p 4 8} {opt ascol}  -  Converts asset returns and prices from daily to a weekly, monthly, quarterly, and yearly frequency


{title:Syntax}

{p 4 6 2}
{cmd:ascol}
{varname}{cmd:},
{cmdab:r:eturns(}{it:{help ascol##returns:[simple | log]}}{cmd:)}
{opt p:rices}
{cmdab:keep:(}{it:{help ascol##keep:[all | vars]}}{cmd:)}
{help ascol##freq:frequency_options}
{help ascol##tsset:timevar(varname)}
{help ascol##tsset:panelvar(varname)}
{opt gen:erate(newvar)}


{title:Description}

{p 4 4 2} {cmd: ascol} converts daily data of asset prices or returns  to weekly,
monthly, quarterly, or yearly frequencies. When converting asset prices to a lower frequency, {opt ascol} selects the last price in the given period.
For converting asset returns, {opt ascol} offers two possibilities - either to sum the daily returns or find products of the daily returns. 
The first choice is used with daily log returns while the second is used with daily simple returns (Detailed discussion is {help ascol##returns:given below}). {opt ascol} requires that the existing data has a time variable that
tracks daily dates. If the data is already {help tsset} or {help xtset}, {cmd:ascol} will automatically
pick the time and panel variables from the previous {help tsset} or {help xtset} declarations. In case the data is not already set for time or panel dimensions, then
the time variable has to be set by using the option {help ascol##timevar:timevar(varname)}.{p_end}

{title:Options}

{marker returns}
{p 4 4 2}  1. {opt r:eturns(simple | log)}: If {varname} has daily returns data, we need to use the {opt r:eturns()} option. This option
can be used with two variations : simple returns and log returns. For detailed discussion, 
examples, and comparisons of simple and log returns, please visit my web page {browse "http://FinTechProfessor.com/2017/12/02/log-vs-simple-returns-examples-and-comparisons/" :here}.
See the following details of when to use which of the two sub-options:{p_end}

{p 8 8 2} {opt 1.1} {opt r:eturns(simple)} : If daily returns have already been calculated with the following
formula; {p_end}
{marker Equation1}
{p 14 8 2} {cmd: simple ri = ( Price[i] – Price[i-1] ) /  Price[i-1]  ... (Eq. 1)} {p_end}
 
{p 8 8 2} Then the appropriate method to convert the returns to n-period cumulative returns would be; {p_end}

{p 14 8 2} {cmd: Cumulative n-period simple returns = (1+simple_r1) * (1+simple_r2) *(1+simple_r3)  … (1+simple_rn)  – 1     ... (Eq. 2)} {p_end}

{p 8 8 2} By invoking option {opt r:eturns(simple)}, {cmd:ascol} applies Eq. 2 to find n-period cumulative
returns. {p_end}


{p 8 8 2} {opt 1.2} {opt r:eturns(log)} : If daily returns have already been calculated with the following
formula; {p_end}

{p 14 8 2}{cmd:log_ri = ln(Price[i]  /  Price[i-1])  ... (Eq. 3)}

{p 8 8 2} Then the appropriate method to convert the returns to n-period cumulative returns would be to just sum the daily returns {p_end}

{p 8 8 2} By invoking option {opt r:eturns(log)}, {cmd:ascol} sums the daily returns to find n-period cumulative returns. {p_end}

{p 8 4 2} {cmd: Therefore}, users must exercise care in selecting the appropriate option in converting daily returns to n-period cumulative returns. {p_end}

{marker prices}
{p 4 4 2}  {cmd: 2.} {opt p:rices} : If the data in memory are asset prices, we shall use the option {opt p:rices}. Please note that option {opt r:eturn} and {opt p:rices}  
cannot be combined together. To collapse prices to the desired frequency, the program finds the last traded prices of the period. {p_end} 

{marker freq}
{p 4 4 2}{cmd: 3.} {opt Frequency Options}

{p 4 4 2} {cmd: ascol} has the following options for data conversion:{p_end}

{p 8 4 2}{cmdab:tow:eek} converts from daily to weekly frequency {p_end} 
{p 8 4 2}{cmdab:tom:onth} converts from daily to monthly frequency {p_end}  
{p 8 4 2}{cmdab:toq:uarter} converts from daily to quarterly frequency  {p_end}  
{p 8 4 2}{cmdab:toy:ear} converts from daily to yearly frequency {p_end}   
  
{marker tsset}
{p 4 4 2}{cmd: 4.} {opt t:imevar(varname)} and {opt p:anelvar(varname)} {p_end} 
{p 4 4 2} {cmd:ascol} needs a variable that tracks daily dates. If the data is already {help tsset}, {cmd: asocl}
will automatically pick the time variable. Therefore, there will be no need to use the option {opt t:imevar()}.
Similarly, if the data is already {help xtset}, {cmd:ascol} will pick both the time and panel variables from
the previous {help xtset} declarations. Again, there will be no need to use the otpions {opt t:imevar()}
or {opt p:anelvar()}. However, if the data has duplicates or has other reasons that do not allow the {help tsset}
or {help xtset} declarations, then we shall have to inform {cmd: ascol} about the time and/or panel variables of the
data set through options {opt t:imevar(varname)} and {opt p:anelvar(varname)}. {p_end}

{marker keep}
{p 4 4 2}{cmd: 5.} {opt keep(all)} or {opt keep(vars)}   {p_end} 
{p 4 4 2} When we convert data from daily to a lower-frequency such as weekly, monthly, etc., we end up with repeated
values of the converted variable. We often just need one value of the variable per cross-sectional unit and time-period.
Therefore, the repeated observations are not needed and should be dropped. This is what the Stata's {help collapse}
command does. The default in {cmd: ascol} is to collapse the data to a lower frequency and delete all other variables
except the newely created one. However, there might be circumstances when we want to retain all the observations without collapsing the data set. Towards this end, we can use the option {opt keep(all)}
or {opt keep(vars)}. {opt keep(all)} will keep the data set as it was before running the command, while {opt keep(vars)}
will collapse the data to a lower frequency and keep all the variables of the data set. Here is the summary:

{p 8 4 2}{opt keep(all)} conversion happens without collapsing the data and without deleting other variables {p_end} 
{p 8 4 2}{opt keep(vars)} conversion happens without deleting other variables; data collapses to a lower frequency {p_end}  

{marker gen}
{p 4 4 2}{cmd: 6.} {opt gen:erate(newvar)}   {p_end} 
{p 4 4 2} This is an optional option to specify the name of the new variable. If left blank, {opt ascol} will automatically
name the new variable as {it : varname_frequency}. 

{title:Example Data Set}

 {space 6}{hline 15} {hi:copy the following and run from Stata do editor} {hline 15}

		clear
		set obs 1000
		gen date=date("1/1/2012" , "DMY")+_n
		format %td date
		tsset date
		gen pr=10
		replace pr=pr[_n-1]+uniform() if _n>1
		gen simpleRi=(pr/l.pr)-1
		gen logRi = ln(pr/l.pr)
		save stocks,replace
{space 8}{hline 80}


{marker examples}
{title:Example 1: From Daily to weekly -  simple returns}

{p 4 4 2} Suppose we have already generated daily simple returns using {help ascol##Equation1:Equation 1},
we shall convert them to  weekly returns with: {p_end} 
{p 4 8 2}{stata "use stocks, clear" :. use stocks, clear}{p_end}
{p 4 8 2}{stata "ascol simpleRi, toweek returns(simple) " :. ascol simpleRi, toweek returns(simple) }
 
 
{p 4 4 2} ascol is the program name, {opt simpleRi} is the stock return variable in our data set, 
{opt toweek} is the program option that tells Stata to convert daily
data to weekly frequency, and the {opt returns(simple)} option tells Stata that our {opt simpleRi} variable
has simple stock returns and therefore ascol will apply {opt Equation 2} above to find cumulative weekly returns.
Please note that we did not use the option {opt t:imevar(varname)} and {opt p:anelvar(varname)}
as our data is already tsset.{p_end}

 
{title:Example 2: From Daily to weekly -  log returns}

{p 4 4 2} Suppose we have already generated log returns using {help ascol##Equation2:Equation 2},
we shall convert them to  weekly returns with: {p_end} 
{p 4 8 2}{stata "use stocks, clear" :. use stocks, clear}{p_end}
{p 4 8 2}{stata "ascol logRi, toweek returns(log) " :. ascol logRi, toweek returns(log) }
 
 
{p 4 4 2} ascol is the program name, {opt logRi} is the stock return variable in our data set, 
{opt toweek} is the program option that tells Stata to convert daily
data to weekly frequency, and the {opt returns(log)} option tells Stata that our {opt logRi} variable
has log stock returns.Therefore ascol will just sum the returns within each week to find cumulative weekly returns. Please note that we did not use the option {opt t:imevar(varname)} and {opt p:anelvar(varname)}
as our data is already tsset.{p_end}

 
 {title:Example 3: From Daily to monthly -  prices}
  
 {p 4 8 2}{stata "use stocks, clear" :. use stocks, clear}{p_end}
 {p 4 8 2}{stata "ascol pr, tomonth price " :. ascol pr, tomonth price }
 
  
{p 4 4 2} {opt pr} is the variable name that has stock prices data, {opt tom:onth} option specifies 
conversion from daily to a monhtly frequency, and the {opt p:rice} specifies that the conversion is
needed for stock prices data.{p_end}
 

{title:Converting Data to Other Frequencies}
  
{p 4 8 2} From daily to quarterly, option {opt toquarter} or {opt} toq is to be used {p_end}
 {p 4 8 2}{stata "ascol pr, toq price " :. ascol pr, toq price }

{p 4 8 2} From daily to yearly, option {opt toyear} or {opt toy} is to be used {p_end}

{p 4 8 2}{stata "ascol pr, toy price " :. ascol pr, toy price }

 
 {title:Example 4: Conversion without collapse - keep all observations and variables}
  {p 4 4 2} We shall use the option {opt keep(all)} to retain all variables and observations in the data set.
  After conversion, you can see that there are duplicate values of the newely created variable {opt week_simpleRi}.
  
 {p 4 8 2}{stata "use stocks, clear" :. use stocks, clear}{p_end}
 {p 4 8 2}{stata "ascol simpleRi , toweek returns(simple) keep(all) " :. ascol simpleRi , toweek returns(simple) keep(all) }
 
  
 {title:Example 5: Collapsing by time variables only - keep  variables}
  {p 4 4 2} We shall use the option {opt keep(vars)} to retain all variables while collapsing the data to a lower frequency.
  After conversion, you can see that there are no duplicate values of the newely created variable. {opt week_simpleRi}.
  
 {p 4 8 2}{stata "use stocks, clear" :. use stocks, clear}{p_end}
 {p 4 8 2}{stata "ascol simpleRi , toweek returns(simple) keep(vars) " :. ascol simpleRi , toweek returns(simple) keep(vars) }

{title:Author}

{p 4 8 2} 

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: *
*                                                                             *
*                       Dr. Attaullah Shah                                    *
*            Institute of Management Sciences, Peshawar, Pakistan             *
*                     Email: attaullah.shah@imsciences.edu.pk                 * 
*                 See my webpage for more programs and help at:               *
*                    {browse "http://www.OpenDoors.Pk"}                                  * 
*                    {browse "https://FinTechProfessor.com"}                             *  
*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*

{marker also}{...}
{title:Also see}

{psee}
{browse "http://www.opendoors.pk/home/paid-help-in-empirical-finance/stata-program-to-construct-j-k-overlappy-momentum-portfolios-strategy": asm    : for momentum portfolios}   {p_end}
{psee}{stata "ssc desc":astile : for creating fastest quantile groups} {p_end}
{psee}{stata "ssc desc asreg":asgen : for weighted average mean} {p_end}
{psee}{stata "ssc desc asrol":asrol : for rolling-window statistics} {p_end}
{psee}{stata "ssc desc asreg":asreg : for rolling-window, by-group, and Fama and MacBeth regressions} {p_end}
{psee}{stata "ssc desc searchfor":searchfor : for searching text in data sets} {p_end}







