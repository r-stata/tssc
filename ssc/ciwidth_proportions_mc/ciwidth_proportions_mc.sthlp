{smcl}
{* *! version 1  2019-11-29}{...}

{vieweralsosee "[PSS-3] ciwidth" "help ciwidth"}{...}
{vieweralsosee "[PSS-3] ciwidth, graph" "help ciwidth graph"}{...}
{vieweralsosee "[PSS-3] ciwidth, table" "help ciwidth table"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[PSS-2] power twoproportions" "help power twoproportions"}{...}
{vieweralsosee "[PSS-5] Glossary" "help pss_glossary"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] epitab" "help cs"}{...}
{viewerjumpto "Syntax" "ciwidth proportions_mc##syntax"}{...}
{viewerjumpto "Description" "ciwidth proportions_mc##description"}{...}
{viewerjumpto "Options" "ciwidth proportions_mc##options"}{...}
{viewerjumpto "Remarks" "ciwidth proportions_mc##remarks"}{...}
{viewerjumpto "Examples" "ciwidth proportions_mc##examples"}{...}
{viewerjumpto "Stored results " "ciwidth proportions_mc##results"}{...}
{viewerjumpto "Author" "ciwidth proportions_mc##author"}{...}
{p2colset 1 29 31 2}{...}
{p2col:{bf:ciwidth proportions_mc} {hline 2}}Precision and power analysis for a CI-based comparison of two independent proportions (RD, RR, or OR){p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}

Precision analysis:

{pstd}
Compute CI width

{p 8 16 2}
{opt ciwidth} {cmd:proportions_mc,}
{opth probw:idth(numlist)}
{opth p1(numlist)}
{it:nspec}
[{help ciwidth proportions_mc##options_table:{it:options}}]


{pstd}
Compute probability of CI width

{p 8 16 2}
{opt ciwidth} {cmd:proportions_mc,}
{opth w:idth(numlist)}
{opth p1(numlist)}
{it:nspec}
[{help ciwidth proportions_mc##options_table:{it:options}}]

{pstd}

Power analysis:

{pstd}
Compute power focusing on lower bound of CI 

{p 8 16 2}
{cmd:ciwidth} {cmd:proportions_mc,}
{opth lbgt(numlist)}
{cmd:table(lbgt power, add)}
{opth p1(numlist)}
{it:nspec}
[{help ciwidth proportions_mc##options_table:{it:options}}]


{pstd}
Compute power focusing on upper bound of CI 

{p 8 16 2}
{cmd:ciwidth} {cmd:proportions_mc,}
{opth ublt(numlist)}
{cmd:table(ublt power, add)}
{opth p1(numlist)}
{it:nspec}
[{help ciwidth proportions_mc##options_table:{it:options}}]


{phang}
{it:nspec} specifies N1 and N2 using a combination of {opth n(numlist)}, {opth n1(numlist)}, {opth n2(numlist)}, {opth nratio(numlist)} 


{marker options_table}{...}
{synoptset 30 tabbed}{...}
{synopthdr :options}
{synoptline}
{p2coldent:* {opth effecttype(numlist)}}Effect Size type; default is {cmd:effecttype(1)} = risk difference (RD). Alternatively, {cmd:effecttype(2)} = relative risk (RR), {cmd:effecttype(3)} = odds ratio (OR){p_end}

{syntab:Main}
{p2coldent:* {opth level(numlist)}}two-sided confidence level; default is {cmd:level(95)}{p_end}
{p2coldent:* {opth probw:idth(numlist)}}probability of CI width; required to compute CI width{p_end}
{p2coldent:* {opth w:idth(numlist)}}CI width, i.e. CI_ub - CI_lb if effecttype(1); CI_ub / CI_lb if effecttype(2) or effecttype(3); required to compute probability of CI width{p_end}
{p2coldent:* {opth halfw:idth(numlist)}}CI half-width, i.e. CI_ub - observed RD if effecttype(1); CI_ub / observed RR if effecttype(2); CI_ub / observed OR if effecttype(3); can be specified in place of {cmd:width}{p_end}
{p2coldent:* {opth n(numlist)}}total sample size{p_end}
{p2coldent:* {opth n1(numlist)}}sample size of the control group{p_end}
{p2coldent:* {opth n2(numlist)}}sample size of the experimental group{p_end}
{p2coldent:* {opth nrat:io(numlist)}}ratio of sample sizes, {cmd:N2/N1}; default is {cmd:nratio(1)}, meaning equal group sizes{p_end}
{p2coldent:* {opth p1(numlist)}}is the proportion in the control (reference) group; required{p_end}
{p2coldent:* {opth p2(numlist)}}is the proportion in the experimental (comparison) group{p_end}
{p2coldent:* {opth trueeffectsize(numlist)}}difference between p2 and p1, i.e. p2-p1 if effecttype(1); p2/p1 if effecttype(2); p2(1-p1)/p1(1-p2) if effecttype(3){p_end}

{p2coldent:* {opth lbgt(numlist)}}compute power that CI_lb > specified value {p_end}
{p2coldent:* {opth ublt(numlist)}}compute power that CI_ub < specified value {p_end}

{syntab:Table}
{synopt :{opt tab:le}{cmd:(}{help ciwidth table##tablespec:{it:tablespec}}{cmd:)}}see {helpb ciwidth table:[PSS-3] ciwidth, table}{p_end}
{synopt :{cmdab:sav:ing(}{it:{help filename}} [{cmd:, replace}]{cmd:)}}save the table data to {it:filename}; use {opt replace} to overwrite existing {it:filename}{p_end}

INCLUDE help ciw_graphopts

{synopt :{opt par:allel}}treat number lists in starred options or in command arguments as parallel when multiple values per option or argument are specified (do not enumerate all possible combinations of values){p_end}
{synopt: {opt noti:tle}}suppress the title{p_end}
{synopt :{opt clear}}leave in memory all possible study results{p_end}
{synoptline}
{p 4 6 2}* Specifying a list of values in at least two starred options 
results in computations for all possible combinations of the values; see
{help numlist}.  Also see the {cmd:parallel} option.{p_end}

{marker tablespec}{...}
{pstd}
where {it:tablespec} is

{p 8 16 2}
{help ciwidth_proportions_mc##column:{it:column}}[{cmd::}{it:label}]
[{it:column}[{cmd::}{it:label}] [...]]
[{cmd:,} {help ciwidth table##tableopts:{it:tableopts}}]

{pstd}
{it:column} is one of the columns defined
{help ciwidth_proportions_mc##column:below}, and {it:label} is a column label (may
contain quotes and compound quotes).

{marker column}{...}
{synoptset 28}{...}
{synopthdr :column}
{synoptline}
{synopt :{cmd:ES_type}}effecttype; 1=RD, 2=RR, 3=OR{p_end}
{synopt :{cmd:level}}confidence level{p_end}
{synopt :{cmd:N}}total number of subjects{p_end}
{synopt :{cmd:N1}}number of subjects in the control group{p_end}
{synopt :{cmd:N2}}number of subjects in the experimental group{p_end}
{synopt :{cmd:nratio}}ratio of sample sizes, experimental to control{p_end}
{synopt :{cmd:p1}}the proportion in the control group{p_end}
{synopt :{cmd:p2}}the proportion in the experimental group{p_end}
{synopt :{cmd:true_ES}}numerical RD/RR/OR difference between p2 and p1{p_end}
{synopt :{cmd:Pr_width}}probability of CI width{p_end}
{synopt :{cmd:width}}CI width{p_end}
{synopt :{cmd:halfwidth}}CI halfwidth{p_end}
{synopt :{cmd:Pr_noCI}}probability of no CI calculated{p_end}
{synopt :{cmd:lbgt}}CI_lb > specified value{p_end}
{synopt :{cmd:ublt}}CI_ub < specified value{p_end}
{synopt :{cmd:power}}power{p_end}
{synopt :{cmd:_all}}display all supported columns{p_end}
{synoptline}
{p 4 6 2}Columns {cmd:nratio Pr_noCI lbgt ublt power} are NOT shown in the default table{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ciwidth proportions_mc} computes confidence interval (CI) width, and 
probability of CI width for a CI for a difference between two proportions 
from independent samples. See {helpb ciwidth:[PSS-3] ciwidth} for precision 
analysis for other CI methods.

{pstd}
{cmd:ciwidth proportions_mc} can also be used to do CI-based power calculations
 (see {helpb power_twoproportions:[PSS-2] power twoproportions}), 
 including non-inferiority power calculations.

{pstd}
N.B. The difference between two proportions can be quantified as the risk 
difference (RD), the relative risk (RR) or the odds ratio (OR). For the risk difference, 
I have expressed the width of the CI in the straightforward manner: 
width = CI_ub - CI_lb. For the relative risk or the odds ratio, 
I have expressed the width of the CI as a ratio: width = CI_ub / CI_lb, 
this naturally follows from the CIs first being calculated on the log scale before 
they are exponentiated.{p_end}


{marker options}{...}
{title:Options}

{marker mainopts}{...}
{dlgtab:Main}

{phang}
{opt level()}, {opt probwidth()}, {opt width()}, {opt n()}, {opt n1()}, {opt n2()}, {opt nratio()}, {opt parallel}, {opt notitle}; see {helpb ciwidth:[PSS-3] ciwidth}.

{phang}
{opt probwidth()}, {opt width()}, {opt halfwidth()}, {opt lbgt()}, {opt ublt()} ... must specify exactly one of these

{phang}
{opt p2()}, {opt trueeffectsize()} ... must specify exactly one of these


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ciwidth proportions_mc} begins by creating a dataset where each row represents a possible study result, 
e.g. row 1: 0 successes in the control group and 0 successes in the experimental group. 
N.B. This creates a dataset of size 1001 x 1001 = 1,002,001 if N1 = N2 = 1,000. Results could take some time for large studies. 

{pstd}
The probability of each study result occurring is then calculated (assuming p1, N1, p2, N2).

{pstd}
The methods described in {help cs} are used to construct CIs. For the odds ratio, the simple Woolf method (rather than the more involved default Cornfield method) is used. 
For rows where there are 0 successes in one group, no CI for RR can be constructed. 
For rows where there are 0 successes or 0 failures in one group, no CI for OR can be constructed. 
Only when a CI is calculated, does {cmd:ciwidth proportions_mc} compute CI width, probability of CI width, or power.
The probability that no CI is calculated is very often negligible, but it can be returned.

{pstd}
The dataset of all possible study results can be left in memory using {opt clear}.


{marker examples}{...}
{title:Examples}

    {title:Background. One possible study result - to show how definition of halfwidth and width vary according to RD/RR/OR}

{phang2}{sf:. }{stata "csi 20 40 80 60, or woolf"}{p_end}

{pstd}
	The observed proportions were 0.4 (40/100) in the control group and 0.2 (20/100) in the experimental group. Therefore,{p_end}

{pstd}
	RD: Risk Difference = -0.2   (-0.32 to -0.08) -> width = CI_ub - CI_lb = 0.24. Note: 95% CI could be expressed as -0.2 +- 0.12{p_end}

{pstd}
	RR: Relative Risk   =  0.5   (0.32 to 0.79) -> width = CI_ub / CI_lb = 2.51. Note: 95% CI could be expressed as 0.5 ×/ 1.58{p_end}

{pstd}
	OR: Odds ratio      =  0.375 (0.20 to 0.71) -> width = CI_ub / CI_lb = 3.54. Note: 95% CI could be expressed as 0.375 ×/ 1.88{p_end}

    {title:Examples A: Computing CI width}

{pstd}	
	Describe the width of a two-sided 95% CI that will arise from a 
	study comparing proportions between two equally-sized groups (total 
	sample size 200), assuming the underlying true proportions 
	are 0.4 in the control group and 0.2 in the experimental group.{p_end}

{pstd}	
	For the risk difference,{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) p2(0.2) probwidth(0.025 0.25 0.5 0.75 0.975)"}{p_end}	
{pstd}    
	For the relative risk,{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) p2(0.2) probwidth(0.025 0.25 0.5 0.75 0.975) effecttype(2)"}{p_end}

{pstd}	 For the odds ratio,{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) p2(0.2) probwidth(0.025 0.25 0.5 0.75 0.975) effecttype(3)"}{p_end}

{pstd}	
	All possible study results can be left in memory using the option {opt clear}{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n1(134) n2(134) p1(0.8) p2(0.6) probwidth(0.25 0.5 0.75) clear"}{p_end}

{pstd}
	Here is the study result in {cmd: Background}:{p_end}
{phang2}{sf:. }{stata "list if c1 == 40 & c2 == 20, abbreviate(20)"}{p_end}	
{pstd}	
	To reproduce mean halfwidth of 0.11 in example on p92 https://www.power-analysis.com/pdfs/power_precision_manual.pdf{p_end}
{phang2}{sf:. }{stata "summarize rd_halfwidth [aweight = probc2c1], detail"}{p_end}

    {title:Examples B: Computing probability of CI width}

{pstd}	
	Similar to Examples A. {cmd:halfwidth()} is specified below, but it is fine to instead specify {cmd:width()}{p_end}

{pstd}	
	For the risk difference,{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) p2(0.2) halfwidth(0.125)"}{p_end}	
{pstd}    
	For the relative risk,{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) p2(0.2) halfwidth(2) effecttype(2)"}{p_end}

{pstd}	
	For the odds ratio,{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) p2(0.2) halfwidth(2) effecttype(3)"}{p_end}

    {title:Example C: How CI width varies with N (graph)}

{pstd}	
	The (median) CI width may not always decrease as sample size increases, 
	as we see in this example, because of the discrete nature of the 
	binomial distribution{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(26 (2) 32) p1(0.2) p2(0.5) probwidth(0.5) graph(xsize(10))"}{p_end}

    {title:Examples D: How CI width varies with underlying true proportions}

{pstd}	
	Holding constant p1, and varying the true effect size:{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) effecttype(1) trueeffectsize(-0.2 (0.1) 0) probwidth(0.5)"}{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) effecttype(2) trueeffectsize(0.5 (0.25) 1) probwidth(0.5)"}{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) effecttype(3) trueeffectsize(0.375 0.65 1) probwidth(0.5)"}{p_end}

{pstd}	
	Varying p1, and holding constant the true effect size:{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.25 0.4 0.6) effecttype(1) trueeffectsize(-0.2)  probwidth(0.5)"}{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.25 0.4 0.6) effecttype(2) trueeffectsize(0.5)   probwidth(0.5)"}{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.25 0.4 0.6) effecttype(3) trueeffectsize(0.375) probwidth(0.5)"}{p_end}

    {title:Example E: Probability no CI can be calculated}

{pstd}	
	By default, this information is not displayed. It has to be asked for. 
	Calculations of width etc. are made based only on study results where a CI can be calculated{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(20) p1(0.5) p2(0.5) probwidth(0.5) effecttype(1 2 3) table(Pr_noCI, add)"}{p_end}

    {title:Examples F: How observed ciwidth relates to observed effect size (not true for means)}

{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) p2(0.2) probwidth(0.5) effecttype(1) clear"}{p_end}
{phang2}{sf:. }{stata "collapse (sum) probc2c1, by(rd_width rd)"}{p_end}
{phang2}{sf:. }{stata "scatter rd_width rd [aweight = probc2c1]"}{p_end}

{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) p2(0.2) probwidth(0.5) effecttype(2) clear"}{p_end}
{phang2}{sf:. }{stata "collapse (sum) probc2c1, by(logrr_width logrr)"}{p_end}
{phang2}{sf:. }{stata "scatter logrr_width logrr [aweight = probc2c1], msize(vsmall)"}{p_end}


{pstd}The next examples are CI-based power analysis. By default, power is not displayed. 
It has to be asked for using the option {opt table()}. true_ES, halfwidth & width are no longer relevant as the program is
 focussing on the upper or lower bound of the CI now in relation to a cutpoint, 
 and not the difference between the two bounds.{p_end}

    {title:Examples G [Power]: Non-inferiority CI-based power calculation}

{pstd}	
	Answers should be similar to those given by the user-written program {cmd: ssi}, 
	which uses a normal approximation. {cmd: ciwidth proportions_mc} is flexible 
	enough for power to be calculated in situations other than p1=p2.  {p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(400) p1(0.15) p2(0.15) lbgt(-0.1) table(level N N1 N2 p1 p2 true_ES ES_type lbgt power)"}{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(400) p1(0.15) p2(0.15) ublt(0.1) table(level N N1 N2 p1 p2 true_ES ES_type ublt power)"}{p_end}
{phang2}{sf:. }{stata "ssc install ssi"}{p_end}
{phang2}{sf:. }{stata "ssi 0.15 0.1, alpha(0.025) n(200) noninferiority"}{p_end}

    {title:Examples H [Power]: Usual (superiority) CI-based power calculation}

{pstd}	
	Answers should be similar to those given by {cmd: power twoproportions}, 
	which uses a complicated equation{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.2) p2(0.4) effecttype(1) lbgt(0.000001) table(lbgt power, add)"}{p_end}
{phang2}{sf:. }{stata "ciwidth proportions_mc, n(200) p1(0.4) p2(0.2) effecttype(1) ublt(0.000001) table(ublt power, add)"}{p_end}
{phang2}{sf:. }{stata "power twoproportions 0.4 0.2, n(200) test(chi2)"}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ciwidth proportions_mc} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt :{cmd:r(level)}}confidence level{p_end}
{synopt :{cmd:r(alpha)}}significance level{p_end}
{synopt :{cmd:r(onesided)}}{cmd:0} two-sided CI{p_end}
{synopt :{cmd:r(N)}}total sample size{p_end}
{synopt :{cmd:r(N1)}}sample size of the control group{p_end}
{synopt :{cmd:r(N2)}}sample size of the experimental group{p_end}
{synopt :{cmd:r(nratio)}}ratio of sample sizes, {cmd:N2/N1}{p_end}
{synopt :{cmd:r(p1)}}proportion in the control group{p_end}
{synopt :{cmd:r(p2)}}proportion in the experimental group{p_end}
{synopt :{cmd:r(true_ES)}}numerical RD/RR/OR difference between p2 and p1{p_end}
{synopt :{cmd:r(ES_type)}}effecttype 1=RD, 2=RR, 3=OR{p_end}
{synopt :{cmd:r(Pr_width)}}probability of CI width{p_end}
{synopt :{cmd:r(width)}}CI width{p_end}
{synopt :{cmd:r(halfwidth)}}CI halfwidth{p_end}
{synopt :{cmd:r(Pr_noCI)}}probability of no CI calculated{p_end}
{synopt :{cmd:r(lbgt)}}CI_lb > specified value, if lbgt() specified){p_end}
{synopt :{cmd:r(ublt)}}CI_ub < specified value, if ublt() specified{p_end}
{synopt :{cmd:r(power)}}power, if lbgt() or ublt() specified{p_end}
{synopt :{cmd:r(separator)}}number of lines between separator lines in the
table{p_end}
{synopt :{cmd:r(divider)}}{cmd:1} if {cmd:divider} is requested in the table,
{cmd:0} otherwise{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt :{cmd:r(type)}}{cmd:ci}{p_end}
{synopt :{cmd:r(method)}}{cmd:proportions_mc}{p_end}
{synopt :{cmd:r(columns)}}displayed table columns{p_end}
{synopt :{cmd:r(labels)}}table column labels{p_end}
{synopt :{cmd:r(widths)}}table column widths{p_end}
{synopt :{cmd:r(formats)}}table column formats{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt :{cmd:r(pss_table)}}table of results{p_end}
{p2colreset}{...}


{marker author}{...}
{title:Author}

{p 4 4 2}
Mark Chatfield, The University of Queensland, Australia.{break}
m.chatfield@uq.edu.au{break}
