{smcl}
{* *! version 1  oct2018}{...}
{cmd:help heatmapgraph}

{hline}

{title:Title}

{p2colset 6 23 23 2}{...}
{p2col:{hi:heatmapgraph} {hline 2}}Applies a framework for measuring the evolution of risks to financial stability over the financial cycle, generate a heatmap graph and reports various associated results
based on a large number of indicators.{p_end}
{p2colreset}{...}


{title:Syntax}

{p 6 28 8}
{cmd:heatmapgraph} 
{it:infofilename}
{ifin}{cmd:,} {cmd:infoid}({it:{help varname}}) {cmd:category}({it:categoryname}) {cmd:component}({it:componentname}) {cmd:turnon}(#) 
{cmd:winsize}({it:startdate1}, {it:enddate1} [, {it:startdate2}, {it:enddate2,...}]) {cmdab:res:ults}({it:{help filename}}) {cmdab:maw:in}(#) 
[ {it:options} ]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt: {opt save(filename)}}saves a database with cycles, trends and standardized indicators (it could be used in future runs saving these processes time){p_end}
{synopt: {opt exclude(varlist)}}indicators to exclude from the final result{p_end}
{synopt: {opt include(varlist)}}indicators to include in the final result ({it:should specify detrending method and threshold, see naming convention below}){p_end}
{synopt: {opt infopath(path)}}path of {it:infofilename} if not in the current working directory{p_end}
{synopt: {opt indexname(indexname)}}label the {it:aggregated index} in the heatmap graph (default, Index){p_end}
{synopt: {opt graphs:eries}}graphs individual indicators with the relevant trend and confidence interval{p_end}
{synopt: {opt labels}}indicators labels included in {it:infofilename} (complete spelling  is strict) to be used as titles in individual indicators graphs{p_end}
{synopt: {opt nostage1}}suppresses stage 1 selection procedure (all available indicators will be selected){p_end}
{synopt: {opt catxcoord(#)}}real number inside [0, 1] interval to calibrate categories labels in heatmap graph. 
As its position depends on time span and frequency perhaps you should run it twice (or more) in order to get its wright position, bigger numbers push labels to the left (default, 0.25){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {opt tsset} your data before using {opt heatmapgraph}; see
{manhelp tsset TS}.
{p_end}


{title:Description}

{pstd}
{cmd:heatmapgraph} applies a framework for measuring the evolution of risks to financial stability over the financial cycle. 
Starting from a large number of indicators of financial stability risk, {cmd:heatmapgraph} selects best indicators signaling overheating periods
based on: i) its capability for detecting overheating of financial activities; ii) successfully minimizes various statistical errors involved in forecasting future
events (loss functions, see below). Then normalize and aggregate these indicators, first into components, then into categories and finally into an aggregate index measure {bf:(see Definitions)}.


{title:Definitions}

{pstd}
{cmd:{it:infofilename}} is a Stata file which its main function is to provide all relevant information about indicators characteristics. It has an special structure:
First, an {cmd:infoid}({it:{help varname}}) which classifies indicators into components (see option {cmd:component}({it:componentname})) and categories (see option {cmd:category}({it:categoryname})) and optionally specify 
indicators labels (see option {cmd: labels}) to be used as titles in the individual indicators graphs (see option {cmdab:graphs:eries}).
Second, as an indicator may be one way, inverted or two way depending on its relation with vulnerabilities, each indicators in {it:infofilename} should be named the same way as the series database (master database) 
followed by an underscore and:

	i)   _1w (one way)
	ii)   _i (inverted)
	iii) _2w (two way)

	
{title:Example {it:infofile} structure}

{c TLC}{hline 11}{c TT}{hline 40}{c TT}{hline 40}{c TT}{hline 40}{c TT}{hline 18}{c TT}{hline 18}{c TT}{hline 18}{c TRC}
{c |}    id     {c |}{dup 15: } var01_1w {dup 15: }{c |}{dup 15: } var02_2w {dup 15: }{c |}{dup 15: } var03_i {dup 16: }{c |}{dup 4: } var04_i {dup 5: }{c |}{dup 4: } var05_1w {dup 4: }{c |}{dup 4: } var06_2w {dup 4: }{c |}
{c LT}{hline 11}{c +}{hline 40}{c +}{hline 40}{c +}{hline 40}{c +}{hline 18}{c +}{hline 18}{c +}{hline 18}{c RT}
{c |} category  {c |} Private nonfinancial sector imbalances {c |} Private nonfinancial sector imbalances {c |} Private nonfinancial sector imbalances {c |} Asset valuations {c |} Asset valuations {c |} Asset valuations {c |}
{c LT}{hline 11}{c +}{hline 40}{c +}{hline 40}{c +}{hline 40}{c +}{hline 18}{c +}{hline 18}{c +}{hline 18}{c RT}
{c |} component {c |}{dup 15: } Household {dup 14: }{c |}{dup 15: } Household {dup 14: }{c |}{dup 17: } PNFC {dup 17: }{c |}{dup 3: } Financial {dup 4: }{c |}{dup 3: } Financial {dup 4: }{c |}{dup 4: } Property {dup 4: }{c |}
{c LT}{hline 11}{c +}{hline 40}{c +}{hline 40}{c +}{hline 40}{c +}{hline 18}{c +}{hline 18}{c +}{hline 18}{c RT}
{c |} labels    {c |}{dup 10: } Mort.credit.growth {dup 10: }{c |}{dup 12: } Debt_to_income {dup 12: }{c |}{dup 12: } Debt_to_profit {dup 12: }{c |}{dup 2: } Term.premium {dup 2: }{c |}{dup 3: } Volatility {dup 3: }{c |}  House.p.growth  {c |}
{c BLC}{hline 11}{c BT}{hline 40}{c BT}{hline 40}{c BT}{hline 40}{c BT}{hline 18}{c BT}{hline 18}{c BT}{hline 18}{c BRC}
{ul:Note:} {it:Suggested relations with vulnerabilities in first row are only for illustration. Include labels without spaces.}


{title:Example {it:seriesfile} (master database) structure}

{c TLC}{hline 14}{c TT}{hline 10}{c TT}{hline 10}{c TT}{hline 10}{c TT}{hline 10}{c TT}{hline 10}{c TT}{hline 10}{c TRC}
{c |}{dup 4: }month{dup 5: }{c |}{dup 2: }var01{dup 3: }{c |}{dup 2: }var02{dup 3: }{c |}{dup 2: }var03{dup 3: }{c |}{dup 2: }var04{dup 3: }{c |}{dup 2: }var05{dup 3: }{c |}{dup 2: }var06{dup 3: }{c |}
{c LT}{hline 14}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c RT}
{c |}{dup 4: }2018m7{dup 4: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}
{c LT}{hline 14}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c RT}
{c |}{dup 4: }2018m8{dup 4: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}
{c LT}{hline 14}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c RT}
{c |}{dup 4: }2018m9{dup 4: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}{dup 2: } ... {dup 3: }{c |}
{c BLC}{hline 14}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BRC}

	
{title:Options}

{dlgtab:Required}

{phang}
{cmd:infoid}({it:{help varname}}) variable name in {it:infofile} which identify category, components and optionally labels (variable "id" in the first table above).

{phang}
{cmd:category}({it:categoryname}) name of category grouping.

{phang}
{cmd:component}({it:componentname}) name of component grouping.

{phang}
{cmdab:res:ults}({it:{help filename}}) name for saved results files (see below).

{phang}
{cmd:turnon(#)} number of times an indicator should move above the upper threshold in the overheat indication period to be selected (integer equal or greater than 1).

{phang}
{cmd:winsize}({it:startdate1}, {it:enddate1} [, {it:startdate2}, {it:enddate2,...}]) periods in which a signal indicating overheating is supposed to be sent (i. e. anticipate a crisis).

{phang}
{cmdab:maw:in}(#) describes the span of the uniformly weighted moving average (integer equal or greater than 2).


{title:Indicators selection}

	{title:1. Trends and gap indicators}
	
	To capture the extent to which the values of the indicators deviate from their trends in order to detect the degree of overheating or overcooling in financial activity 
	the trend of each indicator is extracted using 3 alternative procedures (Stata saved database if {cmd:save}({it:filename}) option declared): 
		
	{c TLC}{hline 28}{c TT}{hline 18}{c TT}{hline 18}{c TT}{hline 18}{c TRC}
	{c |}{dup 8: }{bf:Trend method}{dup 8: }{c |}{dup 5: }{bf:Gap var}{dup 6: }{c |}{dup 4: }{bf:Trend var}{dup 5: }{c |}{dup 1: }{bf:Standardized var}{dup 1: }{c |}
	{c LT}{hline 28}{c +}{hline 18}{c +}{hline 18}{c +}{hline 18}{c RT}
	{c |}{dup 2: }Hodrick-Prescott 1 sided{dup 2: }{c |}{dup 3: }{it:varname}_hp1s{dup 3: }{c |}{dup 2: }{it:varname}_hp1s_tr{dup 1: }{c |}{dup 2: }sthp1s_{it:varname}{dup 2: }{c |}
	{c LT}{hline 28}{c +}{hline 18}{c +}{hline 18}{c +}{hline 18}{c RT}
	{c |}{dup 2: }Hodrick-Prescott 2 sided{dup 2: }{c |}{dup 4: }{it:varname}_hp{dup 4: }{c |}{dup 3: }{it:varname}_hp_tr{dup 2: }{c |}{dup 3: }sthp_{it:varname}{dup 3: }{c |}
	{c LT}{hline 28}{c +}{hline 18}{c +}{hline 18}{c +}{hline 18}{c RT}
	{c |}{dup 7: }Moving average{dup 7: }{c |}{dup 3: }{it:varname}_dem{dup 4: }{c |}{dup 2: }{it:varname}_dem_tr{dup 2: }{c |}{dup 2: }stdem_{it:varname}{dup 3: }{c |}
	{c BLC}{hline 28}{c BT}{hline 18}{c BT}{hline 18}{c BT}{hline 18}{c BRC}

	{title:2. Statistical evaluation of gap indicators}
	
	The indicators are evaluated based on the following two perspectives: (a) whether the indicator can detect the overheating periods defined in {cmd:winsize()}; and 
	(b) whether the indicator successfully minimize various statistical errors involved in forecasting future events.
	
		(a) Threshold levels {bf:(Stage 1)}: In order to detect the overheating of financial activities, we need to evaluate the indicator values in comparison to some upper thresholds. 
		Since we do not know which levels of threshold would be appropriate a priori, we examine several threshold levels. 
		We calculate the root mean square (RMS) of the sum of deviations between actual and trend values (expressed as sigma in the equation shown below) 
		and study 4 cases, 1 time, 1.25 times, 1.5 times, 1.75 times RMS (referenced as threshold 1 to 4 respectively in Excel results file)
		
					sigma = ((1/(N-1)) * sum_N(xi - xit)^2) ^ (1/2)
					
		where xi is the actual value of the indicator x at time i, and xit stands for the trend value of the same indicator at the same point of time.
		The first statistical evaluation criterion can be restated as whether each indicator actually issued an “overheating” signal by moving above the upper threshold 
		in the “overheat indication period”. Indicators which did not send any signal of “overheating” are discarded at this stage. Those which did are taken forward to the next step.
		
		(b) Evaluating statistical errors {bf:(Stage 2)}: When using indicators to make a financial activity assessment, it is ideal that warning signals be issued before an event, 
		i.e., a financial crisis, takes place, and that no warning signals are dispatched when no such event is occurring. It is desirable that either A or D in the 
		table below always be realized:
		
		{c TLC}{hline 20}{c TT}{hline 20}{c TT}{hline 20}{c TRC}
		{c |}{dup 20: }{c |}{dup 7: }{bf:Event}{dup 8: }{c |}{dup 6: }{bf:No event}{dup 6: }{c |}
		{c LT}{hline 20}{c +}{hline 20}{c +}{hline 20}{c RT}
		{c |}{dup 3: }Signal issued{dup 4: }{c |}{dup 1: }Correct signal: A{dup 2: }{c |}{dup 2: }Type II errors: B{dup 1: }{c |}
		{c LT}{hline 20}{c +}{hline 20}{c +}{hline 20}{c RT}
		{c |}{dup 2: }No signal issued{dup 2: }{c |}{dup 1: }Type I errors: C{dup 3: }{c |}{dup 2: }Correct signal: D{dup 1: }{c |}
		{c BLC}{hline 20}{c BT}{hline 20}{c BT}{hline 20}{c BRC}
		
		The threshold should be set at a relatively low level if one would like to to minimize the occurrence of “type I errors (= risk of missing crises).” 
		Meanwhile, there is also a need to keep thresholds at a relatively high level to lower the frequency with which false signals are issued, thereby reducing “type II errors (= risk of issuing false signals).”
		Threshold level will be chosen to a value for which 3 alternatives of a loss function (weighted average of probabilities of type I and type II errors) is minimized:
		
								L(u,t) = u P T1(t) + (1-u) (1-P) T2(t)
				
				P = (a + c) / (a + b + c + d);		T1(t) = c / (a + c);		T2(t) = b / (b + d) 
				
		where, {it:a, b, c, and d} are the numbers of periods corresponding to event A, B, C, and D, {it:u} is the weight parameter (takes 3 alternative values 0.5; 0.7; 0.9, model1 to model3, respectively in Excel results file),
		{it:L(u ,t)} is the policymaker’s loss under the weight {it:u} and the threshold {it:t}, {it:P} is the ratio of the number of periods in which a signal should be issued to the total number of periods, 
		and {it:T1(t)} and {it:T2(t)} are the probabilities of type I errors and type II errors, respectively.
		
		Additionally, to avoid a problem on the noise-to-signal ratio approach where often ends up in setting extremely high threshold values, a fourth NS model is calculated solely on indicators which issue signals 
		in more than two-thirds of the overheat indication period:
		
								NS(t) = (b / (b + d)) / (a / (a + c))
									
		For each indicator to be evaluated in this stage (in conjunction with a trend extraction method and the relevant threshold level) the value of the loss function of models 1 to 4 is calculated,
		with those that minimize the largest amount being selected.
		
	{title:3. Correlation analysis (optional Stage 3)}
	
	Finally, the correlation of the gap (original indicator minus its trend) of all the selected indicators is calculated (see sheet "correlation" in Excel results file) in order to analyze   
	if two indicators are highly correlated (to avoid that a certain source of vulnerability is computed multiple times). Using expert judgment the user could select one and discard the other 
	and do a second run of {cmd:heatmapgraph} with the appropriate {cmd:exclude({it:{help varlist}})} option filled in.

		
{title:Heatmap methodology}

Define k components classifying all indicators and j categories classifying components (see {it: infofile} structure above).
Denoting indicators within each component k by X(l, k, t), where l denotes the specific indicator, (e.g., debt-to-income ratio is one indicator within the Household component and Private nonfinancial sector imbalances category) 
and t denotes a point in time, for each indicator X(l, k, t) subtract the trend (with 3 alternative procedures, see table above) and divide by the standard deviation –denote the standardized indicator by STD(l, k, t)-.
Each component index V(k, t), is generated as the simple unweighted average of the standardized indicators for that component (components are grouped into categories and finally the aggregate index is an average of the latter): 

								V (k, t) = (1 / N) * sum STD(l, k, t) 

Finally, estimate the distribution of each component using a non-parametric kernel estimator. The periodic observation for each component is then transformed onto the (0, 1) interval based on its quantile in its 
historical distribution. This process takes into account the linkage of the indicator with the risk. If the relationship is direct, nothing is modified. If the relation is inverse, the order of the percentiles is reversed 
in such a way that values ​​close to 1 represent observations close to the minimum historical value (maximum vulnerability) of these components. In the case of indicators with two-way risk, the re-scaled indicator value is replaced
by (1 - re-scaled indicator value) for those observations that are below the distribution median.


{title:Examples}

   use heatmap_series.dta, clear
   tset month, m
{phang}{cmd:. heatmapgraph heatmap_info, infoid(id) category(category) component(component) results(heatmap_series1) turnon(2) winsize(2007m5, 2008m4, 2010m10, 2011m9) mawin(12) save(heatmap_series1) labels  nostage1}{p_end}


   use heatmap_series1.dta, clear
   tset month, m
{phang}{cmd:. heatmapgraph heatmap_info, infoid(id) category(category) component(component) results(heatmap_series2) turnon(2) winsize(2007m5, 2008m4, 2010m10, 2011m9) mawin(12)}{p_end}


{title:Saved results}

{it:savefilename.png} PNG file with heatmap graph.
{it:savefilename.xlsx} Excel file with sheets: Stage1, Stage2, Stage2end, correlation, heatmap.
{it:savefilename.dta} Stata file with cycles, trends and standardized variables {bf:(optional)}.
{it:savefilename.docx} Word file individual indicators (time series) graphs {bf:(optional)}.

	{title:Naming convention}

	The Excel results file identify indicators along with detrend method and relevant threshold:
	- hp3_var01 stands for Hodrick-Prescott 2 sided detrend method and threshold "3" (1.5 times RMS) of var01.
	- hp1s2_var02 stands for Hodrick-Prescott 1 sided detrend method and threshold "2" (1.25 times RMS) of var02.
	- dem1_var03 stands for Moving average detrend method and threshold "1" (1 time RMS) of var03.
	
	{title:Excel file saved results}
	Stage1: identify indicator turn on times within each defined window. 
	Stage2: identify chosen indicators from previous stage and each loss function model result (from 1 to 4).
	Stage2end: in case one indicator was selected by different models this stage chooses the one that has the lowest mean loss function (considering models 1 to 3).
	correlation: correlation matrix of indicators´ gap of all possible combinations from previous stage.
	heatmap: final graphed (0, 1) series result (components and aggregated index). In addition, it presents categories results.
	Note that the sequence is: first standardize, then average and finally re-scale to a (0, 1) interval, so averaging categories results do not reproduce aggregated index results.


{title:References}

Aikman D.; J. Bridges, S. Burgess, R. Galletly, I. Levina, C. O’Neill and A. Varadi (2018). “Measuring risks to UK financial stability.” Staff Working Paper No. 738. Bank of England.
Aikman D.; M. Kiley ; S. J. Lee; M. G. Palumbo; M. Warusawitharana (2017). “Mapping heat in the U.S. financial system.” Journal of Banking and Finance, 81 p. 36–64.
Ghosh S. (2016). “Monitoring Macro-Financial Vulnerability: A Primer.” MFM Discussion Paper No.14. The World Bank. Washington DC.
Ito Y; T. Kitamura; K. Nakamura and T. Nakazawa (2014). “New Financial Activity Indexes: Early Warning System for Financial Imbalances in Japan.” Bank of Japan Working Paper Series No.14.
Mencía J. y J. Saurina (2016). “Política Macroprudencial: Objetivos, Instrumentos e Indicadores.” Documentos Ocasionales Nº 1601. Banco de España.


{title:Other packages needed}
{browse "https://ideas.repec.org/c/boc/bocode/s456713.html":matpwcorr}
{browse "https://ideas.repec.org/c/boc/bocode/s456101.html":akdensity}
{browse "https://www.stata.com/stb/stb56/dm79/svmat2.ado":svmat2}
 
 
{title:Author}

Maximo Sangiacomo
{hi:Email:  {browse "mailto:msangia@hotmail.com":msangia@hotmail.com}}
