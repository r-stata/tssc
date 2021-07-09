{smcl}
{* *! version 0.1.2  2017-04-20}{...}
{viewerjumpto "Syntax" "ic##syntax"}{...}
{viewerjumpto "Description" "ic##description"}{...}
{viewerjumpto "Options for ic" "ic##options_ic"}{...}
{viewerjumpto "Options for ici" "ic##options_ici"}{...}
{viewerjumpto "Examples" "ic##examples"}{...}
{viewerjumpto "Stored results" "ic##results"}{...}
{viewerjumpto "References" "ic##references"}{...}


{title:Title}
{p2colset 5 10 22 2}{...}
{p2col :}
Measures of interaction contrast (biological interaction) - ic, ici and icp
{p_end}
{p2colreset}{...}


{title:Summary}
{p2colset 5 10 10 2}{...}
{p2col :}It has become more common to investigate not only single factors effect 
on a outcome but also to look at the interaction between factors, as is 
facilitated by the last decades massive increase in computer resources to 
gather and analyses large databases. Several approaches haves been promoted.{p_end}

{p2col :}For the analyzes of binary (or count) data, a fairly well established 
position holds, that loglinear models estimating measures of relative risk type 
represent a convenient choice, whereas interactions are often best interpreted 
if estimated on a linear/additive scale. {p_end}

{p2col :}This code implement the procedure described in 
{help ic##HL1992:Hosmer & Lemeshow (1992)} and 
{help ic##A2005:Alfredsson et all (2005)} purely in Stata. {p_end}

{p2col :}These two sources however both uses odds ratios as approximations for 
relational risks. This code on the other hand opens up for using proper 
estimates of relational risks.
{p2colreset}{...}


{title:Authors and support}

{phang}{bf:Author:} 	Niels Henrik Bruun, 
						Section for General Practice, 
						Dept. Of Public Health, 
						Aarhus University
{p_end}
{phang}{bf:Coauthor:} 	Morten Fenger-Grøn, 
						Research Unit for General Practice, 
						Aarhus University
{p_end}
{phang}{bf:Coauthor:} 	Anders Prior, 
						Research Unit for General Practice, 
						Aarhus University
{p_end}
{phang}{bf:Support:} nhbr@ph.au.dk{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}{cmd:ic} {it:varlist (min=3)} 
	[{cmd:,} {it:{help ic##ic_options:ic_options}}]

{p 8 14 2}{cmd:ici} {it:matrix_estimates matrix_variance} 
			[{it:macro_with_3_labels}]

{p 8 14 2}{cmd:icp} [{it:{help ic##ic_options:icp_options}}] {cmd::} 
			{it:regression_model_to_estimate_relative_risks} 
	

{synoptset 24 tabbed}{...}
{marker ic_options}{...}
{synopthdr:ic_options}
{synoptline}
{synopt :{opt referenceA}}The reference value for the first variable in the interaction.{break} Default is 0.{p_end}
{synopt :{opt referenceB}}The reference value for the second variable in the interaction.{break} Default is 0.{p_end}
{synopt :{opt exposedA}}The exposed value for the first variable in the interaction.{break} Default is 1.{p_end}
{synopt :{opt exposedB}}The exposed value for the second variable in the interaction.{break} Default is 1.{p_end}
{synopt :{opt show|SHOW}}Show the underlying regression estimating the relative risks.{break} Default is no show.{break}The option show doesn't remove the dummy variables used in the regression. This way the regression is reproducible.{p_end}
{synopt :{opt rrby}}Indicate which estimation method to use for estimating 
adjusted RRs, see {help ic##C2009:Cummings (2009)}. {break}
The following methods are implemented:{break}
	* {bf:or} the classical method using logistic regression to approximate RRs with ORs as described in {help ic##A2005:Alfredsson et all (2005)} (default){break}
	* {bf:poisson} estimating RRs by robust poisson regression (see Method 4 in {help ic##C2009:Cummings (2009)}{break}
	* {bf:binomial} using binomial regression with initiating estimates from a poisson regression for the RR estimates (see Method 2 in {help ic##C2009:Cummings (2009)}{break}
{p_end}{synoptline}
{p2colreset}{...}

{synoptset 24 tabbed}{...}
{marker icp_options}{...}
{synopthdr:icp_options}
{synoptline}
{synopt :{opt referenceA}}The reference value for the first variable in the interaction.{break} Default is 0.{p_end}
{synopt :{opt referenceB}}The reference value for the second variable in the interaction.{break} Default is 0.{p_end}
{synopt :{opt exposedA}}The exposed value for the first variable in the interaction. Default is 1.{p_end}
{synopt :{opt exposedB}}The exposed value for the second variable in the interaction.{break} Default is 1.{p_end}
{synopt :{opt show|SHOW}}Show the underlying regression estimating the relative risks.{break} Default is no show.{break}The option show doesn't remove the dummy variables used in the regression.{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}Tool for calculating 3 different measures of interaction contrast 
(biological interaction) on an additive scale:  relative excess risk due to 
interaction [RERI], attributable proportion [AP] and synergy index [S].
{p_end}

{pstd}Corresponding 95% confidence intervals aand two-tailed tests for no 
interaction (RERI=0, AP=0, S=1, respectively) are given as well.{p_end}

{pstd}Assume that we want to analyze the effects of 2 dichotome factors, A and
 B, on a dichotome outcome Y.
Define Pij as the average risk (the incidence proportion) when A = i and B = j,
i = 0,1 and j = 0,1.{break}
And define the relative risk as RRij = Pij / P00.{p_end}

{pstd}The biological interaction measures is defined as{break}
* RERI = RR11 - RR10 - RR01 - 1{break}
* AP = RERI / R11 {break}
* S = (RR11 - 1) / (RR10 + RR01 - 2){break}
{p_end}{pstd}
{help ic##V2014:VanderWeele (2014)} {help ic##R2008:Rothman (2008)}.{p_end}

{pstd}The estimation/approximation of the RRs are described in
{help ic##HL1992:Hosmer & Lemeshow (1992)} {help ic##A2005:Alfredsson et all (2005)}, 
{help ic##C2009:Cummings (2009)} and {help ic##V2014:VanderWeele (2014)}.

{dlgtab 4:Understanding biological interaction}
{pstd}Below are some (sometimes slightly modified) quotes to help understand 
biological interaction.{p_end}

{pstd}The term statistical interaction is intended to denote the 
interdependence between the effects of two or more factors within the confines 
of a given model of risk. The evaluation of interaction depends on the model 
chosen. ({help ic##R1980:Rothman (1980)}){p_end}

{pstd}Biologic interaction may be defined as the interdependent operation of 
two or more causes to produce disease. ({help ic##R1980:Rothman (1980)}){p_end}

{pstd}Although we may not be able to estimate the additive interaction, i.e. 
p11 - p10 - p01 + p00, directly, we can still proceed as follows. {break}
If we divide by p00 we obtain the following: RERI = RR11 - RR10 - RR01 + 1" 
{help ic##V2014:VanderWeele (2014)}{p_end}

{pstd}"However, again, only the direction, rather than the magnitude, of RERI is 
needed to draw conclusions about the public health relevance of interaction.
 {help ic##V2014:VanderWeele (2014)}{p_end}

{pstd}Another measure of additive interaction that is sometimes used is called 
the attributable proportion and is defined as: AP = RERI / RR11 and essentially 
measures the proportion of the risk in the doubly exposed group that is due to 
the interaction itself. {help ic##V2014:VanderWeele (2014)}{p_end}

{pstd}"The logistic regression model and the Cox regression model are probably 
the most commonly used statistical models in epidemiologic analysis to day.{break} 
Because these models are exponential they are inherently multiplicative and 
become additive only after logarithmic transformation. {break}
Thus, absence of an interaction term in such a model implies a multiplicative 
relation between the disease rates and the presence of an interaction term 
implies departure from multiplicativity, rather than from additivity. {break}
Therefore, the interaction term, in one of these models, has no direct 
relevance for the issue of whether or not biological interaction is present.{break} 
However, the presence of biological interaction can still be asessed from the 
results of a logistic regression model or a Cox regression model, but this 
requires that the model is defined in a special way and that the analysis is 
done adequately." {help ic##A2005:Alfredsson et all (2005)}{p_end}

{pstd}"In this study we showed that calculating measures of interaction on an 
additive scale using preventive factors can give inconsistent results.{break} 
Researchers should therefore be aware to not use preventive factors to 
calculate these measures unless they have been recoded." 
{help ic##K2011:Knol et all (2011)}{p_end}

{dlgtab 4:ic}
{pstd}Given a variable list staring with outcome, factor A, factor B end 
possibly some adjustment variables for the regression the ic estimates the RR
for A, B, the interaction between A and B, RERI, AP and S as well as their 95%
confidence intervals.{p_end}

{pstd}Note that the interaction term is automatically created
based on variable 2 and variable 3 (outcome is variable number 1) in the 
regression.{p_end}

{dlgtab 4:ici}
{pstd}The immediate form of ic. Requires a 1 by 3 or 3 by 1 matrix 
containing the logs of the RRs and their 3 by 3 covariance matrix as input. 
A local containing labels like "labelA labelB labelAB" is optional.{p_end}

{dlgtab 4:icp}
{pstd}This is the advanced prefix form letting the user define regression 
settings to use to get estimates of log relative risks to use interaction 
contrast.{p_end}

{pstd}Note that the interaction term is automatically created
based on variable 2 and variable 3 (outcome is variable number 1) in the 
regression.{p_end}

{pstd}Also note that {cmd:icp} only accepts logistic, logit, binreg, nbreg, 
poisson or stcox (stcox needs a stset first) as regression inputs. {break}
The key point for the regression is that it must produce estimates or at least 
approximations to relative risks.{p_end}


{marker examples}{...}
{title:Examples}

	{help ic##example_1:Code for generating example data}
	{help ic##example_2:The essential output from icp, ici and ic}
	{help ic##example_3:Prefix icp and how it works}
	{help ic##example_4:ici and how it works}
	{help ic##example_5:ic and how it works}
	{help ic##example_6:Using ic on the rheumatoid arthritis dataset}
	{help ic##example_7:Using icp with stcox}


{marker example_1}{...}
{dlgtab 4:Code for generating example data}

	{pstd}Below is code to generate datasets to use in the examples.{p_end}
	{pstd}To reproduce the datasets just copy the whole code blocks into the 
	command window and press enter.{p_end}

    {title:The oral cancer dataset}
	{pstd}To get the example data run the following code:{p_end}

	
		{cmd:. clear all}
		{cmd:. capture cls // Cls only work in Stata 13}
		{cmd:. input alcohol smoking cancer count}
		{cmd:0 0 0 20}
		{cmd:0 0 1 3}
		{cmd:0 1 0 18}
		{cmd:0 1 1 8}
		{cmd:1 0 0 12}
		{cmd:1 0 1 6}
		{cmd:1 1 0 166}
		{cmd:1 1 1 225}
		{cmd:end}
		{cmd:* Expand the dataset (You can't use weights in ic):}
		{cmd:. expand count}
		{cmd:. drop count}
		{cmd:* And add labels and label values:}
		{cmd:. label variable alcohol "Alcohol use"}
		{cmd:. label variable smoking "Smoker"}
		{cmd:. label variable cancer "Oral cancer"}
		{cmd:. label define no_yes 0 "No" 1 "Yes"}
		{cmd:. label define cc 0 "Controls" 1 "Cases"}
		{cmd:. label values alcohol no_yes}
		{cmd:. label values smoking no_yes}
		{cmd:. label values cancer cc}
		{cmd:* And hence the dataset is (Table 1 transposed, more or less):}
		{cmd:. table smoking cancer alcohol}
		

{pstd}This is the example dataset from {help ic##HL1992:Hosmer & Lemeshow (1992)}.
The data concerns smoking and alcohol use in relation to oral cancer among male 
veterans under age 60.{p_end}


    {title:The rheumatoid arthritis dataset}
	{pstd}To get the example data run the following code:{p_end}

	
		{cmd:. clear all}
		{cmd:. capture cls // Cls only work in Stata 13}
		{cmd:. input se sex smoke ra count}
		{cmd:0 0 0 0 73}
		{cmd:0 0 0 1 63}
		{cmd:0 0 1 0 43}
		{cmd:0 0 1 1 44}
		{cmd:0 1 0 0 13}
		{cmd:0 1 0 1 16}
		{cmd:0 1 1 0 17}
		{cmd:0 1 1 1 16}
		{cmd:1 0 0 0 75}
		{cmd:1 0 0 1 98}
		{cmd:1 0 1 0 46}
		{cmd:1 0 1 1 79}
		{cmd:1 1 0 0 29}
		{cmd:1 1 0 1 29}
		{cmd:1 1 1 0 11}
		{cmd:1 1 1 1 28}
		{cmd:2 0 0 0 25}
		{cmd:2 0 0 1 40}
		{cmd:2 0 1 0 11}
		{cmd:2 0 1 1 47}
		{cmd:2 1 0 0 6}
		{cmd:2 1 0 1 9}
		{cmd:2 1 1 0 3}
		{cmd:2 1 1 1 16}
		{cmd:end}
		{cmd:* Expand the dataset (You can't use weights in ic):}
		{cmd:. expand count}
		{cmd:. drop count}
		{cmd:* Add labels and label values:}
		{cmd:. label variable se "SE genes"}
		{cmd:. label variable sex "Sex"}
		{cmd:. label variable smoke "Smoking"}
		{cmd:. label variable ra "Rheumatoid arthritis"}
		{cmd:. label define se 0 "No SE" 1 "Single SE" 2 "Double SE"}
		{cmd:. label values se se}
		{cmd:. label define sex 0 "Women" 1 "Men"}
		{cmd:. label values sex sex}
		{cmd:. label define smoke 0 "Never smokers" 1 "Current Smokers"}
		{cmd:. label values smoke smoke}
		{cmd:. label define ra 0 "No RA" 1 "RA"}
		{cmd:. label values ra ra}
		{cmd:* And hence the table 4 can be reproduced by}
		{cmd:. egen col = group(se ra), label}
		{cmd:. egen row = group(sex smoke), label}
		{cmd:. table row col}

		
{pstd}Table 4 in {help ic##P2004:Padyukov et all (2004)}. Relative risk of 
developing rheumatoid arthritis among subjects exposed to different combinations 
of current cigarette smoking habits and SE genes and attributable proportion 
due to interaction between cigarette smoking and SE genes (single, double, 
or any), by sex.{p_end}

{help ic##examples:Back to examples}


{marker example_2}{...}
{dlgtab 4:The essential output from icp, ici and ic}

{pstd}The output (example below from {cmd:ic} with no labels set, compare with 
table 5 in {help ic##HL1992:Hosmer & Lemeshow (1992)}) starts with the 3 
relative risks used in the calculation of RERI, AP and S. Then comes the 
estimates of RERI, AP and S.{break}
Column 1 are the labels for the estimates, column 2 contains the estimates, 
column 3 contains the P-values for testing away the measure at hand versus the dual 
alternative (for S it is the P-value for testing S = 1).{p_end}

{pstd}The 2 final columns (4 and 5) are lower and upper bound in the 95% 
confidence interval. {break}
To reproduce the result below run the code from example 1
to generate the oral cancer dataset. {break}
Then run the following command:{p_end}

	{cmd:. ic cancer alcohol smoking, rrby(or)}

{pstd}And the output is:{p_end}
	
	+------------------------------------------------------------------------------+
	|            Summary measures | Estimates    P-value  Lower bound  Upper bound |
	|-----------------------------+------------------------------------------------|
	|         alcohol_NOT_smoking |    3.3333     0.1303       0.7006      15.8593 |
	|         smoking_NOT_alcohol |    2.9630     0.1480       0.6800      12.9097 |
	|         alcohol_AND_smoking |    9.0361     0.0005       2.6413      30.9131 |
	|-----------------------------+------------------------------------------------|
	|                        RERI |    3.7398     0.1887      -1.8367       9.3164 |
	|                          AP |    0.4139     0.0957      -0.0731       0.9008 |
	|                           S |    1.8705     0.2483       0.6460       5.4156 |
	+------------------------------------------------------------------------------+
			Interaction exists if RERI != 0 or AP != 0 or S != 1


{help ic##examples:Back to examples}


{marker example_3}{...}
{dlgtab 4:Prefix icp and how it works}

{pstd}Using the oral cancer dataset what is done is shown below. In the example
the log odds are estimated using a logistic regression with option coef.{p_end}

	{cmd:* Generate dummy variables for the regression:}
	{cmd:. generate marker = inlist(alcohol, 0, 1) & inlist(smoking, 0, 1)}
	{cmd:. generate ind11 = (alcohol == 1 & smoking == 1) if marker}
	{cmd:.  replace ind11 = 0 if !missing(alcohol, smoking) & !marker}
	{cmd:. generate ind10 = (alcohol == 1 & smoking == 0) if marker}
	{cmd:.  replace ind10 = 0 if !missing(alcohol, smoking) & !marker}
	{cmd:. generate ind01 = (alcohol == 0 & smoking == 1) if marker}
	{cmd:.  replace ind01 = 0 if !missing(alcohol, smoking) & !marker}
	{cmd:* The values 0 and 1 above can be changed by options in icp}
	{cmd:* Run the regression on the dummy variables:}
	{cmd:. logistic cancer ind10 ind01 ind11, coef}
	{cmd:* Get the log relative risk estimates from the regression:}
	{cmd:. matrix b = r(table)}
	{cmd:. matrix b = b[1, 1..3]}
	{cmd:* Get the variance from the regression:}
	{cmd:. quietly vce}
	{cmd:. matrix V = r(V)}
	{cmd:. matrix V = V[1..3, 1..3]}
	{cmd:* The data used ici is:}
	{cmd:. matlist (b', V)}
	{cmd:* Call ici with estimates:}
	{cmd:. ici b V }
	{cmd:* And clean up:}
	{cmd:. drop ind10 ind01 ind11 marker}
	{cmd:. matrix drop b V}

{pstd}This is much like the description in {help ic##HL1992:Hosmer & Lemeshow (1992)} 
and {help ic##A2005:Alfredsson et all (2005)}.
With the exception that their spreadsheet is replaced with the Stata command
{cmd:ici} which described further down. Instead of these commands the prefix
{cmd:icp} could have been used:{p_end}

	{cmd:. icp: logistic cancer alcohol smoking, coef}

{pstd}So in other words {cmd:icp} takes a regression command with at least 3 
variables and lets the first be the outcome, the next 2 variables be the factors 
used as base for the dummy variables and the rest of the variables are used for 
adjusting.{break}
And if the underlying regression is wanted then use the option show:{p_end}
 
	{cmd:. icp, show: logistic cancer alcohol smoking, coef}

{pstd}Note that the option show doesn't remove the dummy variables used in the 
regression.{p_end}
{pstd}If the calculation of the dummy variables should be based on other values
than 0 and/or 1 then use the options referenceA, referenceB, exposedA and/or 
exposedB.{p_end}

{pstd}So{p_end} 

	{cmd:. icp, referenceA(2) referenceB(3) exposedA(4) exposedB(5): logistic cancer alcohol smoking, coef}

{pstd}would be the same as the following dummy generating commands:{p_end}

	{cmd:. generate marker = inlist(alcohol, 2, 4) & inlist(smoking, 3, 5)}
	{cmd:. generate ind11 = (alcohol == 4 & smoking == 5) if marker}
	{cmd:.  replace ind11 = 0 if !missing(alcohol, smoking) & !marker}
	{cmd:. generate ind10 = (alcohol == 4 & smoking == 3) if marker}
	{cmd:.  replace ind10 = 0 if !missing(alcohol, smoking) & !marker}
	{cmd:. generate ind01 = (alcohol == 2 & smoking == 5) if marker}
	{cmd:.  replace ind01 = 0 if !missing(alcohol, smoking) & !marker}
 
{pstd}Please note that this might lead to a nonsense regression.{p_end}

{pstd}Of course it is possible to chose your own regression after icp, eg:{p_end}

	{cmd:. icp: poisson cancer alcohol smoking, irr vce(robust)}
	
	or
	
	{cmd:. icp: binreg cancer alcohol smoking, rr}

{pstd}However {cmd:icp} only accepts logistic, logit, binreg, nbreg, poisson or 
stcox (stcox needs a stset first) as regression inputs. The key point for the 
regression is that it must produce estimates or at least approximations to 
relative risks.{p_end}

{help ic##examples:Back to examples}


{marker example_4}{...}
{dlgtab 4:ici and how it works}

{pstd}{cmd:ici} can be used in interactively much the same way as the spreadsheet
in {help ic##A2005:Alfredsson et all (2005)}.{break}
It takes 3 estimates of the log relational risk (or approximating odds ratio) as 
first argument in a row or column vector (matrix), second argument is the 
3 by 3 variance matrix and finally (and optionally) labels to use in the output. {break}
So if 2 matrices and a macro for labels are defined as:{p_end}

	{cmd:. matrix b = 1.2039728, 1.0861898, 2.2012326}
	{cmd:. matrix V = .63333333, .38333333, .38333333}
	{cmd:. matrix V = V \ .38333333, .56388889, .38333333}
	{cmd:. matrix V = V \ .38333333, .38333333, .39380187}

	{cmd:. local labels "alcohol_NOT_smoking smoking_NOT_alcohol alcohol_AND_smoking"}

{pstd}Note that matrix b can b either a row or a column vector. {break}
Also one can enter a matrix as a string argument right away. {break}
So the call of {cmd:ici} could be:
{p_end}
	
	{cmd:. ici b V}
	
	or	
	
	{cmd:. ici "1.2039728, 1.0861898, 2.2012326" V "`labels'"}

{pstd}So the parameter label is optional.{p_end}
	
{help ic##examples:Back to examples}


{marker example_5}{...}
{dlgtab 4:ic and how it works}

{pstd}{cmd:ic} is probably how most would like to use the code. Based on 
{help ic##C2009:Cummings (2009)} it offers some standard ways of estimating 
relative risks using {cmd:ic}. This example is based on the oral cancer 
dataset.{p_end}


{pstd}The command below perform the calculations based on odds ratio estimates
, option rrby(or), and show, option show, the underlying regression output:{p_end}
	{cmd:. ic cancer alcohol smoking, show rrby(or)}

{pstd}This is the classical method (and the default).{p_end}
	
{pstd}Here the poisson regression is used as a base for the relative risk 
estimates, option rrby(poisson). Also the controls and the cases are reversed 
for smoking, options referenceB(1) exposedB(0):{p_end}
	{cmd:. ic cancer alcohol smoking, referenceB(1) exposedB(0) rrby(poisson)}
	
{pstd}According to eg {help ic##C2009:Cummings (2009)} the poisson regression
makes robust estimates of the relative risks. However it tends to give too wide
confidence intervals.{p_end}

{pstd}Finally there is a stable estimation, option rrby(binomial), of the 
relative risks using estimates from a similar poisson regression as initiation 
for the binomial regression.{p_end}
	{cmd:. ic cancer alcohol smoking, rrby(binomial)}

{pstd}The binomial regression should give better estimates of the confidence 
intervals. But the algorithm isn't as stable. Hence we initiate with point
estimates from a similar poisson regression.{p_end}

{pstd}Note that if alcohol had eg 3 levels (eg 0 "No" 1 "Moderate" 2 "Extreme").
Then the interaction estimates for "No" (reference) versus "Moderate" (exposed)
would be the traditional usage of {cmd:ic}:{p_end}

	{cmd:. ic cancer alcohol smoking}

{pstd}And then the interaction estimates for "No" (reference, default = 0) 
versus "Extreme" (exposed) would be:{p_end}

	{cmd:. ic cancer alcohol smoking, exposedA(2)}

{help ic##examples:Back to examples}


{marker example_6}{...}
{dlgtab 4:Using ic on the rheumatoid arthritis dataset}

{pstd}In this example we look at a typical use of {cmd:ic}. First we need to run 
the code to get the rheumatoid arthritis dataset. {break}
Then we first need to generate a dichotome variable se2 of se to reproduce the 
result from {help ic##P2004:Padyukov et all (2004)}:{p_end}

	{cmd:. recode se (0=0 "No SE") (1 2 = 1 "SE"), generate(se2)}

{pstd}Note that we also want to adjust for sex in the calculations.So by 
running the following command one gets:{p_end}
	
	{cmd:. ic ra smoke se2 i.sex, rrby(or)}
	+------------------------------------------------------------------------------+
	|            Summary measures | Estimates    P-value  Lower bound  Upper bound |
	|-----------------------------+------------------------------------------------|
	|               smoke_NOT_se2 |    1.0843     0.7366       0.6766       1.7377 |
	|               se2_NOT_smoke |    1.4159     0.0724       0.9689       2.0693 |
	|               smoke_AND_se2 |    2.5999     0.0000       1.7206       3.9287 |
	|-----------------------------+------------------------------------------------|
	|                        RERI |    1.0997     0.0141       0.2217       1.9777 |
	|                          AP |    0.4230     0.0028       0.1461       0.6999 |
	|                           S |    3.1985     0.1310       0.7072      14.4658 |
	+------------------------------------------------------------------------------+
			Interaction exists if RERI != 0 or AP != 0 or S != 1              

{pstd}The factor smoke_AND_se2 is significantly different from 1 
(P-value = 0.0000), so there is a (statistical) multplicative interaction. 
And also by looking at RERI and AP there is a significant biological interaction 
(P-values are 0.0141 0.0028 respectively).{p_end}

{pstd}Now one could be interested in whether this result were the same if there
were a single SE gene present (exposed == 1):{p_end}

	{cmd:. ic ra smoke se i.sex, exposedB(1) rrby(or)}
	+------------------------------------------------------------------------------+
	|            Summary measures | Estimates    P-value  Lower bound  Upper bound |
	|-----------------------------+------------------------------------------------|
	|                smoke_NOT_se |    0.6815     0.0751       0.4468       1.0396 |
	|                se_NOT_smoke |    0.8339     0.2979       0.5923       1.1739 |
	|                smoke_AND_se |    1.2833     0.2112       0.8680       1.8975 |
	|-----------------------------+------------------------------------------------|
	|                        RERI |    0.7679     0.0044       0.2394       1.2965 |
	|                          AP |    0.5984     0.0004       0.2643       0.9325 |
	|                           S |         .          .            .            . |
	+------------------------------------------------------------------------------+
			Interaction exists if RERI != 0 or AP != 0 or S != 1              

{pstd}Here we note that values for S could not be calculated. This is due to estimates
being to big to exponentiate. However here is only a biological interaction 
present (P-values: smoke_AND_se=0.2112, RERI=0.0044, AP=0.0004).{p_end}
			
{pstd}Finally one could be interested in whether this result was the same if 
there was a double SE gene present (exposed == 2):{p_end}

	{cmd:. ic ra smoke se i.sex, exposedB(1) rrby(or)}
	+------------------------------------------------------------------------------+
	|            Summary measures | Estimates    P-value  Lower bound  Upper bound |
	|-----------------------------+------------------------------------------------|
	|                smoke_NOT_se |    0.7865     0.2336       0.5297       1.1677 |
	|                se_NOT_smoke |    1.2505     0.3613       0.7738       2.0208 |
	|                smoke_AND_se |    3.5467     0.0000       1.9412       6.4801 |
	|-----------------------------+------------------------------------------------|
	|                        RERI |    2.5097     0.0230       0.3467       4.6727 |
	|                          AP |    0.7076     0.0000       0.4579       0.9573 |
	|                           S |   68.8603     0.6664       0.0000   1.5604e+10 |
	+------------------------------------------------------------------------------+
			Interaction exists if RERI != 0 or AP != 0 or S != 1              
				  
{pstd}Once again the estimates leading to S have become to big. So they are to 
be ignored. Here there are both a multplicative and a biological interaction 
present (P-values: smoke_AND_se=0.0000, RERI=0.0230, AP=0.0000){p_end}


{help ic##examples:Back to examples}


{marker example_7}{...}
{dlgtab 4:Using icp with stcox}

{pstd}Cox regression is treated a bit different with icp. First the example 
data{p_end}

	{cmd:. use http://www.stata-press.com/data/r12/drugtr.dta, clear}
	{cmd:. egen age_grp = cut(age), group(2) label}

{pstd}Now {cmd:icp} can be used:{p_end}
	{cmd:. icp, show: stcox drug age_grp, nolog cformat(%7.3f)}

                 failure _d:  died
	   analysis time _t:  studytime

	Cox regression -- Breslow method for ties

	No. of subjects =           48                     Number of obs   =        48
	No. of failures =           31
	Time at risk    =          744
                                                           LR chi2(3)      =     27.98
	Log likelihood  =   -85.923498                     Prob > chi2     =    0.0000

	-----------------------------------------------------------------------------------
                       _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
	------------------+----------------------------------------------------------------
	_drug_NOT_age_grp |      0.107      0.069    -3.46   0.001        0.030       0.379
	_age_grp_NOT_drug |      1.967      0.927     1.44   0.151        0.782       4.952
	_drug_AND_age_grp |      0.254      0.137    -2.55   0.011        0.089       0.729
	-----------------------------------------------------------------------------------

	+------------------------------------------------------------------------------+
	|            Summary measures | Estimates    P-value  Lower bound  Upper bound |
	|-----------------------------+------------------------------------------------|
	|            drug_NOT_age_grp |    0.1072     0.0005       0.0303       0.3795 |
	|            age_grp_NOT_drug |    1.9675     0.1507       0.7818       4.9516 |
	|            drug_AND_age_grp |    0.2540     0.0108       0.0885       0.7286 |
	|-----------------------------+------------------------------------------------|
	|                        RERI |   -0.8207     0.3619      -2.5850       0.9437 |
	|                          AP |   -3.2315     0.3434      -9.9159       3.4529 |
	|                           S |         .          .            .            . |
	+------------------------------------------------------------------------------+
                      Interaction exists if RERI != 0 or AP != 0 or S != 1              


{help ic##examples:Back to examples}
   
	
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:icp} store the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(labels)}}The labels used in the output from {cmd:icp}{p_end}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(est)}}A column vector (3 x 1) containing the log estimates{p_end}
{synopt:{cmd:r(var)}}A  (3 x 3) matrix containing the variances{p_end}


{pstd}
{cmd:ici} and {cmd:ic} store the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(labels)}}The labels used in the output from {cmd:icp}{p_end}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(est)}}A column vector (3 x 1) containing the log estimates of the relative risks: RR10, RR01 and RR11.{p_end}
{synopt:{cmd:r(var)}}A (3 x 3) matrix containing the variances of the relative risks: RR10, RR01 and RR11{p_end}
{synopt:{cmd:r(output)}}A (5 x 5) matrix containing the data for the result table{p_end}

{marker references}{...}
{title:References}

{marker A2005}{...}
{phang}
Andersson T, Alfredsson L, Kallberg H, Zdravkovic S, Ahlbom A.
Calculating measures of biological interaction
Eur J Epidemiol. 2005;20(7):575-9.

{marker C2009}{...}
{phang}
Cummings, P., Methods for estimating adjusted risk ratios, Stata Journal",
Stata Press 9-2 2009, 175-196(22),
{browse "http://www.stata-journal.com/article.html?article=st0162":Link to pdf}

{marker HL1992}{...}
{phang}
Hosmer, David W., Lemeshow, Stanley, 
Confidence Interval Estimation of Interaction, 
Epidemiology, Vol. 3, No. 5 (Sep., 1992), pp. 452-456

{marker K2011}{...}
{phang}
Knol, Mirjam J., VanderWeele, Tyler J., Groenwold, Rolf H. H., Klungel, Olaf H.,
Rovers, Maroeska M., Grobbee, Diederick E. 
Estimating measures of interaction on an additive scale for preventive exposures
Eur J Epidemiol (2011) 26:433438 DOI 10.1007/s10654-011-9554-9

{marker P2004}{...}
{phang}
Padyukov L, Silva C, Stolt P, Alfredsson L, Klareskog L. 
A gene-environment interaction between smoking and shared epitope genes in 
HLA-DR provides a high risk of seropositive rheumatoid arthritis. 
Arthritis Rheum 2004; 50: 3085-3092.

{marker R1980}{...}
{phang}
Rothman, K. J., Greenland, S., and Walker, A. M. (1980),
Concepts of interaction;
American Journal of Epidemiology, 112:467470

{marker R2008}{...}
{phang}
Rothman Kenneth J., Lash Timothy L., Greenland Sander, 
Modern Epidemiology 3rd ed., 2008 Lippincott Williams & Wilkins, p. 74-83

{marker V2014}{...}
{phang}
VanderWeele T.J., Knol, M.J., A tutorial on interaction. 
Epidemiologic Methods, Published Ahead of Print May 27, 2014, 
DOI 10.1515/em-2013-0005,
{browse "https://cdn1.sph.harvard.edu/wp-content/uploads/sites/603/2013/03/InteractionTutorial.pdf":Link to pdf}
{p_end}
