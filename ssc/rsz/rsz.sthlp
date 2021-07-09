{smcl}
{* *! version 1.0 20dec2014}{...}

{title:Title}

{phang}
{helpb rsz} {hline 2} Draw a stratified simple random sample, a systematic sample, or a randomly split zones sample, 
	with probabilities proportional to size.{break}

{title:Syntax}

{phang}
{cmd:rsz} {ifin}, {cmd:strsamsize}({it:variable}) {cmd:replicates}({it:number}) {cmd:ranseed}({it:number}) [{cmd:alt}({it:srs/sys/rsz}) {cmd:strata}({it:varlist}) {cmd:sorting}({it:varlist}) {cmd:consorting}({it:varlist}) {cmd:serp}({it:Y/N}) 
	{cmd:mos}({it:variable}) {cmd:exprr}({it:number}) {cmd:inflatedsamsize}({it:Y/N}) {cmd:desiredinitial}({it:number}) {cmd:extra}({it:number}) {cmd:restore}({it:Y/N})] {p_end}

{title:Required parameters}

{phang}
{opt strsamsize(variable)} takes a numeric variable indicating the sample size in each stratum, or a uniform number if there is no stratification.{sf}{p_end}

{phang}
{opt replicates(number)} takes a number indicating how many rounds of releases will be made in data collection under randomly split zones (rsz) design. Specify 1 if not under rsz design. If a number 
	greater than 1 is specified under simple random sampling (srs) or systematic sampling (sys), the sample size will be inflated in each stratum according to the specified number
	and you will need to split the sample for your sequential releases. See technical notes at the end of the file for more information.{p_end}

{phang}
{opt ranseed(number)} takes a number between 0 and 2,147,483,647 as the random seed to draw the sample. {p_end}

{marker options}{...}
{title:Options}

{phang}
{opt alt(srs/sys/rsz)} takes srs, sys, or rsz that indicates the sampling procedure. By default rsz is assumed. {p_end}

{phang}
{opt strata(varlist)} takes stratification variables. By default no stratification (one stratum) is assumed. {p_end}

{phang}
{opt sorting(varlist)} takes sorting variables in order. By default random ordering is assumed.{p_end}

{phang}
{opt consorting(varlist)} takes continuous sorting variables that are usually specified at the end of sorting variables to fix the position of each case in the list. By default 
	no further sorting is assumed.{p_end}

{phang}
{opt serp(Y/N)} takes Y or N to indicate that whether a hierarchical serpentine sorting is desired. The hierarchic serpentine sorting is an improvement over the simple sorting 
	which uniformly sorts a subsequent variable in one specified order (either ascending or descending); in contrast, the hierarchic serpentine sorting alternates the sorting order 
	of a subsequent variable when a boundary of the preceding variable is crossed so that the units 
	at the boundary are similar. By default hierarchical serpentine sorting is assumed.{p_end}

{phang}
{opt mos(variable)} takes a numeric variable indicating the measure of size (MOS) for calculating each case's selection probability, which is the case's MOS divided by 
	the total MOS in the sampling group to which the case belongs. By default, equal selection probabilities are assumed.{p_end}

{phang}
{opt exprr(number)} takes a percent from 0 to 1 which indicates the expected overall response rate. By default, a response rate of 1 is assumed. See technical notes 
	at the end of the file for more information. {p_end}

{phang}
{opt inflatedsamsize(Y/N)} takes Y or N to indicate that whether the sample size variable {it:strsamsize} contain the inflated sample size which takes the number of replicates 
	and expected response rate into account. {it:This option is for the rsz sampling method only.} By default, non-inflated sample size is assumed. 
	See technical notes at the end of the file for more information. {p_end}

{phang}
{opt desiredinitial(number)} takes a number which forces the total initial sample size to the desired sample size as specified rather than leaves it to whatever the rounded result 
	would be. {it:This option is for the rsz sampling method only.} By default, no desired total initial sample size is assumed. 
	See technical notes at the end of the file for more information. {p_end}

{phang}
{opt extra(number)} takes a number which indicates that how many more replicate samples should be drawn in addition to the number as specified in the option {it:replicates}, just in case 
	your assumption are not accurate. By default, no extra is assumed. See technical notes at the end of the file for more information. {p_end}

{phang}
{opt restore(Y/N)} takes Y or N to indicate that whether the input list order should be restored. By default, restore is assumed.{p_end}
	
{title:Description of the Program}

{pstd}
This program was written primarily for drawing a sample by the randomly split zones (rsz) for samples of size one sampling method as proposed in Singh and Ye (2016). It also provides 
	the option to draw a sample by simple random (srs) sampling method or the systematic (sys) sampling method. Under the rsz sampling method, explicit strata will be further 
	stratified into deep strata (or zones) by an additional stratifying variable. Also, the program will split zones into random groups from each of 
	which one and only case will be seleted into the initial sample, although multiple cases from a random group can be selected as replicates if specified. By default hierarchical 
	serpentine sorting is assumed under sys or rsz sampling. If the measure of size (MOS) is provided, it draws the sample with probabilities proportional to size (PPS).{p_end}

{title:Examples}

{pstd}Draw a stratified srs, sys, and rsz sample from the {it:auto} data set (Note: You can click on each line below to run it in STATA.){p_end}
{phang2}{stata webuse auto,clear}{p_end}
{phang2}{stata gen samplesize=4 if foreign==1}{p_end}
{phang3}{stata replace samplesize=8 if foreign==0}{p_end}
{phang2}{stata rsz,strsamsize(samplesize) ranseed(5110652) replicates(1) alt(srs) strata(foreign) }{p_end}
{phang2}{stata rsz,strsamsize(samplesize) ranseed(5110652) replicates(1) alt(sys) strata(foreign) sorting(rep78 headroom make)}{p_end}
{phang2}{stata rsz,strsamsize(samplesize) ranseed(5110652) replicates(1) strata(foreign) sorting(rep78 headroom make)}{p_end}

{pstd}Draw another rsz sample with two replicates.{p_end}
{phang2}{stata rsz,strsamsize(samplesize) ranseed(5110652) replicates(2) strata(foreign) sorting(rep78 headroom make)  exprr(0.5) }{p_end}

{title:Technical Notes}

{pstd}
The program will create deep strata {it:_rszzone} based on the sorted list. The number of deep strata (or zones) will be about half of the desired number of completes. Each deep stratum (or zone) 
	will be randomly split into groups.{break}
Due to nonresponse, a certain stratum may not have at least two responding units for variance estimation purpose. Although it is not ideal, the common practice is to combine the neighboring strata at the estimation stage to ensure that
	every stratum has at least responding units. When sampling with an assumed response rate of 1 under the rsz sampling method, generally the rsz sample only include two cases in each deep stratum {it:_rszzone} for release. This may 
	lead to an undesired consequence of combining many strata at the estimation stage if the response rate is low. There are two ways to reduce or avoid this problem:{p_end}
{phang}
	{space 1}1. Specify an expected response rate in the option {it:exprr}. For example, if you specify an expected response rate of 0.5, the rsz sample will include 
	four cases in each deep stratum {it:_rszzone} for release.{p_end}
{phang}	
	{space 1}2. Specify the number of replicates that will be released in sequence for any random group {it:_rszgroup} without a respondent after exhausting a predetermined contact procedure. In practice the data collection window 
	may not allow many sequential releases due to time constraints. A combination of an expected response rate and the number of replicates can be specified to make sure you only specify the number of replicates the data collection window 
	allows while reducing the problem of combining many strata at the estimation stage. The program will calculate the number of random groups in each zone using this formula:{break}
	{space 6} {it:zonesize=2*(1-(1-exprr)^replicates)} {break}
	where {it:exprr} is the expected response rate and {it:replicates} is the number of replicates the data collection window allows, zonesize is calculated from the formula as the sample size to be released in each of 
	your explicate strata. Due to rounding for integer sample sizes, the total calculated sample size may not be exactly as you desire, you can force it to be your desired total
	by specifying the option {it:desiredinitial}. For example, if you would like to force the total calculated sample size to be 100, specify the option {it:desiredinitial(100)}. Also, if you have done the calculation yourself 
	and the sample size in {it:strsamsize} already contains the calculated sample size to be released in each stratum, you can specify the option {it:inflatedsamsize(Y)} to inform the program. A final note: If you would like to 
	sample extra replicates in addition to what you already requested in the option {it:replicates} just in case your assumptions about expected response rate and number of sequential releases allowed are not accurate, you can 
	specify extra replicates in the option {it:extra}.{p_end}

{title:References}

{pstd}Singh, A.C. and Ye, C. (2016). Randomly Split Zones for Samples of Size One as Reserve Replicates and Random Replacements 
	for Nonrespondents, {it:Proceedings of the American Statistical Association, Survey Research Methods Section}.{p_end}

{title:Disclaimer}

{pstd}This software is provided 'as-is', without any express or implied warranty. In no event will the author be held liable 
	for any damages arising from the use of this software.

{title:Suggested Citation}

{pstd}Ye, C. (2017). Stata module rsz: Draw a stratified simple random sample, a systematic sample, or a randomly split zones sample, 
	with probabilities proportional to size. Version 1.0. {p_end}

{title:Author}

{pstd}Cong Ye, Ph.D.{p_end}
{pstd}Center for Survey and Data Sciences{p_end}
{pstd}American Institutes for Research{p_end}
{pstd}cye@air.org{p_end}
