{smcl}
{* *! version 1.1 30may2017}{...}
{cmd:help screen}
{hline}

{title:Title}

{phang}
{bf:screen} {hline 2} Stata command to quickly identify possible outliers based on the 
interquartile range, percentile or standard deviation.


{title:Syntax}

{p 8 17 2}
{cmdab:screen}
{varlist}
{ifin}
[{cmd:,} {it:options}]


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt t:ype(string)}}{it:string} may be {bf:iqr}, {bf:per}, or {bf:sd};
		e.g. {opt t:ype(sd)}{p_end}
{synopt:{opt l:ower(numeric)}}lower-tail cutoff;
		e.g. {opt l:ower(0.1)}{p_end}
{synopt:{opt u:pper(numeric)}}upper-tail cutoff;
		e.g. {opt u:pper(3)}{p_end}	
{syntab:Options}
{synopt:{opt i:ter(integer)}}screening iterations and only applicable			
		to {opt t:ype(sd)}; e.g. {opt i:ter(2)}{p_end}
{synopt:{opt g:en(integer)}}generates a {varlist} clone and replaces potential outliers with the
		cutoff, mean, median, or missing value; e.g. {opt g:en(2)}{p_end}
{synopt:{opt s:econd(varlist)}}screens {it:varlist} excluding observations with {varlist} outliers{p_end}


{title:Description}

{pstd}
Stata command to quickly identify possible outliers based on the interquartile range, 
percentile or standard deviation. For example, screen can identify Tukey’s severe outliers (more than 3 IQR away 
from the nearer quartile) and mild outliers (between 1.5 and 3 IQR away from the nearer quartile), 
Gaussian outliers based on the three-sigma-rule (more than 3 SD away from the mean), Chebyshev's inequality (no more than 1/k^2 of 
values can be more than k standard deviations away from the mean), and percentile outliers (top and bottom sample trimming). 


{title:Options}	

{dlgtab:Main}

{phang}
{opt t:ype(iqr|per|sd)} indicates screening method and may only be percentile, standard deviation, or interquartile range.

{phang}
{opt l:ower(#)}	specifies lower-tail cutoff. If {opt l:ower(1)} and {opt t:ype(per)}, 
values below the 1st percentile are identified; if {opt l:ower(3)} and {opt t:ype(sd)}, 
values 3 standard deviations below the mean are identified; if {opt l:ower(1.5)} and {opt t:ype(iqr)}, 
values more than 1.5 IQR (75th percentile - 25th percentile) below the first quartile (25th percentile) are identified. 

{phang}
{opt u:pper(#)}	specifies upper-tail cutoff. If {opt u:pper(1)} and {opt t:ype(per)}, 
values above the 99th percentile are identified; if {opt u:pper(3)} and {opt t:ype(sd)}, 
values 3 standard deviations above the mean are identified; if {opt u:pper(1.5)} and {opt t:ype(iqr)}, 
values more than 1.5 IQR (75th percentile - 25th percentile) above the third quartile (75th percentile) are identified.

{dlgtab:Options}

{phang}	
{opt i:ter(#)} number of screening iterations and only applicable to {opt t:ype(sd)}. If {opt i:ter(2)} values are screened twice. 
This is useful when extreme values (possibly data collection errors)
distort the mean and standard deviation which are necessary for outlier detection in the SD method. 

{phang}	
{opt g:en(#)} generates a {varlist} clone and replaces potential outliers with the cutoff value if {opt g:en(1)}; 
with the mean if {opt g:en(2)} and {opt t:ype(per|sd)}; with the median if {opt g:en(2)} and {opt t:ype(iqr)};
and with missing values if {opt g:en(3)}.

{phang}	
{opt s:econd(varlist)} screens {it:varlist} (e.g. protein, iron, and zinc intake) excluding observations 
with {varlist} (e.g. daily meat consumption) outliers. 


{title:Example}	

{phang}{cmd:. screen expenditure, type(sd) lower(3) upper(3) iter(2)}{p_end}

{phang}{cmd:. screen consumption, type(per) upper(2.5) second(kcal iron protein)}{p_end} 
{phang}{cmd:. screen kcal if poor==1, type(iqr) lower(3) gen(1)}{p_end} 

{title:Author}

{pstd}
Marco Santacroce, International Food Policy Research Institute, Washington DC, USA (marcosantacroce.it@gmail.com)


{title:Citation}

{phang}	
Santacroce, Marco (2017).
screen: STATA command to quickly identify possible outliers based on the interquartile range, percentile or standard deviation.

{phang}