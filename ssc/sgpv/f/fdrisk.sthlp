{smcl}
{* *! version 1.00  21 Mar 2020}{...}
{viewerdialog fdrisk "dialog fdrisk"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "SGPV (Main Command)" "help sgpv"}{...}
{vieweralsosee "SGPV Value Calculations" "help sgpvalue"}{...}
{vieweralsosee "SGPV Power Calculations" "help sgpower"}{...}
{vieweralsosee "SGPV Plot Interval Estimates" "help plotsgpv"}{...}
{viewerjumpto "Syntax" "fdrisk##syntax"}{...}
{viewerjumpto "Description" "fdrisk##description"}{...}
{viewerjumpto "Options" "fdrisk##options"}{...}
{* viewerjumpto "Remarks" "fdrisk##remarks"}{...}
{viewerjumpto "Examples" "fdrisk##examples"}{...}
{title:Title}
{phang}
{bf:fdrisk} {hline 2} False Discovery or Confirmation Risk for Second-Generation P-Values (SGPV)

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:fdrisk}
{cmd:,} nulllo(string) nullhi(string) {cmdab:std:err(#)} {cmdab:intt:ype(interval_type)} {cmdab:intl:evel(string)} {cmdab:nulls:pace(string)} {cmdab:nullw:eights(string)} {cmdab:alts:pace(string)} {cmdab:altw:eights(string)}
[{cmdab:sgpv:al(#)} {cmdab:p:i0(#)}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt sgpv:al(#)}}  the observed second-generation {it:p}-value.{p_end}
{synopt:{opt nulllo(string)}}  the lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.{p_end}
{synopt:{opt nullhi(string)}}  the upper bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.{p_end}
{synopt:{opt std:err(#)}}  standard error of the point estimate.{p_end}
{synopt:{opt intt:ype(string)}}  class of interval estimate used.{p_end}
{synopt:{opt intl:evel(string)}}  level of interval estimate. {p_end}
{synopt:{opt nulls:pace(string)}}  support of the null probability distribution.{p_end}
{synopt:{opt nullw:eights(string)}}  probability distribution for the null parameter space.{p_end}
{synopt:{opt alts:pace(string)}}  support for the alternative probability distribution.{p_end}
{synopt:{opt altw:eights(string)}}  probability distribution for the alternative parameter space. {p_end}
{synopt:{opt p:i0(#)}}  prior probability of the null hypothesis.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
This command computes the false discovery risk (sometimes called the "empirical bayes FDR") for a second-generation {it:p}-value of 0, or the false confirmation risk (FCR) for a second-generation {it:p}-value of 1. 
This command should be used mostly for single calculations. 
For calculations after estimation commands use the {help sgpv} command.
A {dialog fdrisk:dialog box} for easier usage of this command is available. 

		The false discovery risk is defined as: 	P(H_0|p_δ=0) = (1 + P(p_δ = 0| H_1)/P(p_δ=0|H_0) * r)^(-1)
		The false confirmation risk is defined as: 	P(H_1|p_δ=1) = (1 + P(p_δ = 1| H_0)/P(p_δ=1|H_1) * 1/r )^(-1)
		with r = P(H_1)/P(H_0) being the ratio of the prior probabilities for the alternative and null hypothesis and {it:p_δ} being the calculated SGPV.	
		See equation(4) in Blume et.al.(2018){p_end}

{pstd}
When possible, one should compute the second-generation {it:p}-value and FDR/FCR on a scale that is symmetric about the null hypothesis. 
For example, if the parameter of interest is an odds ratio, inputs  {it:"stderr"}, {it:"nulllo"},  {it:"nullhi"}, {it:"nullspace"}, and {it:"altspace"} are typically on the log scale.{p_end}

{pstd}
If {it:"TruncNormal"} is used for {it:"nullweights"}, then the distribution used is a truncated Normal distribution with mean equal to the midpoint of {it:"nullspace"}, 
and standard deviation equal to {it:"stderr"}, truncated to the support of {it:"nullspace"}. 
If {it:"TruncNormal"} is used for {it:"altweights"}, then the distribution used is a truncated Normal distribution with mean equal to the midpoint of {it:"altspace"}, 
and standard deviation equal to {it:"stderr"}, truncated to the support of {it:"altspace"}. 
Further customization of these parameters for the truncated Normal distribution are currently not possible, 
although they may be implemented in future versions.{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt sgpv:al(#)}  the observed second-generation {it:p}-value. Default is 0, which gives the false discovery risk. Setting it to 1 gives the false confirmation risk.

{phang}
{opt nulllo(string)}     the lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{phang}
{opt nullhi(string)}     the upper bound of the indifference zone (null interval) upon which the second-generation {it:p}-value was based.

{phang}
{opt std:err(#)}     standard error of the point estimate.

{phang}
{opt intt:ype(string)}  class of interval estimate used. This determines the functional form of the power function. 
Options are "confidence" for a (1-α)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported).

{phang}
{opt intl:evel(string)}     level of interval estimate. If inttype is "confidence", the level is α. If "inttype" is "likelihood", the level is 1/k (not k).

{phang}
{opt nulls:pace(string asis)}  support of the null probability distribution. If "nullweights" is "Point", then "nullspace" is one number. 
If "nullweights" is "Uniform", then "nullspace" are two numbers separated by a space. These numbers can be also formulas which must enclosed in " ".

{phang}
{opt nullw:eights(string)}     probability distribution for the null parameter space. Options are currently "Point", "Uniform", and "TruncNormal".

{phang}
{opt alts:pace(string asis)}  support for the alternative probability distribution. 
If "altweights" is "Point", then "altspace" is one number. If "altweights" is "Uniform" or "TruncNormal", then "altspace" contains two numbers separated by a space.
These numbers can be also formulas which must enclosed in " ".

{phang}
{opt altw:eights(string)}     probability distribution for the alternative parameter space. Options are currently "Point", "Uniform", and "TruncNormal".

{phang}
{opt p:i0(#)}     prior probability of the null hypothesis. Default is 0.5. This value can be only between 0 and 1 (exclusive). 
A prior probability outside of this interval is not sensible. 
The default value assumes that both hypotheses are equally likely.

{marker examples}{...}
{title:Examples}
 To run the examples copy the lines into a Stata or use the file {view fdrisk-examples.do} if installed; if not, you can download it {net "describe sgpv, from(https://raw.githubusercontent.com/skbormann/stata-tools/master/)":here})
{pstd}{bf:False discovery risk with 95% confidence level:} (Click to {stata do fdrisk-examples.do example1:run} the example.){p_end}
	. fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nullweights("Uniform")  nullspace(log(1/1.1) log(1.1)) /// 
		  altweights("Uniform") altspace("2-1*invnorm(1-0.05/2)*0.8" "2+1*invnorm(1-0.05/2)*0.8") inttype("confidence")  intlevel(0.05)		
	{pstd}{bf:False discovery risk with 1/8 likelihood support level:}(Click to {stata do fdrisk-examples.do example2a:run} the example.){p_end}
	. fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)   nullweights("Point")  nullspace(0) /// 
	          altweights("Uniform") altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  inttype("likelihood")  intlevel(1/8) 
	 	
	{bf:with truncated normal weighting distribution:}(Click to {stata do fdrisk-examples.do example2b:run} the example.)
	. fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)   nullweights("Point")  nullspace(0)  altweights("TruncNormal") ///
	          altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  inttype("likelihood")  intlevel(1/8)

{pstd}{bf:False discovery risk with LSI and wider null hypothesis:}(Click to {stata do fdrisk-examples.do example3:run} the example.){p_end}
	. fdrisk, sgpval(0)  nulllo(log(1/1.5)) nullhi(log(1.5))  stderr(0.8)   nullweights("Point")  nullspace(0)  ///
		  altweights("Uniform") altspace("2.5-1*invnorm(1-0.041/2)*0.8" "2.5+1*invnorm(1-0.041/2)*0.8")  inttype("likelihood")  intlevel(1/8)
 
{pstd}	{bf:False confirmation risk example:}(Click to {stata do fdrisk-examples.do example4:run} the example.) {p_end}
	. fdrisk, sgpval(1)  nulllo(log(1/1.5)) nullhi(log(1.5))  stderr(0.15)   nullweights("Uniform")  ///
	          nullspace("0.01 - 1*invnorm(1-0.041/2)*0.15" "0.01 + 1*invnorm(1-0.041/2)*0.15") altweights("Uniform")  altspace(log(1.5) 1.25*log(1.5)) ///
	          inttype("likelihood")  intlevel(1/8)
 


{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(fdr)}}  false discovery risk {p_end}
{synopt:{cmd:r(fcr)}}  false confirmation risk  {p_end}


{title:References}
{pstd}
 Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. {it:PLoS ONE} 13(3): e0188299. 
{browse "https://doi.org/10.1371/journal.pone.0188299"}

{pstd}
Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}-values. {it:The American Statistician}. In press. {browse "https://doi.org/10.1080/00031305.2018.1537893"} 


{title:Author}
{p}
Sven-Kristjan Bormann, School of Economics and Business Administration, University of Tartu.

{title:Bug Reporting}
{psee}
Please submit bugs, comments and suggestions via email to:	{browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}{p_end}
{psee}
Further Stata programs and development versions can be found under {browse "https://github.com/skbormann/stata-tools":https://github.com/skbormann/stata-tools}{p_end}

{title:See Also}
Related commands:
 {help plotsgpv}, {help sgpvalue}, {help sgpower}, {help sgpv}  

