{smcl}
{right:version:  4.5.0}
{cmd:help asrol} {right:Dec 4, 2018}
{hline}
{viewerjumpto "Statistics" "asrol##stat"}{...}
{viewerjumpto "Window" "asrol##window"}{...}
{viewerjumpto "minimum" "asrol##min"}{...}
{viewerjumpto "add" "asrol##add"}{...}
{viewerjumpto "perc" "asrol##perc"}{...}
{viewerjumpto "exclude focal" "asrol##xf"}{...}

{vieweralsosee "other programs" "asrol##also"}{...}


{title:Title}

{p 4 8}{cmd:asrol}  -  Generates rolling-window / groups descriptive statistics {p_end}


{title:Syntax}

{p 4 6 2}
[{help bysort}]: {cmd:asrol}
{varlist} {ifin}, {cmd:} 
{cmdab:s:tat(}{it:{help asrol##stat:stat_options}{cmd:)}}
{cmdab:w:indow(}{it:{help asrol##window:rangevar #}}{cmd:)}
[{cmdab:g:en(}{it:newvar}{cmd:)}
{cmdab:by:(}{it:{help asrol##byvars:varlist}{cmd:)}}
{help asrol##min:{cmdab:min:imum:(}{it:#}{cmd:)} }
{help asrol##add:{cmdab:add:(}{it:#}{cmd:)} }
{help asrol##add:{cmdab:ig:norezero}}
{help asrol##perc:{cmdab:p:erc(}{it:#}{cmd:)} } 
{cmdab:xf:(}{it:{help asrol##xf:[focal | rangevar]}}{cmd:)}]



{p 4 4 2}
The underlined letters signify that the full words can be abbreviated only to the underlined letters. {p_end}



{title:Description}

{p 4 4 2} {cmd: asrol} calculates descriptive statistics in a user's defined rolling-window or over a grouping variable.{cmd: asrol} 
can efficiently handle all types of data structures such as data declared as time series or panel data, undeclared data, or data with 
duplicate values, missing values or data having time series gaps. 
{p_end}

{p 4 4 2} {cmd: asrol} uses efficient coding in the Mata language which makes this version extremely fast as compared to its previous versions or other available programs. The speed efficiency matters more in large data sets. 
While writing the source code of {opt asrol}, I took utmost care in selecting the most efficient choices among available options. Therefore,
every line of code had to undergo several tests to ensure accuracy and speed. In fact, there is a long list of of built-in routines which are meant for different data structures. 
{opt asrol} intelligently identifies data structures and applies the most relevant routine from its library. Hence, {cmd: asrol} speed efficiency is ensured whether the data is rectangular (balanced panel), non-rectangular, has duplicates,
has missing values, or has both duplicates and missing values. 

{title:Syntax Details}

{p 4 4 2}
The program has one required option and 8 optional options: Details are given below: {break}

{title:Options}
{marker stat}{...}

{p 4 4 2}1. {opt s:tat}: to specify required statistics. This version of {cmd: asrol} supports multiple statistics for multiple variables. The following statistics are allowed; {p_end}

{dlgtab:Descriptive Statistics}
{p2colset 8 18 19 2}{...}

{p2col : {opt sd}} Estimates the standard deviation of non-missing values{p_end}

{p2col : {opt mean}}	Finds the arithmetic mean of non-missing values {p_end}

{p2col : {opt gmean}}	Finds the geometric mean of positive values {p_end}

{p2col : {opt  sum}} 	Adds all the numbers in a given window {p_end}

{p2col : {opt  product}} 	Multiplies all the numbers in a given window {p_end}

{p2col : {opt median}} 	Returns median of non-missing values {p_end}

{p2col : {opt count}} 	Counts the number of non-missing observations in a given window {p_end}

{p2col : {opt missing}} Counts the number of missing values in a given window {p_end}

{p2col : {opt min}} 	Returns the smallest value in a given window {p_end}

{p2col : {opt max}} 	Returns the largest value in a given window {p_end}

{p2col : {opt first}} 	Returns the first observation in a given window {p_end}

{p2col : {opt last}} 	Returns the last observation in a given window {p_end}

{p2col : {opt perc(k)}} Returns the k-th percentile of values in a range. This option must be used 
in combination with the option median. See more details in the section below that discusses the 
{help asrol##perc: perc(#)} option. {p_end}

{p2col : {opt add(#)}} Adds the value # to each value in a given window before computing the geometric mean or
products of values. See more details in {help asrol##add: Section 7-4}. {p_end}

{p2col : {opt ig:norezero}} used with product and gmean statistics. See more details in {help asrol##add: Section 7-4}. {p_end}

{hline}

{marker window}{...}

{title:Optional Options}


{p 4 4 2} 1.  The {opt w:indow} option accepts two arguments. The first argument should be name of a numeric variable, let us call it rangevar. The
rangevar and a numeric integer are used for specifying length of the rolling window. Examples of rangevar include time variable such as day, week,
 month, quarter or year. The second argument should be a number that specifies the length of the rolling window. For example, if our time variable is year and we want a rolling window of 5 observations,
(that is, the current observation and previous 4 observations), then option {opt w:indow} will look like: {p_end}

{p 10 4 2} {cmdab:w:indow}({it:year 5}) {break}

{p 4 4 2} {opt Rolling window calculations: } {p_end}
{p 4 4 2} The default for rolling window is to calculate required statistics on available observation that are within the range. Therefore, the calculations
of the required statistics start with one observation at the beginning of the rolling window. As we progress in the data set, the number of observations gradually
increase until the maximum length of the rolling window is reached. Consider the following data of 10 observations, 
where {it:{opt X}} is the variable of interest for which we would like to calculate arithmetic mean in a rolling window
of 5; and {it:{opt months}} is the rangevar. To understand the mechanics of the rolling window more clearly, we shall generate 
three additional statistics: count, first, and last. {p_end}

	bys id: asrol X, window(months 5) stat(count) gen(count)
	bys id: asrol X, window(months 5) stat(mean) gen(mean)
	bys id: asrol X, window(months 5) stat(first) gen(first)
	bys id: asrol X, window(months 5) stat(last) gen(last)

	
	  +--------------------------------------------------------+
	  | id    months        X    mean   count   first     last |
	  |--------------------------------------------------------|
	  |  1   2016m10    .6881   .6881       1   .6881    .6881 |
	  |  1   2016m11    .9795   .8338       2   .6881    .9795 |
	  |  1   2016m12    .6702   .7792       3   .6881    .6702 |
	  |  1    2017m1    .5949   .7331       4   .6881    .5949 |
	  |  1    2017m2    .7971   .7459       5   .6881    .7971 |
	  |--------------------------------------------------------|
	  |  1    2017m3    .7836    .765       5   .9795    .7836 |
	  |  1    2017m4    .6546   .7001       5   .6702    .6546 |
	  |  1    2017m5    .0968   .5854       5   .5949    .9689 |
	  |  1    2017m6    .6885   .6041       5   .7971    .6885 |
	  |  1    2017m7    .8725   .6192       5   .7836    .8725 |
	  +--------------------------------------------------------+


{p 4 4 2} {opt Explanation: } {p_end}
{p 4 4 2} For the first observation, that is 2016m10, the mean value is based on a single observation, as there are no previous
data. The same is reflected by the variables {it:{opt count}}, {it:{opt first}}, and {it:{opt last}}. For the second observation,
the mean value is based on two observations of {it:{opt X}}, i.e., {opt (0.6881 + .9795) / 2 = .8338 :}. We can also observe such details
from the variable {it:{opt count}}, that has a value of 2; variable {it:{opt first}} which shows that the first value in the
rolling window this far is .6881 and {it:{opt last}}, which shows that the last value in the rolling window is .9795. As we move
down the data points, the rolling window keeps on adding more observations until the fifth observation, i.e. 2017m2. After this observation,
the observations at the start of the rolling window are dropped and more recent observations are added. It is pertinent to mention
that users can limit the calculations of required statistics until minimum number of observations are available, see option {help asrol##min: minimum} for more details.


{p 4 4 2} {opt No Window: } {p_end}
{p 4 4 2} Since the option window is optional, it can be dropped altogether. In such a case, {opt asrol} can be used like {help gen} or {help egen}.
When used with {help bysort} prefix, {opt asrol} can closely match the performance of {help egen} in calculating statistics by groups. {p_end}



{p 4 4 2} 2. {opt g:en}: This is an optional option to specify name of the new variable, where the variable name is enclosed in parenthesis after {opt g:en}. 
 If we do not specify this option, {opt asrol} will automatically generate a new variable with the name format of {it:stat_rollingwindow_varname}. When finding mulitple statistics,
 one statistic for multiple variables, or multiple statistics for multiple variables, {cmd: asrol} will automatically assign names to the new
 variables. Therefore, option {opt g:en} cannot be used in such cases.{p_end}

{marker min}
 {p 4 4 2} 
 3. {opt  min:imum(#)} {break}
 The option {opt min:imum} forces {opt asrol} to find required statistics only when the minimum 
 number of observations are available. If a specific window does not have that many 
 observations, values of the new variable will be replaced with missing values. Please note that {hi: #} is an integer and should be
 greater than zero. Therefore, {opt min(0)}, {opt min(-5)}, or {opt min(1.5)} are treated as illegal commands. Examples of legal
 commands are {opt min(2)}, {opt min(10)}, or {opt min(100)}. 
 {p_end}
 
 {marker byvars}{...}
  {p 4 4 2} 
 4. {cmdab:by:( }{it:varlist}{cmd: )} {break}
 {opt asrol} is {it: byable} and hence the required statistics can be calculated using a single variable or multiple variables as sorting filter. For example, we can find mean profitability
 for each company in a rolling window of 5 years. Here, we use a single filter, that is company. Imagine that we have a data set of 40 countries, each one having 60 industries, and each industry 
 has 1000 firms. We might be interested in finding mean profitability of each industry within each country in a rolling window of 5 years. In that case, we shall use the option {help by} or using the {help bysort} prefix.
 Hence both of the following commands yield similar results. However, the command with {cmd: bysort} prefix has some speed advantage. {break}
 
     {cmd: asrol profitability, window(year 5) stat(mean), by(country industry)} 
  
     {cmd: bys country industry : asrol profitability, window(year 5) stat(mean)}

 {marker perc}{...}
 
 {p 4 4 2} 
 6. {opt  p:erc(k)} {break}
 This is an optional option. Without using {opt  p:erc(k)} option, {cmdab:stat(}{it:median}{cmd:)} finds the
 median value or the 50th percentile of the values in a given window. However, if option {opt  p:erc(k)} is specified, then
 the {cmdab:stat(}{it:median}{cmd:)} will find k-th percentile of the values in range. For example, if we are interested
 in finding the 75th percentiles of the values in our desired rolling window, then we have to invoke the option {cmd: perc(.75)}
 along with using the option {cmdab:stat(}{it:median}{cmd:)}. See the following example: {p_end}
 
      {cmd: bys country industry : asrol profitability, window(year 5) stat(median) perc(.75)} 
	
	
{p 4 4 2}  {opt Note: }: {break}
The calculation of percentiles follows a similar method as used in {help summarize} and {help _pctile} as defaults. Therefore,
the percentile values might be slightly different from the values calculated with { help centile}. For details related to different definitions 
of percentiles, see {browse "https://www.jstor.org/stable/2684934": Hyndman and Fan (1996).}  {p_end}

{marker add}{...}

{p 4 4 2} 
7. {opt  Options related to product and gmean} : {opt add(#)} and {opt ig:norezero} {break}
This version of asrol improves the calculation of {bf:product} of values and the {bf:geometric mean}. 
Since both the statistics involve multiplication of values in a given window, the presence of missing values and zeros present
a challenge to getting desired results. Following are the defaults in asrol to deal with missing values and zeros:

{p 8 8 8} 7.1 : Missing values are ignored when calculating the {bf:product} or the {bf:geometric mean} of values.{break}

{p 8 8 8} 7.2 : To be consistent with Stata's default for geometric mean calculations, 
(see {help ameans}), the default in asrol is to ignore zeros and negative numbers. So the geometric mean 
of {bf:0,2,4,6} is {bf: 3.6342412}, that is {bf:[2 * 4 * 6]^(1/3)}. And the 
geometric mean of {bf:0,-2,4,6} is {bf: 4.8989795}, that is {bf:[4 * 6]^(1/2)}.


{p 8 8 8}7.3 : Zeros are considered when calculating the {bf:product} 
 of values. So the product of {bf:0,2,4,6} is {bf: 0}

{p 8 8 2} Two variations are possible when we want to treat zeros differently. These are discussed below:

{p 8 8 8} 7.4 Option {opt ig:norezero}: This option can be used to ignore zeros
 when calculating the {bf:product} of values. Therefore, when the zero is 
 ignored, the product of {bf:0,2,4,6} is {bf: 48} 

{p 8 8 8} 7.5 Option {opt add(#)} : This option adds a constant {bf:#} 
to each values in the range before calculating the {bf:product} or the 
{bf:geometric mean}. Once the required statistic is calculated, then the 
constant is substracted back. So using option {opt add(1)}, the product of {bf:0,.2,.4,.6} is 
{bf: 1.6880001} that is {bf:[1+0 * 1+.2 * 1+.4 * 1+.6] - 1}
and the geometric mean is {bf:.280434} is {bf: [(1+0 * 1+.2 * 1+.4 * 1+.6)^(1/4)] - 1}. 

{p 8 8 8} The Stata's {help ameans} command calculates three types of means, including the geometric mean. 
The difference between {bf:asrol' gmean} function and the Stata 
{help ameans} command lies in the treatment of option {opt add(#)}. 
{help ameans} does not subtract the constant # from the results, 
whereas {bf:asrol} does. 


 {marker xf}{...}
{p 4 4 2} 
8. {opt  xf(excluding focal observation)} {break}
The {opt xf} is an abbreviation that I use for  "{it:excluding focal}". There might be circumstances where we want
to exclude the focal observation while calculating the required statistics. {opt asrol} allows excluding focal 
observation with two flavors. The first one is to exclude only the current observation while
the second one is to exclude all observation of the relevant variable if there are similar (duplicate) values of 
the rangevar elsewhere in the given window. An example will better explain the distinction between the two 
options. Consider the following data of 5 observations, where {it:{opt X}} is the variable of interest for which we would
like to calculate arithmetic mean and {it:{opt year}} is the rangevar. Our calculations do not use any rolling window, therefore the option {opt window} is dropped. {p_end}

{p 4 4 2} 
{opt Example A:}: {p_end}

	 asrol X, stat(mean) xf(focal) gen(xfocal)

{p 4 4 2} 
{opt Example B:}: {p_end}

	asrol X, stat(mean) xf(year) gen(xfyear)
	
	  +---------------------------------------+
	  | year     X        xfocal       xfyear |
	  |---------------------------------------|
	  | 2001   100          350           350 |
	  | 2002   200          325           325 |
	  | 2003   300          300     266.66667 |
	  | 2003   400          275     266.66667 |
	  | 2004   500          250           250 |
	  +---------------------------------------+

{p 4 4 2} {opt Explanation: }: {p_end}

{p 4 4 2}
In {opt Example A}, we invoke the option {opt xf()} as {opt xf(focal)}. {help asrol} generates a new variable {it:{opt xfocal}} that contains the mean values of the rest of
the observations in the given window, excluding the focal observation. Therefore, in the year 2001, {it:{opt xfocal}} variable
has a value of 350, that is the average of the values of {it:{opt X}} in the years 2002, 2003, 2003, 2004 i.e.
(200+300+400+500)/4 = 350. Similarly, the second observation of the {it:{opt xfocal}} variable is 325, that is
(100+300+400+500)/4 = 325. Similar calculations are made when required statistics are estimated in a rolling window. {p_end}

{p 4 4 2} {opt Example B } 
differs from {opt Example A } in definition of the focal observation(s). In {opt Example B}, 
we invoke the option {opt xf()} as {opt xf(year)}, where {it:{opt year}} is an existing numeric variable. With this option, the focal observation(s) is(are) defined as the current observation and other observations where the focal observation
of the rangevar has duplicates. Our data set has two duplicate values in the rangevar, i.e., year 2003.
Therefore, the mean values are calculated as shown bellow:

	+-------------------------------------------------------+	
	|	obs 1: (200 + 300 + 400 + 500)/4 = 350		|
	|	obs 2: (100 + 300 + 400 + 500)/4 = 325		|			
	|	obs 3: (100 + 200 + 500 )     /3 = 266.66667	|		
	|	obs 4: (100 + 200 + 500 )     /3 = 266.66667	|	
	|	obs 5: (100 + 200 + 300 + 400)/4 = 250		|			
	+-------------------------------------------------------+	


{title:Examples}


{title:Example 1: Find arithmetic mean in a rolling window of 4 observations for each group (company)}
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "bys company: asrol invest, stat(mean) win(year 4) " :bys company: asrol invest, stat(mean) win(year 4) } {p_end}

{p 4 8 2} This command calculates arithmetic mean for the variable invest using a four years rolling window and 
stores the results in a new variable, {it:mean4_invest}. 

{title:Example 2: Geometric mean in a rolling window of 10}
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "bys company: asrol invest, stat(gmean) win(year 10) " :bys company: asrol invest, stat(gmean) win(year 10) } {p_end}
 
 
 {title:Example 3: Geometric mean with add(1) option in a rolling window of 10}
 {p 4 8 2}{stata "bys company: asrol invest, stat(gmean) win(year 10) add(1)" :bys company: asrol invest, stat(gmean) win(year 10) add(1) gen(gmean10) } {p_end}


{p 4 8 2} This command calculates arithmatic mean for the variable invest using a four years rolling window and 
stores the results in a new variable, {it:mean4_invest}. 

 {title:Example 4: Find Rolling Standard Deviation} 
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "bys company: asrol invest, stat(sd) win( year 6) " :. bys company: asrol invest, stat(sd) win(year 6)} {p_end}
 
 {p 4 8 2} This command calculates standard deviation for the variable invest using a six years 
 rolling window and stores the results in a new variable , {it:sd4_invest} {p_end}

   
 {title:Example 5: Find 75th percentile in a rolling window of 4 years} 
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "bys company: asrol invest, stat(median) win(year 4) perc(.75) " :. bys company: asrol invest, stat(median) win(year 4) perc(.75) } {p_end}
 
 
 {title:Example 6:  5-period rolling median with minimum of 3 observatons} 
 
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "bys company: asrol invest, stat(mean) win(year 5) min(3) " :. asrol invest, stat(median) win(year 5) min(3) }

 
 {title:Example 7:  Rolling mean with minimum number of observaton while excluding focal observation} 
 
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "bys company: asrol invest, stat(mean) win(year 4) xf(focal) " :bys company: asrol invest, stat(mean) win(year 4) xf(focal) } {p_end}

 
  {title:Example 8:  Find 5-periods rolling mean for three variables in one go} 
 
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "bys company: asrol invest mvalue kstock , stat(mean) win(year 4)" :bys company: asrol invest mvalue kstock, stat(mean) win(year 4) } {p_end}

   {title:Example 9:  Find 5-periods rolling mean, standard deviation, and count for three variables in one go} 
 
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "bys company: asrol invest mvalue kstock , stat(mean sd count) win(year 4)" :bys company: asrol invest mvalue kstock, stat(mean sd count) win(year 4) } {p_end}


 {title:Example 10: Using by option for two or three variables} 
 
 {p 4 8 2} We shall generate a dummy data of 5 countries, 10 industries, 100 years, and 5000 firms for further examples.  {p_end}

 {space 6}{hline 15} {hi:copy the following and run from do editor} {hline 15}
	clear
	set obs 5000
	gen company=_n
	expand 100
	bys company: gen year=_n+1950
	bys company: gen industry=mod(company, 10)+1
	bys industry: gen country=mod(industry, 5)+1
	order company year industry country
	sort company year
	gen profit=uniform()			 
{space 8}{hline 70}


{title:Example 11: Mean by country and industry in a rolling window of 10 years} 
 
 {p 4 8 2}{stata "bys country industry: asrol profit, stat(mean) win(year 10)" :. bys country industry: asrol profit, stat(mean) win(year 10)} {p_end}

 
{title:Example 12: Mean by country and industry without a rolling window} 

 {p 4 8 2}{stata "bys country industry: asrol profit, stat(mean)" :. bys country industry: asrol profit, stat(mean)} {p_end}

 
 {title:Example 13: Mean by country and industry in a rolling window of 12 years and excluding focal observation} 

 {p 4 8 2}{stata "bys country industry: asrol profit, stat(mean) win(year 12) xf(focal)" :. bys country industry: asrol profit, stat(mean) win(year 12) xf(focal)} {p_end}

 
 {title:Example 14: Mean by country and industry in a rolling window of 12 years and excluding focal observation based on year} 

 {p 4 8 2}{stata "bys country industry: asrol profit, stat(mean) win(year 12) xf(year)" :. bys country industry: asrol profit, stat(mean) win(year 12) xf(year)} {p_end}


{title:Author}


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: *
*                                                                   *
*            Dr. Attaullah Shah                                     *
*            Institute of Management Sciences, Peshawar, Pakistan   *
*            Email: attaullah.shah@imsciences.edu.pk                *
*           {browse "www.StataProfessor.com": www.StataProfessor.com}                                 *
*           {browse "www.OpenDoors.Pk": www.OpenDoors.Pk}                                       *
*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*


{marker also}{...}
{title:Also see}

{psee}
{help rolling}, 
{stata "ssc desc astile":astile}, 
{stata "ssc desc ascol":ascol}, 
{stata "ssc desc asreg":asreg},
{browse "http://www.opendoors.pk/asm":asm},
{stata "ssc desc astx":astx},
{stata "ssc desc searchfor":searchfor}.


{title:Acknowledgements}

{p 4 4 2}
 For creating group identifiers, I could have used egen's function, group. But for speed efficiency, 
 Nick Cox's solution of creating group idnetifier was preffered({browse "http://www.stata.com/support/faqs/data-management/creating-group-identifiers": See here}). 
 For finding median in the Mata language, I used the approach suggested by Daniel Klein,
({browse "http://www.statalist.org/forums/forum/general-stata-discussion/mata/1335405-can-i-use-mata-to-calculate-a-median-of-the-outcome-in-the-exposed-and-unexposed-groups-following-matching-with-teffects-psmatch": See here})  {p_end}
